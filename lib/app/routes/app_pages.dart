import 'package:get/get.dart';

import '../modules/auth/login/login_binding.dart';
import '../modules/auth/login/login_view.dart';
import '../modules/filtering/filtering_binding.dart';
import '../modules/filtering/filtering_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/settings/settings_binding.dart';
import '../modules/settings/settings_view.dart';
import '../modules/summary/summary_binding.dart';
import '../modules/summary/summary_view.dart';
import '../modules/xlsio/xlsio_binding.dart';
import '../modules/xlsio/xlsio_view.dart';
import 'app_middleware.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.ROOT;

  static final routes = [
    /// ------------------------------------------------------------------------
    /// ! root
    /// ------------------------------------------------------------------------
    GetPage(
      name: Routes.ROOT,
      page: () => HomeView(),
      binding: HomeBinding(),
      middlewares: [AppMiddleware()],
    ),

    /// ------------------------------------------------------------------------

    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      middlewares: [AppMiddleware()],
    ),
    GetPage(
      name: Routes.SUMMARY,
      page: () => const SummaryView(),
      binding: SummaryBinding(),
      middlewares: [AppMiddleware()],
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      middlewares: [AppMiddleware()],
    ),
    GetPage(
      name: Routes.FILTERING,
      page: () => const FilteringView(),
      binding: FilteringBinding(),
      middlewares: [AppMiddleware()],
    ),
    GetPage(
      name: Routes.XLSIO,
      page: () => const XlsioView(),
      binding: XlsioBinding(),
    ),
  ];
}
