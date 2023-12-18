import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import '../../core/app_base.dart';
import '../../models/bibit_allocation_summary_entity.dart';
import '../../models/bibit_chart_entity.dart';
import '../../models/bibit_index_indices_entity.dart';
import '../../models/bibit_portpolio_entity.dart';
import '../../models/bibit_portpolio_performance_chart_entity.dart';
import '../../models/bibit_stock_tranding_entity.dart';
import '../../models/bibit_stock_watchlist_entity.dart';
import '../../models/bibit_watchlist_entity.dart';
import '../../models/pintu_price_changes_entity.dart';
import '../../models/pintu_supported_currencies_entity.dart';

class BibitRepository {
  List<Map<String, Object>> menuList() {
    return [
      {'icon': CupertinoIcons.home, 'name': 'Home'},
      {'icon': CupertinoIcons.app_badge_fill, 'name': 'Portfolio'},
      {'icon': CupertinoIcons.flame_fill, 'name': 'Explore'},
    ];
  }

  /// ------------------------------------------------------------------------
  /// ! bibit
  /// ------------------------------------------------------------------------
  /// ws
  Future<String> getWSKey() async {
    try {
      final res = await api.get('/stocks/auth/wskey');
      return res.body['data']['wskey'];
    } catch (e) {
      throw ApiException('$e');
    }
  }

  ///ihsg
  Future<BibitChartData> getIHSG() async {
    try {
      final res = await api.get('/stocks/companies/IHSG/charts?period=1d');
      return BibitChartEntity.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getPotpolio
  Future<BibitPortpolioData> getPortpolio() async {
    try {
      final res = await api.get('/portfolio');
      return BibitPortpolioEntity.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getPotpolioPerformance => period = (1D, 1M, 3M, YTD, 1Y, 3Y, ALL)
  Future<BibitPerformanceChartData> getPortpolioPerformance(String period) async {
    try {
      final res = await api.get('/portfolio/performances/charts?period=$period');
      return BibitPerformanceChartEntity.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getWatchList
  Future<List<BibitWatchlistData>> getWatchList({int instrumentGroup = 0}) async {
    try {
      final res = await api.get('/watchlists?instrument_group=$instrumentGroup');
      return BibitWatchlistEntity.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getIndeksIndices
  Future<List<BibitIndexIndicesData>> getIndexIndices() async {
    try {
      final res = await api.get('/stocks/indices?type=main');
      return BibitIndexIndices.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getAllocationSummary
  Future<BibitAllocationSummaryData> getAllocationSummary() async {
    try {
      final res = await api.get('/portfolio/allocations/summary');
      return BibitAllocationSummary.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getStockTranding
  Future<List<BibitStockTrandingData>> getStockTranding() async {
    try {
      final res = await api.get('/stocks/companies/trending');
      return BibitStockTranding.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getStockWatchList
  Future<List<BibitStockWatchlistData>> getStockWatchList() async {
    try {
      final res = await api.get('/watchlists?instrument_group=2');
      return BibitStockWatchlist.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// ------------------------------------------------------------------------
  /// ! pintu
  /// ------------------------------------------------------------------------

  Future<List<dynamic>> rpcPintu() async {
    return await db.rpc('get_pintu');
  }

  /// getSupportedCurrencies
  Future<List<PintuSupportedCurrenciesPayload>> getSupportedCurrencies() async {
    try {
      final res = await api.get('https://api.pintu.co.id/v2/wallet/supportedCurrencies', header: {});
      return PintuSupportedCurrencies.fromJson(res.body).payload!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getPriceChanges
  Future<List<PintuPriceChangesPayload>> getPriceChanges() async {
    try {
      final res = await api.get('https://api.pintu.co.id/v2/trade/price-changes', header: {});
      return PintuPriceChanges.fromJson(res.body).payload!;
    } catch (e) {
      throw ApiException('$e');
    }
  }
}
