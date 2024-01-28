import 'package:get/get.dart';

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
      name: Routes.BIBIT,
      page: () => const BibitView(),
      binding: BibitBinding(),
      middlewares: [AppMiddleware()],
    ),
    GetPage(
      name: Routes.DETAIL_STOCK,
      page: () => const DetailStockView(),
      binding: DetailStockBinding(),
      middlewares: [AppMiddleware()],
    ),
    GetPage(
      name: Routes.DETAIL_CRYPTO,
      page: () => const DetailCryptoView(),
      binding: DetailCryptoBinding(),
      middlewares: [AppMiddleware()],
    ),
    GetPage(
      name: Routes.DETAIL_MUTUAL,
      page: () => const DetailMutualView(),
      binding: DetailMutualBinding(),
      middlewares: [AppMiddleware()],
    ),
    GetPage(
      name: Routes.DETAIL_PORTFOLIO,
      page: () => const DetailPortfolioView(),
      binding: DetailPortfolioBinding(),
      middlewares: [AppMiddleware()],
    ),
  ];
}
