import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../core/app_color.dart';
import '../../helpers/helper_money.dart';
import '../../models/supa_category_entity.dart';
import '../widgets/widget_shimmer_summary.dart';
import 'summary_controller.dart';

class ViewPieChart extends GetView<SummaryController> {
  const ViewPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) {
        final groups = _groupSummaries();
        return VStack(
          [
            'Period: ${controller.monthSelected} ${controller.yearSelected}'.text.bold.make().pOnly(bottom: 16),

            if (groups.isNotEmpty) ...[
              SfCircularChart(
                series: setupChartDataSeries(groups),
                tooltipBehavior: setupTooltip(),
              ).w(double.infinity),

              _buildGroupTable(groups),
            ] else ...[
              ExUiErrorOrEmpty(
                bgColor: AppColor.emptyStatePrimary,
                title: 'No data to see',
                message: 'You dont have any transaction on this period',
              ).h(530),
            ],
          ],
        ).p12().scrollVertical();
      },
      onLoading: MyShimmerSummary(),
    );
  }

  TooltipBehavior setupTooltip() {
    return TooltipBehavior(
      enable: true,
      format: 'point.x : point.y %',
      shouldAlwaysShow: false,
      decimalPlaces: 2,
      builder: (data, point, series, pointIndex, seriesIndex) {
        data as PieChartDataModel;
        final usage = data.usePercentage != null ? ' (${data.usePercentage}%)' : '';
        return Text(
          '${data.name}: ${data.summary.total.moneyFormat()}$usage',
          style: TextStyle(
            fontSize: 11,
            color: Get.isDarkMode ? Colors.black : Colors.white,
          ),
        ).p8();
      },
    );
  }

  /// Returns the pie series with smart data labels.
  List<PieSeries<PieChartDataModel, String>> setupChartDataSeries(
    List<GroupSpendSummary> groups,
  ) {
    final data = groups.map((summary) => PieChartDataModel(summary)).toList();

    return <PieSeries<PieChartDataModel, String>>[
      PieSeries<PieChartDataModel, String>(
        dataSource: data,
        xValueMapper: (data, _) => data.name,
        yValueMapper: (data, _) => data.total,
        dataLabelMapper: (data, _) => data.name,
        radius: '55%',
        pointColorMapper: (datum, index) => datum.color,
        animationDuration: 500,
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          labelIntersectAction: LabelIntersectAction.hide,
          showZeroValue: false,
          labelPosition: ChartDataLabelPosition.outside,
          connectorLineSettings: ConnectorLineSettings(
            type: ConnectorType.curve,
          ),
        ),
      ),
    ];
  }

  Widget _buildGroupTable(List<GroupSpendSummary> groups) {
    return Table(
      border: TableBorder.all(color: Vx.neutral600),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: AppColor.tableHeader),
          children: [
            'Group'.text.bold.make().p12(),
            'Total'.text.align(TextAlign.end).bold.make().p12(),
          ],
        ),
        for (final summary in groups)
          TableRow(
            children: [
              TableCell(
                child:
                    HStack(
                      [
                        CustomPopup(
                          content: VStack([
                            if (summary.maxBudget != null) ...[
                              'Usage ${summary.usePercentage ?? 0}%'.text.black.make(),
                              'Remaining ${summary.remainingBudget?.moneyFormat() ?? 'Rp. 0'} / ${summary.maxBudget?.moneyFormat() ?? 'Rp. 0'}'.text.black.make(),
                            ] else ...[
                              'No Budget'.text.black.make(),
                            ],
                          ]),
                          child: Icon(
                            summary.leadCategory.icon ?? Icons.circle_outlined,
                            size: 14,
                            color: summary.leadCategory.color,
                          ).pOnly(right: 8),
                        ),
                        VStack([
                          '${summary.label}'.text.ellipsis.make(),
                          if (summary.usePercentage != null) 'Usage ${summary.usePercentage}%'.text.size(10).neutral500.make(),
                        ]).expand(),
                      ],
                    ).p8().onTap(
                      () => controller.goAdvanceFilter(
                        summary.primaryCategoryCode,
                      ),
                    ),
              ),
              TableCell(
                child: summary.total.moneyFormat().text.align(TextAlign.end).make().p8(),
              ),
            ],
          ),
      ],
    );
  }

  List<GroupSpendSummary> _groupSummaries() {
    final categoryLookup = {
      for (final summary in controller.categorySummaries) summary.categoryCode: summary,
    };

    final result = <GroupSpendSummary>[];

    for (final group in expenseCategoryGroups) {
      final included = <CategorySpendSummary>[];
      for (final category in group.items) {
        final summary = categoryLookup[category.code];
        if (summary != null && summary.total > 0) {
          included.add(summary);
        }
      }

      if (included.isEmpty) continue;

      final total = included.fold<num>(0, (sum, item) => sum + item.total);
      final allHaveBudget = included.every((item) => item.maxBudget != null);
      final maxBudget = allHaveBudget ? included.fold<num>(0, (sum, item) => sum + (item.maxBudget ?? 0)) : null;
      final remainingBudget = allHaveBudget
          ? included.fold<num>(
              0,
              (sum, item) => sum + (item.remainingBudget ?? 0),
            )
          : null;
      final usePercentage = (maxBudget != null && maxBudget > 0) ? ((total / maxBudget) * 100).round() : null;

      final leadCategory = group.items.firstWhere(
        (category) => included.any((summary) => summary.categoryCode == category.code),
        orElse: () => group.items.first,
      );

      result.add(
        GroupSpendSummary(
          label: group.label,
          total: total,
          maxBudget: maxBudget,
          remainingBudget: remainingBudget,
          usePercentage: usePercentage,
          leadCategory: leadCategory,
          categoryCodes: included.map((item) => item.categoryCode).toList(),
        ),
      );
    }

    return result;
  }
}

class PieChartDataModel {
  PieChartDataModel(this.summary);

  final GroupSpendSummary summary;

  String get name => summary.label;
  double get total => summary.total.toDouble();
  int? get usePercentage => summary.usePercentage;
  Color? get color => summary.leadCategory.color;
}

class GroupSpendSummary {
  GroupSpendSummary({
    required this.label,
    required this.total,
    required this.leadCategory,
    required this.categoryCodes,
    this.maxBudget,
    this.remainingBudget,
    this.usePercentage,
  });

  final String label;
  final num total;
  final num? maxBudget;
  final num? remainingBudget;
  final int? usePercentage;
  final ExpenseCategory leadCategory;
  final List<String> categoryCodes;

  String get primaryCategoryCode => categoryCodes.isNotEmpty ? categoryCodes.first : leadCategory.code;
}
