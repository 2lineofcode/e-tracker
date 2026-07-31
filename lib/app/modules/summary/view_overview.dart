import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

import '../../core/app_color.dart';
import '../../helpers/helpers.dart';
import '../../models/supa_category_entity.dart';
import '../home/home_controller.dart';
import '../widgets/widget_shimmer_summary.dart';
import 'summary_controller.dart';

class ViewOverview extends GetView<SummaryController> {
  const ViewOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => VStack(
        [
          /// header ~
          if (controller.isShowAllYear.isTrue)
            headerAllYear()
          else
            headerPerMonth(),

          16.heightBox,

          /// detail
          if (controller.isShowAllYear.isTrue)
            detailAllYear().expand()
          else
            detailPerMonth().expand(),
        ],
      ).p12(),
      onLoading: MyShimmerSummary(),
    );
  }

  Widget headerAllYear() {
    return GlassContainer(
      width: double.infinity,
      blur: 50,
      border: Border.all(color: AppColor.border),
      borderRadius: BorderRadius.all(Radius.circular(4)),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Vx.pink500, AppColor.primary],
      ),
      child: VStack(
        [
          'Total pengeluaran ${controller.yearSelected}'.text
              .size(12)
              .make()
              .pOnly(bottom: 8),
          '${controller.countOnly1Year.value.moneyFormat()}'.text.bold
              .size(16)
              .make(),
        ],
      ).p12(),
    );
  }

  Widget detailAllYear() {
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(
        fillColor: AppColor.box,
        borderColor: AppColor.border,
        borderRadius: 4,
      ),
      child: Obx(() {
        final sections = _buildYearlySections();
        if (sections.isEmpty) {
          return 'Belum ada data'.text.size(12).neutral500.makeCentered().p16();
        }
        return ListView(children: sections);
      }).p12(),
    );
  }

  Widget headerPerMonth() {
    final dailySafe = controller.dailySafeAllowance;
    final projectedSpend = controller.projectedPeriodSpend;
    final projectedDelta = controller.countBudget.value - projectedSpend;
    final isCurrentMonth = controller.isCurrentSelectedMonth;

    if (controller.countBudget.value.isZero) {
      return GlassContainer(
        width: double.infinity,
        blur: 50,
        border: Border.all(
          color: Get.theme.textTheme.bodySmall!.color!.withAlpha(20),
        ),
        borderRadius: BorderRadius.all(Radius.circular(4)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Vx.pink500, AppColor.primary],
        ),
        child: VStack([
          'Total pengeluaran ${controller.monthSelected.value.reformatDate(from: 'MMMM', to: 'MMM')} ${controller.yearSelected.value}:'
              .text
              .make()
              .pOnly(bottom: 8),
          '${controller.countOnly1Month.value.moneyFormat()}'.text.bold.make(),
        ]).p12(),
      );
    }
    return GlassContainer(
      width: double.infinity,
      blur: 50,
      border: Border.all(
        color: Get.theme.textTheme.bodySmall!.color!.withAlpha(20),
      ),
      borderRadius: BorderRadius.all(Radius.circular(4)),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Vx.pink500, AppColor.primary],
      ),
      child: VStack(
        [
          /// col1
          HStack(
            [
              'Sisa budget'.text.size(11).make().pOnly(right: 8),
              Container(
                color: AppColor.primary,
                child:
                    '${controller.monthSelected.value.reformatDate(from: 'MMMM', to: 'MMM')} ${controller.yearSelected.value}'
                        .text
                        .size(11)
                        .minFontSize(11)
                        .color(AppColor.textOnBackground)
                        .make()
                        .pSymmetric(h: 8, v: 2),
              ).cornerRadius(8),
              Spacer(),
              Obx(
                () => '${controller.countRemainingBudget.value.moneyFormat()}'
                    .text
                    .bold
                    .size(16)
                    .make(),
              ),
            ],
          ),

          /// col2
          ExProgressBar(
            value: (controller.countPercentage.value).toInt(),
            color1: (controller.countPercentage.value).toInt() < 100
                ? AppColor.primary
                : Vx.red500,
            color2: Vx.neutral400,
            radius: 8,
          ).pSymmetric(v: 12),

          /// col3
          HStack(
            [
              'Terpakai: ${controller.countPercentage.value.toDoubleStringAsFixed()}%'
                  .text
                  .size(11)
                  .minFontSize(11)
                  .make()
                  .pOnly(left: 4),
              Spacer(),
              '${controller.countOnly1Month.value.moneyFormat()}'.text
                  .size(11)
                  .bold
                  .color(
                    (controller.countPercentage.value).toInt() < 100
                        ? AppColor.green
                        : AppColor.red,
                  )
                  .minFontSize(11)
                  .make(),
              ' / '.text.size(11).minFontSize(11).make(),
              '${controller.countBudget.value.moneyFormat()}'.text
                  .size(11)
                  .minFontSize(11)
                  .make(),
            ],
          ),

          Divider(),
          HStack([
            _headerMiniMetric(
              label: isCurrentMonth ? 'Aman harian' : 'Rata-rata harian',
              value: isCurrentMonth
                  ? dailySafe.moneyFormatCompact()
                  : controller.dailyAverageSpend.moneyFormatCompact(),
              color: dailySafe > 0 || !isCurrentMonth
                  ? AppColor.green
                  : AppColor.red,
            ).expand(),
            Container(
              width: 1,
              height: 28,
              color: AppColor.border,
            ).pSymmetric(h: 12),
            _headerMiniMetric(
              label: isCurrentMonth ? 'Proyeksi' : 'Total periode',
              value: projectedSpend.moneyFormatCompact(),
              color: projectedDelta >= 0 ? AppColor.green : AppColor.red,
            ).expand(),
          ]).pOnly(bottom: 8),
          if (isCurrentMonth) ...[
            HStack([
              '${controller.dayRemaining.value} hari tersisa'.text
                  .color(AppColor.textReverse)
                  .size(12)
                  .makeCentered(),
              ' · '.text.size(12).make(),
              (projectedDelta >= 0
                      ? 'Masih aman ${projectedDelta.moneyFormatCompact()}'
                      : 'Lebih ${projectedDelta.abs().moneyFormatCompact()}')
                  .text
                  .size(12)
                  .color(projectedDelta >= 0 ? AppColor.green : AppColor.red)
                  .make(),
              Spacer(),
              'Insight AI'.text.underline.size(12).make().onTap(() async {
                controller.menuSelected.value = 5;
                await 100.milliseconds.delay();
                controller.chatInputController.text =
                    'jelasin budget pace periode ini dan kasih batas pengeluaran harian yang aman. jawab singkat aja';
              }),
            ]).pOnly(top: 8),
          ] else ...[
            HStack([
              '${projectedDelta.abs().moneyFormatCompact()} ${projectedDelta >= 0 ? 'di bawah' : 'di atas'} rencana budget'
                  .text
                  .color(projectedDelta >= 0 ? AppColor.green : AppColor.red)
                  .size(12)
                  .makeCentered(),
              Spacer(),
              'Insight AI'.text.underline.size(12).make().onTap(() {
                controller.menuSelected.value = 5;
              }),
            ]).pOnly(top: 8),
          ],
        ],
      ).p8(),
    );
  }

  Widget detailPerMonth() {
    return Obx(
      () => Container(
        width: double.infinity,
        decoration: ExDecorator.box(
          fillColor: AppColor.box,
          borderColor: AppColor.border,
          borderRadius: 4,
        ),
        child: controller.isShowAIAnalysis.isFalse
            ? VStack(
                [
                  Obx(
                    () {
                      final sections = _buildMonthlySections();
                      if (sections.isEmpty) {
                        return 'Belum ada data'.text
                            .size(12)
                            .neutral500
                            .makeCentered()
                            .p16()
                            .expand();
                      }
                      return ListView(
                        children: [
                          _quickInsightStrip(),
                          ...sections,
                        ],
                      ).expand();
                    },
                  ),
                ],
              ).p12()
            : 0.heightBox,
      ),
    );
  }

  Widget _headerMiniMetric({
    required String label,
    required String value,
    required Color color,
  }) {
    return VStack([
      label.text
          .size(10)
          .minFontSize(10)
          .color(Vx.neutral300)
          .make()
          .pOnly(bottom: 2),
      value.text.bold.size(12).minFontSize(12).color(color).make(),
    ]).pSymmetric(h: 4, v: 4);
  }

  Widget _quickInsightStrip() {
    final topCategory = controller.categorySummaries.isNotEmpty
        ? controller.categorySummaries.first
        : null;
    final risks = _budgetRiskCount();
    final unbudgeted = _unbudgetedCategoryCount();

    return Container(
      decoration: ExDecorator.box(
        fillColor: AppColor.card,
        borderColor: AppColor.border,
        borderRadius: 8,
      ),
      child: HStack([
        Container(
          decoration: BoxDecoration(
            color: AppColor.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.tips_and_updates_rounded,
            size: 13,
            color: AppColor.textOnBackground,
          ).centered(),
        ).wh(26, 26).pOnly(right: 8),
        VStack([
          'Kategori terbesar'.text
              .size(9)
              .minFontSize(9)
              .color(AppColor.neutral)
              .make(),
          (topCategory?.resolvedCategory.label ?? '-').text
              .bold
              .size(11)
              .maxLines(1)
              .ellipsis
              .color(AppColor.textReverse)
              .make(),
        ]).expand(),
        _signalPill(
          value: '$risks risiko',
          color: risks > 0 ? AppColor.red : AppColor.green,
        ),
        6.widthBox,
        _signalPill(
          value: '$unbudgeted belum dianggarkan',
          color: unbudgeted > 0 ? AppColor.orange : AppColor.green,
        ),
        8.widthBox,
        IconButton(
          tooltip: 'Tanya AI',
          visualDensity: VisualDensity.compact,
          style: IconButton.styleFrom(
            backgroundColor: AppColor.primary,
            minimumSize: Size(28, 28),
            maximumSize: Size(28, 28),
            padding: EdgeInsets.zero,
          ),
          icon: Icon(
            Icons.auto_awesome_rounded,
            size: 14,
            color: AppColor.textOnBackground,
          ),
          onPressed: () {
            controller.menuSelected.value = 5;
          },
        ),
      ]).pSymmetric(h: 10, v: 6),
    ).pOnly(bottom: 12);
  }

  Widget _signalPill({
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: ExDecorator.box(
        borderRadius: 90,
        borderColor: color.withAlpha(80),
        fillColor: color.withAlpha(20),
      ),
      child: value.text.bold
          .size(9)
          .minFontSize(9)
          .maxLines(1)
          .color(color)
          .make()
          .pSymmetric(h: 7, v: 4),
    );
  }

  Map<String, CategorySpendSummary> _categorySummaryByCode() {
    final map = <String, CategorySpendSummary>{};
    for (final item in controller.categorySummaries) {
      map[item.resolvedCategory.code] = item;
    }
    return map;
  }

  Map<String, num> _budgetsByCategoryCode() {
    if (!Get.isRegistered<HomeController>()) return {};
    final homeController = Get.find<HomeController>();
    if (homeController.budgetsList.isEmpty) return {};

    final budgets = <String, num>{};
    for (final budget in homeController.budgetsList) {
      if (budget.categoryCode == null) continue;
      final category = resolveExpenseCategory(budget.categoryCode);
      final amount = budget.amount ?? 0;
      if (amount > 0) {
        budgets[category.code] = amount;
      }
    }
    return budgets;
  }

  num? _groupBudgetTotal(
    List<ExpenseCategory> categories,
    Map<String, num> budgetsByCategory,
  ) {
    if (budgetsByCategory.isEmpty) return null;
    num totalBudget = 0;
    var hasBudget = false;

    for (final category in categories) {
      final amount = budgetsByCategory[category.code] ?? 0;
      if (amount > 0) {
        totalBudget += amount;
        hasBudget = true;
      }
    }

    return hasBudget ? totalBudget : null;
  }

  List<Widget> _buildYearlySections() {
    final data = _categorySummaryByCode();
    final sections = <Widget>[];

    for (final group in expenseCategoryGroups) {
      final groupItems = group.items
          .map((category) => data[category.code])
          .whereType<CategorySpendSummary>()
          .where((item) => item.total > 0)
          .toList();

      if (groupItems.isEmpty) continue;

      sections.add(
        _buildGroupCard(
          title: group.label,
          total: groupItems.fold<num>(0, (sum, item) => sum + item.total),
          body: VStack([
            ...groupItems.map((item) {
              final resolved = item.resolvedCategory;
              return HStack(
                    [
                      Icon(
                        resolved.icon ?? Icons.circle_outlined,
                        size: 14,
                        color: resolved.color,
                      ).pOnly(right: 12),
                      '${resolved.label}'.text
                          .size(12)
                          .ellipsis
                          .maxLines(1)
                          .make()
                          .expand(),
                      item.total
                          .moneyFormat()
                          .text
                          .size(12)
                          .make()
                          .pOnly(left: 12),
                    ],
                  )
                  .pOnly(bottom: 8)
                  .onTap(() => controller.goAdvanceFilter(resolved.code));
            }),
          ]),
        ),
      );
    }

    return sections;
  }

  List<Widget> _buildMonthlySections() {
    final data = _categorySummaryByCode();
    final sections = <Widget>[];
    final budgetsByCategory = _budgetsByCategoryCode();

    for (final group in expenseCategoryGroups) {
      final groupItems = group.items
          .map((category) => data[category.code])
          .whereType<CategorySpendSummary>()
          .where((item) => item.total > 0)
          .toList();

      if (groupItems.isEmpty) continue;

      sections.add(
        _buildGroupCard(
          title: group.label,
          total: groupItems.fold<num>(0, (sum, item) => sum + item.total),
          budget: _groupBudgetTotal(group.items, budgetsByCategory),
          body: VStack([
            ...groupItems.map((item) => _buildMonthlyCategoryRow(item)),
          ]),
        ),
      );
    }

    return sections;
  }

  Widget _buildGroupCard({
    required String title,
    required num total,
    required Widget body,
    Widget? footer,
    num? budget,
  }) {
    return Container(
      decoration: ExDecorator.box(
        fillColor: AppColor.box,
        borderColor: AppColor.border,
        borderRadius: 12,
      ),
      child: VStack(
        [
          HStack([
            '$title'.text.semiBold
                .size(13)
                .make()
                .pSymmetric(h: 8, v: 2)
                .color(AppColor.border)
                .cornerRadius(4),
            Spacer(),
            total.moneyFormat().text.bold.size(13).make(),
          ]),

          if (budget != null) ...[
            HStack([
              ExProgressBar(
                value: (total / budget * 100).toInt(),
                color1: HelperBibit.getColorForPercentage(
                  (total / budget * 100).toInt(),
                ),
                color2: Vx.neutral400,
              ).wh(200, 4).pOnly(right: 12).expand(),

              '${total.moneyFormatCompact()} / ${budget.moneyFormatCompact()} · ${(total / budget * 100).round()}%'
                  .text
                  .size(10)
                  .minFontSize(10)
                  .color(
                    (total / budget * 100).toInt() < 100
                        ? AppColor.green
                        : AppColor.red,
                  )
                  .make(),
            ]).pOnly(top: 8),
          ],

          Divider(color: AppColor.border).pSymmetric(v: 8),
          body,
          ?footer,
        ],
      ).p12(),
    ).pOnly(bottom: 12);
  }

  Widget _buildMonthlyCategoryRow(CategorySpendSummary item) {
    final category = item.resolvedCategory;
    final spent = item.total;
    final budgetAmount = item.maxBudget ?? 0;
    final percent = budgetAmount > 0
        ? (spent.toDouble() / budgetAmount) * 100
        : 0.0;
    final percentLabel =
        '${(percent.isFinite ? percent.clamp(0, 999).round() : 0)}%';
    final hasBudget = budgetAmount > 0;

    return VStack(
      [
        HStack(
          [
            Icon(
              category.icon ?? Icons.circle_outlined,
              size: 14,
              color: category.color,
            ).pOnly(right: 12),
            '${category.label}'.text
                .size(12)
                .maxLines(1)
                .ellipsis
                .make()
                .expand(),
            '${item.total.moneyFormat()}'.text
                .size(12)
                .bold
                .make()
                .pOnly(left: 12),

            if (hasBudget) ...[
              '($percentLabel)'.text
                  .size(10)
                  .minFontSize(10)
                  .color(
                    percent >= 100
                        ? AppColor.red
                        : percent >= 80
                        ? AppColor.orange
                        : AppColor.green,
                  )
                  .make()
                  .pOnly(left: 3),
            ] else ...[
              '(-)'.text.size(10).minFontSize(10).make().pOnly(left: 3),
            ],
          ],
        ).tooltip(
          hasBudget
              ? 'Terpakai: $percentLabel | Sisa: ${(budgetAmount - spent).moneyFormat()}'
              : '',
        ),
      ],
    ).pOnly(bottom: 12).onTap(() => controller.goAdvanceFilter(category.code));
  }

  int _budgetRiskCount() {
    return controller.categorySummaries
        .where((item) => (item.usePercentage ?? 0) >= 80)
        .length;
  }

  int _unbudgetedCategoryCount() {
    return controller.categorySummaries.where((item) {
      return item.total > 0 &&
          item.categoryCode != 'expense:misc:notes' &&
          item.maxBudget == null;
    }).length;
  }
}
