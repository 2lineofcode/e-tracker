import 'package:get/get.dart';

import '../../../models/bibit_portpolio_entity.dart';
import '../../../models/bibit_portpolio_performance_chart_entity.dart';
import '../../../models/bibit_watchlist_entity.dart';
import '../../../models/cnbc_entity.dart';
import '../bibit_repository.dart';

class SectionBibitHomeController extends GetxController {
  final repo = Get.find<BibitRepository>();
  final ihsg = CnbcMarketEntity().obs;
  final portpolio = BibitPortpolioData().obs;
  final performance1D = BibitPerformanceChartData().obs;
  final performance1M = BibitPerformanceChartData().obs;
  final watchList = <BibitWatchlistData>[].obs;

  @override
  Future<void> onInit() async {
    ihsg.value = await repo.getIHSG();
    portpolio.value = await repo.getPortpolio();
    performance1D.value = await repo.getPortpolioPerformance('1D');
    performance1M.value = await repo.getPortpolioPerformance('1M');
    watchList.value = await repo.getWatchList();
    super.onInit();
  }
}
