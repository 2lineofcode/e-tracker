import 'package:flutter/material.dart';

import '../../core/app_color.dart';
import '../../helpers/helpers.dart';
import '../../models/bibit_product_detail_mutual_entity.dart';

class StackProgressBar extends StatelessWidget {
  const StackProgressBar({
    super.key,
    required this.data,
  });

  final List<BibitProductDetailMutualDataAsset> data;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        height: 50,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var el in data) ...[
              Expanded(
                flex: el.percentage?.toInt() ?? 0,
                child: Container(
                  color: StackProgressBarColorHelper.fromName(el.name ?? ''),
                  child: Align(alignment: Alignment.center),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

mixin StackProgressBarColorHelper {
  static final _colorSet = ['#52B599', '#8948C1', '#E03322'];
  static final rdpu = ['uang', 'depo', 'likuiditas', 'kas'];
  static final rdpt = ['obligasi'];
  static final rds = ['saham'];

  static Color fromName(String name) {
    if (rds.any((element) => name.toLowerCase().contains(element))) {
      return _colorSet[2].fromHex;
    } else if (rdpt.any((element) => name.toLowerCase().contains(element))) {
      return _colorSet[1].fromHex;
    } else if (rdpu.any((element) => name.toLowerCase().contains(element))) {
      return _colorSet[0].fromHex;
    } else {
      return AppColor.neutral;
    }
  }
}
