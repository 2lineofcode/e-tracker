import 'dart:async';

import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/bibit_stock_tranding_entity.dart';
import '../../../models/bibit_stock_watchlist_entity.dart';
import '../../../models/pintu_list_crypto_entity.dart';
import '../../../models/pintu_price_changes_entity.dart';
import '../../../models/pintu_supported_currencies_entity.dart';
import '../bibit_repository.dart';

class SectionBibitExploreController extends GetxController with StateMixin, GetSingleTickerProviderStateMixin {
  final repo = Get.find<BibitRepository>();

  final bibitStockTranding = <BibitStockTrandingData>[].obs;
  final bibitStockWatchlist = <BibitStockWatchlistData>[].obs;

  // pintu
  final _pintuSupportedCurrencies = <PintuSupportedCurrenciesPayload>[].obs;
  final _pintuPriceChanges = <PintuPriceChangesPayload>[].obs;
  final pintuListCrypto = <PintuListCrypto>[].obs;

  late TabController? tabController;
  late Timer? timerPriceChanges;

  @override
  Future<void> onInit() async {
    change(0, status: RxStatus.loading());
    // bibitStockTranding.value = await repo.getStockTranding();
    // bibitStockWatchlist.value = await repo.getStockWatchList();
    _pintuSupportedCurrencies.value = await repo.getSupportedCurrencies();
    _pintuPriceChanges.value = await repo.getPriceChanges();

    fixPintu();
    initPintuRealTimePriceChange();

    tabController = TabController(length: 2, vsync: this);
    change(200, status: RxStatus.success());
    super.onInit();
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
    timerPriceChanges = Timer.periodic(1.seconds, (timer) async {
      _pintuPriceChanges.value = await repo.getPriceChanges();
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

  @override
  void onClose() {
    timerPriceChanges?.cancel();
    super.onClose();
  }
}
