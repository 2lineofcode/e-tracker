import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../helpers/helper_decoration.dart';
import '../../helpers/helper_misc.dart';
import '../../helpers/helper_money.dart';
import '../../routes/app_pages.dart';
import '../widgets/widgets.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
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
    if (kIsWeb) {
      return '${dotenv.get('APP_NAME')}'.text.size(11).bold.make();
    } else {
      return TextField(
        controller: controller.tfSearchExpense,
        decoration: MyDecorationHelper.inputDecorator(hint: 'Search...'),
        style: TextStyle(fontSize: 13),
        onSubmitted: (s) {
          if (s.isNotEmpty) {
            controller.getExpense(find: s);
          } else {
            controller.getExpense();
          }
        },
      ).wh(double.infinity, 30);
    }
  }

  Widget appBarLeading() {
    return IconButton(
      icon: Icon(Icons.add),
      onPressed: () => controller.onShowDialogExpense(),
    );
  }

  Widget appBarAction() {
    return HStack(
      [
        /// Web Only
        if (kIsWeb) ...[
          TextField(
            controller: controller.tfSearchExpense,
            decoration: MyDecorationHelper.inputDecorator(hint: 'Search...'),
            style: TextStyle(fontSize: 13),
            onSubmitted: (s) {
              if (s.isNotEmpty) {
                controller.getExpense(find: s);
              } else {
                controller.getExpense();
              }
            },
          ).wh(150, 30).pSymmetric(h: 8),
        ],
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () => Get.toNamed(Routes.SETTINGS),
        ),
        IconButton(
          icon: Icon(Icons.bar_chart),
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
                  return Icon(Icons.circle, size: 6, color: MoneyHelper.getExpenseFlagColor(total)).positioned(top: 8, right: 8);
                }
                return Container();
              },
            ),
          ).pOnly(bottom: 8),
        ),

        /// category
        Container(
          decoration: BoxDecoration(color: Vx.neutral700),
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
                          Icon(Icons.circle_outlined, color: HexColor.fromHex(item.color ?? '#FFFFFF'), size: 12).pOnly(right: 8),
                          '${item.name}'.text.size(12).make().pOnly(right: 8),
                          if (item.maxBudget != null) ...[
                            Container(
                              color: Vx.neutral800,
                              child: '${item.maxBudget!.moneyFormatCompact()}'.text.size(11).minFontSize(11).make().pSymmetric(h: 4, v: 2),
                            ).cornerRadius(4).pOnly(top: 2),
                          ],
                          Spacer(),
                          if (item.maxBudget == null) Icon(Icons.edit, size: 16, color: Vx.red400),
                        ],
                      ),
                      onTap: () => controller.onEditCategory(entity: item),
                    ).pSymmetric(h: 4);
                  },
                ).expand(),
              ),
              TextField(
                controller: controller.tfCategory,
                decoration: MyDecorationHelper.inputDecorator(hint: 'Add Category'),
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
              () {
                if (controller.isSearchMode.isFalse) {
                  return HStack([
                    Container(
                      color: Colors.blue,
                      child: '${controller.focusedDay.value.toStringEx(format: 'E')}'.text.size(11).bold.make().pSymmetric(h: 4, v: 2),
                    ).cornerRadius(4).pOnly(right: 8),
                    '${controller.focusedDay.value.toStringEx(format: 'dd MMM y')}'.text.size(11).bold.make(),
                    Spacer(),
                    Container(
                      decoration: ExDecorator.box(
                        borderRadius: 90,
                        borderColor: MoneyHelper.getExpenseFlagColorLight(controller.countOfDay.value),
                      ),
                      child: '${MoneyHelper.getExpenseFlagText(controller.countOfDay.value)} Day'
                          .text
                          .size(12)
                          .minFontSize(12)
                          .color(MoneyHelper.getExpenseFlagColorLight(controller.countOfDay.value))
                          .make()
                          .p4()
                          .pSymmetric(h: 4),
                    ),
                  ]);
                } else {
                  return 'Search for: "${controller.tfSearchExpense.text}"'.text.bold.make();
                }
              },
            ).pSymmetric(h: 12).pOnly(top: 12),

            /// item
            ListView.builder(
              itemCount: controller.expenseList.length,
              itemBuilder: (context, index) {
                final item = controller.expenseList[index];
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: Vx.neutral900, borderRadius: BorderRadius.all(Radius.circular(4))),
                  child: Row(
                    children: [
                      VStack([
                        Obx(
                          () => controller.isSearchMode.isTrue
                              ? '${item.date!.reformatDate(from: 'yyyy-MM-dd', to: 'EEE, dd MMM yyyy')}'.text.size(11).minFontSize(11).make().pOnly(bottom: 8)
                              : Container(),
                        ),
                        '${item.note}'.text.bold.make().pOnly(bottom: 4),
                        '${item.categoryName}'.text.size(12).make(),
                      ]),
                      Spacer(),
                      '${MoneyHelper.toRupiah(item.amount?.toDouble())}'.text.bold.size(16).make(),
                    ],
                  ).p12(),
                ).pSymmetric(h: 8, v: 4).onTap(() => controller.onShowDialogExpense(expense: item));
              },
            ).pSymmetric(v: 8).expand(),

            /// sum
            HStack([
              'Total:'.text.bold.make(),
              Spacer(),
              '${MoneyHelper.toRupiah(controller.countOfDay.value)}'.text.bold.make(),
            ]).p12().color(MoneyHelper.getExpenseFlagColorDark(controller.countOfDay.value)),
          ],
        ),
      ),
      onLoading: MyShimmerHome(),
      onEmpty: ExUiErrorOrEmpty(
        illustration: Icon(CupertinoIcons.list_bullet),
        title: 'No Expense'.text.bold.align(TextAlign.center).makeCentered(),
        message: Obx(() => '${controller.focusedDay.value.toStringEx(format: 'dd MMM yyyy')}'.text.neutral500.size(11).makeCentered()),
        action: ExButtonOutline(
          label: 'Add Expense',
          labelSize: 12,
          labelColor: Colors.white,
          isLabelBold: false,
          onPressed: () => controller.onShowDialogExpense(),
        ).centered(),
        bgColor: Color(0xff242424),
      ),
      onError: (e) => ExUiErrorOrEmpty(
        illustration: Icon(CupertinoIcons.wifi_slash),
        title: 'Offline'.text.bold.makeCentered(),
        message: 'No Internet'.text.neutral500.makeCentered(),
        bgColor: Color(0xff242424),
      ),
    );
  }

  Widget footerContent() {
    return HStack([
      Spacer(),
      Obx(
        () => '${controller.focusedDay.value.toStringEx(format: 'MMMM')}: ${MoneyHelper.toRupiah(controller.countOfMonth.value)}'.text.make().onTap(() {
          Get.toNamed(Routes.SUMMARY);
        }),
      ),
    ]).p12();
  }

  Widget floatingActionButton() {
    return Obx(() => controller.expenseList.isNotEmpty
        ? FloatingActionButton(
            backgroundColor: Vx.neutral600,
            child: Icon(Icons.add, color: Colors.white),
            onPressed: () => controller.onShowDialogExpense(),
          ).pOnly(bottom: 60)
        : 0.heightBox);
  }
}
