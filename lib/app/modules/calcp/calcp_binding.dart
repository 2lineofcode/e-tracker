import 'package:get/get.dart';

import 'calcp_controller.dart';

class CalcpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CalcpController>(
      () => CalcpController(),
    );
  }
}
