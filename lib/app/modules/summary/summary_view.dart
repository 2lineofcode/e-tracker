import 'package:ex_kit/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/app_color.dart';
import '../../core/const.dart';
import '../../helpers/helpers.dart';
import '../widgets/widgets.dart';
import 'summary_controller.dart';
import 'view_bar_chart.dart';
import 'view_insights.dart';
import 'view_note_times.dart';
import 'view_overview.dart';
import 'view_pie_chart.dart';

class SummaryView extends GetView<SummaryController> {
  const SummaryView({super.key});
  @override
  Widget build(BuildContext context) {
    return MyLayout(
      drawerKey: drawerKeySummary,
      appBarTitle: 'Ringkasan'.text.size(11).bold.make(),
      appBarAction: appBarAction(),
      sideMenuContent: sideMenuContent(),
      bodyContent: bodyContent(),
      footerContent: footerContent(),
    );
  }

  Widget appBarAction() {
    final menu = controller.menuSelected;
    return Obx(
      () => HStack(
        [
          _navButton(
            label: 'Ringkasan',
            index: 1,
            icon: Image.asset(
              'assets/icons/ic_pig.png',
              height: 18,
              width: 18,
              color: menu.value == 1
                  ? AppColor.textOnBackground
                  : Vx.neutral500,
            ),
          ),
          _navButton(
            label: 'Harian',
            index: 2,
            icon: Icon(
              CupertinoIcons.chart_bar_alt_fill,
              size: 18,
              color: menu.value == 2
                  ? AppColor.textOnBackground
                  : Vx.neutral500,
            ),
          ),
          _navButton(
            label: 'Kategori',
            index: 3,
            icon: Icon(
              CupertinoIcons.chart_pie_fill,
              size: 18,
              color: menu.value == 3
                  ? AppColor.textOnBackground
                  : Vx.neutral500,
            ),
          ),
          _navButton(
            label: 'Note',
            index: 4,
            icon: Image.asset(
              'assets/icons/ic_overview.png',
              height: 18,
              width: 18,
              color: menu.value == 4
                  ? AppColor.textOnBackground
                  : Vx.neutral500,
            ),
          ),
          _navButton(
            label: 'Insight AI',
            index: 5,
            icon: Icon(
              CupertinoIcons.chat_bubble_fill,
              size: 18,
              color: menu.value == 5
                  ? AppColor.textOnBackground
                  : Vx.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navButton({
    required String label,
    required int index,
    required Widget icon,
  }) {
    final selected = controller.menuSelected.value == index;
    return IconButton(
      tooltip: label,
      style: IconButton.styleFrom(
        backgroundColor: selected
            ? AppColor.sideMenuSelected
            : Colors.transparent,
      ),
      icon: icon,
      onPressed: () => controller.menuSelected.value = index,
    );
  }

  Widget sideMenuContent() {
    return VStack([
      /// year direction
      HStack(
        [
          Obx(() => '${controller.yearSelected}'.text.size(16).bold.make()).pSymmetric(h: 8),
          InkWell(
            onTap: () => controller.onShowAllYear(),
            child: Obx(
              () => Container(
                decoration: ExDecorator.box(
                  borderRadius: 90,
                  fillColor: controller.isShowAllYear.isTrue ? AppColor.primary : Colors.transparent,
                  borderColor: controller.isShowAllYear.isTrue ? AppColor.primary : AppColor.border,
                ),
                child: 'Setahun'.text.size(11).minFontSize(11).color(controller.isShowAllYear.isTrue ? AppColor.textOnBackground : null).make().pSymmetric(h: 8, v: 4),
              ).pOnly(left: 4),
            ),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.chevron_left, size: 18),
            onPressed: () => controller.onYearPrev(),
          ),
          InkWell(
            child: Icon(Icons.circle_outlined, size: 14).pSymmetric(h: 4),
            onTap: () => controller.onYearNow(),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, size: 18),
            onPressed: () => controller.onYearNext(),
          ),
        ],
      ).pOnly(bottom: 12),

      /// month list
      Obx(
        () => ListView.separated(
          padding: EdgeInsets.zero,
          physics: ClampingScrollPhysics(),
          itemCount: controller.rpcSumAllMonth.length,
          separatorBuilder: (context, index) => 12.heightBox,
          itemBuilder: (context, index) {
            final item = controller.rpcSumAllMonth[index];
            final period = item.period.toString().reformatDate(from: yM, to: 'MMMM');
            final total = item.total.toString().toInt() ?? 0;
            return Obx(
              () {
                final isSelected =
                    period == controller.monthSelected.value &&
                    controller.isShowAllYear.isFalse;
                return Container(
                  decoration: ExDecorator.box(
                    fillColor: isSelected
                        ? AppColor.sideMenuSelected
                        : Colors.transparent,
                    borderColor: Colors.transparent,
                  ),
                  child: HStack(
                    [
                      '$period'.text.size(11).make(),
                      Spacer(),
                      if (total != 0) ...[
                        Container(
                          decoration: ExDecorator.box(
                            borderRadius: 90,
                            fillColor: isSelected
                                ? AppColor.primary
                                : AppColor.primary.withAlpha(70),
                            borderColor: AppColor.primary.withAlpha(140),
                          ),
                          child: '${total.moneyFormatCompact()}'.text
                              .color(
                                isSelected
                                    ? AppColor.textOnBackground
                                    : AppColor.textReverse,
                              )
                              .size(9)
                              .minFontSize(9)
                              .bold
                              .make()
                              .pSymmetric(h: 6, v: 2),
                        ).cornerRadius(90),
                      ],
                    ],
                  ).p8(),
                ).onInkTap(() {
                  controller.onMonthChange(period);
                });
              },
            );
          },
        ).expand(),
      ),
    ]).p8().expand();
  }

  Widget bodyContent() {
    return Obx(
      () {
        final child = buildUI();
        if (!Get.context!.isMobile) return child;
        return ExSwipe(
          onLeftSwipe: (details) async {
            if (controller.isShowAllYear.isFalse) {
              final currentMonth = controller.monthSelected.value.toDateEx(format: 'MMMM');
              if (currentMonth.month == 12) await controller.onYearNext();

              final add1Month = DateTime(currentMonth.year, currentMonth.month + 1, currentMonth.day);
              await controller.onMonthChange(add1Month.toStringEx(format: 'MMMM'));
            } else {
              await controller.onYearNext();
            }
          },
          onRightSwipe: (details) async {
            if (controller.isShowAllYear.isFalse) {
              final currentMonth = controller.monthSelected.value.toDateEx(format: 'MMMM');
              if (currentMonth.month == 1) await controller.onYearPrev();

              final subtract1Month = DateTime(currentMonth.year, currentMonth.month - 1, currentMonth.day);
              await controller.onMonthChange(subtract1Month.toStringEx(format: 'MMMM'));
            } else {
              await controller.onYearPrev();
            }
          },
          child: child,
        );
      },
    );
  }

  Widget buildUI() {
    switch (controller.menuSelected.value) {
      case 1:
        return ViewOverview();
      case 2:
        return ViewBarChart();
      case 3:
        return ViewPieChart();
      case 4:
        return ViewNoteTimes();
      case 5:
        return ViewInsights();
      default:
        return Container();
    }
  }

  Widget footerContent() {
    return HStack([
      if (Get.context!.isMobile) ...[
        IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back),
        ),
      ],
      Spacer(),
      Obx(
        () => HStack([
          'Total setahun'.text.size(10).neutral500.make().pOnly(right: 8),
          '${controller.countOnly1Year.value.moneyFormat()}'.text.bold.make(),
        ]).onTap(() {
          controller.onShowAllYear();
        }),
      ),
    ]).p12();
  }
}
