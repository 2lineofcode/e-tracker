import 'package:ex/ex.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../helpers/helper_misc.dart';
import '../../../repository/repo_bibit.dart';

class DetailStockController extends GetxController with StateMixin {
  final repo = Get.find<BibitRepository>();

  final symbolSelected = ''.obs;
  final periodSelected = '1Y'.obs;
  final menuSelected = 'Summaries'.obs;
  final uiModeSelected = 'CHART'.obs;

  final isFavorite = false.obs;

  @override
  void onInit() {
    symbolSelected.value = Get.arguments as String;
    change(200, status: RxStatus.success());
    super.onInit();
  }

  void onMenuChange(String item) {
    menuSelected.value = item;
    closeDrawer();
  }

  Future<void> openFile(String url) async {
    try {
      await launchUrlString(url);
    } catch (e) {
      ExSnackbar.danger('doesnt support OS');
    }
  }
}
