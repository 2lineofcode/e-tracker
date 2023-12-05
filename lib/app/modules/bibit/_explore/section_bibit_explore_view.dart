import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/app_color.dart';
import '../../../helpers/helper_bibit.dart';
import '../../../helpers/helpers.dart';
import 'section_bibit_explore_controller.dart';

class SectionBibitExploreView extends GetView<SectionBibitExploreController> {
  const SectionBibitExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (s) => VStack(
        [
          TabBar(
            controller: controller.tabController,
            indicatorColor: AppColor.noteColor,
            labelColor: AppColor.textReverse,
            labelStyle: TextStyle(fontSize: 13),
            unselectedLabelColor: Vx.neutral400,
            unselectedLabelStyle: TextStyle(fontSize: 13),
            tabs: [
              Tab(text: 'Crypto'),
              Tab(text: 'Stock'),
            ],
          ),

          /// body
          TabBarView(
            controller: controller.tabController,
            children: [
              tabCrypto(),
              tabStock(),
            ],
          ).expand(),
        ],
      ),
    );
  }

  Widget tabCrypto() {
    return Obx(
      () => ListView.separated(
        itemCount: controller.pintuListCrypto.length,
        separatorBuilder: (c, i) => Divider(),
        itemBuilder: (context, index) {
          final item = controller.pintuListCrypto[index];
          return HStack(
            [
              SvgPicture.network(
                item.logo ?? '',
                colorFilter: item.color?.fromHex != null ? ColorFilter.mode(item.color?.fromHex ?? Vx.white, BlendMode.srcIn) : null,
              ).pOnly(right: 12),
              VStack([
                HStack([
                  '${item.name}'.text.bold.make(),
                  ' ${BibitHelper.getSymbol(item.day.toDouble())}'.text.color(BibitHelper.getColor(item.day.toDouble())).bold.make(),
                ]),
                '${item.last?.toDouble()?.moneyFormat()}'.text.make(),
              ]),
              Spacer(),
              VStack(
                [
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    HStack(['1D: '.text.bold.size(12).align(TextAlign.center).makeCentered(), '${item.day}%'.text.color(BibitHelper.getColor(item.day.toDouble())).size(12).make()]),
                    Spacer(),
                    HStack(['1W: '.text.bold.size(12).align(TextAlign.center).makeCentered(), '${item.week}%'.text.color(BibitHelper.getColor(item.week.toDouble())).size(12).make()]),
                  ]).w(150),
                  8.heightBox,
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    HStack(['1M: '.text.bold.size(12).align(TextAlign.center).makeCentered(), '${item.month}%'.text.color(BibitHelper.getColor(item.month.toDouble())).size(12).make()]),
                    Spacer(),
                    HStack(['1Y: '.text.bold.size(12).align(TextAlign.center).makeCentered(), '${item.year}%'.text.color(BibitHelper.getColor(item.year.toDouble())).size(12).make()]),
                  ]).w(150),
                ],
              ),
            ],
          ).p8();
        },
      ).pOnly(top: 12),
    );
  }

  Widget tabStock() {
    return Center(child: Text('coming soon'));
  }
}
