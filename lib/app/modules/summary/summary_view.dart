import 'package:ex/ex.dart';
import '../../helpers/helper_color.dart';
import '../../helpers/helper_money.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

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
    return ExButtonOutline(
      label: 'View as Chart',
      labelColor: Colors.white,
      borderColor: Vx.neutral600,
      labelSize: 11,
      height: 36,
      onPressed: () {},
    ).pOnly(right: 12);
  }

  Widget sideMenuContent() {
    return VStack([
      /// year direction
      HStack(
        [
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () => controller.onYearPrev(),
          ),
          Spacer(),
          Obx(() => '${controller.yearSelected}'.text.size(16).bold.make()),
          Spacer(),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: () => controller.onYearNext(),
          ),
        ],
      ).pOnly(bottom: 12),

      /// month list
      Obx(
        () => ListView.separated(
          physics: NeverScrollableScrollPhysics(),
          itemCount: controller.monthList.length,
          separatorBuilder: (context, index) => 12.heightBox,
          itemBuilder: (context, index) {
            final item = controller.monthList[index];

            return Container(
              decoration: ExDecorator.box(
                fillColor: item == controller.monthSelected.value ? Colors.blue : Colors.transparent,
                borderColor: Colors.transparent,
              ),
              child: '$item'.text.size(11).make().p8(),
            ).onTap(() {
              controller.onMonthChange(item);
            });
          },
        ).expand(),
      ),

      ExButtonOutline(
        width: double.infinity,
        label: 'Show All of ${controller.yearSelected.value}',
        labelSize: 11,
        labelColor: Colors.white,
        height: 38,
        onPressed: () => controller.onShowAllYear(),
      ).centered().p8(),
    ]).p8().expand();
  }

  Widget bodyContent() {
    return controller.obx(
      (state) => VStack(
        [
          /// total ~
          Container(
            decoration: ExDecorator.box(fillColor: Vx.neutral900, borderColor: Vx.neutral900, borderRadius: 4),
            child: HStack(
              [
                VStack([
                  'Total Pengeluaran (${controller.monthSelected.value}):'.text.size(11).make().pOnly(bottom: 4),
                  Obx(() => '${MoneyHelper.toRupiah(controller.count1Month.value)}'.text.bold.size(16).make()),
                ]),
                Spacer(),
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
                                ' ${(total / item.maxBudget * 100).toString().toInt()}% '.text.size(10).minFontSize(10).make(),
                                Spacer(),
                                '${MoneyHelper.toRupiah(total)}'.text.size(10).minFontSize(10).blue400.make(),
                                ' / '.text.size(10).minFontSize(10).make(),
                                '${MoneyHelper.toRupiah(item.maxBudget)}'.text.size(10).minFontSize(10).make(),
                              ]),
                            ]).expand(),
                          ] else ...[
                            VStack([
                              MyPercentageBar(value: 0, color1: Colors.red, color2: Vx.neutral700, radius: 8).pOnly(bottom: 4),
                              HStack([
                                'No Budget'.text.size(10).minFontSize(10).make(),
                                Spacer(),
                                '${MoneyHelper.toRupiah(total)}'.text.size(10).minFontSize(10).blue400.make(),
                                ' / '.text.size(10).minFontSize(10).make(),
                                '~'.text.size(10).minFontSize(10).make(),
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
    );
  }

  Widget footerContent() {
    return HStack([
      'Pengeluaran Tahun ${controller.yearSelected}:'.text.size(12).make(),
      Spacer(),
      Obx(() => '${MoneyHelper.toRupiah(controller.count1Year.value)}'.text.size(12).red400.make()),
    ]).p12();
  }
}
