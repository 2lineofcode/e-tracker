import 'package:get/get.dart';
import 'package:overlayment/overlayment.dart';

import '../../../models/bibit_portpolio_detail_entity.dart';
import '../../../models/bibit_portpolio_goal_chart_entity.dart';
import '../../../models/bibit_portpolio_goal_detail_entity.dart';
import '../../../models/bibit_portpolio_goal_ontrack_entity.dart';
import '../../../repository/repo_bibit.dart';
import '../../../routes/app_pages.dart';

class DetailPortfolioController extends GetxController with StateMixin<BibitPortpolioDetailData> {
  final repo = Get.find<BibitRepository>();

  final menuSelected = 'Summaries'.obs;
  final portpolioId = ''.obs;

  final porto = BibitPortpolioDetailData().obs;
  final goalDetail = BibitPortpolioGoalDetailData().obs;
  final goalChart = BibitPortpolioGoalChartData().obs;
  final goalOntrack = BibitPortpolioGoalOntrackData().obs;

  @override
  Future<void> onInit() async {
    portpolioId.value = Get.arguments.toString();
    porto.value = await repo.getPortpolioDetail(portpolioId.value);

    if (porto.value.goalsetting != null) {
      goalDetail.value = await repo.getPortpolioGoalDetail(portpolioId.value);
      goalOntrack.value = await repo.getPortpolioGoalOntrack(portpolioId.value);
      goalChart.value = await repo.getPortpolioGoalChart(portpolioId.value);
    }

    change(porto.value, status: RxStatus.success());
    super.onInit();
  }

  void onMenuChange(String item) {
    menuSelected.value = item;
  }

  void goDetailMutual(String symbol) {
    Overlayment.dismissAll();
    Get.toNamed(Routes.DETAIL_MUTUAL, arguments: symbol);
  }

  void goDetailStock(String symbol) {
    Get.toNamed(Routes.DETAIL_STOCK, arguments: symbol);
  }
}
