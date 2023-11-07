import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../helpers/helper_misc.dart';
import '../../models/autocomplete_entity.dart';
import 'settings_repository.dart';

class SettingsController extends GetxController with StateMixin {
  // repo
  final repo = Get.find<SettingsRepository>();

  // menu
  final menuList = <String>[].obs;
  final menuSelected = AUTO_COMPLETE.obs;

  // AutoComplete
  final tfAutoComplete = TextEditingController();
  final autoCompleteList = <AutoCompleteEntity>[].obs;

  @override
  Future<void> onInit() async {
    menuList.value = await repo.getMenuList();
    autoCompleteList.value = await repo.getAutoComplete();
    change(0, status: RxStatus.success());
    super.onInit();
  }

  void onMenuChange(String menu) {
    menuSelected.value = menu;
    closeDrawer();
  }

  Future<void> onAddAutoComplete(String note) async {
    if (note.isEmpty) return;
    if (note.isBlank!) return;
    await repo.addAutoComplete(note);
    tfAutoComplete.clear();
    autoCompleteList.value = await repo.getAutoComplete();
    change(0, status: RxStatus.success());
  }

  Future<void> onDeleteAutoComplete(AutoCompleteEntity entity) async {
    await repo.deleteAutoComplete(entity.note ?? '');
    autoCompleteList.value = await repo.getAutoComplete();
    change(0, status: RxStatus.success());
  }
}
