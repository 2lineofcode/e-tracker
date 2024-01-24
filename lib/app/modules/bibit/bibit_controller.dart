import 'dart:async';

import 'package:ex/ex.dart';
import 'package:get/get.dart';

import '../../core/app_api.dart';
import '../../helpers/helpers.dart';
import '../../models/stockbit_companies_info_entity.dart';
import '../../repository/repo_bibit.dart';
import '../../repository/repo_stockbit.dart';
import '../../routes/app_pages.dart';

class BibitController extends GetxController with StateMixin {
  final repoBibit = Get.find<BibitRepository>();
  final repoStockbit = Get.find<StockbitRepository>();

  final menuSelected = 'Home'.obs;
  final getCompaniesInfo = StockbitCompaniesInfoData().obs;

  final isMarketOpen = false.obs;
  late Timer? timerMarketOpen;

  @override
  Future<void> onInit() async {
    /// additional security! check login status
    if (db.auth.currentSession?.user.id == null) {
      await 800.milliseconds.delay();
      await db.auth.signOut();
      await Get.offAllNamed(Routes.LOGIN);
    }
    getCompaniesInfo.value = await repoStockbit.getCompaniesInfo();
    isMarketOpen.value = getCompaniesInfo.value.marketHours?.status != 'close';
    change(200, status: RxStatus.success());
    super.onInit();
  }

  Future<void> onMenuChange(String menu) async {
    menuSelected.value = menu;
    closeDrawer();
  }
}
