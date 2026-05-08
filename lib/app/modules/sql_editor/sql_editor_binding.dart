import 'package:get/get.dart';

import 'sql_editor_controller.dart';

class SqlEditorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SqlEditorController>(() => SqlEditorController());
  }
}
