import 'dart:io';

import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'app/core/app_setting.dart';
import 'app/core/app_theme.dart';
import 'app/helpers/helper_misc.dart';
import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initAppConfig();
  await initAppService();
  runApp(expenseTracker());
}

Future<void> initAppConfig() async {
  /// env
  await dotenv.load(fileName: kReleaseMode ? '.env' : '.env.local');

  /// supabase
  await Supabase.initialize(url: dotenv.get('SUPABASE_URL'), anonKey: dotenv.get('SUPABASE_ANON_KEY'));

  /// local storage
  await GetStorage.init();

  /// setup for desktop
  if (isDesktop) {
    final idealSize = Size(690, 700);
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
}

Future<void> initAppService() async {
  Get.put(AppSettingService());
  Get.put(ExHttp(baseURL: dotenv.get('BIBIT_API_URL')), tag: 'bibit');
}

Widget expenseTracker() {
  return GestureDetector(
    onTap: () {
      FocusScopeNode currentFocus = FocusScope.of(Get.context!);
      if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
    },
    child: GetMaterialApp(
      title: dotenv.get('APP_NAME'),
      initialRoute: AppPages.INITIAL,
      theme: AppTheme.light,
      themeMode: AppTheme.theme,
      darkTheme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      getPages: AppPages.routes,
      builder: (context, child) {
        if (kReleaseMode) return child!;
        return Scaffold(
          body: Stack(
            children: [
              child!,
              IconButton(
                icon: Icon(CupertinoIcons.square_stack_3d_down_right_fill),
                onPressed: () => AppTheme.switchTheme(),
              ).positioned(left: 72),
            ],
          ),
        );
      },
    ),
  );
}
