import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';

import '../../core/app_api.dart';
import '../../models/bibit_allocation_summary_entity.dart';
import '../../models/bibit_chart_entity.dart';
import '../../models/bibit_companies_info_entity.dart.dart';
import '../../models/bibit_index_indices_entity.dart';
import '../../models/bibit_performance_allocation_entity.dart';
import '../../models/bibit_performance_chart_entity.dart';
import '../../models/bibit_performance_entity.dart';
import '../../models/bibit_portpolio_entity.dart';
import '../../models/bibit_product_detail_mutual_entity.dart';
import '../../models/bibit_stock_tranding_entity.dart';
import '../../models/bibit_watchlist_mutual_entity.dart';
import '../../models/bibit_watchlist_stock_entity.dart';

class BibitRepository {
  List<Map<String, Object>> menuList() {
    return [
      {'icon': CupertinoIcons.home, 'name': 'Home'},
      {'icon': CupertinoIcons.app_badge_fill, 'name': 'Portfolio'},
      {'icon': CupertinoIcons.chart_bar_alt_fill, 'name': 'Performance'},
      {'icon': CupertinoIcons.flame_fill, 'name': 'Explore'},
    ];
  }

  /// ------------------------------------------------------------------------
  /// ! bibit
  /// ------------------------------------------------------------------------
  /// ws
  Future<String> getWSKey() async {
    try {
      final res = await apiBibit.get('/stocks/auth/wskey');
      return res.body['data']['wskey'];
    } catch (e) {
      throw ApiException('$e');
    }
  }

  ///ihsg
  Future<BibitChartData> getIHSG() async {
    try {
      final res = await apiBibit.get('/stocks/companies/IHSG/charts?period=1d');
      return BibitChart.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getPotpolio
  Future<BibitPortpolioData> getPortpolio() async {
    try {
      final res = await apiBibit.get('/portfolio');
      return BibitPortpolio.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getWatchList
  Future<List<BibitWatchlistMutualData>> getWatchList({int instrumentGroup = 0}) async {
    try {
      final res = await apiBibit.get('/watchlists?instrument_group=$instrumentGroup');
      return BibitWatchlistMutual.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getIndeksIndices
  Future<List<BibitIndexIndicesData>> getIndexIndices() async {
    try {
      final res = await apiBibit.get('/stocks/indices?type=main');
      return BibitIndexIndices.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getAllocationSummary
  Future<BibitAllocationSummaryData> getAllocationSummary() async {
    try {
      final res = await apiBibit.get('/portfolio/allocations/summary');
      return BibitAllocationSummary.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getStockTranding
  Future<List<BibitStockTrandingData>> getStockTranding() async {
    try {
      final res = await apiBibit.get('/stocks/companies/trending');
      return BibitStockTranding.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getStockWatchList
  Future<List<BibitWatchlistStockData>> getStockWatchList() async {
    try {
      final res = await apiBibit.get('/watchlists?instrument_group=2');
      return BibitWatchlistStock.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getCompaniesInfo
  Future<BibitCompaniesInfoData> getCompaniesInfo({String code = 'IHSG'}) async {
    try {
      final res = await apiBibit.get('/stocks/companies/$code/info');
      return BibitCompaniesInfo.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getPerformance
  Future<BibitPerformanceData> getPerformance() async {
    try {
      final res = await apiBibit.get('/portfolio/performances');
      return BibitPerformance.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getPotpolioPerformance => period = (1D, 1M, 3M, YTD, 1Y, 3Y, ALL)
  Future<BibitPerformanceChartData> getPerformancePeriod(String period) async {
    try {
      final res = await apiBibit.get('/portfolio/performances/charts?period=$period');
      return BibitPerformanceChart.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getAllocation
  Future<List<BibitPerformanceAllocationData>> getAllocation() async {
    try {
      final res = await apiBibit.get('/portfolio/allocations');
      return BibitPerformanceAllocation.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getProductDetailMutual => symbol
  Future<BibitProductDetailMutualData> getProductDetailMutual(String symbol) async {
    try {
      final res = await apiMdvk.get('/api/bibit/product?code=$symbol');
      return BibitProductDetailMutual.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// ------------------------------------------------------------------------
  /// ! pintu
  /// ------------------------------------------------------------------------
  Future<List<dynamic>> rpcIHSG() async {
    return await db.rpc('get_ihsg');
  }

  Future<List<dynamic>> rpcPintu() async {
    return await db.rpc('get_pintu');
  }
}
