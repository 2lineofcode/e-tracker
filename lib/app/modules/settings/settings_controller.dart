import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/app_base.dart';
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
  final menuSelected = ''.obs;

  /// Page: AutoComplete
  final tfSearchAutoComplete = TextEditingController();
  final tfAddAutoComplete = TextEditingController();
  final autoCompleteList = <AutoCompleteEntity>[].obs;

  /// Page: App Config
  final tfEco = TextEditingController();
  final tfAverage = TextEditingController();
  final tfSpender = TextEditingController();
  final tfCurrencySymbol = TextEditingController();

  @override
  Future<void> onInit() async {
    /// Page: AutoComplete
    menuList.value = await repo.getMenuList();
    await getAutoCompleteList();

    /// Page: App Config
    tfEco.text = pref.read<num>(kFlagEco)?.moneyFormat() ?? '';
    tfAverage.text = pref.read<num>(kFlagAverage)?.moneyFormat() ?? '';
    tfSpender.text = pref.read<num>(kFlagSpender)?.moneyFormat() ?? '';
    tfCurrencySymbol.text = pref.read<String>(kCurrencySymbol) ?? '';

    menuSelected.value = Get.parameters['page'] ?? APP_CONFIG;
    super.onInit();
  }

  Future<void> onMenuChange(String menu) async {
    menuSelected.value = menu;
    closeDrawer();
  }

  Future<void> getAutoCompleteList({String? q}) async {
    change(0, status: RxStatus.loading());
    if (q != null) {
      autoCompleteList.value = await repo.findAutoComplete(q);
    } else {
      autoCompleteList.value = await repo.getAutoComplete();
    }
    change(0, status: RxStatus.success());
  }

  Future<void> onAddAutoComplete(String note) async {
    if (note.isEmpty) return;
    if (note.isBlank!) return;
    await repo.addAutoComplete(note);
    tfAddAutoComplete.clear();
    autoCompleteList.value = await repo.getAutoComplete();
    change(0, status: RxStatus.success());
  }

  Future<void> onDeleteAutoComplete(AutoCompleteEntity entity) async {
    await repo.deleteAutoComplete(entity.note ?? '');
    autoCompleteList.value = await repo.getAutoComplete();
    change(0, status: RxStatus.success());
  }
}
