import 'package:ex/ex.dart';

import '../core/app_api.dart';
import '../models/bibit_allocation_summary_entity.dart';
import '../models/bibit_performance_allocation_entity.dart';
import '../models/bibit_performance_chart_entity.dart';
import '../models/bibit_performance_entity.dart';
import '../models/bibit_portpolio_entity.dart';
import '../models/bibit_product_detail_allocation_entity.dart';
import '../models/bibit_product_detail_aum_entity.dart';
import '../models/bibit_product_detail_chart_entity.dart';
import '../models/bibit_product_detail_dividend_entity.dart';
import '../models/bibit_product_detail_entity.dart';
import '../models/bibit_product_detail_factsheets_entity.dart';
import '../models/bibit_watchlist_entity.dart';

class BibitRepository {
  /// getPotpolio
  Future<BibitPortpolioData> getPortpolio() async {
    try {
      final res = await apiBibit.get('/portfolio');
      return BibitPortpolio.fromJson(res.body).data!;
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

  /// getAllocationSummary
  Future<BibitAllocationSummaryData> getAllocationSummary() async {
    try {
      final res = await apiBibit.get('/portfolio/allocations/summary');
      return BibitAllocationSummary.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getWatchList
  Future<List<BibitWatchlistData>> getWatchList({int instrumentGroup = 0}) async {
    try {
      final res = await apiBibit.get('/watchlists?instrument_group=$instrumentGroup');
      return BibitWatchlist.fromJson(res.body).data!;
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

  /// getPotpolioPerformance
  Future<BibitPerformanceChartData> getPerformanceByPeriod(String period) async {
    try {
      final res = await apiBibit.get('/portfolio/performances/charts?period=$period');
      return BibitPerformanceChart.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getProductDetail
  Future<BibitProductDetailData> getProductDetail(String code) async {
    try {
      final res = await apiMdvk.get('/api/bibit/product?code=$code');
      logJson(res.body);
      return BibitProductDetail.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getProductDetailChart
  Future<BibitProductDetailChart> getProductDetailChart(String code, String period) async {
    try {
      final res = await apiMdvk.get('/api/bibit/chart?code=$code&period=$period');
      return BibitProductDetailChart.fromJson(res.body);
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getProductDetailAum
  Future<BibitProductDetailAum> getProductDetailAum(String code, String period) async {
    try {
      final res = await apiMdvk.get('/api/bibit/aum?code=$code&period=$period');
      return BibitProductDetailAum.fromJson(res.body);
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getProductDetailStats
  Future<bool> getIsFavorite(String code) async {
    try {
      final res = await apiBibit.get('/products/$code/stats');
      return res.body['data']['is_favorited'] == 1;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getProductDetailAllocations
  Future<BibitProductDetailAllocationData> getProductDetailAllocations(String code) async {
    try {
      final res = await apiBibit.get('/portfolios/allocations/$code');
      return BibitProductDetailAllocation.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getProductDetailSimulation
  Future<List<num>> getProductDetailSimulation(String code) async {
    try {
      final res = await apiBibit.get('/products/$code/simulations');
      final data = res.body['data'];
      return List<num>.from(data.map((e) => e as num));
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getProductDetailFactsheets
  Future<List<BibitProductDetailFactsheetsData>> getProductDetailFactsheets(String code) async {
    try {
      final res = await apiBibit.get('/products/$code/factsheets');
      return BibitProductDetailFactsheets.fromJson(res.body).data!.sortedBy((a, b) => b.date!.compareTo(a.date!));
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getProductDetailProspectus
  Future<List<BibitProductDetailFactsheetsData>> getProductDetailProspectus(String code) async {
    try {
      final res = await apiBibit.get('/products/$code/prospectus');
      return BibitProductDetailFactsheets.fromJson(res.body).data!.reversed.toList();
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getProductDetailDividends
  Future<List<BibitProductDetailDividendData>> getProductDetailDividends(String code) async {
    try {
      final res = await apiBibit.get('/products/$code/dividends?limit=10&page=1');
      return BibitProductDetailDividend.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }
}
