import 'package:get/get.dart';

import 'tester_controller.dart';

class TesterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TesterController>(
      () => TesterController(),
    );
  }
}
