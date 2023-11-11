import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'const.dart';

class AppSettingService extends GetxService {
  @override
  Future<void> onInit() async {
    logI('-- app service init --');

    if (!pref.hasData(kFlagEco) || !pref.hasData(kFlagAverage) || !pref.hasData(kFlagSpender) || !pref.hasData(kIsDarkMode)) {
      logI('-- provide default setting data --');
      await pref.write(kFlagEco, 50000);
      await pref.write(kFlagAverage, 100000);
      await pref.write(kFlagSpender, 100000);
      await pref.write(kIsDarkMode, true);
    }
    super.onInit();
  }

  /// theme management
  ThemeMode get theme => _loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light;
  bool _loadThemeFromBox() => pref.read(kIsDarkMode) ?? false;
  Future<void> _saveThemeToBox(bool isDarkMode) async => pref.write(kIsDarkMode, isDarkMode);
  Future<void> switchTheme() async {
    Get.changeThemeMode(_loadThemeFromBox() ? ThemeMode.light : ThemeMode.dark);
    await _saveThemeToBox(!_loadThemeFromBox());
  }
}
