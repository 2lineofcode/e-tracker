import 'package:ex_kit/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helpers/helper_toast.dart';
import 'app_color.dart';
import 'app_setting.dart';
import 'const.dart';

mixin AppTheme {
  /// * light
  static ThemeData get light => ThemeData.light(useMaterial3: true).copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColor.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColor.scaffoldPrimary,
    canvasColor: AppColor.scaffoldPrimary,
    cardColor: AppColor.box,
    tabBarTheme: TabBarThemeData(
      indicatorColor: AppColor.noteColor,
      labelColor: AppColor.textReverse,
      labelStyle: TextStyle(fontSize: 13),
      unselectedLabelColor: Vx.neutral400,
      unselectedLabelStyle: TextStyle(fontSize: 13),
    ),
    dividerColor: AppColor.divider,
    dividerTheme: DividerThemeData(thickness: 0.5, color: AppColor.divider),
  );

  /// * dark
  static ThemeData get dark => ThemeData.dark(useMaterial3: true).copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColor.primary,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: AppColor.scaffoldPrimary,
    canvasColor: AppColor.scaffoldPrimary,
    cardColor: AppColor.box,
    tabBarTheme: TabBarThemeData(
      indicatorColor: AppColor.noteColor,
      labelColor: AppColor.textReverse,
      labelStyle: TextStyle(fontSize: 13),
      unselectedLabelColor: Vx.neutral400,
      unselectedLabelStyle: TextStyle(fontSize: 13),
    ),
    dividerColor: AppColor.divider,
    dividerTheme: DividerThemeData(thickness: 0.5, color: AppColor.divider),
  );

  /// load theme
  static bool _isDarkMode() => pref.read(kIsDarkMode) ?? true;

  static ThemeMode get currentTheme =>
      _isDarkMode() ? ThemeMode.dark : ThemeMode.light;

  static Future<void> refreshTheme() async {
    ExLoading.show(paddingSymmetric: Get.context!.isMobile ? 90 : 250, child: CupertinoActivityIndicator());
    Get.changeTheme(_isDarkMode() ? dark : light);
    await 500.milliseconds.delay();
    await Get.forceAppUpdate();
    await 500.milliseconds.delay();
    await Get.forceAppUpdate();
    ExLoading.dismiss();
    await HelperToast.success('Theme applied');
  }

  static Future<void> switchTheme() async {
    final isDarkMode = !_isDarkMode();
    await pref.write(kIsDarkMode, isDarkMode);
    Get.changeThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);
    await refreshTheme();
  }
}
