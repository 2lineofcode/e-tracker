import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:lottie/lottie.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/app_color.dart';
import '../../core/const.dart';
import '../../helpers/helpers.dart';
import '../../models/expense_entity.dart';
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
      appBarAction: appBarAction(),
      sideMenuContent: sideMenuContent(),
      sideMenuWidth: 258,
      bodyContent: bodyContent(),
      footerContent: footerContent(),
      floatingActionButton: floatingActionButton(),
    );
  }

  Widget appBarTitle() {
    if (Get.size.width >= 1024) {
      return '${dotenv.get('APP_NAME')}'.text.size(11).bold.make();
    } else {
      return TextField(
        controller: controller.tfSearchExpense.value,
        style: TextStyle(fontSize: 13),
        decoration: DecorationHelper.input(
          prefixIcon: Icon(CupertinoIcons.search, size: 14, color: AppColor.textReverse).pOnly(top: 0),
          hint: 'Search...',
          suffix: Icon(CupertinoIcons.clear, size: 12, color: AppColor.textReverse).pOnly(top: 0).onInkTap(() async {
            controller.tfSearchExpense.value.clear();
            await controller.getExpense();
          }),
        ),
        onSubmitted: (s) => controller.getExpense(find: s.isNotEmpty ? s : null),
      ).wh(double.infinity, 30);
    }
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
        /// Web Only
        if (Get.size.width >= 1024) ...[
          TextField(
            controller: controller.tfSearchExpense.value,
            decoration: DecorationHelper.input(hint: 'Search...'),
            style: TextStyle(fontSize: 13),
            onSubmitted: (s) => controller.getExpense(find: s.isNotEmpty ? s : null),
          ).wh(150, 30).pSymmetric(h: 8),
        ],

        IconButton(
          onPressed: () => controller.goBibit(),
          icon: SvgPicture.asset(
            'assets/icons/ic_robo.svg',
            width: 22,
            colorFilter: ColorFilter.mode(Get.isDarkMode ? Colors.white70 : Colors.white, BlendMode.srcIn),
          ),
        ).pOnly(right: 4),

        IconButton(
          icon: Icon(CupertinoIcons.settings, size: 22),
          onPressed: () => controller.goSetting(),
        ),
        IconButton(
          icon: Icon(CupertinoIcons.chart_bar_square_fill, size: 22),
          onPressed: () => controller.goSummary(),
        ),
      ],
    );
  }

  Widget sideMenuContent() {
    return VStack(
      [
        /// calendar
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
        Container(
          decoration: BoxDecoration(color: AppColor.sideMenuSecondary),
          child: VStack(
            [
              /// 1
              Obx(
                () => controller.rpcSpenderDay.isNotEmpty && controller.rpcSumByCategory.isNotEmpty
                    ? HStack([
                        '🔥 High Spendings!'.text.size(12).make(),
                        Spacer(),
                        CustomPopup(
                          content: VStack([
                            'You spend a lot on `${controller.rpcSumByCategory[0].categoryName}`.'.text.size(13).black.make(),
                            'Total Usage: ${controller.rpcSumByCategory[0].total?.moneyFormat()} (${controller.rpcSumByCategory[0].usePercentage}%) '
                                .text
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
                          ]).w(200),
                          child: Container(
                            decoration: ExDecorator.box(borderRadius: 90, borderColor: Colors.transparent, fillColor: AppColor.cardHeaderPrimary),
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
                          color2: Vx.neutral300,
                          height: 8,
                          radius: 4,
                        ).pSymmetric(h: 12).expand(),
                        CustomPopup(
                          content: VStack([
                            'Budget: ${controller.focusedDay.value.toStringEx(format: 'MMMM')}'.text.size(13).black.make(),
                            'Max Budget: ${controller.countMaxBudget.value.moneyFormat()}'.text.size(11).neutral500.make(),
                            'Usage: ${controller.countOfMonth.value.moneyFormat()} (${controller.countRemainingBudget}%)'.text.size(11).neutral500.make(),
                            Divider(color: Colors.black),
                            'Remaining: ${(controller.countMaxBudget.value - controller.countOfMonth.value).moneyFormat()}'.text.size(11).black.make(),
                            HStack([
                              Spacer(),
                              ExButtonElevated(
                                label: 'Detail',
                                labelSize: 10,
                                labelColor: Colors.white,
                                height: 28,
                                onPressed: () => {Get.back(), controller.goSummary()},
                              )
                            ]).pOnly(top: 8),
                          ]).w(180),
                          child: Container(
                            decoration: ExDecorator.box(borderRadius: 90, borderColor: Colors.transparent, fillColor: AppColor.cardHeaderPrimary),
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
                              color: AppColor.sideMenuPrimary,
                              child: '${item.maxBudget!.moneyFormatCompact()}'.text.size(11).minFontSize(11).make().pSymmetric(h: 4, v: 2),
                            ).cornerRadius(4).pOnly(top: 2),
                          ],
                          Spacer(),
                          if (item.maxBudget == null) Icon(Icons.edit, size: 16, color: AppColor.red),
                        ],
                      ),
                      onTap: () => DialogInputHelper.showDialogCategory(entity: item),
                    ).pSymmetric(h: 4);
                  },
                ).expand(),
              ),

              /// 4
              TextField(
                controller: controller.tfCategory,
                decoration: DecorationHelper.input(hint: 'Add Category'),
                style: TextStyle(fontSize: 13),
                onSubmitted: (value) => controller.onAddCategory(value),
              ).h(33).p8(),
            ],
          ),
        ).expand(),
      ],
    ).expand();
  }

  Widget bodyContent() {
    return SwipeTo(
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
                'Total:'.text.bold.color(AppColor.textOnBackground).make(),
                Spacer(),
                '${controller.countOfDay.value.moneyFormat()}'.text.bold.color(AppColor.textOnBackground).make().onTap(() {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: Get.context!,
                    builder: (context) => FractionallySizedBox(
                      heightFactor: 0.7,
                      widthFactor: Get.context!.isMobile ? 1 : 0.5,
                      child: SimpleCalculator(
                        autofocus: true,
                        hideSurroundingBorder: true,
                        value: controller.countOfDay.value.toDouble(),
                        onTappedDisplay: (p0, p1) => Get.back(),
                      ),
                    ),
                  );
                }),
              ]).p12().color(controller.countOfDay.value.getFlagColorDark()),
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
          color: Colors.blue,
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
    return 'Search for: "${controller.tfSearchExpense.value.text}"'.text.bold.make().pOnly(bottom: 12);
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
            color: isTypeNotes ? AppColor.noteColor : AppColor.cardItemSecondary,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          child: Row(
            children: [
              VStack([
                /// note
                '${item.note}'.text.bold.make().pOnly(bottom: 8),

                /// detail
                item.detail.isNotEmptyAndNotNull
                    ? '${item.detail}'
                        //
                        .text
                        .size(12)
                        .color(isTypeNotes ? Vx.neutral300 : Vx.neutral500)
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
                  isTypeNotes ? '${item.createdAt?.reformatDate(to: 'HH:mm')}'.text.size(11).minFontSize(11).make() : 0.heightBox,
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
    return GroupedListView<ExpenseEntity, String>(
      elements: controller.expenseList,
      groupBy: (element) => element.date ?? '',
      useStickyGroupSeparators: true,
      floatingHeader: true,
      order: GroupedListOrder.DESC,
      groupHeaderBuilder: (item) => Container(
        width: double.infinity,
        decoration: BoxDecoration(color: AppColor.cardHeaderPrimary),
        child: HStack([
          '${item.date!.reformatDate(from: yMd, to: '(E) dd MMM y')}'.text.size(11).bold.make(),
          Spacer(),
          '(${item.date!.toDateEx(format: yMd).getTimeAgoFromNow()})'.text.minFontSize(10).size(10).make(),
        ]).p8(),
      ).onTap(() async => await controller.onCalenderGoDate(item.date!.toDateEx(format: yMd))),
      indexedItemBuilder: (context, item, index) {
        final isTypeNotes = item.categoryName?.contains('Notes') ?? false;
        return Container(
          color: isTypeNotes ? AppColor.noteColor : null,
          width: double.infinity,
          child: Row(
            children: [
              VStack([
                /// note
                '${item.note}'.text.bold.make().pOnly(bottom: 8),

                /// detail
                item.detail.isNotEmptyAndNotNull
                    ? '${item.detail}'
                        //
                        .text
                        .size(12)
                        .color(isTypeNotes ? Vx.neutral300 : Vx.neutral500)
                        .make()
                        .pOnly(bottom: 8)
                    : 0.heightBox,

                /// category
                HStack([
                  Icon(item.category?.icon?.getIconData() ?? Icons.circle_outlined, size: 12, color: item.category?.color?.fromHex).pOnly(right: 8),
                  '${item.categoryName}'.text.size(12).make(),
                  12.widthBox,
                  isTypeNotes ? '(${item.createdAt?.reformatDate(to: 'HH:mm')})'.text.size(11).minFontSize(11).make() : 0.heightBox,
                ]),
              ]),

              /// amount
              Spacer(),
              isTypeNotes ? 0.heightBox : '${item.amount?.moneyFormat()}'.text.bold.size(16).make(),
            ],
          ).p12(),
        ).pSymmetric(h: 8, v: 4).onInkTap(() => DialogInputHelper.showDialogExpense(expense: item));
      },
    ).pSymmetric(v: 8).expand();
  }

  Widget emptyHeaderView() {
    return Obx(
      () => HStack(
        [
          Container(
            color: Colors.blue,
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
      ).pOnly(bottom: 12),
    );
  }

  Widget emptyBodyView() {
    return ExUiErrorOrEmpty(
      bgColor: Theme.of(Get.context!).scaffoldBackgroundColor,
      illustration: Column(
        children: [
          Get.context!.isMobile //
              ? Image.asset('assets/icons/app_icon.png', width: 56, height: 56).pOnly(bottom: 16)
              : Lottie.asset('assets/lottie/empty-1.json', width: 150, reverse: true),
          'No Expense'.text.bold.align(TextAlign.center).make().pOnly(bottom: 8),
          Obx(
            () => '${controller.tfSearchExpense.value.text.isNotEmptyAndNotNull //
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
            onPressed: () => DialogInputHelper.showDialogExpense(),
          ),
        ],
      ),
    ).pOnly(bottom: Get.context!.isMobile ? 0 : 90).expand();
  }

  Widget footerContent() {
    return HStack([
      Spacer(),
      Obx(
        () => '${controller.focusedDay.value.toStringEx(format: 'MMMM')}: ${controller.countOfMonth.value.moneyFormat()}' //
            .text
            .bold
            .make()
            .onTap(() => controller.goSummary()),
      ),
    ]).p12();
  }

  Widget floatingActionButton() {
    return Obx(() => controller.expenseList.isNotEmpty
        ? FloatingActionButton(
            backgroundColor: AppColor.fabPrimary,
            child: Icon(CupertinoIcons.add, color: Colors.white),
            onPressed: () => DialogInputHelper.showDialogExpense(),
          ).pOnly(bottom: Get.context!.isMobile ? 90 : 68)
        : 0.heightBox);
  }
}
