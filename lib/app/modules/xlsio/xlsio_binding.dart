import 'package:get/get.dart';

import 'xlsio_controller.dart';

class XlsioBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<XlsioController>(() => XlsioController());
  }
}
