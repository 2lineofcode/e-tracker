import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import 'const.dart';

mixin AppColor {
  static final _pref = GetStorage(kStorageKey);
  static bool get isDark => _pref.read<bool>(kIsDarkMode) ?? true;
  static const defaultThemeColor = 0xff5D3872;
  static const themeColors = <int>[
    defaultThemeColor,
    0xff2563EB,
    0xff0F766E,
    0xff16A34A,
    0xffD97706,
    0xffDC2626,
    0xffDB2777,
    0xff4F46E5,
  ];

  static int get themeColorValue => _pref.read<int>(kThemeColor) ?? defaultThemeColor;

  static Color _darkTone(double lightness) {
    final hsl = HSLColor.fromColor(primary);
    return hsl.withSaturation((hsl.saturation * 0.7).clamp(0.0, 1.0)).withLightness(lightness).toColor();
  }

  /// selected / unselected
  static Color get primary => Color(themeColorValue);
  static Color get secondary => isDark ? primary.withAlpha(150) : Vx.neutral200;

  /// layout
  static Color get scaffoldPrimary => isDark ? _darkTone(0.06) : Vx.neutral100;
  static Color get sideMenuPrimary => isDark ? _darkTone(0.14) : Vx.neutral100;
  static Color get appbarPrimary => isDark ? _darkTone(0.08) : Vx.neutral100;
  static Color get footerPrimary => isDark ? _darkTone(0.08) : Vx.neutral100;
  static Color get emptyStatePrimary => isDark ? _darkTone(0.08) : Vx.neutral100;

  /// calender
  static Color get calendarSelectedColor => isDark ? primary : primary.withAlpha(150);
  static Color get calendarTodayColor => secondary;
  static Color get calendarWeekEndColor => isDark ? Vx.red300 : Vx.red400;

  /// note
  static Color get noteColor => isDark ? Vx.blue600.withAlpha(50) : Vx.blue600.withAlpha(150);

  /// menu
  static Color get sideMenuSelected => primary.withAlpha(150);
  static Color get menuSelected => primary.withAlpha(100);
  static Color get menuUnSelected => secondary;

  /// textfield
  static Color get textFieldPrimary => isDark ? Vx.neutral800 : Vx.neutral200;

  /// card item
  static Color get card => primary.withAlpha(50);
  static Color get box => primary.withAlpha(20);
  static Color get border => primary.withAlpha(80);
  static Color get divider => neutral;

  /// text on background (special case)
  static Color get textOnBackground => isDark ? Vx.white : Vx.neutral100;
  static Color get textReverse => isDark ? Vx.white : Vx.black;
  static Color get textOnWhiteBackground => isDark ? Vx.black : Vx.black;

  /// table
  static Color get tableHeader => isDark ? card : Vx.neutral300;

  /// shimmer
  static Color get shimmerPrimary => isDark ? box : Vx.neutral300;
  static Color get shimmerSecondary => isDark ? card : Vx.neutral200;

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
