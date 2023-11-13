import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_base.dart';
import 'const.dart';

class AppSettingService extends GetxService {
  @override
  Future<void> onReady() async {
    await checkAndApplyDefaultAppConfig();
    super.onReady();
  }

  // ------------------------------------------------------------------------
  // if new user: setup default app config
  // ------------------------------------------------------------------------
  Future<void> checkAndApplyDefaultAppConfig() async {
    if (!pref.hasData(kFlagEco) || //
        !pref.hasData(kFlagAverage) ||
        !pref.hasData(kFlagSpender) ||
        !pref.hasData(kCurrencySymbol) ||
        !pref.hasData(kIsDarkMode)) {
      await pref.write(kFlagEco, 50000);
      await pref.write(kFlagAverage, 100000);
      await pref.write(kFlagSpender, 100000);
      await pref.write(kCurrencySymbol, 'Rp. ');
      await pref.write(kIsDarkMode, true);
      logI('-- CONFIG CREATED --');
    }
  }

  // ------------------------------------------------------------------------
  // theme management
  // ------------------------------------------------------------------------
  Future<void> switchTheme() async {
    Get.changeThemeMode(_getCurrentTheme() ? ThemeMode.light : ThemeMode.dark);
    await _changeCurrentTheme(!_getCurrentTheme());
    await 600.milliseconds.delay(); // free up time
    await Get.forceAppUpdate();
  }

  ThemeMode get theme => _getCurrentTheme() ? ThemeMode.dark : ThemeMode.light;
  bool _getCurrentTheme() => pref.read(kIsDarkMode) ?? true;
  Future<void> _changeCurrentTheme(bool isDarkMode) async => await pref.write(kIsDarkMode, isDarkMode);
}
