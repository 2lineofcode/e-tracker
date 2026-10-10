import 'dart:io';

import 'package:ex_kit/ex.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:window_manager/window_manager.dart';

import '../../env.g.dart';
import '../helpers/helpers.dart';
import '../models/supa_user_profile_entity.dart';
import 'app_api.dart';
import 'app_color.dart';
import 'const.dart';

/// handy call sharedpref
final pref = GetStorage(kStorageKey);

class AppSettingService extends GetxService {
  @override
  Future<void> onInit() async {
    await setupDesktop();
    await setupAppPref();
    super.onInit();
  }

  /// ------------------------------------------------------------------------
  /// ! setup default app config [for new user]
  /// ------------------------------------------------------------------------
  Future<void> setupAppPref() async {
    final userId = db.auth.currentSession?.user.id;
    if (userId == null) {
      logI('-- CONFIG SKIPPED (not authenticated) --');
      return;
    }

    final response = await db
        .from('profiles')
        .select()
        .eq('id', userId)
        .withConverter<List<SupaUserProfile>>(
          (data) => (data).map((e) => SupaUserProfile.fromJson(e)).toList(),
        );
    if (response.isEmpty) {
      logE('No profile found for $userId');
      return;
    }

    await applyProfilePreferences(response.first);
    if (!pref.hasData(kCurrencySymbol)) await pref.write(kCurrencySymbol, 'Rp. ');
    if (!pref.hasData(kIsDarkMode)) await pref.write(kIsDarkMode, true);
    if (!pref.hasData(kThemeColor)) await pref.write(kThemeColor, AppColor.defaultThemeColor);

    if (!pref.hasData(kCalendarStartDay)) {
      await pref.write(kCalendarStartDay, 1);
    }

    logI('-- CONFIG LOADED --');
  }

  Future<void> applyProfilePreferences(SupaUserProfile profile) async {
    await pref.write(kFlagEco, profile.ecoDay ?? 50000);
    await pref.write(kFlagAverage, profile.averageDay ?? 100000);
    await pref.write(kFlagSpender, profile.spenderDay ?? 100000);
  }

  /// ------------------------------------------------------------------------
  /// ! initForDesktop
  /// ------------------------------------------------------------------------
  Future<void> setupDesktop() async {
    if (!isDesktop) return;

    final idealSize = Size(690, 720); // desktop
    // final idealSize = Size(390, 720); // mobile

    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      title: Env.appName,
      size: idealSize,
      minimumSize: kReleaseMode ? idealSize : null,
      maximumSize: Platform.isWindows ? idealSize : null,
      titleBarStyle: Platform.isMacOS
          ? TitleBarStyle.hidden
          : TitleBarStyle.normal,
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
