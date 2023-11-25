import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_base.dart';
import 'const.dart';

mixin AppTheme {
  // —————————————————————————————————————————————————————————————————————————————
  // light
  // —————————————————————————————————————————————————————————————————————————————
  static final light = ThemeData.light(useMaterial3: true).copyWith(
    /// light -> appbar
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white),
    ),
  );

  // —————————————————————————————————————————————————————————————————————————————
  // dark
  // —————————————————————————————————————————————————————————————————————————————
  static final dark = ThemeData.dark(useMaterial3: true).copyWith();

  // —————————————————————————————————————————————————————————————————————————————
  // config
  // —————————————————————————————————————————————————————————————————————————————
  static ThemeMode get theme => _loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light;
  static bool _loadThemeFromBox() => pref.read(kIsDarkMode) ?? true;
  static Future<void> _saveThemeToBox(bool isDarkMode) async => await pref.write(kIsDarkMode, isDarkMode);
  static Future<void> switchTheme() async {
    Get.changeThemeMode(_loadThemeFromBox() ? ThemeMode.light : ThemeMode.dark);
    await _saveThemeToBox(!_loadThemeFromBox());
    await 600.milliseconds.delay(); // free up time
    await Get.forceAppUpdate();
  }
}
