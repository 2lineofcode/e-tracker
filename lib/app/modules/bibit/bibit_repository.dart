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
import '../../models/bibit_product_detail_allocation_entity.dart';
import '../../models/bibit_product_detail_aum_entity.dart';
import '../../models/bibit_product_detail_chart_entity.dart';
import '../../models/bibit_product_detail_dividend_entity.dart';
import '../../models/bibit_product_detail_factsheets_entity.dart';
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

  /// getProductDetailMutual => code
  Future<BibitProductDetailMutualData> getProductDetailMutual(String code) async {
    try {
      final res = await apiMdvk.get('/api/bibit/product?code=$code');
      return BibitProductDetailMutual.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getProductDetailChart => code, period
  Future<BibitProductDetailChart> getProductDetailChart(String code, String period) async {
    try {
      final res = await apiMdvk.get('/api/bibit/chart?code=$code&period=$period');
      return BibitProductDetailChart.fromJson(res.body);
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getProductDetailAum => code, period
  Future<BibitProductDetailAum> getProductDetailAum(String code, String period) async {
    try {
      final res = await apiMdvk.get('/api/bibit/aum?code=$code&period=$period');
      return BibitProductDetailAum.fromJson(res.body);
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getProductDetailStats => code
  Future<bool> getProductDetailStats(String code) async {
    try {
      final res = await apiBibit.get('/products/$code/stats');
      return res.body['data']['is_favorited'] == 1;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getProductDetailAllocations => code
  Future<BibitProductDetailAllocationData> getProductDetailAllocations(String code) async {
    try {
      final res = await apiBibit.get('/portfolios/allocations/$code');
      return BibitProductDetailAllocation.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getProductDetailSimulation => code
  Future<List<num>> getProductDetailSimulation(String code) async {
    try {
      final res = await apiBibit.get('/products/$code/simulations');
      final data = res.body['data'];
      return List<num>.from(data.map((e) => e as num));
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getProductDetailFactsheets => code
  Future<List<BibitProductDetailFactsheetsData>> getProductDetailFactsheets(String code) async {
    try {
      final res = await apiBibit.get('/products/$code/factsheets');
      return BibitProductDetailFactsheets.fromJson(res.body).data!.sortedBy((a, b) => b.date!.compareTo(a.date!));
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getProductDetailProspectus => code
  Future<List<BibitProductDetailFactsheetsData>> getProductDetailProspectus(String code) async {
    try {
      final res = await apiBibit.get('/products/$code/prospectus');
      return BibitProductDetailFactsheets.fromJson(res.body).data!.reversed.toList();
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getProductDetailDividends => code
  Future<List<BibitProductDetailDividendData>> getProductDetailDividends(String code) async {
    try {
      final res = await apiBibit.get('/products/$code/dividends?limit=10&page=1');
      return BibitProductDetailDividend.fromJson(res.body).data!;
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
