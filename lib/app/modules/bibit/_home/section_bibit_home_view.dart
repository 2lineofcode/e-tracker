import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/app_color.dart';
import '../../../helpers/helper_bibit.dart';
import '../../../helpers/helper_misc.dart';
import '../../../helpers/helper_money.dart';
import 'section_bibit_home_controller.dart';

class SectionBibitHome extends GetView<SectionBibitHomeController> {
  const SectionBibitHome({super.key});

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        /// 1
        porto().pOnly(bottom: 12),

        /// 2
        roi(),

        12.heightBox,

        /// 3
        watchlist(),

        promo(),
      ],
    );
  }

  Widget porto() {
    return Obx(
      () => HStack(
        [
          /// porto
          Container(
            decoration: ExDecorator.box(borderRadius: 4, borderColor: AppColor.neutral),
            child: Row(
              children: [
                Icon(CupertinoIcons.asterisk_circle_fill).pOnly(right: 8),
                VStack([
                  'Nilai Portfolio'.text.size(12).make(),
                  '${controller.portpolio.value.totalporto?.moneyFormat() ?? '~'}'.text.make(),
                ]),
              ],
            ).p8(),
          ).expand(),

          12.widthBox,

          /// ihsg
          Container(
            decoration: ExDecorator.box(borderRadius: 4, borderColor: AppColor.neutral),
            child: Row(
              children: [
                Icon(Icons.area_chart_outlined).pOnly(right: 8),
                VStack([
                  'IHSG Today:'.text.size(12).make(),
                  '${controller.ihsg.value.data?[0].cFLAST?.moneyFormat(symbol: '') ?? '~'} (${controller.ihsg.value.data?[0].pCTCHNG ?? ''}%)'
                      .text
                      .color(BibitHelper.getColor(controller.ihsg.value.data?[0].pCTCHNG))
                      .make(),
                ]),
              ],
            ).p8(),
          ),
        ],
      ),
    );
  }

  Widget roi() {
    return Obx(
      () => Container(
        decoration: ExDecorator.box(borderRadius: 4, borderColor: AppColor.neutral),
        child: Row(
          children: [
            Icon(CupertinoIcons.sum).pOnly(right: 8),
            VStack([
              HStack([
                'Return of Investment'.text.bold.make(),
                Spacer(),
                'Last Update: ${controller.performance1D.value.chart?.last.formatedDate?.toDateEx(format: 'yyyy-MM-dd').getTimeAgoFromNow() ?? '~'}'.text.size(10).minFontSize(10).make(),
              ]).pOnly(bottom: 12),

              /// Today
              ''
                  .richText
                  .withTextSpanChildren([
                    'Today: '.textSpan.color(AppColor.textReverse).make(),
                    '${controller.performance1D.value.change?.moneyFormat() ?? '~'}'.textSpan.make(),
                    ' '.textSpan.make(),
                    '(${controller.performance1D.value.percent?.percentageFormat() ?? '~'})'.textSpan.make(),
                  ])
                  .color(BibitHelper.getColor(controller.performance1D.value.percent))
                  .size(12)
                  .make()
                  .pOnly(bottom: 8),

              /// this month
              ''
                  .richText
                  .withTextSpanChildren([
                    'This Month: '.textSpan.color(AppColor.textReverse).make(),
                    '${controller.performance1M.value.change?.moneyFormat() ?? '~'}'.textSpan.make(),
                    ' '.textSpan.make(),
                    '(${controller.performance1M.value.percent?.percentageFormat() ?? '~'})'.textSpan.make(),
                  ])
                  .color(BibitHelper.getColor(controller.performance1M.value.percent))
                  .size(12)
                  .make()
                  .pOnly(bottom: 8),

              // all time
              ''
                  .richText
                  .withTextSpanChildren([
                    'All Time: '.textSpan.color(AppColor.textReverse).make(),
                    '${controller.portpolio.value.profitloss?.moneyFormat() ?? '~'}'.textSpan.make(),
                    ' '.textSpan.make(),
                    '(${controller.portpolio.value.percentage?.percentageFormat() ?? '~'})'.textSpan.make(),
                  ])
                  .color(BibitHelper.getColor(controller.portpolio.value.percentage))
                  .size(12)
                  .make(),
            ]).expand(),
          ],
        ).p8(),
      ),
    );
  }

  Widget watchlist() {
    return Obx(
      () => Container(
        width: double.infinity,
        decoration: ExDecorator.box(borderRadius: 4, borderColor: AppColor.neutral),
        child: VStack(
          [
            HStack([
              Icon(CupertinoIcons.square_favorites_alt_fill).pOnly(right: 8),
              'Watchlist (${controller.watchList.length})'.text.make(),
            ]).p16(),
            controller.watchList.isEmpty
                ? LinearProgressIndicator().p32()
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: controller.watchList.length,
                    itemBuilder: (context, index) {
                      final item = controller.watchList[index];
                      return ListTile(
                        leading: SvgPicture.network(
                          'https://app.bibit.id/assets/logos/investment-manager/square/${item.investmentManager?.ojkCode}.svg',
                          width: 24,
                          height: 24,
                        ),
                        title: '${item.name}'.text.ellipsis.maxLines(1).size(13).bold.make(),
                        subtitle: '${item.type}'.text.size(11).minFontSize(11).make(),
                        trailing: '${item.xreturn?.percentageFormat()}'.text.color(BibitHelper.getColor(item.xreturn)).make(),
                      );
                    },
                  ).expand(),
          ],
        ),
      ).expand(),
    );
  }

  Widget promo() {
    return Container();
  }
}
