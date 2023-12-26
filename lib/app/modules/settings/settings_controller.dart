import 'dart:async';

import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../core/app_api.dart';
import '../../core/app_setting.dart';
import '../../core/const.dart';
import '../../helpers/helper_misc.dart';
import '../../helpers/helper_money.dart';
import '../../models/autocomplete_entity.dart';
import '../../models/user_profile_entity.dart';
import '../../routes/app_pages.dart';
import '../home/home_controller.dart';
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
  final autoCompleteList = <AutoComplete>[].obs;

  /// Page: App Config
  final tfEco = TextEditingController();
  final tfAverage = TextEditingController();
  final tfSpender = TextEditingController();
  final tfCurrencySymbol = TextEditingController();
  final userProfile = UserProfile().obs;

  @override
  Future<void> onInit() async {
    /// Page: AutoComplete
    menuList.value = await repo.getMenuList();
    unawaited(getAutoCompleteList());
    unawaited(getUserProfile());

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

  Future<void> getUserProfile() async {
    userProfile.value = await repo.getUserProfile().then((value) => value[0]);
  }

  Future<void> getAutoCompleteList({String? q}) async {
    try {
      change(0, status: RxStatus.loading());
      if (q != null) {
        autoCompleteList.value = await repo.findAutoComplete(q);
      } else {
        autoCompleteList.value = await repo.getAutoComplete();
      }

      if (autoCompleteList.isEmpty) {
        change(0, status: RxStatus.empty());
      } else {
        change(200, status: RxStatus.success());
      }
    } catch (e) {
      change(400, status: RxStatus.error('$e'));
    }
  }

  Future<void> onAddAutoComplete(String note) async {
    if (note.isEmpty) return;
    if (note.isBlank!) return;
    await repo.addAutoComplete(note);
    tfAddAutoComplete.clear();
    autoCompleteList.value = await repo.getAutoComplete();
    change(0, status: RxStatus.success());
  }

  Future<void> onDeleteAutoComplete(AutoComplete entity) async {
    await repo.deleteAutoComplete(entity.note ?? '');
    autoCompleteList.value = await repo.getAutoComplete();
    change(0, status: RxStatus.success());
  }

  Future<void> onLogout() async {
    ExLoading.show(
      paddingSymmetric: Get.context!.isMobile ? 90 : 250,
      child: CupertinoActivityIndicator(),
    );
    await db.auth.signOut();
    await Get.delete<HomeController>();
    await Get.offAllNamed(Routes.LOGIN);
    ExLoading.dismiss();
  }
}
