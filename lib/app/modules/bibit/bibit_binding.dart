import 'package:get/get.dart';

import '_home/section_bibit_home_controller.dart';
import 'bibit_controller.dart';
import 'bibit_repository.dart';

class BibitBinding extends Bindings {
  @override
  void dependencies() {
    // section_home
    Get.lazyPut<SectionBibitHomeController>(() => SectionBibitHomeController());

    Get.lazyPut<BibitRepository>(() => BibitRepository());
    Get.lazyPut<BibitController>(() => BibitController());
  }
}
