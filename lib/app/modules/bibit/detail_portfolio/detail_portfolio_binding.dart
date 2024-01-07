import 'package:get/get.dart';

import 'detail_portfolio_controller.dart';

class DetailPortfolioBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailPortfolioController>(() => DetailPortfolioController());
  }
}
