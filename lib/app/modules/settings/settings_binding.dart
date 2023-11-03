import 'package:get/get.dart';

import 'settings_controller.dart';
import 'settings_repository.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsRepository>(() => SettingsRepository());
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
