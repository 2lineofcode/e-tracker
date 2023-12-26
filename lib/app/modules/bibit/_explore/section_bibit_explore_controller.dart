import 'dart:async';
import 'dart:convert';

import 'package:ex/ex.dart';
import 'package:get/get.dart';

import '../../../models/bibit_stock_tranding_entity.dart';
import '../../../models/bibit_watchlist_stock_entity.dart';
import '../../../models/pintu_list_crypto_entity.dart';
import '../../../models/pintu_price_changes_entity.dart';
import '../../../models/pintu_supported_currencies_entity.dart';
import '../bibit_controller.dart';
import '../bibit_repository.dart';

class SectionBibitExploreController extends GetxController with StateMixin, GetSingleTickerProviderStateMixin {
  final repo = Get.find<BibitRepository>();

  final bibitStockTranding = <BibitStockTrandingData>[].obs;
  final bibitStockWatchlist = <BibitWatchlistStockData>[].obs;

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
    // _pintuSupportedCurrencies.value = await repo.getSupportedCurrencies();
    // _pintuPriceChanges.value = await repo.getPriceChanges();

    await repo.rpcPintu().then((response) async {
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
      log('=== pintu priceChanges ===');
      // _pintuPriceChanges.value = await repo.getPriceChanges();
      await repo.rpcPintu().then((response) {
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
    bibitStockTranding.value = await repo.getStockTranding();
    bibitStockWatchlist.value = await repo.getStockWatchList();
    initBibitRealTimePriceChange();
  }

  void initBibitRealTimePriceChange() {
    if (Get.find<BibitController>().isMarketOpen.isTrue) {
      timerBibitPriceChanges = Timer.periodic(5.seconds, (timer) async {
        log('=== stockbit priceChanges ===');
        bibitStockTranding.value = await repo.getStockTranding();
        bibitStockWatchlist.value = await repo.getStockWatchList();
      });
    }
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
