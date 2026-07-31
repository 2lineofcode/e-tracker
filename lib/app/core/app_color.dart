import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import 'const.dart';

mixin AppColor {
  static final _pref = GetStorage(kStorageKey);
  static bool get isDark => _pref.read<bool>(kIsDarkMode) ?? true;
  static const defaultThemeColor = 0xff2563EB;
  static const themeColors = <int>[
    defaultThemeColor,
    0xff4F46E5,
    0xff7C3AED,
    0xffDB2777,
    0xffDC2626,
    0xffD97706,
    0xff16A34A,
    0xff0F766E,
  ];

  static int get themeColorValue {
    final color = _pref.read<int>(kThemeColor);
    return themeColors.contains(color) ? color! : defaultThemeColor;
  }

  /// selected / unselected
  static Color get primary => Color(themeColorValue);
  static Color get secondary => isDark ? Vx.neutral700 : Vx.neutral200;

  /// layout
  static Color get scaffoldPrimary => isDark ? Color(0xFF0F1115) : Color(0xFFF5F6F8);
  static Color get sideMenuPrimary => isDark ? Color(0xFF171A20) : Vx.white;
  static Color get appbarPrimary => isDark ? Color(0xFF12151A) : Vx.white;
  static Color get footerPrimary => isDark ? Color(0xFF12151A) : Vx.white;
  static Color get emptyStatePrimary => isDark ? Color(0xFF171A20) : Color(0xFFF8F9FA);

  /// calender
  static Color get calendarSelectedColor => isDark ? primary : primary.withAlpha(150);
  static Color get calendarTodayColor => secondary;
  static Color get calendarWeekEndColor => isDark ? Vx.red300 : Vx.red400;

  /// note
  static Color get noteColor => isDark ? Vx.blue600.withAlpha(50) : Vx.blue600.withAlpha(150);

  /// menu
  static Color get sideMenuSelected => primary.withAlpha(isDark ? 60 : 35);
  static Color get menuSelected => primary.withAlpha(isDark ? 45 : 25);
  static Color get menuUnSelected => secondary;

  /// textfield
  static Color get textFieldPrimary => isDark ? Color(0xFF1B1F27) : Color(0xFFECEFF3);

  /// card item
  static Color get card => isDark ? Color(0xFF1B1F27) : Vx.white;
  static Color get box => isDark ? Color(0xFF171A20) : Color(0xFFF8F9FB);
  static Color get border => isDark ? Color(0xFF2B3039) : Color(0xFFE1E5EA);
  static Color get divider => border;

  /// text on background (special case)
  static Color get textOnBackground => isDark ? Vx.white : Vx.neutral100;
  static Color get textReverse => isDark ? Vx.white : Vx.black;
  static Color get textOnWhiteBackground => isDark ? Vx.black : Vx.black;

  /// table
  static Color get tableHeader => isDark ? Color(0xFF20252E) : Color(0xFFECEFF3);

  /// shimmer
  static Color get shimmerPrimary => isDark ? Color(0xFF171A20) : Color(0xFFE1E5EA);
  static Color get shimmerSecondary => isDark ? Color(0xFF242A33) : Color(0xFFF1F3F5);

  /// ------------------------------------------------------------------------
  /// green
  static Color get green => isDark ? Vx.green300 : Vx.green600;
  static Color get greenLight => isDark ? Vx.green200 : Vx.green600;
  static Color get greenDark => isDark ? Vx.green600 : Vx.green600;

  /// bibit
  static Color get bibit => isDark ? Color(0xff4CA870) : Color(0xff4CA870);
  static Color get bibitLight => isDark ? Color(0xff57BF7F) : Color(0xff4CA870);
  static Color get bibitDark => isDark ? Color(0xff1B2D25) : Color(0xffEDF8F3);

  /// orange
  static Color get orange => isDark ? Vx.orange300 : Vx.orange500;
  static Color get orangeLight => isDark ? Vx.orange200 : Vx.orange500;
  static Color get orangeDark => isDark ? Vx.orange600 : Vx.orange500;

  /// red
  static Color get red => isDark ? Vx.red400 : Vx.red600;
  static Color get redLight => isDark ? Vx.red200 : Vx.red600;
  static Color get redDark => isDark ? Vx.red600 : Vx.red600;

  /// blue
  static Color get blue => isDark ? Vx.blue300 : Vx.blue600;

  /// neutral
  static Color get neutral => isDark ? Vx.neutral400 : Vx.neutral500;
}
