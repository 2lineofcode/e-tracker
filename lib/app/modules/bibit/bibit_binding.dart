import 'package:get/get.dart';

import '../../repository/repo_bibit.dart';
import '../../repository/repo_stockbit.dart';
import '_explore/section_bibit_explore_controller.dart';
import '_home/section_bibit_home_controller.dart';
import '_performance/section_bibit_performance_controller.dart';
import '_portfolio/section_bibit_portfolio_controller.dart';
import '_transaction/section_bibit_transaction_controller.dart';
import 'bibit_controller.dart';

class BibitBinding extends Bindings {
  @override
  void dependencies() {
    /// repo
    Get.lazyPut<BibitRepository>(() => BibitRepository());
    Get.lazyPut<StockbitRepository>(() => StockbitRepository());

    /// controller
    Get.lazyPut<SectionBibitHomeController>(() => SectionBibitHomeController());
    Get.lazyPut<SectionBibitPorfolioController>(() => SectionBibitPorfolioController());
    Get.lazyPut<SectionBibitPerformanceController>(() => SectionBibitPerformanceController());
    Get.lazyPut<SectionBibitExploreController>(() => SectionBibitExploreController());
    Get.lazyPut<SectionBibitTransactionController>(() => SectionBibitTransactionController());
    Get.lazyPut<BibitController>(() => BibitController());
  }
}
