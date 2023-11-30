import 'package:get/get.dart';

import 'bibit_controller.dart';
import 'bibit_repository.dart';

class BibitBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BibitRepository>(() => BibitRepository());
    Get.lazyPut<BibitController>(() => BibitController());
  }
}
