import 'dart:async';

import 'package:ex/ex.dart';
import 'package:get/get.dart';

import '../../../helpers/helper_bibit.dart';
import '../../../models/bibit_chart_entity.dart';
import '../../../models/bibit_index_indices_entity.dart';
import '../../../models/bibit_portpolio_entity.dart';
import '../../../models/bibit_portpolio_performance_chart_entity.dart';
import '../../../models/bibit_watchlist_entity.dart';
import '../bibit_repository.dart';

class SectionBibitHomeController extends GetxController {
  final repo = Get.find<BibitRepository>();
  final ihsg = BibitChartData().obs;
  final portpolio = BibitPortpolioData().obs;
  final performance1D = BibitPerformanceChartData().obs;
  final performance1M = BibitPerformanceChartData().obs;
  final watchList = <BibitWatchlistData>[].obs;
  final indexIndices = <BibitIndexIndicesData>[].obs;

  late Timer? t;

  @override
  Future<void> onInit() async {
    ihsg.value = await repo.getIHSG();
    portpolio.value = await repo.getPortpolio();
    performance1D.value = await repo.getPortpolioPerformance('1D');
    performance1M.value = await repo.getPortpolioPerformance('1M');
    watchList.value = await repo.getWatchList();
    indexIndices.value = await repo.getIndexIndices();

    /// refresh every 3 second
    t = Timer.periodic(3.seconds, (timer) async {
      if (BibitHelper.isStockMarketOpen) {
        ihsg.value = await repo.getIHSG();
        indexIndices.value = await repo.getIndexIndices();
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    t?.cancel();
    super.onClose();
  }
}
