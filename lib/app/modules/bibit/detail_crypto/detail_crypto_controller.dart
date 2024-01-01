import 'package:ex/ex.dart';
import 'package:get/get.dart';

import '../../../models/pintu_chart_entity.dart';
import '../../../models/pintu_list_crypto_entity.dart';

class DetailCryptoController extends GetxController with StateMixin {
  final productDetail = PintuListCrypto().obs;

  final chart = <PintuChartPayloadChart>[].obs;
  final lastPrice = {}.obs;
  final marketCapital = {}.obs;
  final aboutCoin = {}.obs;
  final periodSelected = 'day'.obs;

  @override
  Future<void> onInit() async {
    productDetail.value = Get.arguments;
    await getChart(productDetail.value.symbol!, periodSelected.value);
    await getLastPrice(productDetail.value.symbol!);
    await getMarketCapital(productDetail.value.symbol!);
    await getAboutCoin(productDetail.value.symbol!);
    change(null, status: RxStatus.success());
    super.onInit();
  }

  void onPeriodChange(String period) async {
    periodSelected.value = period;
    await getChart(productDetail.value.symbol!, period);
    update();
  }

  /// ------------------------------------------------------------------------
  /// ! call api
  /// ------------------------------------------------------------------------
  Future<void> getChart(String symbol, String interval) async {
    final res = await ExHttp().get('https://api.pintu.co.id/v2/trade/chart/$symbol?interval=$interval');
    chart.value = PintuChart.fromJson(res.body).payload?.chart ?? [];
    // reversed chart data
    chart.value = chart.reversed.toList();
  }

  Future<void> getLastPrice(String symbol) async {
    final res = await ExHttp().get('https://api.pintu.co.id/v2/trade/exchange-rate/$symbol');
    lastPrice.value = res.body;
  }

  Future<void> getMarketCapital(String symbol) async {
    final res = await ExHttp().get('https://api.pintu.co.id/v2/util/coin-metrics?currency=$symbol');
    marketCapital.value = res.body;
  }

  Future<void> getAboutCoin(String symbol) async {
    final res = await ExHttp().get('https://pintu-content.herokuapp.com/aboutcurrencies/?language.name=ID&currency.name=${symbol.toUpperCase()}');
    aboutCoin.value = res.body[0];
  }
}
