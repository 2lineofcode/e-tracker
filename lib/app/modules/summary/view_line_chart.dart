import 'package:ex/ex.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlayment/overlayment.dart';

import '../../core/app_color.dart';
import '../../core/const.dart';
import '../../helpers/helpers.dart';
import '../../models/supa_expense_entity.dart';
import '../home/home_repository.dart';
import '../widgets/widget_shimmer_summary.dart';
import 'summary_controller.dart';

class ViewLineChart extends GetView<SummaryController> {
  const ViewLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => VStack(
        [
          'Period: ${controller.monthSelected} ${controller.yearSelected}'.text.bold.make().pOnly(bottom: 16),
          if (controller.rpcSumNoteTimes.isNotEmpty) ...[
            _Chart(
              dataExpense: controller.expenses,
            ).wh(double.infinity, 200),
            24.heightBox,
            '🔥 High Spendings!'.text.make().pOnly(bottom: 12),
            ListView.builder(
              shrinkWrap: true,
              itemCount: controller.highSpender.length,
              itemBuilder: (context, index) {
                final item = controller.highSpender[index];
                return itemListHighSpender(item);
              },
            ).expand(),
          ] else ...[
            ExUiErrorOrEmpty(
              bgColor: AppColor.emptyStatePrimary,
              title: 'No data to see',
              message: 'You dont have any transaction on this period',
            ).h(250),
          ],
        ],
      ).p12(),
      onLoading: MyShimmerSummary(),
    );
  }

  Widget itemListHighSpender(SupaExpense item) {
    return ListTile(
      title: '${item.date?.reformatDate(from: yMd)}'.text.size(12).make(),
      trailing: '${item.amount?.moneyFormat()}'.text.make(),
      onTap: () async {
        final expense = await Get.find<HomeRepository>().getExpense(item.date!);
        await Overlayment.show(
          context: Get.context,
          OverPanel(
            alignment: Alignment.centerRight,
            width: 300,
            child: VStack([
              ExDivider().pSymmetric(v: 16),
              'Detail Expense for ${item.date?.reformatDate(from: yMd)}'.text.bold.make(),
              ExDivider().pSymmetric(v: 16),
              ListView.separated(
                itemCount: expense.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  final itemDetail = expense[index];
                  return HStack([
                    VStack([
                      '${itemDetail.note}'.text.make(),
                      HStack([
                        Icon(itemDetail.category?.icon?.getIconData() ?? Icons.circle_outlined, color: itemDetail.category?.color?.fromHex, size: 12).pOnly(right: 8),
                        '${itemDetail.categoryName}'.text.size(12).neutral400.make(),
                      ]),
                    ]),
                    Spacer(),
                    '${itemDetail.amount?.moneyFormat()}'.text.make(),
                  ]);
                },
              ).expand(),
              ExDivider().pSymmetric(v: 16),
              HStack([
                Spacer(),
                'Total ${item.amount?.moneyFormat()}'.text.bold.make(),
              ]),
              ExDivider().pSymmetric(v: 16),
            ]).p8(),
          ),
        );
      },
    );
  }
}

class _Chart extends GetView<SummaryController> {
  const _Chart({required this.dataExpense});

  final List<SupaExpense> dataExpense;

  @override
  Widget build(BuildContext context) {
    final newData = dataExpense.reversed.toList();
    return GetBuilder<SummaryController>(
      init: SummaryController(),
      initState: (_) {},
      builder: (_) {
        return LineChart(
          LineChartData(
            lineTouchData: lineTooltip(newData),
            gridData: FlGridData(),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles()),
              rightTitles: AxisTitles(sideTitles: SideTitles()),
              topTitles: AxisTitles(sideTitles: SideTitles()),
              leftTitles: AxisTitles(sideTitles: SideTitles()),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                color: AppColor.bibit,
                // belowBarData: BarAreaData(show: true, color: AppColor.bibit.withAlpha(50)),
                isCurved: false,
                barWidth: 1,
                dotData: FlDotData(show: false),
                spots: [
                  for (int i = 0; i < newData.length; i++) ...[
                    FlSpot(i.toDouble(), newData[i].amount?.toDouble() ?? 0),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  LineTouchData lineTooltip(List<SupaExpense> chart) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Vx.white,
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((LineBarSpot touchedSpot) {
            final item = chart[touchedSpot.spotIndex];
            final amount = item.amount?.moneyFormat();
            final date = item.date?.reformatDate(from: 'yyyy-MM-dd');
            final output = '$date\n $amount';
            final textStyle = TextStyle(color: Vx.black, fontSize: 11);
            return LineTooltipItem('$output', textStyle);
          }).toList();
        },
      ),
    );
  }
}
