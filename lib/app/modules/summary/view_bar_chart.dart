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
          HStack([
            controller.selectedPeriodLabel
                .text
                .bold
                .make()
                .expand(),
            _legend(AppColor.green, 'Hemat'),
            8.widthBox,
            _legend(AppColor.orange, 'Normal'),
            8.widthBox,
            _legend(AppColor.red, 'Boros'),
          ]).pOnly(bottom: 16),
          if (controller.expenses.isNotEmpty) ...[
            /// chart
            _Chart(
              dataExpense: controller.expenses,
            ).wh(double.infinity, 220).pOnly(bottom: 16),

            /// list high spendings
            if (controller.highSpender.isNotEmpty) ...[
              Container(
                decoration: ExDecorator.box(
                  borderRadius: 8,
                  borderColor: AppColor.border,
                  fillColor: AppColor.box,
                ),
                child: VStack(
                  [
                    HStack([
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 16,
                        color: AppColor.red,
                      ).pOnly(right: 8),
                      'Pengeluaran tinggi'.text.bold.make(),
                      Spacer(),
                      '${controller.highSpender.length}'.text
                          .size(10)
                          .bold
                          .color(AppColor.textOnBackground)
                          .make()
                          .pSymmetric(h: 8, v: 3)
                          .color(AppColor.primary)
                          .cornerRadius(90),
                    ]).p12(),
                    Divider(height: 1, color: AppColor.border),
                    ListView.separated(
                      shrinkWrap: true,
                      itemCount: controller.highSpender.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 1, color: AppColor.border),
                      itemBuilder: (context, index) {
                        final item = controller.highSpender[index];
                        return itemListHighSpender(item);
                      },
                    ).expand(),
                  ],
                ),
              ).expand(),
            ] else ...[
              ExUiErrorOrEmpty(
                bgColor: AppColor.emptyStatePrimary,
                title: 'Tidak ada pengeluaran tinggi',
                message: '',
              ).expand(),
            ],
          ]
          /// empty view
          else ...[
            ExUiErrorOrEmpty(
              bgColor: AppColor.emptyStatePrimary,
              title: 'Belum ada data',
              message: '',
            ).expand(),
          ],
        ],
      ).p12(),
      onLoading: MyShimmerSummary(),
    );
  }

  Widget _legend(Color color, String label) {
    return HStack([
      Container(color: color).wh(7, 7).cornerRadius(90).pOnly(right: 4),
      label.text.size(9).minFontSize(9).color(AppColor.neutral).make(),
    ]);
  }

  Widget itemListHighSpender(SupaExpense item) {
    return HStack([
      Container(color: item.amount?.getFlagColor() ?? AppColor.neutral)
          .wh(3, 24)
          .cornerRadius(90)
          .pOnly(right: 10),
      '${item.date?.reformatDate(from: yMd, to: 'dd MMM yyyy')}'
          .text
          .size(11)
          .make()
          .expand(),
      '${item.amount?.moneyFormat()}'.text.size(11).bold.make(),
      Icon(Icons.chevron_right, size: 15, color: AppColor.neutral)
          .pOnly(left: 6),
    ]).pSymmetric(h: 12, v: 10).onInkTap(() => openDetail(item));
  }
}

class _Chart extends GetView<SummaryController> {
  const _Chart({required this.dataExpense});

  final List<SupaExpense> dataExpense;

  @override
  Widget build(BuildContext context) {
    final points = _chartPoints();
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        minY: 0,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColor.border.withAlpha(90),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                if (value == 0) return SizedBox.shrink();
                return SideTitleWidget(
                  meta: meta,
                  space: 6,
                  child: value.moneyFormatCompact().text
                      .size(9)
                      .minFontSize(9)
                      .color(AppColor.neutral)
                      .make(),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt() - 1;
                if (index < 0 || index >= points.length) {
                  return SizedBox.shrink();
                }
                final point = points[index];
                final show = controller.isShowAllYear.isTrue ||
                    point.x == 1 ||
                    point.x % 5 == 0 ||
                    point.x == points.length;
                if (!show) return SizedBox.shrink();
                return SideTitleWidget(
                  meta: meta,
                  space: 6,
                  child: point.shortLabel.text
                      .size(9)
                      .minFontSize(9)
                      .color(AppColor.neutral)
                      .make(),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          for (final point in points)
            BarChartGroupData(
              x: point.x,
              barRods: [
                BarChartRodData(
                  toY: point.amount.toDouble(),
                  color: point.amount > 0
                      ? point.amount.getFlagColor()
                      : Colors.transparent,
                  width: controller.isShowAllYear.isTrue ? 12 : 5,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(3),
                  ),
                ),
              ],
            ),
        ],
        barTouchData: BarTouchData(
          touchTooltipData: _tooltip(points),
          touchCallback: (event, response) {
            if (response?.spot == null || event is! FlTapUpEvent) return;
            final point = points[response!.spot!.touchedBarGroupIndex];
            if (point.amount <= 0) return;
            if (controller.isShowAllYear.isTrue) {
              controller.onMonthChange(point.label);
            } else if (point.date != null) {
              openDetail(
                SupaExpense(
                  date: point.date!.toStringEx(format: yMd),
                  amount: point.amount,
                ),
              );
            }
          },
          mouseCursorResolver: (event, response) {
            if (response?.spot == null) return MouseCursor.defer;
            final point = points[response!.spot!.touchedBarGroupIndex];
            return point.amount > 0
                ? SystemMouseCursors.click
                : MouseCursor.defer;
          },
        ),
      ),
    );
  }

  List<_ChartPoint> _chartPoints() {
    final values = <int, num>{};
    for (final expense in dataExpense) {
      final date = DateTime.tryParse(expense.date ?? '');
      if (date == null) continue;
      final index = controller.isShowAllYear.isTrue
          ? expensePeriodForDate(date, controller.calendarStartDay)
              .end
              .subtract(1.days)
              .month
          : date.difference(controller.selectedPeriod.start).inDays + 1;
      values[index] = (values[index] ?? 0) + (expense.amount ?? 0);
    }

    if (controller.isShowAllYear.isTrue) {
      return List.generate(12, (index) {
        final month = DateTime(2000, index + 1).toStringEx(format: 'MMMM');
        return _ChartPoint(
          x: index + 1,
          label: month,
          shortLabel: month.substring(0, 3),
          amount: values[index + 1] ?? 0,
        );
      });
    }

    final period = controller.selectedPeriod;
    final days = period.end.difference(period.start).inDays;
    return List.generate(days, (index) {
      final day = index + 1;
      final date = period.start.add(index.days);
      return _ChartPoint(
        x: day,
        label: date.toStringEx(format: 'd MMM'),
        shortLabel: '${date.day}',
        amount: values[day] ?? 0,
        date: date,
      );
    });
  }

  BarTouchTooltipData _tooltip(List<_ChartPoint> points) {
    return BarTouchTooltipData(
      fitInsideHorizontally: true,
      fitInsideVertically: true,
      tooltipHorizontalAlignment: FLHorizontalAlignment.center,
      direction: TooltipDirection.top,
      getTooltipColor: (group) => AppColor.textReverse,
      getTooltipItem: (group, groupIndex, rod, rodIndex) {
        final point = points[groupIndex];
        if (point.amount <= 0) return null;
        final period = point.date?.toStringEx(format: 'dd MMM yyyy') ??
            '${point.label} ${controller.yearSelected.value}';
        return BarTooltipItem(
          '$period\n${point.amount.moneyFormat()}',
          TextStyle(
            color: AppColor.scaffoldPrimary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }
}

class _ChartPoint {
  const _ChartPoint({
    required this.x,
    required this.label,
    required this.shortLabel,
    required this.amount,
    this.date,
  });

  final int x;
  final String label;
  final String shortLabel;
  final num amount;
  final DateTime? date;
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
      backgroundSettings: BackgroundSettings(color: AppColor.card.withAlpha(150), blur: isMobileWeb ? null : 1),
      animation: OverSlideAnimation(
        begin: Offset(1, 0),
        end: Offset(0, 0),
        durationMilliseconds: 100,
        reverseDurationMilliseconds: 100,
      ),
      child: VStack([
        '# ${item.date?.reformatDate(from: yMd)}'.text.bold.make().pSymmetric(v: 12),
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
              () {
                if (Get.context!.isMobile) Overlayment.dismissLast();
                DialogExpense.openManualInput(
                  expense: itemDetail,
                  customCallback: () async {
                    await Overlayment.dismissAll();
                    await 100.milliseconds.delay();
                    await openDetail(item);
                  },
                );
              },
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
