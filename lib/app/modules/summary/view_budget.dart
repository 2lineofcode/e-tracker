import 'dart:convert';

import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

import '../../core/app_color.dart';
import '../../helpers/helper_misc.dart';
import '../../helpers/helper_money.dart';
import '../../models/supa_category_entity.dart';
import '../home/home_controller.dart';
import '../home/section_dialog_input.dart';
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
    return GlassContainer(
      width: double.infinity,
      // decoration: ExDecorator.box(fillColor: AppColor.cardHeaderPrimary, borderColor: AppColor.cardHeaderPrimary, borderRadius: 4),
      color: AppColor.cardHeaderPrimary,
      blur: 50,
      border: Border.all(color: Get.theme.textTheme.bodySmall!.color!.withAlpha(20)),
      borderRadius: BorderRadius.all(Radius.circular(4)),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColor.cardHeaderPrimary,
          Get.theme.scaffoldBackgroundColor,
        ],
      ),
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
                    Icon(item.categoryIcon?.getIconData(), size: 12, color: item.categoryColor?.fromHex).pOnly(right: 8),
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
    if (controller.countBudget.value.isZero) {
      return GlassContainer(
        width: double.infinity,
        color: AppColor.cardHeaderPrimary,
        blur: 50,
        border: Border.all(color: Get.theme.textTheme.bodySmall!.color!.withAlpha(20)),
        borderRadius: BorderRadius.all(Radius.circular(4)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.cardHeaderPrimary,
            Get.theme.scaffoldBackgroundColor,
          ],
        ),
        child: VStack([
          'Total:'.text.make().pOnly(bottom: 8),
          '${controller.countOnly1Month.value.moneyFormat()}'.text.bold.make(),
        ]).p12(),
      );
    }
    return GlassContainer(
      width: double.infinity,
      color: AppColor.cardHeaderPrimary,
      blur: 50,
      border: Border.all(color: Get.theme.textTheme.bodySmall!.color!.withAlpha(20)),
      borderRadius: BorderRadius.all(Radius.circular(4)),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColor.cardHeaderPrimary,
          Get.theme.scaffoldBackgroundColor,
        ],
      ),
      child: VStack(
        [
          /// col1
          HStack(
            [
              'Remaining Budget'.text.size(11).make().pOnly(right: 8),
              Container(
                color: Vx.blue500,
                child: '${controller.monthSelected.value.reformatDate(from: 'MMMM', to: 'MMM')} ${controller.yearSelected.value}'
                    .text
                    .size(11)
                    .minFontSize(11)
                    .color(AppColor.textOnBackground)
                    .make()
                    .pSymmetric(h: 4, v: 2),
              ).cornerRadius(4),
              Spacer(),
              Obx(() => '${controller.countRemainingBudget.value.moneyFormat()}'.text.bold.size(16).make()),
            ],
          ),

          /// col2
          ExProgressBar(
            value: (controller.countPercentage.value).toInt(),
            color1: (controller.countPercentage.value).toInt() < 100 ? AppColor.bibit : AppColor.red,
            color2: AppColor.neutralLight,
            radius: 8,
          ).pSymmetric(v: 12),

          /// col3
          HStack(
            [
              'Used: ${controller.countPercentage.value.toDoubleStringAsFixed()}%'.text.size(11).minFontSize(11).make().pOnly(left: 4),
              Spacer(),
              '${controller.countOnly1Month.value.moneyFormat()}'
                  .text
                  .size(11)
                  .bold
                  .color(
                    (controller.countPercentage.value).toInt() < 100 ? AppColor.green : AppColor.red,
                  )
                  .minFontSize(11)
                  .make(),
              ' / '.text.size(11).minFontSize(11).make(),
              '${controller.countBudget.value.moneyFormat()}'.text.size(11).minFontSize(11).make(),
            ],
          ),

          if (DateTime.now().month == controller.monthSelected.value.toDateEx(format: 'MMMM').month && DateTime.now().year == controller.yearSelected.value.toInt()) ...[
            HStack([
              '${dayInMonth(DateTime.now()) - DateTime.now().day + 1} Day Remaining'.text.color(AppColor.blue).size(12).makeCentered().pOnly(top: 8),
            ]).centered(),
          ],
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
              separatorBuilder: (context, index) => 8.heightBox,
              itemBuilder: (context, index) {
                final item = controller.rpcSumByCategory[index];
                return Container(
                  decoration: ExDecorator.box(fillColor: AppColor.cardHeaderPrimary, borderColor: AppColor.cardHeaderPrimary, borderRadius: 4),
                  child: HStack(
                    [
                      Icon(item.categoryIcon?.getIconData(), size: 16, color: item.categoryColor?.fromHex).pOnly(right: 12),

                      /// 1
                      VStack([
                        '${item.categoryName}'.text.size(12).ellipsis.maxLines(1).make().pOnly(bottom: 2),
                        if (item.maxBudget != null && item.maxBudget! > 0) ...[
                          '${item.remainingBudget?.moneyFormat()}'.text.size(11).color(item.remainingBudget! < 0 ? AppColor.red : AppColor.textReverse).bold.make(),
                        ] else ...[
                          'No Budget'.text.size(11).bold.make(),
                        ],
                      ]).w(Get.context!.isMobile ? 100 : 130).pOnly(right: 12),

                      /// 2
                      if (item.maxBudget != null && item.maxBudget! > 0) ...[
                        VStack([
                          ExProgressBar(
                            value: item.usePercentage ?? 0,
                            color1: item.usePercentage! < 100 ? AppColor.bibit : AppColor.red,
                            color2: AppColor.neutralLight,
                            radius: 2,
                            height: 8,
                          ).pOnly(bottom: 4),
                          HStack([
                            ' ${item.usePercentage}% '.text.size(11).minFontSize(11).make(),
                            Spacer(),
                            'Rp. ${item.total?.moneyFormatCompact()}'.text.size(11).minFontSize(11).bold.color(item.usePercentage! < 100 ? AppColor.green : AppColor.red).make(),
                            ' / '.text.size(11).minFontSize(11).make(),
                            'Rp. ${item.maxBudget?.moneyFormatCompact()}'.text.size(12).minFontSize(11).make(),
                          ]),
                        ]).pOnly(right: 12).expand(),
                      ] else ...[
                        VStack([
                          ExProgressBar(
                            value: 0,
                            color1: Colors.transparent,
                            color2: AppColor.neutralLight,
                            radius: 2,
                            height: 8,
                          ).pOnly(bottom: 4),
                          HStack([
                            '${item.total?.moneyFormat()}'.text.bold.size(11).minFontSize(11).color(AppColor.blue).make(),
                            Spacer(),
                            InkWell(
                              child: 'Setup Budget'.text.underline.size(11).minFontSize(11).make(),
                              onTap: () {
                                logI(jsonEncode(item));
                                final entity = SupaCategory(
                                  id: item.categoryId,
                                  createdAt: DateTime.now().toStringEx(),
                                  name: item.categoryName,
                                  color: item.categoryColor,
                                  icon: item.categoryIcon,
                                  maxBudget: item.maxBudget,
                                );

                                DialogInputHelper.showDialogCategory(
                                  entity: entity,
                                  callback: () async {
                                    await Get.find<HomeController>().getCategory();
                                    await controller.onMonthChange(controller.monthSelected.value);
                                  },
                                );
                              },
                            ),
                          ]),
                        ]).pOnly(right: 12).expand(),
                      ],
                    ],
                  ).onInkTap(() => controller.goAdvanceFilter(item.categoryName ?? '')).p12(),
                );
              },
            ).expand(),
          ),
        ],
      ).p12(),
    );
  }
}
