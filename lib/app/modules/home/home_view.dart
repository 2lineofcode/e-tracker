import 'package:animated_icon/animated_icon.dart';
import 'package:ex_kit/ex.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:overlayment/overlayment.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../core/app_api.dart';
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

  String _dateDistanceLabel(DateTime date) {
    final days = DateUtils.dateOnly(date)
        .difference(DateUtils.dateOnly(DateTime.now()))
        .inDays;
    if (days == 0) return 'Hari ini';
    if (days == 1) return 'Besok';
    if (days == -1) return 'Kemarin';
    return days > 0 ? '$days hari lagi' : '${days.abs()} hari lalu';
  }

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
    return LayoutBuilder(
      builder: (context, constraints) => RawAutocomplete<_SearchOption>(
        textEditingController: controller.tfSearchExpense.value,
        focusNode: controller.searchFocusNode,
        displayStringForOption: (option) => option.input,
        optionsBuilder: (value) => searchOptions(value.text),
        onSelected: (option) {
          if (option.submit) {
            controller.getExpense(find: option.query);
          } else {
            controller.searchFocusNode.requestFocus();
          }
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              color: AppColor.appbarPrimary,
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: AppColor.border),
              ),
              child: SizedBox(
                width: constraints.maxWidth,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 280),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(vertical: 6),
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: HStack([
                          Icon(
                            option.icon,
                            size: 14,
                            color: option.color,
                          ).pOnly(right: 10),
                          option.label.text
                              .size(12)
                              .ellipsis
                              .make()
                              .expand(),
                          if (option.suffix != null)
                            '${option.suffix}'.text
                                .size(11)
                                .color(AppColor.neutral)
                                .make(),
                        ]).pSymmetric(h: 12, v: 10),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
        fieldViewBuilder: (
          context,
          textController,
          focusNode,
          onFieldSubmitted,
        ) {
          return ValueListenableBuilder<TextEditingValue>(
            valueListenable: textController,
            builder: (context, value, child) => TextField(
              controller: textController,
              focusNode: focusNode,
              style: TextStyle(fontSize: 13),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                filled: true,
                fillColor: Get.isDarkMode ? AppColor.card : Colors.white,
                hintText: '@ Kategori · # Tanggal · \$ Minimal · ? Note',
                hintStyle: TextStyle(fontSize: 12, color: AppColor.neutral),
                prefixIcon: Icon(
                  UIconsPro.regularRounded.search,
                  size: 15,
                  color: AppColor.neutral,
                ),
                prefixIconConstraints: BoxConstraints(minWidth: 40),
                suffixIcon: value.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Bersihkan',
                        icon: Icon(
                          UIconsPro.solidRounded.cross_small,
                          size: 14,
                        ),
                        onPressed: () async {
                          textController.clear();
                          await controller.getExpense();
                          focusNode.requestFocus();
                        },
                      ),
                suffixIconConstraints: BoxConstraints(minWidth: 38),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColor.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColor.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColor.primary),
                ),
              ),
              onSubmitted: (value) {
                if (searchOptions(value).isNotEmpty) {
                  onFieldSubmitted();
                } else {
                  submitSearch(value);
                }
              },
            ).h(38),
          );
        },
      ),
    );
  }

  // ignore: library_private_types_in_public_api
  Iterable<_SearchOption> searchOptions(String value) {
    final text = value.trimLeft();
    if (text.isEmpty) {
      return [
        _SearchOption.command(
          label: 'Kategori',
          input: '@',
          icon: CupertinoIcons.square_grid_2x2,
          color: AppColor.primary,
        ),
        _SearchOption.command(
          label: 'Tanggal',
          input: '#',
          icon: CupertinoIcons.calendar,
          color: AppColor.blue,
        ),
        _SearchOption.command(
          label: 'Nominal ≥',
          input: r'$',
          icon: CupertinoIcons.money_dollar_circle,
          color: AppColor.green,
        ),
        _SearchOption.command(
          label: 'Note',
          input: '?',
          icon: CupertinoIcons.text_quote,
          color: AppColor.orange,
        ),
      ];
    }

    if (text.startsWith('@')) {
      final query = text.substring(1).toLowerCase();
      return controller.categoryList
          .where((category) {
            return category.label.toLowerCase().contains(query) ||
                category.groupLabel.toLowerCase().contains(query) ||
                category.code.toLowerCase().contains(query);
          })
          .map(
            (category) => _SearchOption(
              label: category.label,
              input: '@${category.label}',
              query: '@${category.code}',
              icon: category.icon,
              color: category.color,
              suffix: '@',
            ),
          );
    }

    if (text.startsWith('#')) {
      final query = text.substring(1).toLowerCase();
      return [
        _SearchOption(
          label: 'Hari ini',
          input: '#today',
          query: '#today',
          icon: CupertinoIcons.today,
          color: AppColor.blue,
          suffix: '#today',
        ),
        _SearchOption(
          label: '7 hari',
          input: '#7',
          query: '#7',
          icon: CupertinoIcons.calendar,
          color: AppColor.orange,
          suffix: '#7',
        ),
        _SearchOption(
          label: '30 hari',
          input: '#30',
          query: '#30',
          icon: CupertinoIcons.calendar,
          color: AppColor.orange,
          suffix: '#30',
        ),
        _SearchOption(
          label: 'Bulan ini',
          input: '#month',
          query: '#month',
          icon: CupertinoIcons.calendar_today,
          color: AppColor.green,
          suffix: '#month',
        ),
      ].where((option) {
        return option.label.toLowerCase().contains(query) ||
            option.input.substring(1).contains(query);
      });
    }

    if (text.startsWith(r'$')) {
      final query = text.substring(1).replaceAll(RegExp(r'[^0-9]'), '');
      return [10000, 50000, 100000, 500000, 1000000]
          .where((amount) => '$amount'.startsWith(query))
          .map(
            (amount) => _SearchOption(
              label: '≥ ${amount.moneyFormat()}',
              input: '\$$amount',
              query: '\$$amount',
              icon: CupertinoIcons.money_dollar_circle,
              color: AppColor.green,
              suffix: '\$$amount',
            ),
          );
    }

    if (text.startsWith('?')) {
      final query = text.substring(1).toLowerCase();
      final notes = controller.expenseList
          .map((expense) => expense.note?.trim() ?? '')
          .where(
            (note) =>
                note.isNotEmpty && note.toLowerCase().contains(query),
          )
          .toSet();

      if (notes.isEmpty) {
        if (query.isNotEmpty) return const [];
        return [
          _SearchOption.command(
            label: 'Ketik note atau detail',
            input: text,
            icon: CupertinoIcons.text_quote,
            color: AppColor.orange,
          ),
        ];
      }

      return notes.map(
        (note) => _SearchOption(
          label: note,
          input: '?$note',
          query: '?$note',
          icon: CupertinoIcons.text_quote,
          color: AppColor.orange,
          suffix: '?',
        ),
      );
    }

    return const [];
  }

  Future<void> submitSearch(String value) async {
    final query = value.trim();
    await controller.getExpense(find: query.isEmpty ? null : query);
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
              onGoDate: controller.onCalenderGoDate,
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
                  final recurring = controller.recurringExpensesForDay(day);
                  if (events.isNotEmpty || recurring.isNotEmpty) {
                    var total = 0;
                    for (var event in events) total += event.toInt()!;
                    return HStack([
                      if (events.isNotEmpty)
                        Icon(
                          Icons.circle,
                          size: 6,
                          color: total.getFlagColor(),
                        ),
                      if (events.isNotEmpty && recurring.isNotEmpty)
                        2.widthBox,
                      if (recurring.isNotEmpty)
                        Icon(
                          Icons.circle,
                          size: 6,
                          color: AppColor.blue,
                        ).tooltip(
                          'Tagihan: ${recurring.map((item) => item.note).join(', ')}',
                        ),
                    ]).positioned(top: 8, right: 8);
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
            '::Fitur'.text.size(12).bold.make().pOnly(top: 2, bottom: 12),

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
                    'Total Hari Boros'.text.size(12).make(),
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
                    title: 'Budget',
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
                    title: 'Aset',
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
                    title: 'Goal',
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
                    title: 'Note',
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
                  count: 'Buka',
                  ontap: () => Get.toNamed(Routes.CALCP),
                ).pOnly(bottom: 12),

                // :7:
                buildTools(
                  title: 'Alat',
                  icon: Icon(
                    UIconsPro.solidRounded.box,
                    size: 14,
                    color: Color.fromARGB(255, 171, 160, 243),
                  ),
                  count: 'Buka',
                  ontap: () => Get.toNamed(Routes.TOOLS),
                ).pOnly(bottom: 12),

                // :666:
                Obx(
                  () =>
                      buildTools(
                            title: 'SQL Editor',
                            icon: Icon(
                              UIconsPro.solidRounded.database,
                              size: 14,
                              color: Color.fromARGB(255, 123, 99, 196),
                            ),
                            count: 'Buka',
                            ontap: () => Get.toNamed(Routes.SQL_EDITOR),
                          )
                          .pOnly(bottom: 12)
                          .hide(
                            isVisible:
                                controller.userProfile.value.username ==
                                'abehbatre',
                          ),
                ),

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
          'High Spending'.text.black.bold.size(12).make(),
          'ada ${list.length} hari nih'.text.size(10).minFontSize(10).color(Vx.neutral500).make(),
        ]).expand(),
      ]).pOnly(bottom: 8),

      if (list.isEmpty) ...[
        'Belum ada hari boros'.text.size(11).color(Vx.neutral500).makeCentered().pSymmetric(v: 12),
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
              (controller.isFocusedCurrentMonth
                      ? 'Proyeksi+'
                      : 'Ringkasan Budget')
                  .text
                  .bold
                  .size(12)
                  .make()
                  .expand(),
              if (controller.budgetWarningCount > 0)
                '${controller.budgetWarningCount} risiko'.text
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
            if (controller.noSpendStreak > 0)
              HStack([
                '${controller.noSpendStreak} hari no-spend'.text
                    .size(10)
                    .minFontSize(10)
                    .color(AppColor.green)
                    .make()
                    .pSymmetric(h: 7, v: 3)
                    .box
                    .color(AppColor.green.withAlpha(22))
                    .make()
                    .cornerRadius(90),
              ]).pOnly(bottom: 8),
            if (controller.hasCurrentMonthCashflow) ...[
              HStack([
                'Sisa sampai gajian'.text
                    .size(11)
                    .minFontSize(11)
                    .color(AppColor.neutral)
                    .make()
                    .expand(),
                controller.cashAfterScheduledBills
                    .moneyFormatCompact()
                    .text
                    .bold
                    .size(12)
                    .color(
                      controller.cashAfterScheduledBills >= 0
                          ? AppColor.green
                          : AppColor.red,
                    )
                    .make(),
              ]).pOnly(bottom: 4),
              HStack([
                '${controller.daysUntilPayday} hari · ${controller.nextPayday.toStringEx(format: 'dd MMM')}'
                    .text
                    .size(10)
                    .minFontSize(10)
                    .color(AppColor.neutral)
                    .make()
                    .expand(),
                '${controller.safeDailyUntilPayday.moneyFormatCompact()}/hari'
                    .text
                    .size(10)
                    .minFontSize(10)
                    .color(
                      controller.safeDailyUntilPayday >= 0
                          ? AppColor.green
                          : AppColor.red,
                    )
                    .make(),
              ]).pOnly(bottom: 8),
              Divider(color: AppColor.border).pOnly(bottom: 8),
            ],
            if (hasBudget) ...[
              HStack([
                (controller.isFocusedCurrentMonth
                        ? 'Proyeksi outcome'
                        : 'Total outcome')
                    .text
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
              if (controller.isFocusedCurrentMonth)
                HStack([
                  'Batas aman harian'.text
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
              (controller.isFocusedCurrentMonth
                      ? isOverProjection
                            ? 'Terlalu cepat ${controller.projectedBudgetDelta.abs().moneyFormatCompact()}'
                            : 'Budget masih aman, sisa ${controller.projectedBudgetDelta.moneyFormatCompact()}'
                      : isOverProjection
                      ? 'Lewat budget ${controller.projectedBudgetDelta.abs().moneyFormatCompact()}'
                      : 'Sisa budget ${controller.projectedBudgetDelta.moneyFormatCompact()}')
                  .text
                  .size(10)
                  .minFontSize(10)
                  .color(isOverProjection ? AppColor.red : AppColor.green)
                  .make(),
            ] else ...[
              'Atur budget kategori untuk melihat proyeksi.'.text
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
                    'Tagihan Mendatang'.text.bold.size(11).make(),
                  ]).pOnly(bottom: 6),
                  ...upcoming.map((item) {
                    final dueText = item.remainingDays == 0
                        ? 'hari ini'
                        : '${item.remainingDays} hari';
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
                    'Belum dianggarkan'.text.bold.size(11).make(),
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
          title: 'Sedang offline',
          message: '$e',
          bgColor: AppColor.emptyStatePrimary,
        ),
      ),
    );
  }

  Widget bodyHeaderBasicView() {
    final flagLabel = switch (controller.countOfDay.value.getFlagText()) {
      'Hemat' => 'Hari hemat',
      'Biasa' => 'Hari biasa',
      'Boros' => 'Hari boros',
      final label => label,
    };

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
          _dateDistanceLabel(controller.focusedDay.value).text
              .size(11)
              .minFontSize(11)
              .make(),
        ]),
        Spacer(),
        CustomPopup(
          content: Obx(
            () => VStack(
              [
                if (controller.countOfDay.value.getFlagText() == 'Hemat') ...[
                  'Pengeluaran hari ini'.text
                      .color(AppColor.textOnWhiteBackground)
                      .make(),
                  Divider(thickness: 0.3).w(200),
                  'Terpakai ${controller.countOfDay.value.moneyFormatCompact()} dari ${controller.userProfile.value.ecoDay?.moneyFormatCompact()}'
                      .text
                      .size(12)
                      .black
                      .make()
                      .pOnly(bottom: 2),
                  'Sisa ${(controller.userProfile.value.ecoDay! - controller.countOfDay.value).moneyFormatCompact()}'
                      .text
                      .size(12)
                      .green700
                      .make(),
                ],

                if (controller.countOfDay.value.getFlagText() == 'Biasa') ...[
                  'Pengeluaran hari ini'.text
                      .color(AppColor.textOnWhiteBackground)
                      .make(),
                  Divider(thickness: 0.3).w(200),
                  'Terpakai ${controller.countOfDay.value.moneyFormatCompact()} dari ${controller.userProfile.value.averageDay?.moneyFormatCompact()}'
                      .text
                      .size(12)
                      .black
                      .make()
                      .pOnly(bottom: 2),
                  'Sisa ${(controller.userProfile.value.averageDay! - controller.countOfDay.value).moneyFormatCompact()}'
                      .text
                      .size(12)
                      .green700
                      .make(),
                ],

                if (controller.countOfDay.value.getFlagText() == 'Boros') ...[
                  'Pengeluaran hari ini'.text
                      .color(AppColor.textOnWhiteBackground)
                      .make(),
                  Divider(thickness: 0.3).w(200),
                  'Terpakai ${controller.countOfDay.value.moneyFormatCompact()} dari ${controller.userProfile.value.spenderDay?.moneyFormatCompact()}'
                      .text
                      .size(12)
                      .black
                      .make()
                      .pOnly(bottom: 2),
                  'Selisih ${(controller.userProfile.value.spenderDay! - controller.countOfDay.value).moneyFormat()}'
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
            child: flagLabel
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
                'Menampilkan:'.text.bold.make().pOnly(right: 8),
                '$searchText hari terakhir'.text.size(12).make(),
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
              'Rentang tanggal:'.text.bold.make().pOnly(bottom: 4),
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
              'Cari: `${controller.tfSearchExpense.value.text}`'.text.bold
                  .make(),
              Spacer(),
              if (!searchText.startsWith('#'))
                'Atur filter'.text.size(8).underline.make().onInkTap(() {
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
    if (item.imagePath.isEmptyOrNull) return 0.heightBox;

    return FutureBuilder<String>(
      future: db.storage
          .from('expense-images')
          .createSignedUrl(item.imagePath!, 300),
      builder: (_, snapshot) => ExImageNoCacheView(
        url: snapshot.data ?? '',
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
            category.label.contains('Note');

        return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isTypeNotes
                    ? AppColor.noteColor
                    : AppColor.card,
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
                          .ellipsis
                          .make()
                          .expand(),
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
                      : HStack([
                          IconButton(
                            tooltip: 'Ulangi transaksi',
                            visualDensity: VisualDensity.compact,
                            icon: Icon(CupertinoIcons.doc_on_doc, size: 14),
                            onPressed: () => DialogExpense.repeatExpense(item),
                          ),
                          '${item.amount?.moneyFormat()}'.text.bold
                              .size(16)
                              .make(),
                        ]),
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
            color: AppColor.card,
          ),
          child: HStack(
            [
              '${item.date!.reformatDate(from: yMd, to: '(E) dd MMM y')}'.text
                  .size(11)
                  .bold
                  .make(),
              Spacer(),
              '(${_dateDistanceLabel(item.date!.toDateEx(format: yMd))})'.text
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
            category.label.contains('Note');
        return Container(
              decoration: BoxDecoration(
                color: isTypeNotes
                    ? AppColor.noteColor
                    : AppColor.card,
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
                      : HStack([
                          IconButton(
                            tooltip: 'Ulangi transaksi',
                            visualDensity: VisualDensity.compact,
                            icon: Icon(CupertinoIcons.doc_on_doc, size: 14),
                            onPressed: () => DialogExpense.repeatExpense(item),
                          ),
                          '${item.amount?.moneyFormat()}'.text.bold
                              .size(16)
                              .make(),
                        ]).pOnly(left: 12),
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
            'Hasil pencarian: "${controller.tfSearchExpense.value.text}"'.text
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
              _dateDistanceLabel(controller.focusedDay.value).text
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
              child: 'Belum ada data'.text
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
    return Obx(() {
      final search = controller.tfSearchExpense.value.text;
      if (search.isNotEmpty) {
        return ExUiErrorOrEmpty(
          bgColor: Theme.of(Get.context!).scaffoldBackgroundColor,
          title: 'Tidak ditemukan',
          message: '"$search"',
        ).expand();
      }

      final totals = controller.focusedMonthDailyTotals;
      final total = totals.fold<num>(0, (sum, amount) => sum + amount);
      final stats = monthlyExpenseStats(totals);
      final weeks = weeklyExpenseTotals(totals);

      return VStack([
        Container(
          decoration: ExDecorator.box(
            borderRadius: 8,
            borderColor: AppColor.border,
            fillColor: AppColor.card,
          ),
          child: VStack([
            HStack([
              'Pengeluaran ${controller.focusedPeriodLabel}'
                  .text
                  .bold
                  .size(12)
                  .make()
                  .expand(),
              total.moneyFormatCompact().text.bold.size(12).make(),
            ]).pOnly(bottom: 16),
            _emptyMonthChart(totals).h(200),
          ]).p12(),
        ).pOnly(bottom: 12),
        HStack([
          _dashboardMetric(
            icon: CupertinoIcons.calendar,
            label: 'Hari aktif',
            value: '${stats.activeDays}',
          ).expand(),
          8.widthBox,
          _dashboardMetric(
            icon: CupertinoIcons.divide,
            label: 'Rata-rata',
            value: stats.average.moneyFormatCompact(),
          ).expand(),
          8.widthBox,
          _dashboardMetric(
            icon: CupertinoIcons.arrow_up_right,
            label: stats.highestDay == 0
                ? 'Tertinggi'
                : 'Tertinggi · tgl ${stats.highestDay}',
            value: stats.highest.moneyFormatCompact(),
          ).expand(),
        ]).pOnly(bottom: 12),
        _weeklyDashboard(weeks, totals.length),
      ]).p12().scrollVertical().expand();
    });
  }

  Widget _weeklyDashboard(List<num> weeks, int daysInMonth) {
    final maxWeek = weeks.fold<num>(
      0,
      (max, amount) => amount > max ? amount : max,
    );
    return Container(
      decoration: ExDecorator.box(
        borderRadius: 8,
        borderColor: AppColor.border,
        fillColor: AppColor.card,
      ),
      child: VStack([
        HStack([
          Icon(
            CupertinoIcons.chart_bar_alt_fill,
            size: 13,
            color: AppColor.primary,
          ).pOnly(right: 7),
          'Aktivitas mingguan'.text.bold.size(11).make().expand(),
          Icon(
            CupertinoIcons.chevron_right,
            size: 11,
            color: AppColor.neutral,
          ),
        ]).pOnly(bottom: 12).onInkTap(() => controller.goSummary()),
        ...weeks.asMap().entries.map((entry) {
          final start = entry.key * 7 + 1;
          final end = (start + 6).clamp(1, daysInMonth).toInt();
          final percentage = maxWeek <= 0
              ? 0
              : (entry.value / maxWeek * 100).round();
          return VStack([
            HStack([
              'Minggu ${entry.key + 1} · $start–$end'.text
                  .size(9)
                  .minFontSize(9)
                  .color(AppColor.neutral)
                  .make()
                  .expand(),
              entry.value.moneyFormatCompact().text.bold.size(10).make(),
            ]).pOnly(bottom: 4),
            ExProgressBar(
              value: percentage,
              color1: AppColor.primary,
              color2: AppColor.border,
            ).h(4).pOnly(bottom: entry.key == weeks.length - 1 ? 0 : 10),
          ]);
        }),
      ]).p12(),
    );
  }

  Widget _dashboardMetric({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      decoration: ExDecorator.box(
        borderRadius: 8,
        borderColor: AppColor.border,
        fillColor: AppColor.card,
      ),
      child: VStack([
        HStack([
          Icon(icon, size: 11, color: AppColor.primary).pOnly(right: 5),
          label.text
              .size(9)
              .minFontSize(9)
              .color(AppColor.neutral)
              .ellipsis
              .make()
              .expand(),
        ]).pOnly(bottom: 6),
        value.text.bold.size(12).ellipsis.make(),
      ]).p12(),
    );
  }

  Widget _emptyMonthChart(List<num> totals) {
    final maxAmount = totals.fold<num>(
      0,
      (max, amount) => amount > max ? amount : max,
    );
    final chartMax = maxAmount > 0 ? maxAmount.toDouble() * 1.15 : 1.0;
    return LineChart(
      LineChartData(
        minX: 1,
        maxX: totals.length.toDouble(),
        minY: 0,
        maxY: chartMax,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColor.border.withAlpha(90),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: chartMax / 4,
              maxIncluded: false,
              getTitlesWidget: (value, meta) {
                if (value == 0) return SizedBox.shrink();
                return SideTitleWidget(
                  meta: meta,
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
              reservedSize: 22,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                final showStep = index % 5 == 0 && totals.length - index > 2;
                if (index != 1 && !showStep && index != totals.length) {
                  return SizedBox.shrink();
                }
                final date = controller.focusedPeriod.start.add(
                  (index - 1).days,
                );
                return SideTitleWidget(
                  meta: meta,
                  child: '${date.day}'.text
                      .size(9)
                      .minFontSize(9)
                      .color(AppColor.neutral)
                      .make(),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (spot) => AppColor.textReverse,
            getTooltipItems: (spots) => spots.map((spot) {
              final date = controller.focusedPeriod.start.add(
                (spot.x.toInt() - 1).days,
              );
              return LineTooltipItem(
                '${date.toStringEx(format: 'dd MMM')}\n${spot.y.moneyFormat()}',
                TextStyle(
                  color: AppColor.scaffoldPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              totals.length,
              (index) => FlSpot(
                (index + 1).toDouble(),
                totals[index].toDouble(),
              ),
            ),
            isCurved: true,
            barWidth: 2,
            color: AppColor.primary,
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, barData) =>
                  spot.y > 0 ||
                  controller.focusedPeriod.start
                          .add((spot.x.toInt() - 1).days) ==
                      DateUtils.dateOnly(controller.focusedDay.value),
              getDotPainter: (spot, percent, barData, index) {
                final selected =
                    controller.focusedPeriod.start
                            .add((spot.x.toInt() - 1).days) ==
                        DateUtils.dateOnly(controller.focusedDay.value);
                return FlDotCirclePainter(
                  radius: selected ? 4 : 2,
                  color: selected ? AppColor.primary : AppColor.card,
                  strokeWidth: 2,
                  strokeColor: AppColor.primary,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColor.primary.withAlpha(24),
            ),
          ),
        ],
      ),
    );
  }

  Widget footerContent() {
    return HStack([
      Obx(
        () => CustomPopup(
          content: VStack([
            '${controller.userProfile.value.fullName} (${controller.userProfile.value.calculatedAge ?? '-'})'
                .text
                .size(12)
                .black
                .bold
                .make(),
            Divider().w(180),
            'Saldo        : ${controller.userProfile.value.balance?.moneyFormat()}'.text
                .size(12)
                .black
                .make(),
            'Penghasilan : ${controller.userProfile.value.income?.moneyFormat()}'.text
                .size(12)
                .black
                .make(),
            'Diperbarui   : ${controller.userProfile.value.updatedAt?.reformatDate(to: 'dd MMM y, HH:mm')}'
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
            '${controller.focusedPeriodLabel}: ${controller.countOfMonth.value.moneyFormat()}' //
                .text
                .make()
                .onTap(() => controller.goSummary()),
      ),
    ]).p12().pOnly(bottom: isMobileWeb ? 12 : 0);
  }

  Widget floatingActionButton() {
    return FloatingActionButton(
      mini: true,
      tooltip: 'Tambah pengeluaran',
      backgroundColor: AppColor.primary,
      child: Icon(CupertinoIcons.add, color: Colors.white),
      onPressed: () => DialogExpense.openAIInput(),
    ).pOnly(bottom: Get.context!.isMobile ? 90 : 68);
  }
}

class _SearchOption {
  const _SearchOption({
    required this.label,
    required this.input,
    required this.query,
    required this.icon,
    required this.color,
    this.suffix,
  }) : submit = true;

  const _SearchOption.command({
    required this.label,
    required this.input,
    required this.icon,
    required this.color,
  }) : query = '',
       suffix = input,
       submit = false;

  final String label;
  final String input;
  final String query;
  final IconData? icon;
  final Color? color;
  final String? suffix;
  final bool submit;
}
