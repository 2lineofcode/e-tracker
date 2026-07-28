import 'package:get/get.dart';

import 'notes_controller.dart';
import 'notes_repository.dart';

class NotesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotesRepository>(
      () => NotesRepository(),
    );
    Get.lazyPut<NotesController>(
      () => NotesController(),
    );
  }
}
