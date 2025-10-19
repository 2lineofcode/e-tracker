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
import 'package:uicons_pro/uicons_pro.dart';

import '../../core/app_color.dart';
import '../../core/const.dart';
import '../../helpers/helpers.dart';
import '../../models/supa_expense_entity.dart';
import '../widgets/widgets.dart';
import 'home_controller.dart';
import 'section_dialog_asset.dart';
import 'section_dialog_budget.dart';
import 'section_dialog_expense.dart';
import 'section_dialog_goal.dart';
import 'section_dialog_note.dart';

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
                  '\n- by "Date Range", example: "2023-01-01 2023-01-07"'.textSpan.make(),
                ])
                .black
                .size(11)
                .minFontSize(11)
                .make(),
          ]),
          child: Icon(
            CupertinoIcons.search,
            size: 14,
            color: AppColor.textReverse,
          ).pOnly(top: 0),
        ),
        hint: 'Search: Note, Category, Days, Date Range...',
        suffix:
            Icon(
              CupertinoIcons.clear,
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

        /// add-ons
        VStack(
          [
            Divider(color: AppColor.border),

            // :0:
            '::Tools'.text.size(12).bold.make().pOnly(top: 2, bottom: 8),

            // :1: high spending
            Obx(
              () => HStack([
                Icon(UIconsPro.solidRounded.sensor_fire, size: 14, color: Color.fromARGB(255, 195, 86, 69)).pOnly(right: 8),
                'High Spendings!'.text.size(12).make(),
                Spacer(),
                CustomPopup(
                  content: VStack(
                    [
                      '🔥 High Spendings'.text.bold.black.size(12).make().pOnly(bottom: 8),
                      for (var e in controller.rpcSpenderDay) ...[
                        '- ${e['date'].toString().reformatDate(from: yMd, to: 'dd MMM')} \t\t ${e['total'].toString().toInt()?.moneyFormat()}'
                            .text //
                            .black
                            .size(11)
                            .minFontSize(11)
                            .make()
                            .pOnly(top: 4)
                            .onTap(() => controller.onCalenderGoDate(e['date'].toString().toDateEx(format: yMd))),
                      ],
                    ],
                  ).w(150).scrollVertical(),
                  child: Container(
                    decoration: ExDecorator.box(
                      borderRadius: 90,
                      borderColor: Colors.transparent,
                      fillColor: AppColor.primary.withAlpha(100),
                    ),
                    child: '${controller.rpcSpenderDay.length}'.text.size(11).minFontSize(11).makeCentered().pOnly(left: 8, right: 8, top: 2, bottom: 2),
                  ),
                ),
              ]).pOnly(left: 4, right: 8),
            ).pOnly(bottom: 12),

            // :2: budgets
            VStack(
              [
                HStack([
                  Icon(UIconsPro.solidRounded.piggy_bank_budget, size: 14, color: Color.fromARGB(255, 69, 195, 109)).pOnly(right: 8),
                  'Budgets Planning'.text.size(12).make().expand(),
                  Container(
                    decoration: ExDecorator.box(
                      borderRadius: 90,
                      borderColor: Colors.transparent,
                      fillColor: AppColor.primary.withAlpha(100),
                    ),
                    child: Obx(() => '${controller.budgetsList.length}'.text.size(11).minFontSize(11).make().pSymmetric(h: 8, v: 2)),
                  ),
                ]).pOnly(left: 4, right: 8).onInkTap(() => DialogBudget.openList()),
              ],
            ).pOnly(bottom: 12),

            // :3:
            VStack(
              [
                HStack([
                  Icon(UIconsPro.solidRounded.plant_seed_invest, size: 14, color: Color.fromARGB(255, 195, 193, 69)).pOnly(right: 8),
                  'Assets'.text.size(12).make().expand(),
                  Container(
                    decoration: ExDecorator.box(borderRadius: 90, borderColor: Colors.transparent, fillColor: AppColor.primary.withAlpha(100)),
                    child: Obx(() => '${controller.totalAssets.value.moneyFormatCompact()}'.text.size(11).minFontSize(11).make().pSymmetric(h: 8, v: 2)),
                  ),
                ]).pOnly(left: 4, right: 8).onInkTap(() => DialogAsset.openList()),
              ],
            ).pOnly(bottom: 12),

            // :4:
            VStack(
              [
                HStack([
                  Icon(UIconsPro.solidRounded.location_crosshairs, size: 14, color: Color.fromARGB(255, 69, 132, 195)).pOnly(right: 8),
                  'Goals'.text.size(12).make().expand(),
                  Container(
                    decoration: ExDecorator.box(
                      borderRadius: 90,
                      borderColor: Colors.transparent,
                      fillColor: AppColor.primary.withAlpha(100),
                    ),
                    child: 'Open'.text.size(11).minFontSize(11).make().pSymmetric(h: 8, v: 2),
                  ),
                ]).pOnly(left: 4, right: 8).onInkTap(() => DialogGoal.openList()),
              ],
            ).pOnly(bottom: 12),

            // :5:
            VStack(
              [
                HStack([
                  Icon(UIconsPro.solidRounded.notebook, size: 14, color: Color.fromARGB(255, 204, 211, 186)).pOnly(right: 8),
                  'Notes'.text.size(12).make().expand(),
                  Container(
                    decoration: ExDecorator.box(
                      borderRadius: 90,
                      borderColor: Colors.transparent,
                      fillColor: AppColor.primary.withAlpha(100),
                    ),
                    child: 'Open'.text.size(11).minFontSize(11).make().pSymmetric(h: 8, v: 2),
                  ),
                ]).pOnly(left: 4, right: 8).onInkTap(() => DialogNote.openList()),
              ],
            ).pOnly(bottom: 12),

            // :6:
            // VStack(
            //   [
            //     HStack([
            //       Icon(UIconsPro.solidRounded.file_excel, size: 14, color: Color.fromARGB(255, 57, 182, 107)).pOnly(right: 8),
            //       'Xlsio'.text.size(12).make().expand(),
            //       Container(
            //         decoration: ExDecorator.box(
            //           borderRadius: 90,
            //           borderColor: Colors.transparent,
            //           fillColor: AppColor.primary.withAlpha(100),
            //         ),
            //         child: 'Open'.text.size(11).minFontSize(11).make().pSymmetric(h: 8, v: 2),
            //       ),
            //     ]).pOnly(left: 4, right: 8).onInkTap(() => Get.toNamed(Routes.XLSIO)),
            //   ],
            // ).pOnly(bottom: 12),

            // :summary:
            Spacer(),
            Container(
              decoration: ExDecorator.box(
                borderRadius: 4,
                borderColor: AppColor.border,
                fillColor: AppColor.card,
              ),
              child: VStack(
                [
                  HStack([
                    'Spend vs Budgets'.text.bold.size(11).minFontSize(11).make().expand(),
                    Obx(() {
                      final totalSpentRaw = controller.totalSumAllBudget.value;
                      final totalBudgetRaw = controller.totalAllBudget.value;
                      final totalSpent = totalSpentRaw.isFinite ? totalSpentRaw : 0;
                      final totalBudget = totalBudgetRaw.isFinite ? totalBudgetRaw : 0;
                      return '${totalSpent.moneyFormatCompact()} / ${totalBudget.moneyFormatCompact()}'.text.size(12).make();
                    }),
                  ]),
                  Obx(
                    () {
                      final totalSpentRaw = controller.totalSumAllBudget.value;
                      final totalBudgetRaw = controller.totalAllBudget.value;
                      final totalSpent = totalSpentRaw.isFinite && totalSpentRaw >= 0 ? totalSpentRaw.toDouble() : 0.0;
                      final totalBudget = totalBudgetRaw.isFinite && totalBudgetRaw > 0 ? totalBudgetRaw.toDouble() : 0.0;
                      final ratio = totalBudget == 0 ? 0.0 : (totalSpent / totalBudget) * 100;
                      final percentage = ratio.isFinite && !ratio.isNaN ? ratio.clamp(0, 999).round() : 0;
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
                          '${percentage.toInt()}%'.text.size(11).minFontSize(11).make().pOnly(left: 12),
                        ],
                      );
                    },
                  ).pSymmetric(v: 3),

                  /// day remaining...
                  Obx(() {
                    if (DateTime.now().month == controller.focusedDay.value.month && DateTime.now().year == controller.focusedDay.value.year) {
                      return HStack([
                        '${dayInMonth(DateTime.now()) - DateTime.now().day} Day Remaining'.text.color(AppColor.textReverse).size(10).minFontSize(10).make(),
                      ]);
                    }
                    return 0.heightBox;
                  }),
                ],
              ).p12(),
            ).pOnly(bottom: 12),
          ],
        ).pSymmetric(h: 12).expand(),
      ],
    ).expand();
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
                '${controller.countOfDay.value.moneyFormat()}'.text.bold.color(AppColor.textReverse).make().onInkTap(() {
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
              '🗓️ ($startDate → $endDate)'.text.size(11).minFontSize(11).make().pOnly(top: 4),
            ],
          ).p8(),
        );
      } else {
        try {
          final startDate = searchText.substring(0, 10).reformatDate(from: yMd, to: 'd MMM y');
          final endDate = searchText.substring(11).reformatDate(from: yMd, to: 'd MMM y');
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
              'Search For: `${controller.tfSearchExpense.value.text}`'.text.bold.make(),
              Spacer(),
              'Filter'.text.size(8).underline.make().onInkTap(() {
                DialogExpense.openAdvenceFilter(
                  controller.tfSearchExpense.value.text,
                );
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
        final category = item.resolvedCategory;
        final isTypeNotes = category.code == 'expense:misc:notes' || category.label.contains('Notes');

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
                    Icon(
                      CupertinoIcons.time,
                      size: 10,
                    ).pOnly(left: 8, right: 2, top: 2),
                    '(${item.createdAt?.reformatDate(to: 'HH:mm')})'.text.size(10).minFontSize(10).make(),
                  ],
                ]).pOnly(bottom: 8),

                /// detail
                item.detail.isNotEmptyAndNotNull
                    ? '${item.detail}'
                          //
                          .text
                          .size(12)
                          .color(
                            Get.isDarkMode ? Vx.neutral300 : Vx.neutral800,
                          )
                          .make()
                          .pOnly(bottom: 8)
                    : 0.heightBox,

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

                  isTypeNotes ? '${item.createdAt?.reformatDate(to: 'HH:mm')}'.text.white.size(11).minFontSize(11).make() : 0.heightBox,
                ]),
              ]).expand(),

              /// amount
              isTypeNotes ? 0.heightBox : '${item.amount?.moneyFormat()}'.text.bold.size(16).make(),
            ],
          ).p12(),
        ).pSymmetric(h: 8, v: 4).onInkTap(() => DialogExpense.openManualInput(expense: item));
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
              '${item.date!.reformatDate(from: yMd, to: '(E) dd MMM y')}'.text.size(11).bold.make(),
              Spacer(),
              '(${item.date!.toDateEx(format: yMd).getTimeAgoFromNow()})'.text.minFontSize(11).size(11).make(),
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
        final isTypeNotes = category.code == 'expense:misc:notes' || category.label.contains('Notes');
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
                          .color(
                            Get.isDarkMode ? Vx.neutral300 : Vx.neutral800,
                          )
                          .make()
                          .pOnly(bottom: 8)
                    : 0.heightBox,

                /// category
                HStack([
                  Icon(
                    category.icon ?? Icons.circle_outlined,
                    size: 12,
                    color: category.color,
                  ).pOnly(right: 8),
                  '${category.label}'.text.color(isTypeNotes ? Vx.white : AppColor.textReverse).size(12).ellipsis.make().expand(),
                  isTypeNotes ? '(${item.createdAt?.reformatDate(to: 'HH:mm')})'.text.white.size(11).minFontSize(11).make() : 0.heightBox,
                ]),
              ]).expand(),

              /// amount
              isTypeNotes ? 0.heightBox : '${item.amount?.moneyFormat()}'.text.bold.size(16).make().pOnly(left: 12),
            ],
          ).p12(),
        ).pSymmetric(h: 8, v: 8).onInkTap(() => DialogExpense.openManualInput(expense: item));
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
              decoration: ExDecorator.box(
                borderRadius: 90,
                borderColor: AppColor.textReverse,
              ),
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
            '${controller.userProfile.value.fullName} (${controller.userProfile.value.age})'.text.size(12).black.bold.make(),
            Divider().w(180),
            'Balance   : ${controller.userProfile.value.balance}'.text.size(12).black.make(),
            'Income    : ${controller.userProfile.value.income}'.text.size(12).black.make(),
            'LastUpd. : ${controller.userProfile.value.updatedAt?.reformatDate(to: 'dd MMM y, HH:mm')}'.text.size(12).black.make(),
          ]), //.onTap(() => controller.goSetting()),
          child: Icon(
            UIconsPro.solidRounded.clipboard_user,
            color: AppColor.textReverse,
            size: 18,
          ),
        ),
      ),

      Obx(
        () => '${controller.footerStatus}'.text.ellipsis.size(12).make().tooltip(controller.footerStatus.value).pOnly(left: 8, right: 12),
      ).expand(),
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
              onPressed: () => DialogExpense.openAIInput(),
            ).pOnly(bottom: Get.context!.isMobile ? 90 : 68)
          : 0.heightBox,
    );
  }
}
