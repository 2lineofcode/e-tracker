import 'dart:io';

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
  await dotenv.load();

  /// supabase
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY'),
  );

  /// desktop only
  if (PlatformUtil.isDesktop()) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      size: Size(655, 700),
      // minimumSize: Size(655, 700),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: Platform.isMacOS ? TitleBarStyle.hidden : TitleBarStyle.normal,
      alwaysOnTop: Platform.isMacOS ? false : true,
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
      // .copyWith(
      //   textTheme: GoogleFonts.latoTextTheme(TextTheme()),
      // ),
      debugShowCheckedModeBanner: false,
      scrollBehavior: PlatformUtil.isDesktop() ? NoThumbScrollBehavior() : null,
      getPages: AppPages.routes,
    ),
  );
}
