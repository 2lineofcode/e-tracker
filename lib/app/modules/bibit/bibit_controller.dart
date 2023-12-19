import 'package:ex/ex.dart';
import 'package:get/get.dart';

import '../../core/app_base.dart';
import '../../helpers/helpers.dart';
import '../../routes/app_pages.dart';
import '_explore/section_bibit_explore_controller.dart';
import '_home/section_bibit_home_controller.dart';
import '_portfolio/section_bibit_portfolio_controller.dart';
import 'bibit_repository.dart';

class BibitController extends GetxController with StateMixin {
  final repo = Get.find<BibitRepository>();
  final menuList = [].obs;
  final menuSelected = 'Home'.obs;

  @override
  Future<void> onInit() async {
    /// additional security! check login status
    if (db.auth.currentSession?.user.id == null) {
      await 800.milliseconds.delay();
      await db.auth.signOut();
      await Get.offAllNamed(Routes.LOGIN);
    }
    menuList.value = repo.menuList();
    change(200, status: RxStatus.success());
    super.onInit();
  }

  Future<void> onMenuChange(String menu) async {
    menuSelected.value = menu;
    closeDrawer();
  }

  @override
  void onClose() {
    Get.delete<SectionBibitHomeController>();
    Get.delete<SectionBibitPorfolioController>();
    Get.delete<SectionBibitExploreController>();
    super.onClose();
  }
}
