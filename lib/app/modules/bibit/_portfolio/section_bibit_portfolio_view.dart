import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/app_color.dart';
import '../../../helpers/helper_bibit.dart';
import '../../../helpers/helper_misc.dart';
import '../../../helpers/helper_money.dart';
import '../../../models/bibit_allocation_summary_entity.dart';
import 'section_bibit_portfolio_controller.dart';

class SectionBibitPorfolioView extends GetView<SectionBibitPorfolioController> {
  const SectionBibitPorfolioView({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (data) => VStack(
        [
          header(data).pOnly(bottom: 16),
          portpolio(),
        ],
      ).scrollVertical(),
    );
  }

  Widget header(BibitAllocationSummaryData? data) {
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(borderRadius: 4, borderColor: AppColor.neutral),
      child: Stack(
        children: [
          VStack(
            [
              'Nilai Portofolio'.text.size(12).make(),
              '${data?.totalPortfolio?.moneyFormat()}'.text.size(16).bold.make().pOnly(bottom: 4),
              '${BibitHelper.getSymbol(data?.profitLossAmount)} ${data?.profitLossAmount?.moneyFormat()} (${data?.profitLossPercentage?.percentageFormat()})'
                  .text
                  .color(BibitHelper.getColor(data?.profitLossPercentage))
                  .size(12)
                  .make()
                  .pOnly(bottom: 24),
              ListView.builder(
                itemCount: data?.allocations?.length ?? 0,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final colorList = ['#4CA870', '#4C96E1', '#997CD5', '#4CA2BE', '#CD9F63'];
                  final item = data?.allocations?[index];
                  return VStack(
                    [
                      VxCircle(
                        backgroundColor: colorList[index].fromHex.withAlpha(40),
                        child: '${item?.percentage?.percentageFormat()}'.text.size(12).bold.color(colorList[index].fromHex).makeCentered(),
                      ).wh(55, 55).pOnly(bottom: 8),
                      '${item?.label}'.text.size(11).minFontSize(11).make(),
                      Spacer(),
                    ],
                    alignment: MainAxisAlignment.center,
                    crossAlignment: CrossAxisAlignment.center,
                  ).pOnly(right: 24);
                },
              ).h(90).centered(),
            ],
          ).p12(),
          if (data?.profitLossAmount != null) ...[
            SvgPicture.network(
              data!.profitLossAmount!.isNegative
                  ? 'https://app.bibit.id/static/media/bg-downtrend-dark.e2b751733811d9cddc85.svg'
                  : 'https://app.bibit.id/static/media/bg-uptrend-dark.8bdce522ca56b5d02eea.svg',
            ).positioned(right: 0, bottom: 0),
          ],
        ],
      ),
    );
  }

  Widget portpolio() {
    return VStack(
      [
        'Portofolio'.text.make().pOnly(bottom: 8),
        Obx(
          () => ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: controller.portpolio.length,
            separatorBuilder: (c, i) => 8.heightBox,
            itemBuilder: (context, index) {
              final item = controller.portpolio[index];
              return Container(
                decoration: ExDecorator.box(borderColor: AppColor.neutral, borderRadius: 4),
                child: HStack([
                  SvgPicture.network(
                    Get.isDarkMode //
                        ? 'https://app.bibit.id/assets/images/portfolio/green/dark/${item.templateid}.svg'
                        : 'https://app.bibit.id/assets/images/portfolio/green/${item.templateid}.svg',
                    height: 32,
                    width: 32,
                  ),
                  VStack([
                    '${item.name}'.text.size(12).bold.make().pOnly(bottom: 4),
                    '${item.invested?.moneyFormat()}'.text.size(12).make(),
                  ]).pOnly(left: 16),
                  Spacer(),
                  if (item.profitloss != 0) ...[
                    '${item.profitloss == 0 ? '' : item.profitloss?.moneyFormat()} '.text.color(BibitHelper.getColor(item.profitloss)).size(12).make(),
                    '(${item.percentage?.percentageFormat()})'.text.size(11).minFontSize(11).color(BibitHelper.getColor(item.percentage)).make(),
                    ' ${BibitHelper.getSymbol2(item.percentage)}'.text.color(BibitHelper.getColor(item.percentage)).make(),
                  ],
                ]).p8(),
              );
            },
          ),
        ),
      ],
    );
  }
}
