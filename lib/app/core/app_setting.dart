import 'dart:io';

import 'package:ex/ex.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import '../../env.g.dart';
import '../helpers/helpers.dart';
import '../routes/app_pages.dart';
import 'app_base.dart';
import 'const.dart';

class AppSettingService extends GetxService {
  @override
  Future<void> onInit() async {
    await checkAndApplyDefaultAppConfig();
    await initForDesktop();
    await isLogin();
    super.onInit();
  }

  /// ------------------------------------------------------------------------
  /// ! setup default app config [for new user]
  /// ------------------------------------------------------------------------
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

  /// ------------------------------------------------------------------------
  /// ! isLogined
  /// ------------------------------------------------------------------------
  bool get _isLogined => db.auth.currentSession?.user.id != null;
  Future<void> isLogin() async {
    if (!_isLogined) {
      await 500.milliseconds.delay();
      await Get.offAllNamed(Routes.LOGIN);
      OverlayHelper.notification('Auth Issue, Please Login!');
      return;
    }
  }


  /// ------------------------------------------------------------------------
  /// ! initForDesktop
  /// ------------------------------------------------------------------------
  Future<void> initForDesktop() async {
    if (isDesktop) {
      final idealSize = Size(690, 700);
      await windowManager.ensureInitialized();
      WindowOptions windowOptions = WindowOptions(
        title: Env.appName,
        size: idealSize,
        minimumSize: kReleaseMode ? idealSize : null,
        maximumSize: Platform.isWindows ? idealSize : null,
        titleBarStyle: Platform.isMacOS ? TitleBarStyle.hidden : TitleBarStyle.normal,
        alwaysOnTop: Platform.isWindows ? true : false,
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
      );
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    }
  }
}
