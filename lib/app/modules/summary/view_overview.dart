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
          if (controller.isShowAllYear.isTrue) headerAllYear() else headerPerMonth(),

          16.heightBox,

          /// detail
          if (controller.isShowAllYear.isTrue) detailAllYear().expand() else detailPerMonth().expand(),
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
          'Total Expense ${controller.yearSelected}'.text.size(12).make().pOnly(bottom: 8),
          '${controller.countOnly1Year.value.moneyFormat()}'.text.bold.size(16).make(),
        ],
      ).p12(),
    );
  }

  Widget detailAllYear() {
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(fillColor: AppColor.box, borderColor: AppColor.border, borderRadius: 4),
      child: Obx(() {
        final sections = _buildYearlySections();
        if (sections.isEmpty) {
          return 'No data yet'.text.size(12).neutral500.makeCentered().p16();
        }
        return ListView(children: sections);
      }).p12(),
    );
  }

  Widget headerPerMonth() {
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
          'Total Expense ${controller.monthSelected.value.reformatDate(from: 'MMMM', to: 'MMM')} ${controller.yearSelected.value}:'.text.make().pOnly(bottom: 8),
          '${controller.countOnly1Month.value.moneyFormat()}'.text.bold.make(),
        ]).p12(),
      );
    }
    return GlassContainer(
      width: double.infinity,
      blur: 50,
      border: Border.all(color: Get.theme.textTheme.bodySmall!.color!.withAlpha(20)),
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
              'Remaining Budget'.text.size(11).make().pOnly(right: 8),
              Container(
                color: AppColor.primary,
                child: '${controller.monthSelected.value.reformatDate(from: 'MMMM', to: 'MMM')} ${controller.yearSelected.value}'.text
                    .size(11)
                    .minFontSize(11)
                    .color(AppColor.textOnBackground)
                    .make()
                    .pSymmetric(h: 8, v: 2),
              ).cornerRadius(8),
              Spacer(),
              Obx(
                () => '${controller.countRemainingBudget.value.moneyFormat()}'.text.bold.size(16).make(),
              ),
            ],
          ),

          /// col2
          ExProgressBar(
            value: (controller.countPercentage.value).toInt(),
            color1: (controller.countPercentage.value).toInt() < 100 ? AppColor.primary : Vx.red500,
            color2: Vx.neutral400,
            radius: 8,
          ).pSymmetric(v: 12),

          /// col3
          HStack(
            [
              'Used: ${controller.countPercentage.value.toDoubleStringAsFixed()}%'.text.size(11).minFontSize(11).make().pOnly(left: 4),
              Spacer(),
              '${controller.countOnly1Month.value.moneyFormat()}'.text.size(11).bold.color((controller.countPercentage.value).toInt() < 100 ? AppColor.green : AppColor.red).minFontSize(11).make(),
              ' / '.text.size(11).minFontSize(11).make(),
              '${controller.countBudget.value.moneyFormat()}'.text.size(11).minFontSize(11).make(),
            ],
          ),

          Divider(),
          if (DateTime.now().month == controller.monthSelected.value.toDateEx(format: 'MMMM').month && DateTime.now().year == controller.yearSelected.value.toInt()) ...[
            HStack([
              '${dayInMonth(DateTime.now()) - DateTime.now().day} Day Remaining'.text.color(AppColor.textReverse).size(12).makeCentered(),
              Spacer(),
              'AI Insights'.text.underline.size(12).make().onTap(() async {
                controller.menuSelected.value = 5;
                await 100.milliseconds.delay();
                controller.chatInputController.text =
                    'sisa uangku ${controller.countRemainingBudget.value.moneyFormat()} untuk ${dayInMonth(DateTime.now()) - DateTime.now().day} hari lagi sampai akhir bulan. baiknya perhari nya berapa? jawab singkat aja';
                // await 100.milliseconds.delay();
                // await controller.sendMessage();
              }),
            ]).pOnly(top: 8),
          ] else ...[
            HStack([
              if (controller.countPercentage.value.toDouble() < 20) ...[
                'Look Invalid! '.text.color(AppColor.red).size(12).make(),
              ] else ...[
                'Surplus ${controller.surplus.value.moneyFormat()}'.text.color(AppColor.blue).size(12).makeCentered(),
              ],
              Spacer(),
              'AI Insights'.text.underline.size(12).make().onTap(() {
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
                        return 'No data yet'.text.size(12).neutral500.makeCentered().p16().expand();
                      }
                      return ListView(
                        children: sections,
                      ).expand();
                    },
                  ),
                ],
              ).p12()
            : 0.heightBox,
      ),
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

  num? _groupBudgetTotal(List<CategorySpendSummary> items, Map<String, num> budgetsByCategory) {
    if (budgetsByCategory.isEmpty) return null;
    num totalBudget = 0;
    var hasBudget = false;

    for (final item in items) {
      final amount = budgetsByCategory[item.categoryCode] ?? 0;
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
    final budgetsByCategory = _budgetsByCategoryCode();

    for (final group in expenseCategoryGroups) {
      final groupItems = group.items.map((category) => data[category.code]).whereType<CategorySpendSummary>().where((item) => item.total > 0).toList();

      if (groupItems.isEmpty) continue;

      sections.add(
        _buildGroupCard(
          title: group.label,
          total: groupItems.fold<num>(0, (sum, item) => sum + item.total),
          budget: _groupBudgetTotal(groupItems, budgetsByCategory),
          body: VStack([
            ...groupItems.map((item) {
              final resolved = item.resolvedCategory;
              return HStack(
                [
                  Icon(resolved.icon ?? Icons.circle_outlined, size: 14, color: resolved.color).pOnly(right: 12),
                  '${resolved.label}'.text.size(12).ellipsis.maxLines(1).make().expand(),
                  item.total.moneyFormat().text.size(12).make().pOnly(left: 12),
                ],
              ).pOnly(bottom: 8).onTap(() => controller.goAdvanceFilter(resolved.code));
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
      final groupItems = group.items.map((category) => data[category.code]).whereType<CategorySpendSummary>().where((item) => item.total > 0).toList();

      if (groupItems.isEmpty) continue;

      sections.add(
        _buildGroupCard(
          title: group.label,
          total: groupItems.fold<num>(0, (sum, item) => sum + item.total),
          budget: _groupBudgetTotal(groupItems, budgetsByCategory),
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
            '$title'.text.semiBold.size(13).make().pSymmetric(h: 8, v: 2).color(AppColor.border).cornerRadius(4),
            Spacer(),
            total.moneyFormat().text.bold.size(13).make(),
          ]),

          if (budget != null) ...[
            HStack([
              ExProgressBar(
                value: (total / budget * 100).toInt(),
                color1: HelperBibit.getColorForPercentage((total / budget * 100).toInt()),
                color2: Vx.neutral400,
              ).wh(200, 4).pOnly(right: 12).expand(),

              HStack([
                Spacer(),
                '('.text.size(10).minFontSize(10).make(),
                '${total.moneyFormatCompact()}'.text.size(10).minFontSize(10).color((total / budget * 100).toInt() < 100 ? AppColor.green : AppColor.red).make(),
                ' / ${budget.moneyFormatCompact()}'.text.size(10).minFontSize(10).make(),
                ')'.text.size(10).minFontSize(10).make().pOnly(right: 8),
                '${(total / budget * 100).toStringAsFixed(2)}%'.text.size(10).minFontSize(10).color((total / budget * 100).toInt() < 100 ? AppColor.green : AppColor.red).make(),
              ]).w(140),
            ]).pOnly(top: 8),
          ],

          Divider(color: AppColor.border).pSymmetric(v: 8),
          body,
          if (footer != null) footer,
        ],
      ).p16(),
    ).pOnly(bottom: 16);
  }

  Widget _buildMonthlyCategoryRow(CategorySpendSummary item) {
    final category = item.resolvedCategory;
    final hasBudget = item.maxBudget != null && item.maxBudget! > 0;

    return VStack(
      [
        HStack(
          [
            Icon(
              category.icon ?? Icons.circle_outlined,
              size: 14,
              color: category.color,
            ).pOnly(right: 12),
            '${category.label}'.text.size(12).maxLines(1).ellipsis.make().expand(),
            item.total.moneyFormat().text.size(12).bold.make().pOnly(left: 12),
          ],
        ),
        if (hasBudget) ...[
          ExProgressBar(
            value: item.usePercentage ?? 0,
            color1: item.usePercentage! < 100 ? AppColor.primary : Colors.red,
            color2: Vx.neutral400,
            radius: 9,
            height: 6,
          ).pOnly(top: 6, bottom: 4),
          HStack([
            '${item.usePercentage}% used'.text.size(11).neutral500.make(),
            Spacer(),
            'Remaining ${item.remainingBudget?.moneyFormat() ?? 0.moneyFormat()}'.text
                .size(11)
                .color(
                  item.remainingBudget! < 0 ? AppColor.red : AppColor.textReverse,
                )
                .make(),
          ]),
        ],
      ],
    ).pOnly(bottom: 12).onTap(() => controller.goAdvanceFilter(category.code));
  }
}
