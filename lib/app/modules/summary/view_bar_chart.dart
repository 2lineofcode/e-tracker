import 'package:ex_kit/ex.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlayment/overlayment.dart';

import '../../core/app_color.dart';
import '../../core/const.dart';
import '../../helpers/helpers.dart';
import '../../models/supa_expense_entity.dart';
import '../home/home_repository.dart';
import '../home/section_dialog_expense.dart';
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
            _Chart(
              dataExpense: controller.expenses,
            ).wh(double.infinity, 200).pOnly(bottom: 24),

            /// list high spendings
            if (controller.highSpender.isNotEmpty) ...[
              Container(
                decoration: ExDecorator.box(
                  borderRadius: 4,
                  borderColor: AppColor.border,
                ),
                child: VStack(
                  [
                    '🔥 High Spendings! (${controller.highSpender.length})'.text.bold.make().pOnly(bottom: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      itemCount: controller.highSpender.length,
                      separatorBuilder: (context, index) => 8.heightBox,
                      itemBuilder: (context, index) {
                        final item = controller.highSpender[index];
                        return itemListHighSpender(item);
                      },
                    ).expand(),
                  ],
                ).p12(),
              ).expand(),
            ],
          ]
          /// empty view
          else ...[
            ExUiErrorOrEmpty(
              bgColor: AppColor.emptyStatePrimary,
              title: 'No data to see',
              message: 'You dont have enough data transaction on this period',
            ).expand(),
          ],
        ],
      ).p12(),
      onLoading: MyShimmerSummary(),
    );
  }

  Widget itemListHighSpender(SupaExpense item) {
    return Container(
      decoration: ExDecorator.box(
        borderRadius: 12,
        borderColor: AppColor.border,
        fillColor: AppColor.box,
      ),
      child: ListTile(
        title: '${item.date?.reformatDate(from: yMd)}'.text.size(12).make(),
        trailing: '${item.amount?.moneyFormat()}'.text.make(),
      ).onInkTap(() => openDetail(item)),
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
              ],
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
              },
            ),
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
        final date = fixChart[groupIndex].date?.reformatDate(
          from: 'yyyy-MM-dd',
        );
        final output = '$date\n $amount';
        final textStyle = TextStyle(color: Vx.black, fontSize: 11);
        return BarTooltipItem('$output', textStyle);
      },
    );
  }
}

Future<void> openDetail(SupaExpense item) async {
  ExLoading.show(paddingSymmetric: 250, child: CupertinoActivityIndicator());
  final expense = await Get.find<HomeRepository>().getExpense(item.date!);
  ExLoading.dismiss();

  await Overlayment.show(
    context: Get.context,
    OverPanel(
      alignment: Alignment.centerRight,
      width: 300,
      backgroundSettings: BackgroundSettings(color: AppColor.card, blur: 1),
      animation: OverSlideAnimation(
        begin: Offset(1, 0),
        end: Offset(0, 0),
        durationMilliseconds: 100,
        reverseDurationMilliseconds: 100,
      ),
      child: VStack([
        'Detail Expense for ${item.date?.reformatDate(from: yMd)}'.text.bold.make().pSymmetric(v: 12),
        12.heightBox,
        ListView.separated(
          itemCount: expense.length,
          separatorBuilder: (context, index) => 12.heightBox,
          itemBuilder: (context, index) {
            final itemDetail = expense[index];
            return Container(
              decoration: ExDecorator.box(borderRadius: 4, borderColor: AppColor.border, fillColor: AppColor.box),
              child: HStack([
                VStack([
                  '${itemDetail.note}'.text.make(),
                  HStack([
                    Icon(itemDetail.resolvedCategory.icon ?? Icons.circle_outlined, color: itemDetail.resolvedCategory.color, size: 12).pOnly(right: 8),
                    itemDetail.resolvedCategory.label.text.ellipsis.size(12).color(AppColor.neutral).make().expand(),
                  ]),
                ]).expand(),
                '${itemDetail.amount?.moneyFormat()}'.text.make(),
              ]).p8(),
            ).onInkTap(
              () => DialogExpense.openManualInput(
                expense: itemDetail,
                customCallback: () async {
                  await Overlayment.dismissAll();
                  await 100.milliseconds.delay();
                  await openDetail(item);
                },
              ),
            );
          },
        ).expand(),
        Divider(),
        HStack([
          Spacer(),
          'Total ${item.amount?.moneyFormat()}'.text.bold.make(),
        ]),
        Divider(),
      ]).p8(),
    ),
  );
}
