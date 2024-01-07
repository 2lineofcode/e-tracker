import 'package:get/get.dart';

import '../core/app_api.dart';
import '../modules/auth/login/login_binding.dart';
import '../modules/auth/login/login_view.dart';
import '../modules/bibit/bibit_binding.dart';
import '../modules/bibit/bibit_view.dart';
import '../modules/bibit/detail_crypto/detail_crypto_binding.dart';
import '../modules/bibit/detail_crypto/detail_crypto_view.dart';
import '../modules/bibit/detail_mutual/detail_mutual_binding.dart';
import '../modules/bibit/detail_mutual/detail_mutual_view.dart';
import '../modules/bibit/detail_portfolio/detail_portfolio_binding.dart';
import '../modules/bibit/detail_portfolio/detail_portfolio_view.dart';
import '../modules/bibit/detail_stock/detail_stock_binding.dart';
import '../modules/bibit/detail_stock/detail_stock_view.dart';
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

  static const INITIAL = Routes.ROOT;

  static final routes = [
    /// ------------------------------------------------------------------------
    /// ! root
    /// ------------------------------------------------------------------------
    GetPage(
      name: Routes.ROOT,
      page: () =>
          db.auth.currentSession?.user.id != null ? HomeView() : LoginView(),
      binding: db.auth.currentSession?.user.id != null
          ? HomeBinding()
          : LoginBinding(),
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
    ),
    GetPage(
      name: Routes.SUMMARY,
      page: () => const SummaryView(),
      binding: SummaryBinding(),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.FILTERING,
      page: () => const FilteringView(),
      binding: FilteringBinding(),
    ),
    GetPage(
      name: Routes.BIBIT,
      page: () => const BibitView(),
      binding: BibitBinding(),
    ),
    GetPage(
      name: Routes.DETAIL_STOCK,
      page: () => const DetailStockView(),
      binding: DetailStockBinding(),
    ),
    GetPage(
      name: Routes.DETAIL_CRYPTO,
      page: () => const DetailCryptoView(),
      binding: DetailCryptoBinding(),
    ),
    GetPage(
      name: Routes.DETAIL_MUTUAL,
      page: () => const DetailMutualView(),
      binding: DetailMutualBinding(),
    ),
    GetPage(
      name: Routes.DETAIL_PORTFOLIO,
      page: () => const DetailPortfolioView(),
      binding: DetailPortfolioBinding(),
    ),
  ];
}
