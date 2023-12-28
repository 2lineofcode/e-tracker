import 'package:get/get.dart';

import '../../../repository/repo_bibit.dart';
import '../../../repository/repo_stockbit.dart';
import 'detail_stock_controller.dart';

class DetailStockBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BibitRepository>(() => BibitRepository());
    Get.lazyPut<StockbitRepository>(() => StockbitRepository());
    
    Get.lazyPut<DetailStockController>(() => DetailStockController());
  }
}
