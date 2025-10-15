import 'dart:io';

import 'package:ex_kit/ex.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:groq/groq.dart';
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
    await checkAndApplyDefaultAppConfig();
    await initForDesktop();
    super.onInit();
  }

  /// ------------------------------------------------------------------------
  /// ! setup default app config [for new user]
  /// ------------------------------------------------------------------------
  Future<void> checkAndApplyDefaultAppConfig() async {
    final response = await db //
        .from('profiles')
        .select()
        .eq('id', db.auth.currentSession?.user.id ?? '')
        .withConverter<List<SupaUserProfile>>((data) {
      return (data).map((e) => SupaUserProfile.fromJson(e)).toList();
    });

    await pref.write(kFlagEco, response[0].ecoDay ?? 50000);
    await pref.write(kFlagAverage, response[0].averageDay ?? 100000);
    await pref.write(kFlagSpender, response[0].spenderDay ?? 100000);

    if (!pref.hasData(kFlagEco) || //
        !pref.hasData(kFlagAverage) ||
        !pref.hasData(kFlagSpender) ||
        !pref.hasData(kCurrencySymbol) ||
        !pref.hasData(kIsDarkMode)) {
      await pref.write(kCurrencySymbol, 'Rp. ');
      await pref.write(kIsDarkMode, true);
    }
    logI('-- CONFIG LOADED --');
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
