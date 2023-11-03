import 'package:get/get.dart';

import 'filtering_controller.dart';
import 'filtering_repository.dart';

class FilteringBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FilteringRepository>(() => FilteringRepository());
    Get.lazyPut<FilteringController>(() => FilteringController());
  }
}
