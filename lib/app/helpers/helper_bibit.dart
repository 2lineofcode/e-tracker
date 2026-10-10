import 'dart:ui';
import 'package:ex_kit/ex.dart';

import '../core/app_color.dart';

mixin HelperBibit {
  /// #### getColorForPercentage
  /// - if number > 100 return red,
  /// - else if number > 80, return orange,
  /// - else return green
  static Color getColorForPercentage(dynamic number) {
    try {
      if (number > 100) {
        return Vx.red600;
      } else if (number > 80) {
        return Vx.orange600;
      } else {
        return AppColor.calendarSelectedColor;
      }
    } catch (_) {
      return AppColor.textReverse;
    }
  }
}
