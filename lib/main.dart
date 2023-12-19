import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/core/app_setting.dart';
import 'app/core/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'env.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// supabase
  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);

  /// local storage
  await GetStorage.init();

  /// app setting
  Get.put(AppSettingService());

  /// http
  Get.put(ExHttp(baseURL: Env.bibitApiUrl), tag: 'bibit');

  runApp(expenseTracker());
}

Widget expenseTracker() {
  return GestureDetector(
    onTap: () {
      FocusScopeNode currentFocus = FocusScope.of(Get.context!);
      if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
    },
    child: GetMaterialApp(
      title: Env.appName,
      initialRoute: AppPages.INITIAL,
      theme: AppTheme.light,
      themeMode: AppTheme.currentTheme,
      darkTheme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      getPages: AppPages.routes,
      defaultTransition: Transition.fadeIn,
      builder: (context, child) {
        if (kReleaseMode) return child!;
        return Scaffold(
          body: Stack(
            children: [
              child!,
              IconButton(
                icon: Icon(CupertinoIcons.square_stack_3d_down_right_fill),
                onPressed: () async => await AppTheme.switchTheme(),
              ).positioned(left: 72),
            ],
          ),
        );
      },
    ),
  );
}
