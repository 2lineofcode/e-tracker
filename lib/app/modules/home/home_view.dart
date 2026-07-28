import 'package:animated_icon/animated_icon.dart';
import 'package:ex_kit/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:lottie/lottie.dart';
import 'package:overlayment/overlayment.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../core/app_color.dart';
import '../../core/app_setting.dart';
import '../../core/const.dart';
import '../../helpers/helpers.dart';
import '../../models/supa_expense_entity.dart';
import '../../routes/app_pages.dart';
import '../widgets/widgets.dart';
import 'home_controller.dart';
import 'section_dialog_asset.dart';
import 'section_dialog_budget.dart';
import 'section_dialog_expense.dart';
import 'section_dialog_goal.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return MyLayout(
      drawerKey: drawerKeyHome,
      appBarTitle: appBarTitle(),
      appBarLeading: appBarLeading().pOnly(right: 8),
      isShowAppBarLeading: false,
      appBarAction: appBarAction(),
      sideMenuContent: sideMenuContent(),
      sideMenuWidth: 258,
      bodyContent: bodyContent(),
      footerContent: footerContent(),
      floatingActionButton: floatingActionButton(),
    );
  }

  Widget appBarTitle() {
    return TextField(
      controller: controller.tfSearchExpense.value,
      style: TextStyle(fontSize: 13),
      decoration: HelperDecoration.input(
        fillColor: Get.isDarkMode ? AppColor.card : null,
        prefixIcon: CustomPopup(
          content: VStack([
            ''.richText
                .withTextSpanChildren([
                  'Search Features:\n'.textSpan.size(13).bold.make(),
                  '\n- by "Note", example: "Nasi Padang"'.textSpan.make(),
                  '\n- by "Category", example: "Food"'.textSpan.make(),
                  '\n- by "Days", example: "7"'.textSpan.make(),
                  '\n- by "Date Range", example: "2023-01-01 2023-01-07"'
                      .textSpan
                      .make(),
                ])
                .black
                .size(11)
                .minFontSize(11)
                .make(),
          ]),
          child: Icon(
            UIconsPro.regularRounded.search,
            size: 13,
            color: AppColor.textReverse,
          ).pOnly(top: 0),
        ),
        hint: 'Search: Note, Category, Days, Date Range...',
        suffix:
            Icon(
              UIconsPro.solidRounded.cross_small,
              size: 12,
              color: AppColor.textReverse,
            ).pOnly(top: 0).onInkTap(() async {
              controller.tfSearchExpense.value.clear();
              await controller.getExpense();
            }),
      ),
      onSubmitted: (s) => controller.getExpense(find: s.isNotEmpty ? s : null),
    ).wh(double.infinity, 30);
  }

  Widget appBarLeading() {
    return IconButton(
      icon: Icon(CupertinoIcons.add, size: 22),
      onPressed: () => DialogExpense.openManualInput(),
    );
  }

  Widget appBarAction() {
    return HStack(
      [
        IconButton(
          onPressed: () => controller.goSetting(),
          icon: isMobileWeb
              ? Icon(CupertinoIcons.settings_solid, size: 20)
              : AnimateIcon(
                  onTap: () => controller.goSetting(),
                  iconType: IconType.animatedOnHover,
                  height: 20,
                  width: 20,
                  color: Get.isDarkMode ? Colors.white70 : Colors.black54,
                  animateIcon: AnimateIcons.settings,
                ),
        ).pOnly(right: 4),
        IconButton(
          onPressed: () => controller.goSummary(),
          icon: isMobileWeb
              ? Icon(CupertinoIcons.arrow_up_arrow_down, size: 18)
              : AnimateIcon(
                  onTap: () => controller.goSummary(),
                  iconType: IconType.continueAnimation,
                  height: 20,
                  width: 20,
                  color: Get.isDarkMode ? Colors.white70 : Colors.black54,
                  animateIcon: AnimateIcons.activity,
                ),
        ),
      ],
    );
  }

  Widget sideMenuContent() {
    return VStack(
      [
        /// calendar :header
        GetBuilder<HomeController>(
          init: HomeController(),
          initState: (_) {},
          builder: (_) {
            return MyCalendarHeader(
              focusedDay: controller.focusedDay.value,
              onGoPrevMonth: () => controller.onCalenderGoPrevMonth(),
              onGoToday: () => controller.onCalenderGoToday(),
              onGoNextMonth: () => controller.onCalenderGoNextMonth(),
              onGoDate: (dt) {
                controller.selectedDays.clear();
                controller.selectedDays.add(dt);
                controller.focusedDay.value = dt;
                controller.getExpense();
              },
            );
          },
        ),

        /// calendar :body
        GetBuilder<HomeController>(
          init: HomeController(),
          initState: (_) {},
          builder: (_) {
            return MyCalenderBody<String>(
              focusedDay: controller.focusedDay.value,
              minimumDate: DateTime.utc(2020),
              maximumDate: DateTime.utc(2030),
              onCalendarCreated: (c) => controller.calenderPageController = c,
              onPageChanged: (fd) => controller.onCalenderPageChanged(fd),
              onDaySelected: controller.onCalenderDayChange,
              selectedDayPredicate: (day) =>
                  controller.selectedDays.contains(day),
              eventLoader: controller.onCalenderLoadEvent,
              calendarStartDay: pref.read<int>(kCalendarStartDay) ?? 1,

              /// custom
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isNotEmpty) {
                    var total = 0;
                    for (var event in events) total += event.toInt()!;
                    return Icon(
                      Icons.circle,
                      size: 6,
                      color: total.getFlagColor(),
                    ).positioned(top: 8, right: 8);
                  }
                  return Container();
                },
              ),
            ).pOnly(bottom: 8);
          },
        ),

        /// add-ons
        VStack(
          [
            Divider(color: AppColor.border),

            // :0:
            '::Tools'.text.size(12).bold.make().pOnly(top: 2, bottom: 12),

            Expanded(
              child: VStack([
                Obx(() => financeInsightCard()).pOnly(bottom: 12),

                // :1: high spending
                Obx(
                  () => HStack([
                    Icon(
                      UIconsPro.solidRounded.sensor_fire,
                      size: 14,
                      color: Color.fromARGB(255, 195, 86, 69),
                    ).pOnly(right: 8),
                    'High Spendings!'.text.size(12).make(),
                    Spacer(),
                    CustomPopup(
                      content: highSpendingPopupContent(),
                      child: Container(
                        decoration: ExDecorator.box(
                          borderRadius: 90,
                          borderColor: Colors.transparent,
                          fillColor: AppColor.primary.withAlpha(100),
                        ),
                        child: '${controller.rpcSpenderDay.length}'.text
                            .size(11)
                            .minFontSize(11)
                            .makeCentered()
                            .pOnly(left: 8, right: 8, top: 2, bottom: 2),
                      ),
                    ),
                  ]).pOnly(left: 4, right: 8),
                ).pOnly(bottom: 12),

                // :2: budgets
                Obx(
                  () => buildTools(
                    title: 'Budgets Planning',
                    icon: Icon(
                      UIconsPro.solidRounded.piggy_bank_budget,
                      size: 14,
                      color: Color.fromARGB(255, 69, 195, 109),
                    ),
                    count: '${controller.budgetsList.length}',
                    ontap: () => DialogBudget.openList(),
                  ).pOnly(bottom: 12),
                ),

                // :3:
                Obx(
                  () => buildTools(
                    title: 'Assets',
                    icon: Icon(
                      UIconsPro.solidRounded.plant_seed_invest,
                      size: 14,
                      color: Color.fromARGB(255, 195, 193, 69),
                    ),
                    count:
                        '${controller.totalAssets.value.moneyFormatCompact()}',
                    ontap: () => DialogAsset.openList(),
                  ).pOnly(bottom: 12),
                ),

                // :4:
                Obx(
                  () => buildTools(
                    title: 'Goals',
                    icon: Icon(
                      UIconsPro.solidRounded.location_crosshairs,
                      size: 14,
                      color: Color.fromARGB(255, 69, 132, 195),
                    ),
                    count: '${controller.goalsList.length}',
                    ontap: () => DialogGoal.openList(),
                  ).pOnly(bottom: 12),
                ),

                // :5:
                Obx(
                  () => buildTools(
                    title: 'Notes',
                    icon: Icon(
                      UIconsPro.solidRounded.notebook,
                      size: 14,
                      color: Color.fromARGB(255, 204, 211, 186),
                    ),
                    count: '${controller.notesList.length}',
                    ontap: () => Get.toNamed(Routes.NOTES),
                  ).pOnly(bottom: 12),
                ),

                // :6:
                buildTools(
                  title: 'Calc+',
                  icon: Icon(
                    UIconsPro.solidRounded.file_excel,
                    size: 14,
                    color: Color.fromARGB(255, 57, 182, 107),
                  ),
                  count: 'Open',
                  ontap: () => Get.toNamed(Routes.CALCP),
                ).pOnly(bottom: 12),

                // :7:
                Obx(
                  () =>
                      buildTools(
                            title: 'SQL Editor',
                            icon: Icon(
                              UIconsPro.solidRounded.database,
                              size: 14,
                              color: Color.fromARGB(255, 123, 99, 196),
                            ),
                            count: 'Open',
                            ontap: () => Get.toNamed(Routes.SQL_EDITOR),
                          )
                          .pOnly(bottom: 12)
                          .hide(
                            isVisible:
                                controller.userProfile.value.username ==
                                'abehbatre',
                          ),
                ),

                // :8:
                buildTools(
                  title: 'Worksheet',
                  icon: Icon(
                    UIconsPro.solidRounded.data_transfer,
                    size: 14,
                    color: Color.fromARGB(255, 252, 252, 252),
                  ),
                  count: 'Open',
                  ontap: () => Get.toNamed(Routes.TESTER),
                ).pOnly(bottom: 12).hide(isVisible: kDebugMode),

                // :summary:
                Container(
                  decoration: ExDecorator.box(
                    borderRadius: 4,
                    borderColor: AppColor.border,
                    fillColor: AppColor.card,
                  ),
                  child: VStack(
                    [
                      HStack([
                        'Spend vs Budgets'.text.bold
                            .size(11)
                            .minFontSize(11)
                            .make()
                            .expand(),
                        Obx(() {
                          final totalSpentRaw =
                              controller.totalSumAllBudget.value;
                          final totalBudgetRaw =
                              controller.totalAllBudget.value;
                          final totalSpent = totalSpentRaw.isFinite
                              ? totalSpentRaw
                              : 0;
                          final totalBudget = totalBudgetRaw.isFinite
                              ? totalBudgetRaw
                              : 0;
                          return '${totalSpent.moneyFormatCompact()} / ${totalBudget.moneyFormatCompact()}'
                              .text
                              .size(12)
                              .make();
                        }),
                      ]),
                      Obx(
                        () {
                          final totalSpentRaw =
                              controller.totalSumAllBudget.value;
                          final totalBudgetRaw =
                              controller.totalAllBudget.value;
                          final totalSpent =
                              totalSpentRaw.isFinite && totalSpentRaw >= 0
                              ? totalSpentRaw.toDouble()
                              : 0.0;
                          final totalBudget =
                              totalBudgetRaw.isFinite && totalBudgetRaw > 0
                              ? totalBudgetRaw.toDouble()
                              : 0.0;
                          final ratio = totalBudget == 0
                              ? 0.0
                              : (totalSpent / totalBudget) * 100;
                          final percentage = ratio.isFinite && !ratio.isNaN
                              ? ratio.clamp(0, 999).round()
                              : 0;
                          final progressValue = percentage.clamp(0, 100);

                          return HStack(
                            [
                              ExProgressBar(
                                value: progressValue.toInt(),
                                color1: HelperBibit.getColorForPercentage(
                                  percentage.toInt(),
                                ),
                                color2: Vx.neutral400,
                              ).h(4).expand(),
                              '${percentage.toInt()}%'.text
                                  .size(11)
                                  .minFontSize(11)
                                  .make()
                                  .pOnly(left: 12),
                            ],
                          );
                        },
                      ).pSymmetric(v: 3),

                      /// day remaining...
                      Obx(() {
                        if (DateTime.now().month ==
                                controller.focusedDay.value.month &&
                            DateTime.now().year ==
                                controller.focusedDay.value.year) {
                          return HStack([
                            '${dayInMonth(DateTime.now()) - DateTime.now().day} Day Remaining'
                                .text
                                .color(AppColor.textReverse)
                                .size(10)
                                .minFontSize(10)
                                .make(),
                          ]);
                        }
                        return 0.heightBox;
                      }),
                    ],
                  ).p12(),
                ).onInkTap(() => controller.goSummary()).pOnly(bottom: 12),
              ]).scrollVertical(physics: ClampingScrollPhysics()),
            ),
          ],
        ).pSymmetric(h: 12).expand(),
      ],
    ).expand();
  }

  Widget highSpendingPopupContent() {
    final list = controller.rpcSpenderDay;
    final visibleList = list.take(8).toList();

    return VStack([
      HStack([
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: ExDecorator.box(
            borderRadius: 6,
            borderColor: Colors.transparent,
            fillColor: AppColor.red.withAlpha(28),
          ),
          child: Icon(
            UIconsPro.solidRounded.sensor_fire,
            size: 14,
            color: AppColor.red,
          ),
        ).pOnly(right: 8),
        VStack([
          'High Spendings'.text.black.bold.size(12).make(),
          '${list.length} peak days'.text.size(10).minFontSize(10).color(Vx.neutral500).make(),
        ]).expand(),
      ]).pOnly(bottom: 8),

      if (list.isEmpty) ...[
        'No high spending day yet'.text.size(11).color(Vx.neutral500).makeCentered().pSymmetric(v: 12),
      ] else ...[
        ...visibleList.asMap().entries.map((entry) {
          final item = entry.value;
          return highSpendingRow(
            rank: entry.key + 1,
            date: item['date'].toString(),
            total: item['total'].toString().toInt() ?? 0,
          ).pOnly(bottom: entry.key == visibleList.length - 1 ? 0 : 4);
        }),
      ],
    ]).w(168).p8().scrollVertical();
  }

  Widget highSpendingRow({
    required int rank,
    required String date,
    required int total,
  }) {
    return Container(
      decoration: ExDecorator.box(
        borderRadius: 6,
        borderColor: Vx.neutral200,
        fillColor: Vx.neutral100,
      ),
      child: HStack([
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: ExDecorator.box(
            borderRadius: 90,
            borderColor: Colors.transparent,
            fillColor: total.getFlagColor().withAlpha(35),
          ),
          child: '$rank'.text.bold.size(9).color(total.getFlagColor()).make(),
        ).pOnly(right: 6),
        date.reformatDate(from: yMd, to: 'dd MMM').text.black.bold.size(11).make().expand(),
        total.moneyFormatCompact().text.bold.size(10).minFontSize(9).color(total.getFlagColor()).make(),
      ]).pSymmetric(h: 7, v: 5),
    ).onInkTap(
      () => controller.onCalenderGoDate(date.toDateEx(format: yMd)),
    );
  }

  Widget buildTools({
    required String title,
    required Icon icon,
    required String count,
    required Function ontap,
  }) {
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: 100.milliseconds,
            decoration: BoxDecoration(
              color: isHovered ? AppColor.card : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: VStack(
              [
                HStack([
                  icon.pOnly(right: 8),
                  '$title'.text
                      .size(12)
                      .fontWeight(
                        isHovered ? FontWeight.bold : FontWeight.normal,
                      )
                      .make()
                      .expand(),
                  Container(
                    decoration: ExDecorator.box(
                      borderRadius: 90,
                      borderColor: Colors.transparent,
                      fillColor: AppColor.primary.withAlpha(100),
                    ),
                    child: '$count'.text
                        .size(11)
                        .minFontSize(11)
                        .make()
                        .pSymmetric(h: 8, v: 2),
                  ),
                ]).pOnly(left: 4, right: 8).onInkTap(() => ontap()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget financeInsightCard() {
    final hasBudget = controller.totalAllBudget.value > 0;
    final isOverProjection = controller.projectedBudgetDelta < 0;
    final upcoming = controller.upcomingRepeatTransactions.take(2).toList();
    final unbudgeted = controller.unbudgetedCategorySpending.take(2).toList();
    final isExpanded = false.obs;

    return Container(
      decoration: ExDecorator.box(
        borderRadius: 8,
        borderColor: AppColor.border,
        fillColor: AppColor.card,
      ),
      child: Obx(
        () => VStack(
          [
            HStack([
              Icon(
                UIconsPro.solidRounded.chart_pie,
                size: 14,
                color: AppColor.primary,
              ).pOnly(right: 8),
              'Smart Forecast'.text.bold.size(12).make().expand(),
              if (controller.budgetWarningCount > 0)
                '${controller.budgetWarningCount} risk'.text
                    .size(10)
                    .minFontSize(10)
                    .color(AppColor.textOnBackground)
                    .make()
                    .pSymmetric(h: 6, v: 2)
                    .color(AppColor.red)
                    .cornerRadius(90)
                    .pOnly(right: 8),
              Icon(
                isExpanded.value
                    ? CupertinoIcons.chevron_up
                    : CupertinoIcons.chevron_down,
                size: 12,
                color: AppColor.neutral,
              ),
            ]).pOnly(bottom: 8).onInkTap(() => isExpanded.toggle()),
            if (hasBudget) ...[
              HStack([
                'Projected'.text
                    .size(11)
                    .minFontSize(11)
                    .color(AppColor.neutral)
                    .make()
                    .expand(),
                controller.projectedMonthSpend
                    .moneyFormatCompact()
                    .text
                    .bold
                    .size(12)
                    .make(),
              ]).pOnly(bottom: 4),
              HStack([
                'Daily safe'.text
                    .size(11)
                    .minFontSize(11)
                    .color(AppColor.neutral)
                    .make()
                    .expand(),
                controller.dailyAllowance
                    .moneyFormatCompact()
                    .text
                    .bold
                    .size(12)
                    .color(
                      controller.dailyAllowance > 0
                          ? AppColor.green
                          : AppColor.red,
                    )
                    .make(),
              ]).pOnly(bottom: 4),
              HStack([
                ExProgressBar(
                  value: controller.projectedBudgetPercent.clamp(0, 100),
                  color1: HelperBibit.getColorForPercentage(
                    controller.projectedBudgetPercent,
                  ),
                  color2: Vx.neutral400,
                ).h(4).expand(),
                '${controller.projectedBudgetPercent}%'.text
                    .size(10)
                    .minFontSize(10)
                    .make()
                    .pOnly(left: 8),
              ]).pOnly(bottom: 6),
              (isOverProjection
                      ? 'Over pace by ${controller.projectedBudgetDelta.abs().moneyFormatCompact()}'
                      : 'On pace, spare ${controller.projectedBudgetDelta.moneyFormatCompact()}')
                  .text
                  .size(10)
                  .minFontSize(10)
                  .color(isOverProjection ? AppColor.red : AppColor.green)
                  .make(),
            ] else ...[
              'Set category budgets to unlock burn-rate forecast.'.text
                  .size(11)
                  .minFontSize(11)
                  .color(AppColor.neutral)
                  .make(),
            ],
            AnimatedCrossFade(
              duration: 180.milliseconds,
              crossFadeState: isExpanded.value
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: 0.heightBox,
              secondChild: VStack([
                if (upcoming.isNotEmpty) ...[
                  Divider(color: AppColor.border).pSymmetric(v: 8),
                  HStack([
                    Icon(
                      UIconsPro.solidRounded.calendar_clock,
                      size: 12,
                      color: AppColor.blue,
                    ).pOnly(right: 8),
                    'Upcoming'.text.bold.size(11).make(),
                  ]).pOnly(bottom: 6),
                  ...upcoming.map((item) {
                    final dueText = item.remainingDays == 0
                        ? 'today'
                        : '${item.remainingDays}d';
                    return HStack([
                      '${item.note}'.text
                          .size(11)
                          .ellipsis
                          .maxLines(1)
                          .make()
                          .expand(),
                      '${item.amount.moneyFormatCompact()} · $dueText'.text
                          .size(10)
                          .minFontSize(10)
                          .color(AppColor.neutral)
                          .make()
                          .pOnly(left: 8),
                    ]).pOnly(bottom: 4);
                  }),
                ],
                if (unbudgeted.isNotEmpty) ...[
                  Divider(color: AppColor.border).pSymmetric(v: 8),
                  HStack([
                    Icon(
                      UIconsPro.solidRounded.triangle_warning,
                      size: 12,
                      color: AppColor.red,
                    ).pOnly(right: 8),
                    'Unbudgeted'.text.bold.size(11).make(),
                  ]).pOnly(bottom: 6),
                  ...unbudgeted.map((item) {
                    return HStack([
                      Icon(
                        item.key.icon ?? Icons.circle_outlined,
                        size: 11,
                        color: item.key.color,
                      ).pOnly(right: 6),
                      item.key.label.text
                          .size(11)
                          .ellipsis
                          .maxLines(1)
                          .make()
                          .expand(),
                      item.value
                          .moneyFormatCompact()
                          .text
                          .size(10)
                          .minFontSize(10)
                          .color(AppColor.neutral)
                          .make()
                          .pOnly(left: 8),
                    ]).pOnly(bottom: 4);
                  }),
                ],
              ]),
            ),
          ],
        ).p12(),
      ),
    );
  }

  Widget bodyContent() {
    return ExSwipe(
      onLeftSwipe: (detail) async {
        controller.focusedDay.value = controller.focusedDay.value.add(1.days);
        await controller.onCalenderDayChange(
          controller.focusedDay.value,
          controller.focusedDay.value,
        );
      },
      onRightSwipe: (detail) async {
        controller.focusedDay.value = controller.focusedDay.value.subtract(
          1.days,
        );
        await controller.onCalenderDayChange(
          controller.focusedDay.value,
          controller.focusedDay.value,
        );
      },
      child: controller.obx(
        (state) => Obx(
          () => VStack(
            [
              /// header
              Obx(
                () => controller.isSearchMode.isFalse
                    // normal view
                    ? bodyHeaderBasicView()
                    // search mode view
                    : bodyHeaderSearchView(),
              ).pSymmetric(h: 12).pOnly(top: 12),

              /// item
              Obx(
                () => controller.isSearchMode.isFalse
                    // normal view
                    ? bodyItemBasicView()
                    // search mode view
                    : bodyItemSearchView(),
              ),

              /// sum
              HStack([
                'Total:'.text.bold.color(AppColor.textReverse).make(),
                Spacer(),
                '${controller.countOfDay.value.moneyFormat()}'.text.bold
                    .color(AppColor.textReverse)
                    .make()
                    .onInkTap(() {
                      HelperOverlay.openCalculator(
                        initialValue: controller.countOfDay.value.toDouble(),
                        onTappedDisplay: (p0, p1) => Overlayment.dismissAll(),
                      );
                    }),
              ]).p12().color(AppColor.primary.withAlpha(30)),
            ],
          ),
        ),
        onLoading: MyShimmerHome(),
        onEmpty: VStack([
          emptyHeaderView(),
          Divider(),
          emptyBodyView(),
        ]).p12(),
        onError: (e) => ExUiErrorOrEmpty(
          illustration: Icon(CupertinoIcons.wifi_slash),
          title: 'Offline',
          message: '$e',
          bgColor: AppColor.emptyStatePrimary,
        ),
      ),
    );
  }

  Widget bodyHeaderBasicView() {
    return HStack(
      [
        Container(
          color: AppColor.primary,
          height: 28,
          child: '${controller.focusedDay.value.toStringEx(format: 'E')}'.text
              .size(11)
              .bold
              .color(AppColor.textOnBackground)
              .makeCentered()
              .pSymmetric(h: 4, v: 2),
        ).cornerRadius(4).pOnly(right: 10),
        VStack([
          '${controller.focusedDay.value.toStringEx(format: 'dd MMM y')}'.text
              .size(12)
              .bold
              .make(),
          '${controller.focusedDay.value.getTimeAgoFromNow()}'.text
              .size(11)
              .minFontSize(11)
              .make(),
        ]),
        Spacer(),
        CustomPopup(
          content: Obx(
            () => VStack(
              [
                if (controller.countOfDay.value.getFlagText() == 'Eco') ...[
                  'Your score of spend this day'.text
                      .color(AppColor.textOnWhiteBackground)
                      .make(),
                  Divider(thickness: 0.3).w(200),
                  'Usage: ${controller.countOfDay.value.moneyFormatCompact()} of ${controller.userProfile.value.ecoDay?.moneyFormatCompact()}'
                      .text
                      .size(12)
                      .black
                      .make()
                      .pOnly(bottom: 2),
                  'Remaining: ${(controller.userProfile.value.ecoDay! - controller.countOfDay.value).moneyFormatCompact()}'
                      .text
                      .size(12)
                      .green700
                      .make(),
                ],

                if (controller.countOfDay.value.getFlagText() == 'Average') ...[
                  'Your score of spend this day'.text
                      .color(AppColor.textOnWhiteBackground)
                      .make(),
                  Divider(thickness: 0.3).w(200),
                  'Usage: ${controller.countOfDay.value.moneyFormatCompact()} of ${controller.userProfile.value.averageDay?.moneyFormatCompact()}'
                      .text
                      .size(12)
                      .black
                      .make()
                      .pOnly(bottom: 2),
                  'Remaining: ${(controller.userProfile.value.averageDay! - controller.countOfDay.value).moneyFormatCompact()}'
                      .text
                      .size(12)
                      .green700
                      .make(),
                ],

                if (controller.countOfDay.value.getFlagText() == 'Spender') ...[
                  'Your score of spend this day'.text
                      .color(AppColor.textOnWhiteBackground)
                      .make(),
                  Divider(thickness: 0.3).w(200),
                  'Usage: ${controller.countOfDay.value.moneyFormatCompact()} of ${controller.userProfile.value.spenderDay?.moneyFormatCompact()}'
                      .text
                      .size(12)
                      .black
                      .make()
                      .pOnly(bottom: 2),
                  'Minus: ${(controller.userProfile.value.spenderDay! - controller.countOfDay.value).moneyFormat()}'
                      .text
                      .size(12)
                      .red500
                      .make(),
                ],
              ],
            ),
          ),
          child: Container(
            decoration: ExDecorator.box(
              borderRadius: 90,
              borderColor: controller.countOfDay.value.getFlagColorLight(),
            ),
            child: '${controller.countOfDay.value.getFlagText()} Day'
                //
                .text
                .size(12)
                .minFontSize(12)
                .color(controller.countOfDay.value.getFlagColorLight())
                .make()
                .p4()
                .pSymmetric(h: 4),
          ),
        ),
      ],
    ).pOnly(bottom: 12);
  }

  Widget bodyHeaderSearchView() {
    final searchText = controller.tfSearchExpense.value.text;

    /// date range
    if (searchText.startsWith(RegExp(r'[0-9]'))) {
      //
      if (searchText.isNotEmpty && searchText.length <= 3) {
        final startDate = DateTime.now()
            .subtract(Duration(days: searchText.toInt()! - 1))
            .toStringEx(format: 'd MMM y');
        final endDate = DateTime.now().toStringEx(format: 'd MMM y');
        return Container(
          decoration: ExDecorator.box(
            borderRadius: 4,
            borderColor: AppColor.border,
          ),
          width: double.infinity,
          child: VStack(
            [
              HStack([
                'Showing data:'.text.bold.make().pOnly(right: 8),
                '$searchText days from today'.text.size(12).make(),
              ]),
              '🗓️ ($startDate → $endDate)'.text
                  .size(11)
                  .minFontSize(11)
                  .make()
                  .pOnly(top: 4),
            ],
          ).p8(),
        );
      } else {
        try {
          final startDate = searchText
              .substring(0, 10)
              .reformatDate(from: yMd, to: 'd MMM y');
          final endDate = searchText
              .substring(11)
              .reformatDate(from: yMd, to: 'd MMM y');
          return Container(
            decoration: ExDecorator.box(
              borderRadius: 4,
              borderColor: AppColor.border,
            ),
            width: double.infinity,
            child: VStack([
              'Showing for date range:'.text.bold.make().pOnly(bottom: 4),
              '🗓️ $startDate → $endDate'.text.size(12).make(),
            ]).p8(),
          );
        } catch (e) {
          HelperErrorLog.record(
            page: 'homeView',
            action: 'bodyHeaderSearchView',
            stack: e.toString(),
          );
          return '$searchText'.text.make();
        }
      }
    }

    /// text @note / @category
    return VStack(
      [
        Container(
          decoration: ExDecorator.box(
            borderRadius: 4,
            borderColor: AppColor.border,
          ),
          child: HStack(
            [
              'Search For: `${controller.tfSearchExpense.value.text}`'.text.bold
                  .make(),
              Spacer(),
              'Filter'.text.size(8).underline.make().onInkTap(() {
                DialogExpense.openAdvenceFilter(
                  controller.tfSearchExpense.value.text,
                );
              }),
            ],
          ).p8(),
        ).pOnly(bottom: 8),
        controller.isAdvanceSearch.isTrue
            ? '${controller.advanceSearchText}'.text
                  .size(12)
                  .minFontSize(12)
                  .make()
            : 0.heightBox,
      ],
    ).pOnly(bottom: 12);
  }

  Widget expenseImageThumbnail(SupaExpense item) {
    if (item.imageUrl.isEmptyOrNull) return 0.heightBox;

    return ExImageNoCacheView(
      url: item.imageUrl!,
      size: 48,
      radius: 10,
      errorBuilder: (_, _, _) => Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColor.card.withAlpha(80),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 18,
          color: AppColor.neutral,
        ),
      ),
    ).pOnly(right: 12);
  }

  Widget expenseDetailText(String? detail, {required bool isTypeNotes}) {
    if (detail.isEmptyOrNull) return 0.heightBox;

    final text = detail ?? '';
    final urlRegex = RegExp(r'(https?:\/\/[^\s]+|www\.[^\s]+)');
    final baseStyle = TextStyle(
      fontSize: 12,
      color: isTypeNotes
          ? Vx.white
          : Get.isDarkMode
          ? Vx.neutral300
          : Vx.neutral800,
    );
    final linkStyle = baseStyle.copyWith(
      color: AppColor.blue,
      decoration: TextDecoration.underline,
      decorationColor: AppColor.blue,
    );

    final spans = <InlineSpan>[];
    var currentIndex = 0;

    for (final match in urlRegex.allMatches(text)) {
      if (match.start > currentIndex) {
        spans.add(
          TextSpan(
            text: text.substring(currentIndex, match.start),
            style: baseStyle,
          ),
        );
      }

      final rawUrl = match.group(0) ?? '';
      final launchUrl = rawUrl.startsWith('www.') ? 'https://$rawUrl' : rawUrl;
      spans.add(
        TextSpan(
          text: rawUrl,
          style: linkStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () async => await launchUrlString(launchUrl),
        ),
      );
      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex), style: baseStyle));
    }

    return RichText(text: TextSpan(children: spans)).pOnly(bottom: 8);
  }

  Widget bodyItemBasicView() {
    return ListView.builder(
      itemCount: controller.expenseList.length,
      itemBuilder: (context, index) {
        final item = controller.expenseList[index];
        final category = item.resolvedCategory;
        final isTypeNotes =
            category.code == 'expense:misc:notes' ||
            category.label.contains('Notes');

        return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isTypeNotes
                    ? AppColor.noteColor
                    : AppColor.card.withAlpha(50),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Row(
                children: [
                  expenseImageThumbnail(item),
                  VStack([
                    /// note
                    HStack([
                      '${item.note}'.text.bold
                          .color(isTypeNotes ? Vx.white : AppColor.textReverse)
                          .make(),
                      if (!isTypeNotes) ...[
                        Icon(
                          CupertinoIcons.time,
                          size: 10,
                        ).pOnly(left: 8, right: 2, top: 2),
                        '(${item.createdAt?.reformatDate(to: 'HH:mm')})'.text
                            .size(10)
                            .minFontSize(10)
                            .make(),
                      ],
                    ]).pOnly(bottom: 8),

                    /// detail
                    expenseDetailText(item.detail, isTypeNotes: isTypeNotes),

                    /// category
                    HStack([
                      Icon(
                        category.icon ?? Icons.circle_outlined,
                        color: category.color,
                        size: 12,
                      ).pOnly(right: 8),
                      '${category.label}'
                          //
                          .text
                          .size(12)
                          .color(isTypeNotes ? Vx.white : AppColor.textReverse)
                          .ellipsis
                          .make()
                          .expand(),

                      isTypeNotes
                          ? '${item.createdAt?.reformatDate(to: 'HH:mm')}'
                                .text
                                .white
                                .size(11)
                                .minFontSize(11)
                                .make()
                          : 0.heightBox,
                    ]),
                  ]).expand(),

                  /// amount
                  isTypeNotes
                      ? 0.heightBox
                      : '${item.amount?.moneyFormat()}'.text.bold
                            .size(16)
                            .make(),
                ],
              ).p12(),
            )
            .pSymmetric(h: 8, v: 4)
            .onInkTap(() => DialogExpense.openManualInput(expense: item));
      },
    ).pSymmetric(v: 8).expand();
  }

  Widget bodyItemSearchView() {
    return GroupedListView<SupaExpense, String>(
      elements: controller.expenseList,
      groupBy: (element) => element.date ?? '',
      useStickyGroupSeparators: true,
      floatingHeader: true,
      order: GroupedListOrder.DESC,
      groupHeaderBuilder: (item) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Get.isDarkMode ? Color(0xFF19151F) : Colors.white,
          ),
          child: HStack(
            [
              '${item.date!.reformatDate(from: yMd, to: '(E) dd MMM y')}'.text
                  .size(11)
                  .bold
                  .make(),
              Spacer(),
              '(${item.date!.toDateEx(format: yMd).getTimeAgoFromNow()})'.text
                  .minFontSize(11)
                  .size(11)
                  .make(),
            ],
          ).p8(),
        ).onTap(
          () async => await controller.onCalenderGoDate(
            item.date!.toDateEx(format: yMd),
          ),
        );
      },
      indexedItemBuilder: (context, item, index) {
        final category = item.resolvedCategory;
        final isTypeNotes =
            category.code == 'expense:misc:notes' ||
            category.label.contains('Notes');
        return Container(
              decoration: BoxDecoration(
                color: isTypeNotes
                    ? AppColor.noteColor
                    : AppColor.card.withAlpha(50),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              width: double.infinity,
              child: Row(
                children: [
                  expenseImageThumbnail(item),
                  VStack([
                    /// note
                    '${item.note}'.text.bold
                        .color(isTypeNotes ? Vx.white : AppColor.textReverse)
                        .make()
                        .pOnly(bottom: 8),

                    /// detail
                    expenseDetailText(item.detail, isTypeNotes: isTypeNotes),

                    /// category
                    HStack([
                      Icon(
                        category.icon ?? Icons.circle_outlined,
                        size: 12,
                        color: category.color,
                      ).pOnly(right: 8),
                      '${category.label}'.text
                          .color(isTypeNotes ? Vx.white : AppColor.textReverse)
                          .size(12)
                          .ellipsis
                          .make()
                          .expand(),
                      isTypeNotes
                          ? '(${item.createdAt?.reformatDate(to: 'HH:mm')})'
                                .text
                                .white
                                .size(11)
                                .minFontSize(11)
                                .make()
                          : 0.heightBox,
                    ]),
                  ]).expand(),

                  /// amount
                  isTypeNotes
                      ? 0.heightBox
                      : '${item.amount?.moneyFormat()}'.text.bold
                            .size(16)
                            .make()
                            .pOnly(left: 12),
                ],
              ).p12(),
            )
            .pSymmetric(h: 8, v: 8)
            .onInkTap(() => DialogExpense.openManualInput(expense: item));
      },
    ).pSymmetric(v: 12).expand();
  }

  Widget emptyHeaderView() {
    return Obx(
      () => HStack(
        [
          if (controller.tfSearchExpense.value.text.isNotBlank) ...[
            'Search for: "${controller.tfSearchExpense.value.text}"'.text
                .make(),
          ] else ...[
            Container(
              color: AppColor.primary,
              height: 28,
              child: '${controller.focusedDay.value.toStringEx(format: 'E')}'
                  .text
                  .size(11)
                  .bold
                  .color(AppColor.textOnBackground)
                  .makeCentered()
                  .pSymmetric(h: 4, v: 2),
            ).cornerRadius(4).pOnly(right: 10),
            VStack([
              '${controller.focusedDay.value.toStringEx(format: 'dd MMM y')}'
                  .text
                  .size(12)
                  .bold
                  .make(),
              '${controller.focusedDay.value.getTimeAgoFromNow()}'.text
                  .size(11)
                  .minFontSize(11)
                  .make(),
            ]),
            Spacer(),
            Container(
              decoration: ExDecorator.box(
                borderRadius: 90,
                borderColor: AppColor.textReverse,
              ),
              child: 'No Record'.text
                  .size(12)
                  .minFontSize(12)
                  .color(AppColor.textReverse)
                  .make()
                  .p4()
                  .pSymmetric(h: 4),
            ),
          ],
        ],
      ).pOnly(bottom: 12),
    );
  }

  Widget emptyBodyView() {
    return ExUiErrorOrEmpty(
      bgColor: Theme.of(Get.context!).scaffoldBackgroundColor,
      illustration: Column(
        children: [
          Get
                  .context!
                  .isMobile //
              ? Image.asset(
                  'assets/icons/app_icon.png',
                  width: 56,
                  height: 56,
                ).pOnly(bottom: 16)
              : Lottie.asset(
                  'assets/lottie/empty.json',
                  width: 150,
                  reverse: true,
                ),
          'No Expense'.text.bold
              .align(TextAlign.center)
              .make()
              .pOnly(bottom: 8),
          Obx(
            () =>
                '${controller.tfSearchExpense.value.text.isNotEmptyAndNotNull //
                        ? '"${controller.tfSearchExpense.value.text}" Not found' //
                          : ' in ${controller.focusedDay.value.toStringEx(format: 'dd MMM y')}'} '
                    .text
                    .neutral500
                    .size(11)
                    .align(TextAlign.center)
                    .makeCentered(),
          ),
          16.heightBox,
          ExButtonOutline(
            label: 'Add Expense',
            labelSize: 12,
            labelColor: AppColor.textReverse,
            onPressed: () => DialogExpense.openAIInput(),
          ),
        ],
      ),
    ).pOnly(bottom: Get.context!.isMobile ? 0 : 90).expand();
  }

  Widget footerContent() {
    return HStack([
      Obx(
        () => CustomPopup(
          content: VStack([
            '${controller.userProfile.value.fullName} (${controller.userProfile.value.age})'
                .text
                .size(12)
                .black
                .bold
                .make(),
            Divider().w(180),
            'Balance   : ${controller.userProfile.value.balance}'.text
                .size(12)
                .black
                .make(),
            'Income    : ${controller.userProfile.value.income}'.text
                .size(12)
                .black
                .make(),
            'LastUpd. : ${controller.userProfile.value.updatedAt?.reformatDate(to: 'dd MMM y, HH:mm')}'
                .text
                .size(12)
                .black
                .make(),
          ]), //.onTap(() => controller.goSetting()),
          child: ExAvatarView(
            source: controller.userProfile.value.avatarUrl ?? '',
            name: controller.userProfile.value.fullName ?? '',
            size: 32,
          ),
        ),
      ),

      Obx(
        () => '${controller.footerStatus}'.text.ellipsis
            .size(12)
            .make()
            .tooltip(controller.footerStatus.value)
            .pOnly(left: 8, right: 12),
      ).expand(),
      Obx(
        () =>
            '${controller.focusedDay.value.toStringEx(format: 'MMM')}: ${controller.countOfMonth.value.moneyFormat()}' //
                .text
                .make()
                .onTap(() => controller.goSummary()),
      ),
    ]).p12().pOnly(bottom: isMobileWeb ? 12 : 0);
  }

  Widget floatingActionButton() {
    return Obx(
      () => controller.expenseList.isNotEmpty
          ? FloatingActionButton(
              mini: true,
              backgroundColor: AppColor.primary,
              child: Icon(CupertinoIcons.add, color: Colors.white),
              onPressed: () => DialogExpense.openAIInput(),
            ).pOnly(bottom: Get.context!.isMobile ? 90 : 68)
          : 0.heightBox,
    );
  }
}
