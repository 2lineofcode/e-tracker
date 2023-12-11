import 'package:get/get.dart';

import 'detail_mutual_controller.dart';

class DetailMutualBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailMutualController>(() => DetailMutualController());
  }
}
