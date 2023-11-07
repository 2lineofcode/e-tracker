import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helpers/helper_misc.dart';
import '../../helpers/helper_money.dart';
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
                child: ' Show All '.text.size(11).minFontSize(11).make().pSymmetric(h: 4, v: 2),
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
          physics: ClampingScrollPhysics(),
          itemCount: controller.monthList.length,
          separatorBuilder: (context, index) => 12.heightBox,
          itemBuilder: (context, index) {
            final item = controller.monthList[index];

            return Obx(
              () => Container(
                decoration: ExDecorator.box(
                  fillColor: item == controller.monthSelected.value ? Colors.blue : Colors.transparent,
                  borderColor: Colors.transparent,
                ),
                child: HStack(
                  [
                    '$item'.text.size(11).make().pOnly(right: 8),
                    Obx(
                      () => controller.countByMonth.length >= 12 && controller.countByMonth[index] != 0
                          ? Container(
                              color: Colors.white,
                              child: '${controller.countByMonth[index].moneyFormatCompact()}'.text.black.size(9).minFontSize(9).bold.make().pSymmetric(h: 2, v: 1),
                            ).cornerRadius(4)
                          : 0.heightBox,
                    ),
                  ],
                ).p8(),
              ).onTap(() {
                controller.onMonthChange(item);
              }),
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
          /// summaries ~
          Container(
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
                      child: '${controller.monthSelected.value}'.text.size(11).minFontSize(11).make().pSymmetric(h: 4, v: 2),
                    ).cornerRadius(4),
                    Spacer(),
                    Obx(() => '${MoneyHelper.toRupiah(controller.countRemainingBudget.value)}'.text.bold.size(16).make()),
                  ],
                ),

                /// col2
                MyPercentageBar(
                  value: (controller.countPercentage.value * 100).toInt(),
                  color1: controller.countRemainingBudget.value < 0 ? Colors.red : Colors.blue,
                  color2: Vx.neutral700,
                  radius: 8,
                ).pSymmetric(v: 12),

                /// col3
                HStack(
                  [
                    'Used: ${MoneyHelper.toPercentage(controller.countPercentage.value)}'.text.size(11).minFontSize(11).make().pOnly(left: 4),
                    Spacer(),
                    '${MoneyHelper.toRupiah(controller.countOnly1Month.value)}'.text.size(11).bold.blue400.minFontSize(11).make(),
                    ' / '.text.size(11).minFontSize(11).make(),
                    '${MoneyHelper.toRupiah(controller.countBudget.value)}'.text.size(11).minFontSize(11).make(),
                  ],
                ),
              ],
            ).p8(),
          ),
          16.heightBox,

          /// content
          Container(
            width: double.infinity,
            decoration: ExDecorator.box(fillColor: Vx.neutral900, borderColor: Vx.neutral900, borderRadius: 4),
            child: VStack(
              [
                Obx(
                  () => ListView.separated(
                    itemCount: controller.category.length,
                    separatorBuilder: (context, index) => Divider(),
                    itemBuilder: (context, index) {
                      final item = controller.category[index];
                      final total = controller.countByCategory[index]['total'];
                      return HStack(
                        [
                          /// 1
                          VStack([
                            '${item.name}'.text.size(10).color(HexColor.fromHex(item.color ?? '#ffffff')).ellipsis.maxLines(1).make().pOnly(bottom: 2),
                            '${MoneyHelper.toRupiah(total)}'.text.size(11).bold.make(),
                          ]).w(150).pOnly(right: 12),

                          /// 2
                          if (item.maxBudget != null && item.maxBudget! > 0) ...[
                            VStack([
                              MyPercentageBar(
                                value: (total / item.maxBudget * 100).toString().toInt() ?? 0,
                                color1: (total / item.maxBudget * 100).toString().toInt()! < 90 ? Colors.blue : Colors.red,
                                color2: Vx.neutral700,
                                radius: 8,
                              ).pOnly(bottom: 4),
                              HStack([
                                ' ${(total / item.maxBudget * 100).toString().toInt()}% '.text.size(11).minFontSize(11).make(),
                                Spacer(),
                                '${MoneyHelper.toRupiah(total)}'.text.size(11).minFontSize(11).blue400.make(),
                                ' / '.text.size(11).minFontSize(11).make(),
                                '${MoneyHelper.toRupiah(item.maxBudget)}'.text.size(11).minFontSize(11).make(),
                              ]),
                            ]).expand(),
                          ] else ...[
                            VStack([
                              MyPercentageBar(value: 0, color1: Colors.red, color2: Vx.neutral700, radius: 8).pOnly(bottom: 4),
                              HStack([
                                'No Budget'.text.size(11).minFontSize(11).make(),
                                Spacer(),
                                '${MoneyHelper.toRupiah(total)}'.text.size(11).minFontSize(11).blue400.make(),
                                ' / '.text.size(11).minFontSize(11).make(),
                                '~'.text.size(11).minFontSize(11).make(),
                              ]),
                            ]).expand(),
                          ],
                        ],
                      ).onInkTap(() => controller.goAdvanceFilter(item.name!)).pOnly(bottom: 12);
                    },
                  ).expand(),
                ),
              ],
            ).p12(),
          ).expand(),
        ],
      ).p12(),
      onLoading: MyShimmerSummary(),
    );
  }

  Widget footerContent() {
    return HStack([
      'Expenditure in ${controller.yearSelected}:'.text.make(),
      Spacer(),
      Obx(() => '${MoneyHelper.toRupiah(controller.countOnly1Year.value)}'.text.red400.make()),
    ]).p12();
  }
}
