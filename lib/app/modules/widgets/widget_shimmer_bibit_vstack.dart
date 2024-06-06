import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';

import '../../core/app_color.dart';

class MyShimmerBibitVStack extends StatelessWidget {
  const MyShimmerBibitVStack({
    super.key,
    this.itemCount = 3,
  });

  final int? itemCount;

  @override
  Widget build(BuildContext context) {
    final pc = AppColor.shimmerPrimary;
    final sc = AppColor.shimmerSecondary;
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return ListTile(
          leading: ExAvatarView(
            source: '',
            size: 28,
            borderColor: Colors.white,
          ).shimmer(primaryColor: pc, secondaryColor: sc),
          title: Container(width: 60, height: 12, color: pc).shimmer(primaryColor: pc, secondaryColor: sc),
          subtitle: Container(width: 70, height: 12, color: pc).shimmer(primaryColor: pc, secondaryColor: sc),
          trailing: Container(width: 44, height: 16, color: pc).shimmer(primaryColor: pc, secondaryColor: sc),
        ).shimmer(primaryColor: pc, secondaryColor: sc);
      },
    );
  }
}
