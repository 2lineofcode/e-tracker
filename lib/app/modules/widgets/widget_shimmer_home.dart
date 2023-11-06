import 'package:ex/ex.dart';
import 'package:flutter/material.dart';

class MyShimmerHome extends StatelessWidget {
  const MyShimmerHome({super.key});

  @override
  Widget build(BuildContext context) {
    const pc = Vx.neutral600;
    const sc = Vx.neutral700;
    return VStack(
      [
        HStack([
          Container(color: Colors.white).wh(100, 16).cornerRadius(2).shimmer(primaryColor: pc, secondaryColor: sc),
          Spacer(),
          Container(color: Colors.white).wh(50, 24).cornerRadius(2).shimmer(primaryColor: pc, secondaryColor: sc),
        ]),
        16.heightBox,
        ListView.builder(
          itemCount: 1,
          itemBuilder: (context, index) {
            return Container(color: Colors.white).wh(double.infinity, 55).cornerRadius(2).shimmer(primaryColor: pc, secondaryColor: sc).pOnly(bottom: 8);
          },
        ).expand(),
      ],
    ).p12();
  }
}
