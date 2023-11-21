import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:lottie/lottie.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/app_color.dart';
import '../../core/const.dart';
import '../../helpers/helper_decoration.dart';
import '../../helpers/helper_misc.dart';
import '../../helpers/helper_money.dart';
import '../../models/expense_entity.dart';
import '../../routes/app_pages.dart';
import '../widgets/widgets.dart';
import 'home_controller.dart';
import 'section_dialog_input.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyLayout(
        appBarTitle: appBarTitle(),
        appBarLeading: appBarLeading().pOnly(right: 8),
        appBarAction: appBarAction(),
        sideMenuContent: sideMenuContent(),
        bodyContent: bodyContent(),
        footerContent: footerContent(),
        floatingActionButton: floatingActionButton(),
      ),
    );
  }

  Widget appBarTitle() {
    if (Get.size.width >= 1024) {
      return '${dotenv.get('APP_NAME')}'.text.size(11).bold.make();
    } else {
      return TextField(
        controller: controller.tfSearchExpense.value,
        style: TextStyle(fontSize: 13),
        decoration: MyDecoration.input(
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
      onPressed: () => HomeDialogInput.onShowDialogExpense(),
    );
  }

  Widget appBarAction() {
    return HStack(
      [
        /// Web Only
        if (Get.size.width >= 1024) ...[
          TextField(
            controller: controller.tfSearchExpense.value,
            decoration: MyDecoration.input(hint: 'Search...'),
            style: TextStyle(fontSize: 13),
            onSubmitted: (s) => controller.getExpense(find: s.isNotEmpty ? s : null),
          ).wh(150, 30).pSymmetric(h: 8),
        ],
        IconButton(
          icon: Icon(CupertinoIcons.settings, size: 22),
          onPressed: () => Get.toNamed(Routes.SETTINGS),
        ),
        IconButton(
          icon: Icon(CupertinoIcons.chart_bar_square_fill, size: 22),
          onPressed: () => Get.toNamed(Routes.SUMMARY),
        ),
      ],
    );
  }

  Widget sideMenuContent() {
    return VStack(
      [
        /// calendar
        Obx(
          () => MyCalendarHeader(
            focusedDay: '${controller.focusedDay.value.toStringEx(format: 'MMMM yyyy')}'.text.bold.make().pSymmetric(h: 8),
            onGoPrevMonth: () => controller.onCalenderGoPrevMonth(),
            onGoToday: () => controller.onCalenderGoToday(),
            onGoNextMonth: () => controller.onCalenderGoNextMonth(),
          ),
        ),
        Obx(
          () => MyCalenderBody<String>(
            focusedDay: controller.focusedDay.value,
            minimumDate: DateTime.utc(2020),
            maximumDate: DateTime.utc(2030),
            onCalendarCreated: (c) => controller.calenderPageController = c,
            onPageChanged: (focusedDay) => controller.focusedDay.value = focusedDay,
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
          ).pOnly(bottom: 8),
        ),

        /// category
        Container(
          decoration: BoxDecoration(color: AppColor.sideMenuSecondary),
          child: VStack(
            [
              Obx(
                () => ' 📦 CATEGORY (${controller.categoryList.length})'.text.bold.make().onTap(() => controller.getCategory()).pSymmetric(h: 8, v: 16),
              ),
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
                      onTap: () => HomeDialogInput.onEditCategory(entity: item),
                    ).pSymmetric(h: 4);
                  },
                ).expand(),
              ),
              TextField(
                controller: controller.tfCategory,
                decoration: MyDecoration.input(hint: 'Add Category'),
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
    return controller.obx(
      (state) => Obx(
        () => VStack(
          [
            /// header
            Obx(
              () => controller.isSearchMode.isFalse

                  // normal view
                  ? HStack(
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
                            child: '${controller.countOfDay.value.getFlagText()} Day'.text.size(12).minFontSize(12).color(controller.countOfDay.value.getFlagColorLight()).make().p4().pSymmetric(h: 4),
                          ),
                        ),
                      ],
                    ).pOnly(bottom: 12)

                  // search mode
                  : 'Search for: "${controller.tfSearchExpense.value.text}"'.text.bold.make().pOnly(bottom: 12),
            ).pSymmetric(h: 12).pOnly(top: 12),

            /// item
            Obx(
              () => controller.isSearchMode.isFalse

                  /// normal view
                  ? ListView.builder(
                      itemCount: controller.expenseList.length,
                      itemBuilder: (context, index) {
                        final item = controller.expenseList[index];
                        return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(color: AppColor.cardItemSecondary, borderRadius: BorderRadius.all(Radius.circular(4))),
                          child: Row(
                            children: [
                              VStack([
                                '${item.note}'.text.bold.make().pOnly(bottom: 8),
                                HStack([
                                  Icon(item.category?.icon?.getIconData() ?? Icons.circle_outlined, color: item.category?.color?.fromHex, size: 12).pOnly(right: 8),
                                  '${item.category?.name}'.text.size(12).make(),
                                ]),
                              ]),
                              Spacer(),
                              '${item.amount?.moneyFormat()}'.text.bold.size(16).make(),
                            ],
                          ).p12(),
                        ).pSymmetric(h: 8, v: 4).onInkTap(() => HomeDialogInput.onShowDialogExpense(expense: item));
                      },
                    ).pSymmetric(v: 8).expand()

                  /// search mode view
                  : GroupedListView<ExpenseEntity, String>(
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
                      ).onTap(() async => await controller.onCalenderGoDate(item)),
                      indexedItemBuilder: (context, item, index) => SizedBox(
                        width: double.infinity,
                        child: Row(
                          children: [
                            VStack([
                              '${item.note}'.text.make().pOnly(bottom: 8),
                              HStack([
                                Icon(item.category?.icon?.getIconData() ?? Icons.circle_outlined, size: 12, color: item.category?.color?.fromHex).pOnly(right: 8),
                                '${item.categoryName}'.text.size(12).make(),
                              ]),
                            ]),
                            Spacer(),
                            '${item.amount?.moneyFormat()}'.text.bold.size(16).make(),
                          ],
                        ).p12(),
                      ).pSymmetric(h: 8, v: 4).onInkTap(() => HomeDialogInput.onShowDialogExpense(expense: item)),
                    ).pSymmetric(v: 8).expand(),
            ),

            /// sum
            HStack([
              'Total:'.text.bold.color(AppColor.textOnBackground).make(),
              Spacer(),
              '${controller.countOfDay.value.moneyFormat()}'.text.bold.color(AppColor.textOnBackground).make(),
            ]).p12().color(controller.countOfDay.value.getFlagColorDark()),
          ],
        ),
      ),
      onLoading: MyShimmerHome(),
      onEmpty: VStack(
        [
          Obx(
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
          ),
          Divider(),
          ExUiErrorOrEmpty(
            bgColor: Theme.of(Get.context!).scaffoldBackgroundColor,
            illustration: Column(
              children: [
                Lottie.asset('assets/lottie/empty-1.json', width: 150, reverse: true),
                'No Expense'.text.bold.align(TextAlign.center).make().pOnly(bottom: 8),
                Obx(
                  () => '${controller.tfSearchExpense.value.text.isNotEmptyAndNotNull //-
                          ? '"${controller.tfSearchExpense.value.text}" Not found' //-
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
                  onPressed: () => HomeDialogInput.onShowDialogExpense(),
                ),
              ],
            ),
          ).pOnly(bottom: 90).expand(),
        ],
      ).p12(),
      onError: (e) => ExUiErrorOrEmpty(
        illustration: Icon(CupertinoIcons.wifi_slash),
        title: 'Offline'.text.bold.makeCentered(),
        message: '$e'.text.neutral500.makeCentered(),
        bgColor: AppColor.emptyStatePrimary,
      ),
    );
  }

  Widget footerContent() {
    return HStack([
      Spacer(),
      Obx(
        () => '${controller.focusedDay.value.toStringEx(format: 'MMMM')}: ${controller.countOfMonth.value.moneyFormat()}'.text.bold.make().onTap(() {
          Get.toNamed(Routes.SUMMARY);
        }),
      ),
    ]).p12();
  }

  Widget floatingActionButton() {
    return Obx(() => controller.expenseList.isNotEmpty
        ? FloatingActionButton(
            backgroundColor: AppColor.fabPrimary,
            child: Icon(CupertinoIcons.add, color: Colors.white),
            onPressed: () => HomeDialogInput.onShowDialogExpense(),
          ).pOnly(bottom: Get.context!.isMobile ? 90 : 68)
        : 0.heightBox);
  }
}
