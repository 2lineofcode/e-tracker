import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'app/routes/app_pages.dart';
import 'const.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// supabase
  await Supabase.initialize(url: SUPABASE_URL, anonKey: SUPABASE_ANON_KEY);

  /// winman
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = WindowOptions(
    size: Size(655, 700),
    minimumSize: Size(655, 700),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(
    GetMaterialApp(
      title: 'Application',
      initialRoute: AppPages.INITIAL,
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      getPages: AppPages.routes,
    ),
  );
}
