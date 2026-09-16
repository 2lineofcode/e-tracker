import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';
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
        final total = groups.fold<num>(
          0,
          (sum, group) => sum + group.total,
        );
        return VStack(
          [
            controller.selectedPeriodLabel
                .text
                .bold
                .make()
                .pOnly(bottom: 8),

            if (groups.isNotEmpty) ...[
              SfCircularChart(
                margin: EdgeInsets.zero,
                annotations: [
                  CircularChartAnnotation(
                    widget: VStack([
                      'Total'.text
                          .size(9)
                          .minFontSize(9)
                          .color(AppColor.neutral)
                          .makeCentered(),
                      total.moneyFormatCompact().text
                          .size(13)
                          .bold
                          .makeCentered(),
                    ]),
                  ),
                ],
                series: setupChartDataSeries(groups, total),
                tooltipBehavior: setupTooltip(),
              ).wh(double.infinity, 270),

              _buildGroupList(groups, total),
            ] else ...[
              ExUiErrorOrEmpty(
                bgColor: AppColor.emptyStatePrimary,
                title: 'Belum ada data',
                message: '',
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
      shouldAlwaysShow: false,
      canShowMarker: false,
      color: AppColor.textReverse,
      elevation: 0,
      builder: (data, point, series, pointIndex, seriesIndex) {
        data as PieChartDataModel;
        return Text(
          '${data.name}\n${data.summary.total.moneyFormat()}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11,
            color: AppColor.scaffoldPrimary,
          ),
        ).p8();
      },
    );
  }

  List<DoughnutSeries<PieChartDataModel, String>> setupChartDataSeries(
    List<GroupSpendSummary> groups,
    num total,
  ) {
    final data = groups.map((summary) => PieChartDataModel(summary)).toList();

    return <DoughnutSeries<PieChartDataModel, String>>[
      DoughnutSeries<PieChartDataModel, String>(
        dataSource: data,
        xValueMapper: (data, _) => data.name,
        yValueMapper: (data, _) => data.total,
        dataLabelMapper: (data, _) =>
            data.total / total >= 0.05 ? data.name : '',
        radius: '72%',
        innerRadius: '58%',
        pointColorMapper: (datum, index) => datum.color,
        animationDuration: 350,
        onPointTap: (details) {
          final index = details.pointIndex;
          if (index == null || index >= groups.length) return;
          controller.goAdvanceFilter(groups[index].primaryCategoryCode);
        },
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          labelIntersectAction: LabelIntersectAction.hide,
          showZeroValue: false,
          labelPosition: ChartDataLabelPosition.outside,
          textStyle: TextStyle(
            color: AppColor.textReverse,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          connectorLineSettings: ConnectorLineSettings(
            type: ConnectorType.curve,
            color: AppColor.neutral,
            width: 1,
          ),
        ),
      ),
    ];
  }

  Widget _buildGroupList(List<GroupSpendSummary> groups, num total) {
    return Container(
      decoration: ExDecorator.box(
        borderRadius: 8,
        borderColor: AppColor.border,
        fillColor: AppColor.box,
      ),
      child: VStack([
        for (var index = 0; index < groups.length; index++) ...[
          _buildGroupRow(groups[index], total),
          if (index < groups.length - 1)
            Divider(height: 1, color: AppColor.border),
        ],
      ]),
    );
  }

  Widget _buildGroupRow(GroupSpendSummary summary, num total) {
    final share = total > 0 ? (summary.total / total * 100).round() : 0;
    final usage = summary.usePercentage;
    final usageColor = usage == null
        ? AppColor.neutral
        : usage >= 100
        ? AppColor.red
        : usage >= 80
        ? AppColor.orange
        : AppColor.green;

    return VStack([
      HStack([
        Container(
          decoration: BoxDecoration(
            color: summary.leadCategory.color?.withAlpha(30),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(
            summary.leadCategory.icon ?? Icons.circle_outlined,
            size: 15,
            color: summary.leadCategory.color,
          ).centered(),
        ).wh(30, 30).pOnly(right: 10),
        VStack([
          summary.label.text.bold.size(11).ellipsis.make(),
          if (usage != null)
            'Budget $usage%'.text
                .size(9)
                .minFontSize(9)
                .color(usageColor)
                .make(),
        ]).expand(),
        '$share%'.text
            .size(9)
            .minFontSize(9)
            .color(AppColor.neutral)
            .make()
            .pOnly(right: 10),
        summary.total.moneyFormat().text.bold.size(11).make(),
        Icon(Icons.chevron_right, size: 15, color: AppColor.neutral)
            .pOnly(left: 6),
      ]),
      if (usage != null) ...[
        8.heightBox,
        ClipRRect(
          borderRadius: BorderRadius.circular(90),
          child: LinearProgressIndicator(
            value: (usage / 100).clamp(0, 1).toDouble(),
            minHeight: 3,
            color: usageColor,
            backgroundColor: AppColor.border.withAlpha(70),
          ),
        ),
      ],
    ]).p12().onInkTap(
      () => controller.goAdvanceFilter(summary.primaryCategoryCode),
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

    result.sort((a, b) => b.total.compareTo(a.total));
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
