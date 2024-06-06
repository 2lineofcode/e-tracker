import 'package:ex_kit/ex.dart';
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

class ViewBarChart extends GetView<SummaryController> {
  const ViewBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => VStack(
        [
          'Period: ${controller.monthSelected} ${controller.yearSelected}'.text.bold.make().pOnly(bottom: 16),
          if (controller.expenses.length > 1) ...[
            /// chart
            _Chart(dataExpense: controller.expenses).wh(double.infinity, 200).pOnly(bottom: 24),

            /// list high spendings
            if (controller.highSpender.isNotEmpty) ...[
              '🔥 High Spendings! (${controller.highSpender.length})'.text.make().pOnly(bottom: 12),
              ListView.builder(
                shrinkWrap: true,
                itemCount: controller.highSpender.length,
                itemBuilder: (context, index) {
                  final item = controller.highSpender[index];
                  return itemListHighSpender(item);
                },
              ).expand(),
            ],
          ]

          /// empty view
          else ...[
            ExUiErrorOrEmpty(
              bgColor: AppColor.emptyStatePrimary,
              title: 'No data to see',
              message: 'You dont have enough data transaction on this period',
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
      onTap: () => openDetail(item),
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
        return BarChart(
          BarChartData(
            gridData: FlGridData(),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: [
              for (int i = 0; i < newData.length; i++) ...[
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      fromY: newData[i].amount?.toDouble() ?? 0,
                      toY: 0,
                      color: newData[i].amount!.getFlagColor(),
                      width: controller.isShowAllYear.isTrue ? 1 : 6,
                      borderRadius: BorderRadius.zero,
                    ),
                  ],
                ),
              ]
            ],
            barTouchData: BarTouchData(
                touchTooltipData: lineTooltip(dataExpense),
                touchCallback: (event, response) {
                  if (response != null && response.spot != null && event is FlTapUpEvent) {
                    final item = dataExpense.reversed.toList()[response.spot!.touchedBarGroupIndex];
                    openDetail(item);
                  }
                },
                mouseCursorResolver: (event, response) {
                  return response == null || response.spot == null ? MouseCursor.defer : SystemMouseCursors.click;
                }),
          ),
        );
      },
    );
  }

  BarTouchTooltipData lineTooltip(List<SupaExpense> chart) {
    final fixChart = chart.reversed.toList();
    return BarTouchTooltipData(
      fitInsideHorizontally: true,
      fitInsideVertically: true,
      tooltipHorizontalAlignment: FLHorizontalAlignment.center,
      direction: TooltipDirection.top,
      getTooltipItem: (group, groupIndex, rod, rodIndex) {
        final amount = fixChart[groupIndex].amount?.moneyFormat();
        final date = fixChart[groupIndex].date?.reformatDate(from: 'yyyy-MM-dd');
        final output = '$date\n $amount';
        final textStyle = TextStyle(color: Vx.black, fontSize: 11);
        return BarTooltipItem('$output', textStyle);
      },
    );
  }
}

Future<void> openDetail(SupaExpense item) async {
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
}
