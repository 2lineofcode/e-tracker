import 'dart:io';

import 'package:ex/ex.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'app/core/app_setting.dart';
import 'app/helpers/helper_misc.dart';
import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// env
  if (kDebugMode) {
    await dotenv.load(fileName: '.env.local');
  } else {
    await dotenv.load(fileName: '.env');
  }

  /// supabase
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY'),
  );

  /// local storage
  await GetStorage.init();

  /// load app setting
  Get.put(AppSettingService());

  /// desktop only
  if (PlatformUtil.isDesktop()) {
    final idealSize = Size(675, 700);
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      title: dotenv.get('APP_NAME'),
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

  runApp(
    GetMaterialApp(
      title: dotenv.get('APP_NAME'),
      initialRoute: AppPages.INITIAL,
      theme: ThemeData.light(),
      themeMode: Get.find<AppSettingService>().theme,
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      getPages: AppPages.routes,
      builder: (context, child) {
        if (kReleaseMode) return child!;
        return Scaffold(
          body: Stack(
            children: [
              child!,
              HStack(
                [
                  IconButton(
                    icon: Icon(Icons.bug_report),
                    onPressed: () async {
                      await Get.find<AppSettingService>().switchTheme();
                      await 300.milliseconds.delay();
                      await Get.forceAppUpdate();
                    },
                  ),
                  12.widthBox,
                  IconButton(
                    icon: Icon(Icons.abc),
                    onPressed: () async {
                      await Get.forceAppUpdate();
                    },
                  ),
                ],
              ).positioned(left: 100),
            ],
          ),
        );
      },
    ),
  );
}
