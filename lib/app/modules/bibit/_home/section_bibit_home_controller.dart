import 'dart:async';

import 'package:ex/ex.dart';
import 'package:get/get.dart';

import '../../../models/bibit_performance_chart_entity.dart';
import '../../../models/bibit_portpolio_entity.dart';
import '../../../models/bibit_watchlist_entity.dart';
import '../../../models/stockbit_chart_entity.dart';
import '../../../models/stockbit_index_indices_entity.dart';
import '../../../models/stockbit_watchlist_entity.dart';
import '../../../repository/repo_bibit.dart';
import '../../../repository/repo_stockbit.dart';
import '../../../routes/app_pages.dart';
import '../bibit_controller.dart';

class SectionBibitHomeController extends GetxController {
  final repoBibit = Get.find<BibitRepository>();
  final repoStockbit = Get.find<StockbitRepository>();

  final ihsg = StockbitChartData().obs;
  final portpolio = BibitPortpolioData().obs;
  final performance1D = BibitPerformanceChartData().obs;
  final performance1M = BibitPerformanceChartData().obs;
  final watchListMutual = <BibitWatchlistData>[].obs;
  final watchListStock = <StockbitWatchlistData>[].obs;
  final indexIndices = <StockbitIndexIndicesData>[].obs;
  final wsKey = ''.obs;

  late Timer? timerPriceChanges;

  @override
  Future<void> onInit() async {
    portpolio.value = await repoBibit.getPortpolio();
    performance1D.value = await repoBibit.getPerformanceByPeriod('1D');
    performance1M.value = await repoBibit.getPerformanceByPeriod('1M');
    watchListMutual.value = await repoBibit.getWatchList();
    watchListStock.value = await repoStockbit.getWatchList();
    ihsg.value = await repoStockbit.getChart();
    indexIndices.value = await repoStockbit.getIndexIndices();
    wsKey.value = await repoStockbit.getWSKey();

    /// refresh every second
    timerPriceChanges = Timer.periodic(5.seconds, (timer) async {
      try {
        if (Get.find<BibitController>().isMarketOpen.isTrue) {
          ihsg.value = await repoStockbit.getChart();
          indexIndices.value = await repoStockbit.getIndexIndices();
        }
      } catch (e) {
        timerPriceChanges?.cancel();
      }
    });

    /// test socket
    // final uri = 'wss://ws3.stockbit.com/primus/${ExRandom.numeric(3)}/${ExRandom.randomMerge('abcdef', '0123456789').maxLength(8)}/websocket';
    // ws = WebSocket(Uri.parse(uri));
    // ws?.send( { 'wskey': '${wsKey.value}', 'loggedInUser': 'bibit', 'chname': { 'C': ['IHSG'] } } );
    // ws?.send(['"primus::ping::${DateTime.now().millisecondsSinceEpoch}"']);
    // ws?.messages.listen((event) => print('event: ${event.toString()}'));
    super.onInit();
  }

  void goDetailMutual(BibitWatchlistData item) {
    Get.toNamed(Routes.DETAIL_MUTUAL, arguments: item.symbol);
  }

  void goDetailStock(StockbitWatchlistData item) {
    Get.toNamed(Routes.DETAIL_STOCK, arguments: item.symbol);
  }

  @override
  void onClose() {
    try {
      timerPriceChanges?.cancel();
      // ws?.close();
    } catch (_) {}
    super.onClose();
  }
}
