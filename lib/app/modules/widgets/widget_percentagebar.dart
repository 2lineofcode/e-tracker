import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyPercentageBar extends StatelessWidget {
  const MyPercentageBar({
    required this.value,
    required this.color1,
    required this.color2,
    this.radius,
    super.key,
    this.height,
  });

  final int value;
  final double? height;
  final Color color1;
  final Color color2;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final rest = 100 - value;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: const MediaQueryData(),
        child: Stack(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  flex: 100,
                  child: Container(
                    height: height ?? 12,
                    color: Vx.neutral500,
                  ).cornerRadius(radius ?? 20),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                if (value != 0) ...[
                  Expanded(
                    flex: value,
                    child: Container(
                      width: 200,
                      height: height ?? 12,
                      color: color1,
                    ).cornerRadius(radius ?? 20),
                  ),
                ],
                Expanded(
                  flex: rest,
                  child: Container(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
