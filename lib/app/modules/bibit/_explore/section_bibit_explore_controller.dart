import 'dart:async';
import 'dart:convert';

import 'package:ex/ex.dart';
import 'package:get/get.dart';

import '../../../core/app_api.dart';
import '../../../models/pintu_list_crypto_entity.dart';
import '../../../models/pintu_price_changes_entity.dart';
import '../../../models/pintu_supported_currencies_entity.dart';
import '../../../models/stockbit_stock_tranding_entity.dart';
import '../../../models/stockbit_watchlist_entity.dart';
import '../../../repository/repo_bibit.dart';
import '../../../repository/repo_stockbit.dart';
import '../../../routes/app_pages.dart';
import '../bibit_controller.dart';

class SectionBibitExploreController extends GetxController with StateMixin, GetSingleTickerProviderStateMixin {
  final repoBibit = Get.find<BibitRepository>();
  final repoStockbit = Get.find<StockbitRepository>();

  final bibitStockTranding = <StockbitStockTrandingData>[].obs;
  final bibitStockWatchlist = <StockbitWatchlistData>[].obs;

  // pintu
  final _pintuSupportedCurrencies = <PintuSupportedCurrenciesPayload>[].obs;
  final _pintuPriceChanges = <PintuPriceChangesPayload>[].obs;
  final pintuListCrypto = <PintuListCrypto>[].obs;

  late Timer? timerPintuPriceChanges;
  late Timer? timerBibitPriceChanges;

  @override
  Future<void> onInit() async {
    change(0, status: RxStatus.loading());

    /// pintu
    await (pintu());

    /// stockbit
    unawaited(stockbit());

    change(200, status: RxStatus.success());
    super.onInit();
  }

  Future<void> pintu() async {
    await db.rpc('get_pintu').then((response) async {
      final r0 = jsonDecode(response[0]['response']);
      final supportedCurrencies = PintuSupportedCurrencies.fromJson(r0);
      _pintuSupportedCurrencies.value = supportedCurrencies.payload!;

      final r1 = jsonDecode(response[1]['response']);
      final priceChanges = PintuPriceChanges.fromJson(r1);
      _pintuPriceChanges.value = priceChanges.payload!;
    });

    fixPintu();
    initPintuRealTimePriceChange();
  }

  void fixPintu() {
    pintuListCrypto.clear();
    final limitPintuList = _pintuSupportedCurrencies.take(15).toList();
    limitPintuList.removeAt(0); // remove first index
    _pintuSupportedCurrencies.value = limitPintuList;

    for (var priceChanges in _pintuPriceChanges) {
      final pairSymbol = priceChanges.pair.allBefore('/').toUpperCase();

      for (var supported in _pintuSupportedCurrencies) {
        if (supported.currencySymbol == pairSymbol) {
          pintuListCrypto.add(
            PintuListCrypto(
              name: supported.name,
              symbol: supported.currencySymbol,
              logo: supported.logo,
              color: supported.color,
              last: priceChanges.latestPrice,
              day: priceChanges.day,
              week: priceChanges.week,
              month: priceChanges.month,
              year: priceChanges.year,
            ),
          );
        }
      }
    }
    pintuListCrypto.sort((a, b) => a.symbol!.compareTo(b.symbol!));
  }

  void initPintuRealTimePriceChange() {
    timerPintuPriceChanges = Timer.periodic(1.seconds, (timer) async {
      await db.rpc('get_pintu').then((response) {
        final r1 = jsonDecode(response[1]['response']);
        final priceChanges = PintuPriceChanges.fromJson(r1);
        _pintuPriceChanges.value = priceChanges.payload!;
      });
      pintuListCrypto.clear();
      for (var priceChanges in _pintuPriceChanges) {
        final pairSymbol = priceChanges.pair.allBefore('/').toUpperCase();
        for (var supported in _pintuSupportedCurrencies) {
          if (supported.currencySymbol == pairSymbol) {
            pintuListCrypto.add(
              PintuListCrypto(
                name: supported.name,
                symbol: supported.currencySymbol,
                logo: supported.logo,
                color: supported.color,
                last: priceChanges.latestPrice,
                day: priceChanges.day,
                week: priceChanges.week,
                month: priceChanges.month,
                year: priceChanges.year,
              ),
            );
          }
        }
      }
      pintuListCrypto.sort((a, b) => a.symbol!.compareTo(b.symbol!));
    });
  }

  ///
  Future<void> stockbit() async {
    bibitStockTranding.value = await repoStockbit.getStockTranding();
    bibitStockWatchlist.value = await repoStockbit.getWatchList();
    initBibitRealTimePriceChange();
  }

  void initBibitRealTimePriceChange() {
    if (Get.find<BibitController>().isMarketOpen.isTrue) {
      timerBibitPriceChanges = Timer.periodic(5.seconds, (timer) async {
        bibitStockTranding.value = await repoStockbit.getStockTranding();
        bibitStockWatchlist.value = await repoStockbit.getWatchList();
      });
    }
  }

  void goDetailStock(String symbol) {
    Get.toNamed(Routes.DETAIL_STOCK, arguments: symbol);
  }

  void goDetailCrypto(PintuListCrypto item) {
    Get.toNamed(Routes.DETAIL_CRYPTO, arguments: item);
  }

  @override
  void onClose() {
    try {
      timerPintuPriceChanges?.cancel();
      timerBibitPriceChanges?.cancel();
    } catch (_) {}
    super.onClose();
  }
}
