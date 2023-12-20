import 'package:get/get.dart';

import '_explore/section_bibit_explore_controller.dart';
import '_home/section_bibit_home_controller.dart';
import '_performance/section_bibit_performance_controller.dart';
import '_portfolio/section_bibit_portfolio_controller.dart';
import 'bibit_controller.dart';
import 'bibit_repository.dart';

class BibitBinding extends Bindings {
  @override
  void dependencies() {
    // section
    Get.lazyPut<SectionBibitHomeController>(() => SectionBibitHomeController());
    Get.lazyPut<SectionBibitPorfolioController>(() => SectionBibitPorfolioController());
    Get.lazyPut<SectionBibitPerformanceController>(() => SectionBibitPerformanceController());
    Get.lazyPut<SectionBibitExploreController>(() => SectionBibitExploreController());

    Get.lazyPut<BibitRepository>(() => BibitRepository());
    Get.lazyPut<BibitController>(() => BibitController());
  }
}
