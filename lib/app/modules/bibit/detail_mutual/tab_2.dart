import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/app_color.dart';
import '../../../core/const.dart';
import 'detail_mutual_controller.dart';

class DetailMutualTab2 extends GetView<DetailMutualController> {
  const DetailMutualTab2({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => VStack(
        [
          HStack([
            Spacer(),
            'As of ${state?.holding?[0].date?.reformatDate(from: yMd, to: 'dd MMM yy')}'.text.size(12).make(),
          ]),
          ListView.separated(
            itemCount: state?.holding?.length ?? 0,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              final item = state?.holding?[index];
              return ListTile(
                leading: ExAvatarView(
                  source: item!.name!.contains('Pemerintah') || item.name!.contains('Obligasi FR')
                      ? 'https://app.bibit.id/static/media/fr.85aa5d00b99e36c3c0a63d1822859f97.svg'
                      : 'https://assets.stockbit.com/logos/companies/${item.symbol}.png',
                  name: '${item.name.firstWord}',
                  bgColor: AppColor.bibitDark,
                  borderColor: AppColor.bibitDark,
                  textSize: 11,
                  size: 28,
                ),
                title: HStack([
                  if (state?.type == 'Saham') ...[
                    '${item.symbol}'.text.size(11).minFontSize(11).make().pSymmetric(h: 8, v: 2).box.color(AppColor.neutral).make().cornerRadius(12).pOnly(right: 8),
                    '${item.name}'.text.size(12).maxLines(1).ellipsis.make(),
                  ] else ...[
                    '${item.name}'.text.size(12).maxLines(1).ellipsis.make(),
                  ],
                ]),
              );
            },
          ).expand(),
        ],
      ).p12(),
    );
  }
}
