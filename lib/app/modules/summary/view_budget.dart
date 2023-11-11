import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/app_color.dart';
import '../../helpers/helper_misc.dart';
import '../../helpers/helper_money.dart';
import '../../models/category_entity.dart';
import '../home/home_controller.dart';
import '../widgets/widget_percentagebar.dart';
import '../widgets/widget_shimmer_summary.dart';
import 'summary_controller.dart';

class ViewBudget extends GetView<SummaryController> {
  const ViewBudget({super.key});

  @override
  Widget build(BuildContext context) {
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
      decoration: ExDecorator.box(fillColor: AppColor.cardHeaderPrimary, borderColor: AppColor.cardHeaderPrimary, borderRadius: 4),
      child: VStack(
        [
          'Total Expense ${controller.yearSelected}'.text.size(12).make().pOnly(bottom: 8),
          '${controller.countOnly1Year.value.moneyFormat()}'.text.bold.size(16).make(),
        ],
      ).p12(),
    );
  }

  Widget detailAllYear() {
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(fillColor: AppColor.cardItemSecondary, borderColor: AppColor.cardItemSecondary, borderRadius: 4),
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
                    Icon(Icons.circle_outlined, size: 12, color: item.categoryColor?.fromHex).pOnly(right: 8),
                    '${item.categoryName}'.text.ellipsis.maxLines(1).make().pOnly(bottom: 2).expand(),
                    '${item.total?.moneyFormat()}'.text.make(),
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
      decoration: ExDecorator.box(fillColor: AppColor.cardHeaderPrimary, borderColor: AppColor.cardHeaderPrimary, borderRadius: 4),
      child: VStack(
        [
          /// col1
          HStack(
            [
              'Remaining Budget'.text.size(11).make().pOnly(right: 8),
              Container(
                color: Colors.blue,
                child: '${controller.monthSelected.value} ${controller.yearSelected.value}'.text.size(11).minFontSize(11).color(AppColor.textOnBackground).make().pSymmetric(h: 4, v: 2),
              ).cornerRadius(4),
              Spacer(),
              Obx(() => '${controller.countRemainingBudget.value.moneyFormat()}'.text.bold.size(16).make()),
            ],
          ),

          /// col2
          MyPercentageBar(
            value: (controller.countPercentage.value * 100).toInt(),
            color1: (controller.countPercentage.value * 100).toInt() < 100 ? AppColor.green : AppColor.red,
            color2: Vx.neutral700,
            radius: 8,
          ).pSymmetric(v: 12),

          /// col3
          HStack(
            [
              'Used: ${controller.countPercentage.value.percentageFormat()}'.text.size(11).minFontSize(11).make().pOnly(left: 4),
              Spacer(),
              '${controller.countOnly1Month.value.moneyFormat()}'
                  .text
                  .size(11)
                  .bold
                  .color((controller.countPercentage.value * 100).toInt() < 100 ? AppColor.green : AppColor.red)
                  .minFontSize(11)
                  .make(),
              ' / '.text.size(11).minFontSize(11).make(),
              '${controller.countBudget.value.moneyFormat()}'.text.size(11).minFontSize(11).make(),
            ],
          ),
        ],
      ).p8(),
    );
  }

  Widget detailPerMonth() {
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(fillColor: AppColor.cardItemSecondary, borderColor: AppColor.cardItemSecondary, borderRadius: 4),
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
                    Icon(Icons.circle, size: 6, color: item.categoryColor?.fromHex).pOnly(right: 8),

                    /// 1
                    VStack([
                      '${item.categoryName}'.text.size(12).ellipsis.maxLines(1).make().pOnly(bottom: 2),
                      if (item.maxBudget != null && item.maxBudget! > 0) ...[
                        '${item.remainingBudget?.moneyFormat()}'.text.size(11).color(item.remainingBudget! < 0 ? AppColor.red : AppColor.textReverse).bold.make(),
                      ] else ...[
                        'No Budget'.text.size(11).bold.make(),
                      ],
                    ]).w(130).pOnly(right: 12),

                    /// 2
                    if (item.maxBudget != null && item.maxBudget! > 0) ...[
                      VStack([
                        MyPercentageBar(
                          value: item.usePercentage ?? 0,
                          color1: item.usePercentage! < 100 ? AppColor.green : AppColor.red,
                          color2: Vx.neutral700,
                          radius: 8,
                        ).pOnly(bottom: 4),
                        HStack([
                          ' ${item.usePercentage}% '.text.size(11).minFontSize(11).make(),
                          Spacer(),
                          '${item.total?.moneyFormat()}'.text.size(11).minFontSize(11).bold.color(item.usePercentage! < 100 ? AppColor.green : AppColor.red).make(),
                          ' / '.text.size(11).minFontSize(11).make(),
                          '${item.maxBudget?.moneyFormat()}'.text.size(12).minFontSize(11).make(),
                        ]),
                      ]).expand(),
                    ] else ...[
                      VStack([
                        MyPercentageBar(value: 0, color1: Colors.transparent, color2: Vx.neutral700, radius: 8).pOnly(bottom: 4),
                        HStack([
                          '${item.total?.moneyFormat()}'.text.bold.size(11).minFontSize(11).color(AppColor.blue).make(),
                          Spacer(),
                          InkWell(
                            child: 'Setup Budget'.text.underline.size(11).minFontSize(11).make(),
                            onTap: () {
                              final entity = CategoryEntity(
                                id: item.categoryId,
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
}
