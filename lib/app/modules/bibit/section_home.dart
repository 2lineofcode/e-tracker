import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/app_color.dart';
import 'bibit_controller.dart';

class SectionHome extends GetView<BibitController> {
  const SectionHome({super.key});

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
      ],
    );
  }

  Container watchlist() {
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(borderRadius: 4, borderColor: AppColor.neutral),
      child: VStack(
        [
          HStack([
            Icon(CupertinoIcons.square_favorites_alt_fill).pOnly(right: 8),
            'Watchlist (5)'.text.make(),
          ]).pOnly(bottom: 16),
          ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(Icons.abc),
                title: 'ABF Indonesia Bond Index Fund $index'.text.ellipsis.maxLines(1).size(13).bold.make(),
                subtitle: 'Obligasi'.text.size(11).minFontSize(11).make(),
                trailing: VStack([
                  'asd'.text.make(),
                  'asd'.text.make(),
                ]),
              );
            },
          ).h(380),
        ],
      ).p8(),
    );
  }

  Container roi() {
    return Container(
      decoration: ExDecorator.box(borderRadius: 4, borderColor: AppColor.neutral),
      child: Row(
        children: [
          Icon(CupertinoIcons.sum).pOnly(right: 8),
          VStack([
            HStack([
              'Return of Investment'.text.bold.make(),
              Spacer(),
              'Last: (Rabu) 30/11/23'.text.size(10).minFontSize(10).make(),
            ]).pOnly(bottom: 4),
            'Today: Rp. 73.827 (-0.05%)'.text.size(12).make(),
            'This Month: Rp. 73.827 (-0.05%)'.text.size(12).make(),
            'All Time: Rp. 73.827 (-0.05%)'.text.size(12).make(),
          ]).expand(),
        ],
      ).p8(),
    );
  }

  HStack porto() {
    return HStack(
      [
        Container(
          decoration: ExDecorator.box(borderRadius: 4, borderColor: AppColor.neutral),
          child: Row(
            children: [
              Icon(CupertinoIcons.asterisk_circle_fill).pOnly(right: 8),
              VStack([
                'Nilai Portfolio'.text.size(12).make(),
                'Rp. 144.690.019'.text.make(),
              ]),
            ],
          ).p8(),
        ).expand(),
        12.widthBox,
        Container(
          decoration: ExDecorator.box(borderRadius: 4, borderColor: AppColor.neutral),
          child: Row(
            children: [
              Icon(Icons.area_chart_outlined).pOnly(right: 8),
              VStack([
                'IHSG Today:'.text.size(12).make(),
                '7.122 (+0.12%)'.text.color(AppColor.green).make(),
              ]),
            ],
          ).p8(),
        ),
      ],
    );
  }
}
