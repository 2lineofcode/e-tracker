import 'package:get/get.dart';

import '../bibit_repository.dart';
import 'detail_mutual_controller.dart';

class DetailMutualBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BibitRepository>(() => BibitRepository());
    Get.lazyPut<DetailMutualController>(() => DetailMutualController());
  }
}
