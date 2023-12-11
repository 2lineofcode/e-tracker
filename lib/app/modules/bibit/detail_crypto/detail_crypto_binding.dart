import 'package:get/get.dart';

import 'detail_crypto_controller.dart';

class DetailCryptoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailCryptoController>(() => DetailCryptoController());
  }
}
