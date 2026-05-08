import 'package:get/get.dart';

import '../modules/auth/login/login_binding.dart';
import '../modules/auth/login/login_view.dart';
import '../modules/calcp/calcp_binding.dart';
import '../modules/calcp/calcp_view.dart';
import '../modules/filtering/filtering_binding.dart';
import '../modules/filtering/filtering_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/settings/settings_binding.dart';
import '../modules/settings/settings_view.dart';
import '../modules/sql_editor/sql_editor_binding.dart';
import '../modules/sql_editor/sql_editor_view.dart';
import '../modules/summary/summary_binding.dart';
import '../modules/summary/summary_view.dart';
import '../modules/tester/tester_binding.dart';
import '../modules/tester/tester_view.dart';
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
      name: Routes.SQL_EDITOR,
      page: () => const SqlEditorView(),
      binding: SqlEditorBinding(),
    ),
    GetPage(
      name: Routes.CALCP,
      page: () => const CalcpView(),
      binding: CalcpBinding(),
    ),
    GetPage(
      name: Routes.TESTER,
      page: () => const TesterView(),
      binding: TesterBinding(),
    ),
  ];
}
