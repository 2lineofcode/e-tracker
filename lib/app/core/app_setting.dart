import 'dart:io';

import 'package:ex_kit/ex.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:groq/groq.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:overlayment/overlayment.dart';
import 'package:window_manager/window_manager.dart';

import '../../env.g.dart';
import '../helpers/helpers.dart';
import '../models/supa_user_profile_entity.dart';
import 'app_api.dart';
import 'const.dart';

/// handy call sharedpref
final pref = GetStorage(kStorageKey);

final gemini = Gemini.instance;

final groq = Groq(
  apiKey: Env.groqApiKey,
  configuration: Configuration(model: 'openai/gpt-oss-20b', temperature: 0.2),
);

class AppSettingService extends GetxService {
  @override
  Future<void> onInit() async {
    await setupDesktop();
    await setupAppPref();
    await setupHotkey();
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

    final needInit = [
      kFlagEco,
      kFlagAverage,
      kFlagSpender,
      kCurrencySymbol,
      kIsDarkMode,
    ].any((key) => !pref.hasData(key));

    if (needInit) {
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

      final profile = response.first;

      await pref.write(kCurrencySymbol, 'Rp. ');
      await pref.write(kIsDarkMode, true);
      await pref.write(kFlagEco, profile.ecoDay ?? 50000);
      await pref.write(kFlagAverage, profile.averageDay ?? 100000);
      await pref.write(kFlagSpender, profile.spenderDay ?? 100000);
    }

    logI('-- CONFIG LOADED --');
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

  // ────────────────────────────────────────────────────────────────
  // ⵌ hotkey
  // ────────────────────────────────────────────────────────────────
  Future<void> setupHotkey() async {
    if (!isDesktop) return;

    HotKey _hotKeyEsc = HotKey(
      key: PhysicalKeyboardKey.escape,
      modifiers: [],
      scope: HotKeyScope.inapp,
    );

    await hotKeyManager.register(
      _hotKeyEsc,
      keyUpHandler: (hotKey) {
        logD('hotKeyEsc Pressed');
        try {
          if (Get.isDialogOpen!) {
            Get.back();
          }
          if (Overlayment.count != 0) {
            Overlayment.dismissLast();
          }
        } catch (_) {}
      },
    );
  }
}
