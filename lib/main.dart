import 'package:ex_kit/ex.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:uicons_pro/uicons_pro.dart';

import 'app/core/app_setting.dart';
import 'app/core/app_theme.dart';
import 'app/core/const.dart';
import 'app/routes/app_middleware.dart';
import 'app/routes/app_pages.dart';
import 'env.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sw = Stopwatch()..start();

  /// supabase
  await Supabase.initialize(url: Env.supabaseUrl, publishableKey: Env.supabaseAnonKey);

  /// local storage
  await GetStorage.init(kStorageKey);

  /// app setting
  await Get.putAsync(() async => AppSettingService());

  sw.stop();
  logD('All Depedencies loaded in ${sw.elapsedMilliseconds}ms');
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
      child: ToastificationWrapper(
        child: GetMaterialApp(
          title: Env.appName,
          localizationsDelegates: FleatherLocalizations.localizationsDelegates,
          initialRoute: AppPages.INITIAL,
          theme: AppTheme.light,
          themeMode: AppTheme.currentTheme,
          darkTheme: AppTheme.dark,
          debugShowCheckedModeBanner: false,
          getPages: AppPages.routes,
          unknownRoute: GetPage(
            name: '/404',
            page: () => const NotFoundScreen(),
          ),
          defaultTransition: Transition.fadeIn,
          builder: (context, child) {
            if (kReleaseMode) return child!;
            return Scaffold(
              body: Stack(
                children: [
                  child!,
                  HStack([
                    IconButton(
                      icon: Icon(UIconsPro.solidRounded.circle, size: 16),
                      onPressed: () async => await AppTheme.switchTheme(),
                    ),
                  ]).positioned(left: 0),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
