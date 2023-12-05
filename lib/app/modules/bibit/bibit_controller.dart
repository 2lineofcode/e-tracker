import 'package:get/get.dart';

import '../../helpers/helper_misc.dart';
import 'bibit_repository.dart';

class BibitController extends GetxController with StateMixin {
  final repo = Get.find<BibitRepository>();
  final menuList = [].obs;
  final menuSelected = 'Home'.obs;

  @override
  Future<void> onInit() async {
    menuList.value = repo.menuList();
    change(200, status: RxStatus.success());
    super.onInit();
  }

  Future<void> onMenuChange(String menu) async {
    menuSelected.value = menu;
    closeDrawer();
  }
}
