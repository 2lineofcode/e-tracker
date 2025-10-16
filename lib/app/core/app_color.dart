import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

mixin AppColor {

  /// selected / unselected
  static Color get primary => Get.isDarkMode ? Color.fromARGB(255, 93, 56, 114) : Color.fromARGB(255, 59, 12, 85);
  static Color get secondary => Get.isDarkMode ? Color.fromARGB(255, 69, 45, 83).withAlpha(150): Vx.neutral200;

  /// layout
  static Color get sideMenuPrimary => Get.isDarkMode ? Color(0xFF261C2C) : Vx.neutral100;
  static Color get appbarPrimary => Get.isDarkMode ? Color(0xff16141A) : Vx.neutral100;
  static Color get footerPrimary => Get.isDarkMode ? Color(0xff16141A) : Vx.neutral100;
  static Color get emptyStatePrimary => Get.isDarkMode ? Color(0xff16141A) : Vx.neutral100;

  /// calender
  static Color get calendarSelectedColor => Get.isDarkMode ? primary: primary.withAlpha(150);
  static Color get calendarTodayColor => secondary;
  static Color get calendarWeekEndColor => Get.isDarkMode ? Vx.red300 : Vx.red400;
  
  /// note
  static Color get noteColor => Get.isDarkMode ? Vx.blue600.withAlpha(50) : Vx.blue600.withAlpha(150);

  /// menu
  static Color get sideMenuSelected => primary.withAlpha(150);
  static Color get menuSelected => primary.withAlpha(100);
  static Color get menuUnSelected => secondary;

  /// textfield
  static Color get textFieldPrimary => Get.isDarkMode ? Vx.neutral800 : Vx.neutral200;

  /// card item
  static Color get card => primary.withAlpha(50);
  static Color get box => primary.withAlpha(20);
  static Color get border => primary.withAlpha(80);
  static Color get divider => primary.withAlpha(80);
  
  /// text on background (special case)
  static Color get textOnBackground => Get.isDarkMode ? Vx.white : Vx.neutral100;
  static Color get textReverse => Get.isDarkMode ? Vx.white : Vx.black;
  static Color get textOnWhiteBackground => Get.isDarkMode ? Vx.black : Vx.black;

  /// table
  static Color get tableHeader => Get.isDarkMode ? card : Vx.neutral300;

  /// shimmer
  static Color get shimmerPrimary => Get.isDarkMode ? box : Vx.neutral300;
  static Color get shimmerSecondary => Get.isDarkMode ? card : Vx.neutral200;

  /// ------------------------------------------------------------------------
  /// green
  static Color get green => Get.isDarkMode ? Vx.green300 : Vx.green600;
  static Color get greenLight => Get.isDarkMode ? Vx.green200 : Vx.green600;
  static Color get greenDark => Get.isDarkMode ? Vx.green600 : Vx.green600;

  /// bibit
  static Color get bibit => Get.isDarkMode ? Color(0xff4CA870) : Color(0xff4CA870);
  static Color get bibitLight => Get.isDarkMode ? Color(0xff57BF7F) : Color(0xff4CA870);
  static Color get bibitDark => Get.isDarkMode ? Color(0xff1B2D25) : Color(0xffEDF8F3);

  /// orange
  static Color get orange => Get.isDarkMode ? Vx.orange300 : Vx.orange500;
  static Color get orangeLight => Get.isDarkMode ? Vx.orange200 : Vx.orange500;
  static Color get orangeDark => Get.isDarkMode ? Vx.orange600 : Vx.orange500;

  /// red
  static Color get red => Get.isDarkMode ? Vx.red400 : Vx.red600;
  static Color get redLight => Get.isDarkMode ? Vx.red200 : Vx.red600;
  static Color get redDark => Get.isDarkMode ? Vx.red600 : Vx.red600;

  /// blue
  static Color get blue => Get.isDarkMode ? Vx.blue300 : Vx.blue600;

  /// neutral
  static Color get neutral => Get.isDarkMode ? Vx.neutral700 : Vx.neutral300;
  static Color get neutralLight => Get.isDarkMode ? Vx.neutral300 : Vx.neutral700;
}
