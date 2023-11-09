import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/v4.dart';

import '../../core/const.dart';
import '../../helpers/helper_misc.dart';
import '../../helpers/helper_money.dart';
import '../../models/category_entity.dart';
import '../home/home_controller.dart';
import '../widgets/widget_shimmer_summary.dart';
import '../widgets/widgets.dart';
import 'summary_controller.dart';

class SummaryView extends GetView<SummaryController> {
  const SummaryView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyLayout(
        appBarTitle: 'Summary'.text.size(11).bold.make(),
        appBarAction: appBarAction(),
        sideMenuContent: sideMenuContent(),
        bodyContent: bodyContent(),
        footerContent: footerContent(),
      ),
    );
  }

  Widget appBarAction() {
    return IconButton(
      icon: Icon(CupertinoIcons.chart_pie, size: 18),
      onPressed: () {},
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
                  fillColor: controller.isShowAllYear.isTrue ? Colors.blue : Colors.transparent,
                  borderColor: controller.isShowAllYear.isTrue ? Colors.blue : Vx.neutral400,
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
                    fillColor: period == controller.monthSelected.value ? Colors.blue : Colors.transparent,
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
                ).onTap(() {
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
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(fillColor: Vx.neutral900, borderColor: Vx.neutral900, borderRadius: 4),
      child: VStack(
        [
          'Total Expense ${controller.yearSelected}'.text.size(12).make().pOnly(bottom: 8),
          '${MoneyHelper.toRupiah(controller.countOnly1Year.value)}'.text.bold.size(16).make(),
        ],
      ).p12(),
    );
  }

  Widget detailAllYear() {
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(fillColor: Vx.neutral900, borderColor: Vx.neutral900, borderRadius: 4),
      child: VStack(
        [
          Obx(
            () => ListView.separated(
              itemCount: controller.rpcSumByCategory.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                final item = controller.rpcSumByCategory[index];
                return HStack(
                  [
                    Icon(Icons.circle_outlined, size: 12, color: HexColor.fromHex(item.categoryColor ?? '')).pOnly(right: 8),
                    '${item.categoryName}'.text.ellipsis.maxLines(1).make().pOnly(bottom: 2).expand(),
                    '${MoneyHelper.toRupiah(item.total)}'.text.make(),
                  ],
                ).onInkTap(() => controller.goAdvanceFilter(item.categoryName!)).pOnly(bottom: 12);
              },
            ).expand(),
          ),
        ],
      ).p12(),
    );
  }

  Widget headerPerMonth() {
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(fillColor: Vx.neutral900, borderColor: Vx.neutral900, borderRadius: 4),
      child: VStack(
        [
          /// col1
          HStack(
            [
              'Remaining Budget'.text.size(11).make().pOnly(right: 8),
              Container(
                color: Colors.blue,
                child: '${controller.monthSelected.value} ${controller.yearSelected.value}'.text.size(11).minFontSize(11).make().pSymmetric(h: 4, v: 2),
              ).cornerRadius(4),
              Spacer(),
              Obx(() => '${MoneyHelper.toRupiah(controller.countRemainingBudget.value)}'.text.bold.size(16).make()),
            ],
          ),

          /// col2
          MyPercentageBar(
            value: (controller.countPercentage.value * 100).toInt(),
            color1: (controller.countPercentage.value * 100).toInt() < 50
                ? Vx.green300
                : (controller.countPercentage.value * 100).toInt() < 100
                    ? Vx.orange300
                    : Vx.red500,
            color2: Vx.neutral700,
            radius: 8,
          ).pSymmetric(v: 12),

          /// col3
          HStack(
            [
              'Used: ${MoneyHelper.toPercentage(controller.countPercentage.value)}'.text.size(11).minFontSize(11).make().pOnly(left: 4),
              Spacer(),
              '${MoneyHelper.toRupiah(controller.countOnly1Month.value)}'
                  .text
                  .size(11)
                  .bold
                  .color(
                    (controller.countPercentage.value * 100).toInt() < 50
                        ? Vx.green300
                        : (controller.countPercentage.value * 100).toInt() < 100
                            ? Vx.orange300
                            : Vx.red500,
                  )
                  .minFontSize(11)
                  .make(),
              ' / '.text.size(11).minFontSize(11).make(),
              '${MoneyHelper.toRupiah(controller.countBudget.value)}'.text.size(11).minFontSize(11).make(),
            ],
          ),
        ],
      ).p8(),
    );
  }

  Widget detailPerMonth() {
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(fillColor: Vx.neutral900, borderColor: Vx.neutral900, borderRadius: 4),
      child: VStack(
        [
          Obx(
            () => ListView.separated(
              itemCount: controller.rpcSumByCategory.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                final item = controller.rpcSumByCategory[index];
                return HStack(
                  [
                    /// 1
                    VStack([
                      '${item.categoryName}'.text.size(12).ellipsis.maxLines(1).make().pOnly(bottom: 2),
                      if (item.maxBudget != null && item.maxBudget! > 0) ...[
                        '${MoneyHelper.toRupiah(item.remainingBudget)}'.text.size(11).color(item.remainingBudget! < 0 ? Vx.red400 : Vx.white).bold.make(),
                      ] else ...[
                        'No Budget'.text.size(11).bold.make(),
                      ],
                    ]).w(150).pOnly(right: 12),

                    /// 2
                    if (item.maxBudget != null && item.maxBudget! > 0) ...[
                      VStack([
                        MyPercentageBar(
                          value: item.usePercentage ?? 0,
                          color1: item.usePercentage! < 50
                              ? Vx.green300
                              : item.usePercentage! < 100
                                  ? Vx.orange300
                                  : Vx.red500,
                          color2: Vx.neutral700,
                          radius: 8,
                        ).pOnly(bottom: 4),
                        HStack([
                          ' ${item.usePercentage}% '.text.size(11).minFontSize(11).make(),
                          Spacer(),
                          '${MoneyHelper.toRupiah(item.total)}'
                              .text
                              .size(11)
                              .minFontSize(11)
                              .bold
                              .color(
                                item.usePercentage! < 50
                                    ? Vx.green300
                                    : item.usePercentage! < 100
                                        ? Vx.orange300
                                        : Vx.red300,
                              )
                              .make(),
                          ' / '.text.size(11).minFontSize(11).make(),
                          '${MoneyHelper.toRupiah(item.maxBudget)}'.text.size(12).minFontSize(11).make(),
                        ]),
                      ]).expand(),
                    ] else ...[
                      VStack([
                        MyPercentageBar(value: 0, color1: Colors.red, color2: Vx.neutral700, radius: 8).pOnly(bottom: 4),
                        HStack([
                          '${MoneyHelper.toRupiah(item.total)}'.text.bold.size(11).minFontSize(11).blue300.make(),
                          Spacer(),
                          InkWell(
                            child: 'Setup Budget'.text.underline.size(11).minFontSize(11).make(),
                            onTap: () {
                              final entity = CategoryEntity(
                                id: UuidV4().generate(),
                                createdAt: DateTime.now().toStringEx(),
                                name: item.categoryName,
                                color: item.categoryColor,
                                icon: item.categoryIcon,
                                maxBudget: item.maxBudget,
                              );

                              Get.find<HomeController>().onEditCategory(
                                entity: entity,
                                callback: () async {
                                  await Get.find<HomeController>().getCategory();
                                  await controller.onMonthChange(controller.monthSelected.value);
                                },
                              );
                            },
                          ),
                        ]),
                      ]).expand(),
                    ],
                  ],
                ).onInkTap(() => controller.goAdvanceFilter(item.categoryName ?? '')).pOnly(bottom: 12);
              },
            ).expand(),
          ),
        ],
      ).p12(),
    );
  }

  Widget footerContent() {
    return HStack([
      Obx(() => 'Expenditure in ${controller.yearSelected}:'.text.make()),
      Spacer(),
      Obx(() => '${MoneyHelper.toRupiah(controller.countOnly1Year.value)}'.text.bold.red200.make()),
    ]).p12();
  }
}
