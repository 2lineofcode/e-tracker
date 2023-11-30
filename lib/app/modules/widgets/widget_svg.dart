import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';

class MySvg extends StatelessWidget {
  const MySvg({
    required this.url,
    required this.size,
    super.key,
    this.backgroundColor,
  });

  final String url;
  final double size;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ScalableImageWidget.fromSISource(
      background: backgroundColor,
      si: ScalableImageSource.fromSvgHttpUrl(Uri.parse('$url'), warnF: (p0) {}),
    ).wh(size, size);
  }
}
