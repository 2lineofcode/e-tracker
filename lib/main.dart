import 'package:ex_kit/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/core/app_setting.dart';
import 'app/core/app_theme.dart';
import 'app/core/const.dart';
import 'app/routes/app_middleware.dart';
import 'app/routes/app_pages.dart';
import 'env.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// gemini
  Gemini.init(apiKey: Env.geminiApiKey);

  /// supabase
  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);

  /// local storage
  await GetStorage.init(kStorageKey);

  /// app setting
  Get.put(AppSettingService());

  /// http
  Get.put(ExHttp(baseURL: Env.bibitApiUrl), tag: 'bibit');
  Get.put(ExHttp(baseURL: Env.mdvkApiUrl), tag: 'mdvk');

  runApp(ExpenseTracker());
}

class ExpenseTracker extends StatelessWidget {
  const ExpenseTracker({super.key});

  @override
  Widget build(BuildContext context) {
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
        unknownRoute: GetPage(name: '/404', page: () => const NotFoundScreen()),
        defaultTransition: Transition.fadeIn,
        builder: (context, child) {
          if (kReleaseMode) return child!;
          return Scaffold(
            body: Stack(
              children: [
                child!,
                HStack([
                  IconButton(
                    icon: Icon(CupertinoIcons.circle_lefthalf_fill, size: 16),
                    onPressed: () async => await AppTheme.switchTheme(),
                  ),
                ]).positioned(left: 72),
              ],
            ),
          );
        },
      ),
    );
  }
}
