import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/const.dart';
import '../../helpers/helper_misc.dart';
import '../../helpers/helper_money.dart';
import '../../models/autocomplete_entity.dart';
import 'settings_repository.dart';

class SettingsController extends GetxController with StateMixin {
  // repo
  final repo = Get.find<SettingsRepository>();

  // menu
  final menuList = <String>[].obs;
  final menuSelected = AUTO_COMPLETE.obs;

  /// Page: AutoComplete
  final tfAutoComplete = TextEditingController();
  final autoCompleteList = <AutoCompleteEntity>[].obs;

  /// Page: App Config
  final tfEco = TextEditingController();
  final tfAverage = TextEditingController();
  final tfSpender = TextEditingController();

  @override
  Future<void> onInit() async {
    /// Page: AutoComplete
    menuList.value = await repo.getMenuList();
    autoCompleteList.value = await repo.getAutoComplete();

    /// Page: App Config
    tfEco.text = pref.read<num>(kFlagEco)?.moneyFormat() ?? '';
    tfAverage.text = pref.read<num>(kFlagAverage)?.moneyFormat() ?? '';
    tfSpender.text = pref.read<num>(kFlagSpender)?.moneyFormat() ?? '';

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
