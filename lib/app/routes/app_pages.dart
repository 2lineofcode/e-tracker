import 'package:get/get.dart';

import '../modules/bibit/bibit_binding.dart';
import '../modules/bibit/bibit_view.dart';
import '../modules/filtering/filtering_binding.dart';
import '../modules/filtering/filtering_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/settings/settings_binding.dart';
import '../modules/settings/settings_view.dart';
import '../modules/summary/summary_binding.dart';
import '../modules/summary/summary_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SUMMARY,
      page: () => const SummaryView(),
      binding: SummaryBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.FILTERING,
      page: () => const FilteringView(),
      binding: FilteringBinding(),
    ),
    GetPage(
      name: _Paths.BIBIT,
      page: () => const BibitView(),
      binding: BibitBinding(),
    ),
  ];
}
