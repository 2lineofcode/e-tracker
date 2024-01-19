import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/app_color.dart';
import '../../core/const.dart';
import '../../helpers/helpers.dart';
import '../widgets/widgets.dart';
import 'summary_controller.dart';
import 'view_bar_chart.dart';
import 'view_budget.dart';
import 'view_note_times.dart';
import 'view_pie_chart.dart';

class SummaryView extends GetView<SummaryController> {
  const SummaryView({super.key});
  @override
  Widget build(BuildContext context) {
    return MyLayout(
      drawerKey: drawerKeySummary,
      appBarTitle: 'Summary'.text.size(11).bold.make(),
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
          IconButton(
            icon: Icon(CupertinoIcons.archivebox_fill, size: 18, color: menu.value == 1 ? AppColor.menuSelected : AppColor.menuUnSelected),
            onPressed: () => menu.value = 1,
          ),
          IconButton(
            icon: Icon(CupertinoIcons.chart_bar_alt_fill, size: 18, color: menu.value == 2 ? AppColor.menuSelected : AppColor.menuUnSelected),
            onPressed: () => menu.value = 2,
          ),
          IconButton(
            icon: Icon(CupertinoIcons.chart_pie_fill, size: 18, color: menu.value == 3 ? AppColor.menuSelected : AppColor.menuUnSelected),
            onPressed: () => menu.value = 3,
          ),
          IconButton(
            icon: Icon(CupertinoIcons.doc_chart_fill, size: 18, color: menu.value == 4 ? AppColor.menuSelected : AppColor.menuUnSelected),
            onPressed: () => menu.value = 4,
          ),
        ],
      ),
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
                  fillColor: controller.isShowAllYear.isTrue ? AppColor.sideMenuSelected : Colors.transparent,
                  borderColor: controller.isShowAllYear.isTrue ? AppColor.sideMenuSelected : Vx.neutral400,
                ),
                child: ' Show All '.text.size(11).minFontSize(11).make().pSymmetric(h: 4, v: 4),
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
                return Container(
                  decoration: ExDecorator.box(
                    fillColor: period == controller.monthSelected.value ? AppColor.sideMenuSelected : Colors.transparent,
                    borderColor: Colors.transparent,
                  ),
                  child: HStack(
                    [
                      '$period'.text.size(11).make().pOnly(right: 8),
                      if (total != 0) ...[
                        Container(
                          color: Colors.white,
                          child: '${total.moneyFormatCompact()}'.text.black.size(9).minFontSize(9).bold.make().pSymmetric(h: 2, v: 1),
                        ).cornerRadius(4)
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
      () => ExSwipe(
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
        child: buildUI(),
      ),
    );
  }

  Widget buildUI() {
    switch (controller.menuSelected.value) {
      case 1:
        return ViewBudget();
      case 2:
        return ViewBarChart();
      case 3:
        return ViewPieChart();
      case 4:
        return ViewNoteTimes();
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
        () => '${controller.countOnly1Year.value.moneyFormat()}'.text.bold.make().onTap(() {
          controller.onShowAllYear();
        }),
      ),
    ]).p12();
  }
}
