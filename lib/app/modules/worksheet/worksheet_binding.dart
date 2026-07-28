import 'package:get/get.dart';

import 'worksheet_controller.dart';

class TesterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorksheetController>(
      () => WorksheetController(),
    );
  }
}
