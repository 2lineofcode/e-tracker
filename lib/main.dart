import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';

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
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      scrollBehavior: PlatformUtil.isDesktop() ? NoThumbScrollBehavior() : null,
      getPages: AppPages.routes,
    ),
  );
}
