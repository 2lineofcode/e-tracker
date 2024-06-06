import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:ex_kit/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/app_color.dart';
import '../../../core/const.dart';
import '../../../helpers/helper_bibit.dart';
import '../../../helpers/helper_money.dart';
import '../../widgets/widgets.dart';
import '../bibit_controller.dart';
import 'section_bibit_home_controller.dart';

class SectionBibitHomeView extends GetView<SectionBibitHomeController> {
  const SectionBibitHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        /// 1
        porto().pOnly(bottom: 12),

        /// 2
        roi().pOnly(bottom: 12),

        indexStock(),

        /// 3
        watchlist(),

        promo(),
      ],
    ).scrollVertical();
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
                  '${controller.ihsg.value.latest?.moneyFormat(symbol: '') ?? '~'} (${controller.ihsg.value.percentage ?? ''}%)'
                      .text
                      .color(BibitHelper.getColor(controller.ihsg.value.percentage))
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
        child: Stack(
          children: [
            HStack(
              [
                Icon(CupertinoIcons.sum).pOnly(right: 8),
                VStack([
                  HStack([
                    'Return of Investment'.text.bold.make(),
                    Spacer(),
                    'Last Update: ${controller.performance1W.value.chart?.last.formatedDate?.reformatDate(from: yMd, to: 'dd MMM y') ?? '~'}'.text.size(10).minFontSize(10).make(),
                  ]).pOnly(bottom: 12),

                  /// Today
                  ''
                      .richText
                      .withTextSpanChildren([
                        'This Week: '.textSpan.color(AppColor.textReverse).make(),
                        '${controller.performance1W.value.change?.moneyFormat() ?? '~'}'.textSpan.make(),
                        ' '.textSpan.make(),
                        '(${controller.performance1W.value.percent?.percentageFormat() ?? '~'})'.textSpan.make(),
                      ])
                      .color(BibitHelper.getColor(controller.performance1W.value.percent))
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
            if (controller.performance1W.value.percent != null) ...[
              SvgPicture.network(
                controller.performance1W.value.percent!.isNegative
                    ? 'https://app.bibit.id/static/media/bg-downtrend-dark.e2b751733811d9cddc85.svg'
                    : 'https://app.bibit.id/static/media/bg-uptrend-dark.8bdce522ca56b5d02eea.svg',
                width: 100,
                height: 80,
                fit: BoxFit.fill,
              ).positioned(right: 0, bottom: 0),
            ],
          ],
        ),
      ),
    );
  }

  Widget indexStock() {
    return Obx(
      () => controller.indexIndices.isEmpty
          ? MyShimmerBibitHStack(itemCount: ExRandom.between(4, 7)).pSymmetric(h: 4)
          : VStack(
              [
                'Index Saham'.text.bold.make().pOnly(bottom: 8),
                ListView.builder(
                  itemCount: controller.indexIndices.length,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final item = controller.indexIndices[index];
                    return Container(
                      decoration: ExDecorator.box(borderRadius: 4, borderColor: AppColor.neutral),
                      constraints: BoxConstraints(minWidth: 120),
                      child: ZStack(
                        [
                          VStack([
                            '${item.symbol}'.text.bold.make().pOnly(bottom: 4),
                            if (Get.find<BibitController>().isMarketOpen.isFalse) ...[
                              '${item.percent?.toDoubleStringAsFixed(digit: 2)}%'.text.color(BibitHelper.getColor(item.percent)).make(),
                            ] else ...[
                              AnimatedTextKit(
                                repeatForever: true,
                                isRepeatingAnimation: true,
                                animatedTexts: [
                                  FadeAnimatedText(
                                    '${BibitHelper.getSymbol(item.percent)} ${item.percent?.toDoubleStringAsFixed(digit: 2)}%',
                                    textStyle: TextStyle(color: BibitHelper.getColor(item.percent)),
                                    duration: 5.seconds,
                                  ),
                                ],
                              ),
                            ],
                          ]).p8(),
                          SvgPicture.network(
                            item.percent!.isNegative
                                ? 'https://app.bibit.id/static/media/bg-downtrend-dark.e2b751733811d9cddc85.svg'
                                : 'https://app.bibit.id/static/media/bg-uptrend-dark.8bdce522ca56b5d02eea.svg',
                            width: 100,
                            height: 80,
                            fit: BoxFit.fill,
                          ).positioned(right: 0, bottom: 0),
                        ],
                      ),
                    ).pOnly(right: 8);
                  },
                ).h(65).pOnly(bottom: 12),
              ],
            ),
    );
  }

  Widget watchlist() {
    final selectedView = 'Mutual'.obs;
    return Obx(
      () => Container(
        width: double.infinity,
        decoration: ExDecorator.box(borderRadius: 4, borderColor: AppColor.neutral),
        child: VStack(
          [
            HStack(
              [
                'Watchlist'.text.bold.make(),
                Spacer(),
                CustomRadioButton(
                  height: 33,
                  width: 66,
                  elevation: 0,
                  defaultSelected: selectedView.value,
                  buttonLables: ['Mutual', 'Stock'],
                  buttonValues: ['Mutual', 'Stock'],
                  radioButtonValue: (s) => selectedView.value = s,
                  selectedColor: AppColor.green.withAlpha(100),
                  unSelectedColor: Colors.transparent,
                  unSelectedBorderColor: Colors.transparent,
                  selectedBorderColor: Colors.transparent,
                  buttonTextStyle: ButtonTextStyle(
                    selectedColor: Vx.black,
                    unSelectedColor: AppColor.textReverse,
                    textStyle: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ).p16(),
            controller.watchListMutual.isEmpty
                ? MyShimmerBibitVStack()
                : selectedView.value == 'Mutual'

                    /// mutual list
                    ? ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: controller.watchListMutual.length,
                        itemBuilder: (context, index) {
                          final item = controller.watchListMutual[index];
                          return ListTile(
                            leading: ExAvatarView(
                              source: 'https://app.bibit.id/assets/logos/investment-manager/square/${item.investmentManager?.ojkCode}.svg',
                              size: 28,
                              borderColor: Colors.white,
                            ),
                            title: '${item.name}'.text.ellipsis.maxLines(1).size(13).bold.make(),
                            subtitle: '${item.type}'.text.size(11).minFontSize(11).make(),
                            trailing: '${item.xReturn?.percentageFormat()}'.text.color(BibitHelper.getColor(item.xReturn)).make(),
                            onTap: () => controller.goDetailMutual(item),
                          );
                        },
                      )

                    /// stock list
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: controller.watchListStock.length,
                        itemBuilder: (context, index) {
                          final item = controller.watchListStock[index];
                          return ListTile(
                            leading: ExAvatarView(
                              source: item.iconUrl ?? '',
                              size: 28,
                              borderColor: Colors.white,
                            ),
                            title: '${item.name}'.text.ellipsis.maxLines(1).size(13).bold.make(),
                            subtitle: '${item.symbol}'.text.size(11).minFontSize(11).make(),
                            trailing: '${item.percent?.toStringAsFixed(2)}%'.text.color(BibitHelper.getColor(item.percent)).make(),
                            onTap: () => controller.goDetailStock(item),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }

  Widget promo() {
    return Container();
  }
}
