import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';

import '../../core/app_color.dart';

class MyShimmerHome extends StatelessWidget {
  const MyShimmerHome({super.key});

  @override
  Widget build(BuildContext context) {
    final pc = AppColor.shimmerPrimary;
    final sc = AppColor.shimmerSecondary;
    return VStack(
      [
        HStack([
          Container(color: Colors.white).wh(100, 16).cornerRadius(2).shimmer(primaryColor: pc, secondaryColor: sc),
          Spacer(),
          Container(color: Colors.white).wh(70, 24).cornerRadius(90).shimmer(primaryColor: pc, secondaryColor: sc),
        ]),
        16.heightBox,
        ListView.builder(
          itemCount: ExRandom.between(1, 5),
          itemBuilder: (context, index) {
            return Container(color: Colors.white).wh(double.infinity, 55).cornerRadius(2).shimmer(primaryColor: pc, secondaryColor: sc).pOnly(bottom: 8);
          },
        ).expand(),
      ],
    ).p12();
  }
}
