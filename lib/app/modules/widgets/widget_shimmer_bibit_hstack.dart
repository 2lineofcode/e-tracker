import 'package:ex/ex.dart';
import 'package:flutter/material.dart';

import '../../core/app_color.dart';

class MyShimmerBibitHStack extends StatelessWidget {
  const MyShimmerBibitHStack({
    super.key,
    this.itemCount = 3,
  });

  final int? itemCount;

  @override
  Widget build(BuildContext context) {
    final pc = AppColor.shimmerPrimary;
    final sc = AppColor.shimmerSecondary;
    return ListView.builder(
      itemCount: itemCount,
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Container(
          decoration: ExDecorator.box(borderRadius: 4, borderColor: AppColor.neutral),
          constraints: BoxConstraints(minWidth: 120),
          child: ZStack(
            [
              VStack([
                ''.text.bold.make().shimmer(primaryColor: pc, secondaryColor: sc).pOnly(bottom: 4),
                ''.text.make().shimmer(primaryColor: pc, secondaryColor: sc),
              ]).p8(),
            ],
          ),
        ).shimmer(primaryColor: pc, secondaryColor: sc).pOnly(right: 8);
      },
    ).h(65).pOnly(bottom: 12);
  }
}
