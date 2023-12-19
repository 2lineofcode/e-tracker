import 'dart:async';

import 'package:ex/ex.dart';
import 'package:get/get.dart';
import 'package:web_socket_client/web_socket_client.dart';

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
  final wsKey = ''.obs;

  late Timer? timerPriceChanges;
  late WebSocket? ws;

  @override
  Future<void> onInit() async {
    ihsg.value = await repo.getIHSG();
    portpolio.value = await repo.getPortpolio();
    performance1D.value = await repo.getPortpolioPerformance('1D');
    performance1M.value = await repo.getPortpolioPerformance('1M');
    watchList.value = await repo.getWatchList();
    indexIndices.value = await repo.getIndexIndices();
    wsKey.value = await repo.getWSKey();

    /// refresh every second
    timerPriceChanges = Timer.periodic(1.seconds, (timer) async {
      if (BibitHelper.isStockMarketOpen) {
        log('=== idx30 price changes ===');
        ihsg.value = await repo.getIHSG();
        indexIndices.value = await repo.getIndexIndices();
      }
    });

    /// test socket
    // final uri = 'wss://ws3.stockbit.com/primus/${ExRandom.numeric(3)}/${ExRandom.randomMerge('abcdef', '0123456789').maxLength(8)}/websocket';
    // ws = WebSocket(Uri.parse(uri));
    // ws?.send(BibitWS(wskey: wsKey.value, loggedInUser: 'bibit', chname: BibitWSChname(c: ['IHSG'])).toJson());
    // ws?.send(['"primus::ping::${DateTime.now().millisecondsSinceEpoch}"']);
    // ws?.messages.listen((event) => print('event: ${event.toString()}'));
    super.onInit();
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
