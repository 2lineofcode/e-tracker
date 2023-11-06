import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../models/autocomplete_note_entity.dart';
import 'settings_repository.dart';

class SettingsController extends GetxController with StateMixin {
  // repo
  final repo = Get.find<SettingsRepository>();

  // menu
  final menuList = <String>[].obs;
  final menuSelected = AUTO_COMPLETE.obs;

  // AutocompleteNote
  final tfAutocompleteNote = TextEditingController();
  final autocompleteNote = <AutocompleteNoteEntity>[].obs;

  @override
  Future<void> onInit() async {
    menuList.value = await repo.getMenuList();
    autocompleteNote.value = await repo.getAutocompleteNote();
    change(0, status: RxStatus.success());
    super.onInit();
  }

  void onMenuChange(String menu) {
    menuSelected.value = menu;
  }

  Future<void> onAddAutocompleteNote(String note) async {
    if (note.isEmpty) return;
    if (note.isBlank!) return;
    await repo.addAutocompleteNote(note);
    tfAutocompleteNote.clear();
    autocompleteNote.value = await repo.getAutocompleteNote();
    change(0, status: RxStatus.success());
  }

  Future<void> onDeleteAutocompleteNote(AutocompleteNoteEntity entity) async {
    await repo.deleteAutocompleteNote(entity.note ?? '');
    autocompleteNote.value = await repo.getAutocompleteNote();
    change(0, status: RxStatus.success());
  }
}
