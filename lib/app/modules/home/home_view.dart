import 'package:animated_icon/animated_icon.dart';
import 'package:ex_kit/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:lottie/lottie.dart';
import 'package:overlayment/overlayment.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/app_color.dart';
import '../../core/const.dart';
import '../../helpers/helpers.dart';
import '../../models/supa_expense_entity.dart';
import '../widgets/widgets.dart';
import 'home_controller.dart';
import 'section_dialog_input.dart';

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
      decoration: DecorationHelper.input(
        fillColor: Get.isDarkMode ? AppColor.card : null,
        prefixIcon: CustomPopup(
          content: VStack([
            ''.richText
                .withTextSpanChildren([
                  'Search Features:\n'.textSpan.size(13).bold.make(),
                  '\n- by "Note", example: "Nasi Padang"'.textSpan.make(),
                  '\n- by "Category", example: "Food"'.textSpan.make(),
                  '\n- by "Days", example: "7"'.textSpan.make(),
                  '\n- by "Date Range", example: "2023-01-01 2023-01-07"'.textSpan.make(),
                ])
                .black
                .size(11)
                .minFontSize(11)
                .make(),
          ]),
          child: Icon(CupertinoIcons.search, size: 14, color: AppColor.textReverse).pOnly(top: 0),
        ),
        hint: 'Search: Note, Category, Days, Date Range...',
        suffix: Icon(CupertinoIcons.clear, size: 12, color: AppColor.textReverse).pOnly(top: 0).onInkTap(() async {
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
      onPressed: () => DialogInputHelper.showDialogExpense(),
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
          onPressed: () => controller.goBibit(),
          icon: Image.asset('assets/icons/ic_robo.png', height: 20, width: 20, color: Get.isDarkMode ? Colors.white.withAlpha(230) : Colors.white),
        ).pOnly(right: 4).hide(),
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
              selectedDayPredicate: (day) => controller.selectedDays.contains(day),
              eventLoader: controller.onCalenderLoadEvent,

              /// custom
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isNotEmpty) {
                    var total = 0;
                    for (var event in events) total += event.toInt()!;
                    return Icon(Icons.circle, size: 6, color: total.getFlagColor()).positioned(top: 8, right: 8);
                  }
                  return Container();
                },
              ),
            ).pOnly(bottom: 8);
          },
        ),

        /// info
        VStack(
          [
            /// 1
            Obx(
              () => controller.rpcSpenderDay.isNotEmpty && controller.rpcSumByCategory.isNotEmpty
                  ? HStack([
                      '🔥 High Spendings!'.text.size(12).make(),
                      Spacer(),
                      CustomPopup(
                        content: VStack([
                          Wrap(
                            children: [
                              'You spend a lot on '.text.size(13).black.make(),
                              Icon(
                                controller.rpcSumByCategory[0].categoryIcon?.getIconData(),
                                color: Vx.black,
                                size: 16,
                              ).pOnly(bottom: 2, right: 6),
                              '(${controller.rpcSumByCategory[0].categoryName})'.text.size(11).black.make(),
                            ],
                          ),
                          'Total Usage: ${controller.rpcSumByCategory[0].total?.moneyFormat()} (${controller.rpcSumByCategory[0].usePercentage}%) '.text
                              .size(11)
                              .minFontSize(11)
                              .color(controller.rpcSumByCategory[0].usePercentage! > 100 ? Colors.red : Vx.neutral500)
                              .make(),
                          Divider(),
                          for (var e in controller.rpcSpenderDay) ...[
                            '- ${e['date'].toString().reformatDate(from: yMd, to: 'dd MMM')} \t\t ${e['total'].toString().toInt()?.moneyFormat()}'
                                .text //
                                .neutral500
                                .size(11)
                                .minFontSize(11)
                                .make()
                                .pOnly(top: 4)
                                .onTap(() => controller.onCalenderGoDate(e['date'].toString().toDateEx(format: yMd))),
                          ],
                        ]).w(220).scrollVertical(),
                        child: Container(
                          decoration: ExDecorator.box(borderRadius: 90, borderColor: Colors.transparent, fillColor: AppColor.primary.withAlpha(100)),
                          child: '${controller.rpcSpenderDay.length}'.text.size(11).minFontSize(11).makeCentered().pOnly(left: 8, right: 8, top: 2, bottom: 2),
                        ),
                      ),
                    ]).p8()
                  : Container(),
            ),

            /// 2
            Obx(
              () => controller.countRemainingBudget.value != 0
                  ? HStack([
                      '💰 Budget'.text.size(12).make(),
                      ExProgressBar(
                        value: controller.countRemainingBudget.value,
                        color1: BibitHelper.getColorForPercentage((controller.countRemainingBudget.value).toInt()),
                        color2: Vx.neutral400,
                        height: 8,
                        radius: 4,
                      ).pSymmetric(h: 12).expand(),
                      CustomPopup(
                        content: VStack([
                          '== ${controller.focusedDay.value.toStringEx(format: 'MMMM y')} =='.text.size(13).black.makeCentered(),
                          '${controller.countRemainingBudget.value <= 100 ? '✅ You are on budget' : '🔴 You are over budget'}'.text.black.size(12).makeCentered(),
                          Table(
                            border: TableBorder.all(borderRadius: BorderRadius.circular(8), color: AppColor.neutralLight),
                            children: [
                              // row 1
                              TableRow(
                                children: [
                                  TableCell(
                                    child: VStack([
                                      'Spent so far'.text.neutral500.size(12).makeCentered(),
                                      '${controller.countOfMonth.value.moneyFormat()}'.text.size(13).black.makeCentered(),
                                    ]).p12(),
                                  ),
                                  TableCell(
                                    child: VStack([
                                      'Budgeted'.text.neutral500.size(12).makeCentered(),
                                      '${controller.countMaxBudget.value.moneyFormat()}'.text.size(13).black.makeCentered(),
                                    ]).p12(),
                                  ),
                                ],
                              ),
                              // row 2
                              TableRow(
                                children: [
                                  TableCell(
                                    child: VStack([
                                      'Remaining'.text.neutral500.size(12).makeCentered(),
                                      if (controller.countMaxBudget.value - controller.countOfMonth.value >= 0) ...[
                                        '${(controller.countMaxBudget.value - controller.countOfMonth.value).moneyFormat()}'.text.size(13).black.makeCentered(),
                                        '(${100 - controller.countRemainingBudget.value}%)'.text.blue500.size(12).blue500.makeCentered(),
                                      ] else ...[
                                        '${0.moneyFormat()}'.text.black.size(13).makeCentered(),
                                        '(0%)'.text.blue500.size(12).blue500.makeCentered(),
                                      ],
                                    ]).p12(),
                                  ),
                                  TableCell(
                                    child: VStack([
                                      'You can spent'.text.neutral500.size(12).makeCentered(),
                                      if (controller.focusedDay.value.month == DateTime.now().month && controller.focusedDay.value.year == DateTime.now().year) ...[
                                        '${((controller.countMaxBudget.value - controller.countOfMonth.value) / (dayInMonth(DateTime.now()) - DateTime.now().day + 1)).moneyFormat()}'.text
                                            .size(13)
                                            .black
                                            .makeCentered(),
                                        '(Per Day)'.text.blue500.size(12).makeCentered(),
                                      ] else ...[
                                        '-'.text.blue500.size(13).makeCentered(),
                                        '(Passed)'.text.green600.size(12).makeCentered(),
                                      ],
                                    ]).p12(),
                                  ),
                                ],
                              ),
                            ],
                          ).pSymmetric(v: 8),
                          if (controller.focusedDay.value.month == DateTime.now().month && controller.focusedDay.value.year == DateTime.now().year) ...[
                            '${(dayInMonth(DateTime.now()) - DateTime.now().day + 1)} Remaining Days'.text.black.size(12).makeCentered(),
                          ] else ...[
                            // 'Based your income, surplus Rp.2.122.112'.text.black.size(12).makeCentered(),
                          ],
                          ExButtonElevated(
                            label: 'View Detail',
                            labelSize: 10,
                            labelColor: Colors.white,
                            backgroundColor: AppColor.sideMenuPrimary,
                            height: 33,
                            width: double.infinity,
                            onPressed: () => {Get.back(), controller.goSummary()},
                          ).pSymmetric(h: 24).pOnly(top: 8),
                        ]).w(250),
                        child: Container(
                          decoration: ExDecorator.box(borderRadius: 90, borderColor: Colors.transparent, fillColor: AppColor.primary.withAlpha(100)),
                          child: '${controller.countRemainingBudget}%'.text.size(11).minFontSize(11).makeCentered().pOnly(left: 8, right: 8, top: 2, bottom: 2),
                        ),
                      ),
                    ]).p8()
                  : Container(),
            ),

            /// 3
            Divider(),
            Obx(
              () => ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: controller.categoryList.length,
                itemBuilder: (context, index) {
                  final item = controller.categoryList[index];
                  return ListTile(
                    title: HStack(
                      [
                        Icon(item.icon?.getIconData() ?? Icons.circle_outlined, color: item.color?.fromHex, size: 16).pOnly(right: 8),
                        '${item.name}'.text.size(12).make().pOnly(right: 8),
                        if (item.maxBudget != null) ...[
                          Container(
                            color: AppColor.primary.withAlpha(100),
                            child: '${item.maxBudget!.moneyFormatCompact()}'.text.size(11).minFontSize(11).make().pSymmetric(h: 4, v: 2),
                          ).cornerRadius(4).pOnly(top: 2),
                        ],
                        Spacer(),
                        if (item.maxBudget == null && item.name != 'Notes') ...[
                          !isMobileWeb
                              ? Icon(Icons.edit, size: 16)
                              : AnimateIcon(
                                  onTap: () => DialogInputHelper.showDialogCategory(category: item),
                                  iconType: IconType.animatedOnHover,
                                  animateIcon: AnimateIcons.edit,
                                  color: AppColor.textReverse,
                                ).wh(16, 16),
                        ],
                      ],
                    ),
                    onTap: () => DialogInputHelper.showDialogCategory(category: item),
                  ).pSymmetric(h: 4);
                },
              ).expand(),
            ),

            /// 4
            TextField(
              controller: controller.tfCategory,
              decoration: DecorationHelper.input(
                hint: 'Add Category',
                fillColor: Get.isDarkMode ? AppColor.card : null,
              ),
              style: TextStyle(fontSize: 13),
              onSubmitted: (value) => controller.onAddCategory(value),
            ).h(33).p8().pOnly(top:16),
          ],
        ).expand(),
      ],
    ).expand();
  }

  Widget bodyContent() {
    return ExSwipe(
      onLeftSwipe: (detail) async {
        controller.focusedDay.value = controller.focusedDay.value.add(1.days);
        await controller.onCalenderDayChange(controller.focusedDay.value, controller.focusedDay.value);
      },
      onRightSwipe: (detail) async {
        controller.focusedDay.value = controller.focusedDay.value.subtract(1.days);
        await controller.onCalenderDayChange(controller.focusedDay.value, controller.focusedDay.value);
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
                '${controller.countOfDay.value.moneyFormat()}'.text.bold.color(AppColor.textReverse).make().onInkTap(() {
                  OverlayHelper.openCalculator(
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
          child: '${controller.focusedDay.value.toStringEx(format: 'E')}'.text.size(11).bold.color(AppColor.textOnBackground).makeCentered().pSymmetric(h: 4, v: 2),
        ).cornerRadius(4).pOnly(right: 10),
        VStack([
          '${controller.focusedDay.value.toStringEx(format: 'dd MMM y')}'.text.size(12).bold.make(),
          '${controller.focusedDay.value.getTimeAgoFromNow()}'.text.size(11).minFontSize(11).make(),
        ]),
        Spacer(),
        CustomPopup(
          content: 'Your score of spend this day'.text.color(AppColor.textOnWhiteBackground).make(),
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
        final startDate = DateTime.now().subtract(Duration(days: searchText.toInt()! - 1)).toStringEx(format: 'd MMM y');
        final endDate = DateTime.now().toStringEx(format: 'd MMM y');
        return Container(
          decoration: ExDecorator.box(borderRadius: 4, borderColor: AppColor.border),
          width: double.infinity,
          child: VStack(
            [
              HStack([
                'Showing data:'.text.bold.make().pOnly(right: 8),
                '$searchText days from today'.text.size(12).make(),
              ]),
              '🗓️ ($startDate → $endDate)'.text.size(11).minFontSize(11).make().pOnly(top: 4),
            ],
          ).p8(),
        );
      } else {
        try {
          final startDate = searchText.substring(0, 10).reformatDate(from: yMd, to: 'd MMM y');
          final endDate = searchText.substring(11).reformatDate(from: yMd, to: 'd MMM y');
          return Container(
            decoration: ExDecorator.box(borderRadius: 4, borderColor: AppColor.border),
            width: double.infinity,
            child: VStack([
              'Showing for date range:'.text.bold.make().pOnly(bottom: 4),
              '🗓️ $startDate → $endDate'.text.size(12).make(),
            ]).p8(),
          );
        } catch (e) {
          ErrorLogHelper.record(page: 'homeView', action: 'bodyHeaderSearchView', stack: e.toString());
          return '$searchText'.text.make();
        }
      }
    }

    /// text @note / @category
    return VStack(
      [
        Container(
          decoration: ExDecorator.box(borderRadius: 4, borderColor: AppColor.border),
          child: HStack(
            [
              'Search For: `${controller.tfSearchExpense.value.text}`'.text.bold.make(),
              Spacer(),
              'Filter'.text.size(8).underline.make().onInkTap(() {
                DialogInputHelper.advenceFilterExpense(controller.tfSearchExpense.value.text);
              }),
            ],
          ).p8(),
        ).pOnly(bottom: 8),
        controller.isAdvanceSearch.isTrue ? '${controller.advanceSearchText}'.text.size(12).minFontSize(12).make() : 0.heightBox,
      ],
    ).pOnly(bottom: 12);
  }

  Widget bodyItemBasicView() {
    return ListView.builder(
      itemCount: controller.expenseList.length,
      itemBuilder: (context, index) {
        final item = controller.expenseList[index];
        final isTypeNotes = item.categoryName?.contains('Notes') ?? false;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isTypeNotes ? AppColor.noteColor : AppColor.card.withAlpha(50),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Row(
            children: [
              VStack([
                /// note
                HStack([
                  '${item.note}'.text.bold.color(isTypeNotes ? Vx.white : AppColor.textReverse).make(),
                  if (!isTypeNotes) ...[
                    Icon(CupertinoIcons.time, size: 10).pOnly(left: 8, right: 2, top: 2),
                    '(${item.createdAt?.reformatDate(to: 'HH:mm')})'.text.size(10).minFontSize(10).make(),
                  ],
                ]).pOnly(bottom: 8),

                /// detail
                item.detail.isNotEmptyAndNotNull
                    ? '${item.detail}'
                          //
                          .text
                          .size(12)
                          .color(Get.isDarkMode ? Vx.neutral300 : Vx.neutral800)
                          .make()
                          .pOnly(bottom: 8)
                    : 0.heightBox,

                /// category
                HStack([
                  Icon(item.category?.icon?.getIconData() ?? Icons.circle_outlined, color: item.category?.color?.fromHex, size: 12).pOnly(right: 8),
                  '${item.category?.name}'
                      //
                      .text
                      .size(12)
                      .color(isTypeNotes ? Vx.white : AppColor.textReverse)
                      .make(),
                  Spacer(),
                  isTypeNotes ? '${item.createdAt?.reformatDate(to: 'HH:mm')}'.text.white.size(11).minFontSize(11).make() : 0.heightBox,
                ]),
              ]).expand(),

              /// amount
              isTypeNotes ? 0.heightBox : '${item.amount?.moneyFormat()}'.text.bold.size(16).make(),
            ],
          ).p12(),
        ).pSymmetric(h: 8, v: 4).onInkTap(() => DialogInputHelper.showDialogExpense(expense: item));
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
          decoration: BoxDecoration(color: Get.isDarkMode ? Color(0xFF19151F) : Colors.white),
          child: HStack(
            [
              '${item.date!.reformatDate(from: yMd, to: '(E) dd MMM y')}'.text.size(11).bold.make(),
              Spacer(),
              '(${item.date!.toDateEx(format: yMd).getTimeAgoFromNow()})'.text.minFontSize(11).size(11).make(),
            ],
          ).p8(),
        ).onTap(() async => await controller.onCalenderGoDate(item.date!.toDateEx(format: yMd)));
      },
      indexedItemBuilder: (context, item, index) {
        final isTypeNotes = item.categoryName?.contains('Notes') ?? false;
        return Container(
          decoration: BoxDecoration(
            color: isTypeNotes ? AppColor.noteColor : AppColor.card.withAlpha(50),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          width: double.infinity,
          child: Row(
            children: [
              VStack([
                /// note
                '${item.note}'.text.bold.color(isTypeNotes ? Vx.white : AppColor.textReverse).make().pOnly(bottom: 8),

                /// detail
                item.detail.isNotEmptyAndNotNull
                    ? '${item.detail}'
                          //
                          .text
                          .size(12)
                          .color(Get.isDarkMode ? Vx.neutral300 : Vx.neutral800)
                          .make()
                          .pOnly(bottom: 8)
                    : 0.heightBox,

                /// category
                HStack([
                  Icon(item.category?.icon?.getIconData() ?? Icons.circle_outlined, size: 12, color: item.category?.color?.fromHex).pOnly(right: 8),
                  '${item.categoryName}'.text.color(isTypeNotes ? Vx.white : AppColor.textReverse).size(12).make(),
                  12.widthBox,
                  isTypeNotes ? '(${item.createdAt?.reformatDate(to: 'HH:mm')})'.text.white.size(11).minFontSize(11).make() : 0.heightBox,
                ]),
              ]).expand(),

              /// amount
              isTypeNotes ? 0.heightBox : '${item.amount?.moneyFormat()}'.text.bold.size(16).make(),
            ],
          ).p12(),
        ).pSymmetric(h: 8, v: 8).onInkTap(() => DialogInputHelper.showDialogExpense(expense: item));
      },
    ).pSymmetric(v: 12).expand();
  }

  Widget emptyHeaderView() {
    return Obx(
      () => HStack(
        [
          if (controller.tfSearchExpense.value.text.isNotBlank) ...[
            'Search for: "${controller.tfSearchExpense.value.text}"'.text.make(),
          ] else ...[
            Container(
              color: AppColor.primary,
              height: 28,
              child: '${controller.focusedDay.value.toStringEx(format: 'E')}'.text.size(11).bold.color(AppColor.textOnBackground).makeCentered().pSymmetric(h: 4, v: 2),
            ).cornerRadius(4).pOnly(right: 10),
            VStack([
              '${controller.focusedDay.value.toStringEx(format: 'dd MMM y')}'.text.size(12).bold.make(),
              '${controller.focusedDay.value.getTimeAgoFromNow()}'.text.size(11).minFontSize(11).make(),
            ]),
            Spacer(),
            Container(
              decoration: ExDecorator.box(borderRadius: 90, borderColor: AppColor.textReverse),
              child: 'No Record'.text.size(12).minFontSize(12).color(AppColor.textReverse).make().p4().pSymmetric(h: 4),
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
              ? Image.asset('assets/icons/app_icon.png', width: 56, height: 56).pOnly(bottom: 16)
              : Lottie.asset('assets/lottie/empty.json', width: 150, reverse: true),
          'No Expense'.text.bold.align(TextAlign.center).make().pOnly(bottom: 8),
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
            onPressed: () => DialogInputHelper.dialogExpenseAI(),
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
            '${controller.userProfile.value.fullName} (${controller.userProfile.value.age})'.text.size(12).black.bold.make(),
            Divider().w(180),
            'Balance   : ${controller.userProfile.value.balance}'.text.size(12).black.make(),
            'Income    : ${controller.userProfile.value.income}'.text.size(12).black.make(),
            'LastUpd. : ${controller.userProfile.value.updatedAt?.reformatDate(to: 'dd MMM y, HH:mm')}'.text.size(12).black.make(),
          ]), //.onTap(() => controller.goSetting()),
          child: Icon(Icons.circle_notifications_rounded, color: AppColor.textReverse, size: 16),
        ),
      ),

      Obx(() => '${controller.footerStatus}'.text.ellipsis.size(12).make().tooltip(controller.footerStatus.value).pOnly(left: 8, right: 12)).expand(),
      Obx(
        () =>
            '${controller.focusedDay.value.toStringEx(format: 'MMM')}: ${controller.countOfMonth.value.moneyFormat()}' //
                .text
                .make()
                .onTap(() => controller.goSummary()),
      ),
    ]).p12();
  }

  Widget floatingActionButton() {
    return Obx(
      () => controller.expenseList.isNotEmpty
          ? FloatingActionButton(
              mini: true,
              backgroundColor: AppColor.primary,
              child: Icon(CupertinoIcons.add, color: Colors.white),
              onPressed: () => DialogInputHelper.dialogExpenseAI(),
            ).pOnly(bottom: Get.context!.isMobile ? 90 : 68)
          : 0.heightBox,
    );
  }
}
