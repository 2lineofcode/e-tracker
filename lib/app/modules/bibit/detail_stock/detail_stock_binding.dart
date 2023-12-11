import 'package:get/get.dart';

import 'detail_stock_controller.dart';

class DetailStockBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailStockController>(() => DetailStockController());
  }
}
