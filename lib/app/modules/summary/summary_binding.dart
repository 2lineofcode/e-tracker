import 'package:get/get.dart';

import 'summary_controller.dart';
import 'summary_repository.dart';

class SummaryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SummaryRepository>(() => SummaryRepository());
    Get.lazyPut<SummaryController>(() => SummaryController());
  }
}
