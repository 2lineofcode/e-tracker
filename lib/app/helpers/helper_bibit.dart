import 'dart:ui';
import 'package:ex/ex.dart';

import '../core/app_color.dart';

mixin BibitHelper {
  /// #### isStockMarketOpen
  /// - true:
  ///     - mon-thu: 09.00 - 12.00 WIB, 13.30 - 15.49 WIB,
  ///     - friday: 09.00 - 11.30 WIB, 14.00 - 15.49 WIB
  /// - false: other day
  static bool get isStockMarketOpens {
    final now = DateTime.now();
    final dayOfWeek = now.weekday;
    final currentHour = now.hour;
    final currentMinute = now.minute;

    /// monday - thursday
    if (dayOfWeek >= 1 && dayOfWeek <= 4) {
      if ((currentHour == 9 && currentMinute >= 0) || (currentHour == 10) || (currentHour == 11 && currentMinute <= 59)) {
        return true;
      } else if ((currentHour == 13 && currentMinute >= 30) || (currentHour == 14 && currentMinute <= 49)) {
        return true;
      }
    } else if (dayOfWeek == 5) {
      // friday
      if ((currentHour == 9 && currentMinute >= 0) || (currentHour == 11 && currentMinute <= 30)) {
        return true;
      } else if ((currentHour == 14 && currentMinute >= 0) || (currentHour == 15 && currentMinute <= 49)) {
        return true;
      }
    }

    return false; // Di luar jam perdagangan
  }

  /// #### getEmoji
  /// 💪 or 🖕
  static String getEmoji(dynamic number) {
    try {
      if (number == 0) return '';
      if (number > 0) {
        return '💪';
      } else {
        return '🖕🏽';
      }
    } catch (_) {
      return '-';
    }
  }

  /// #### getSymbol
  /// ↗ or ↘
  static String getSymbol(dynamic number) {
    try {
      if (number == 0) return '';
      if (number > 0) {
        return '↗';
      } else {
        return '↘';
      }
    } catch (_) {
      return '-';
    }
  }

  /// #### getSymbol2
  /// ▲ or ▼
  static String getSymbol2(dynamic number) {
    try {
      if (number == 0) return '';
      if (number > 0) {
        return '▲';
      } else {
        return '▼';
      }
    } catch (_) {
      return '-';
    }
  }

  /// #### getColor
  /// - if number > 0, return green,
  /// - else if < 0 return red,
  /// - else return grey
  static Color getColor(dynamic number) {
    try {
      if (number == 0) {
        return AppColor.textReverse;
      } else if (number > 0) {
        return AppColor.green;
      } else if (number < 0) {
        return AppColor.red;
      } else {
        return AppColor.textReverse;
      }
    } catch (_) {
      return AppColor.textReverse;
    }
  }

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
        return Vx.green600;
      }
    } catch (_) {
      return AppColor.textReverse;
    }
  }
}
