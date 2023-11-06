import 'package:ex/ex.dart';
import 'package:flutter/material.dart';

class MyShimmerSummary extends StatelessWidget {
  const MyShimmerSummary({super.key});

  @override
  Widget build(BuildContext context) {
    const pc = Vx.neutral600;
    const sc = Vx.neutral700;
    return VStack(
      [
        Container(color: Colors.white).wh(double.infinity, 60).cornerRadius(4).shimmer(primaryColor: pc, secondaryColor: sc).pOnly(bottom: 16),
        Container(color: Colors.white).w(double.infinity).cornerRadius(4).shimmer(primaryColor: pc, secondaryColor: sc).pOnly(bottom: 8).expand(),
      ],
    ).p12();
  }
}
