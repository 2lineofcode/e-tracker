import 'package:ex/ex.dart';

import '../core/app_api.dart';
import '../models/bibit_allocation_summary_entity.dart';
import '../models/bibit_cart_entity.dart';
import '../models/bibit_history_mutual_entity.dart';
import '../models/bibit_history_stock_entity.dart';
import '../models/bibit_order_detail_entity.dart';
import '../models/bibit_performance_allocation_entity.dart';
import '../models/bibit_performance_chart_entity.dart';
import '../models/bibit_performance_entity.dart';
import '../models/bibit_portpolio_detail_entity.dart';
import '../models/bibit_portpolio_entity.dart';
import '../models/bibit_portpolio_goal_chart_entity.dart';
import '../models/bibit_portpolio_goal_detail_entity.dart';
import '../models/bibit_portpolio_goal_ontrack_entity.dart';
import '../models/bibit_product_detail_allocation_entity.dart';
import '../models/bibit_product_detail_aum_entity.dart';
import '../models/bibit_product_detail_chart_entity.dart';
import '../models/bibit_product_detail_dividend_entity.dart';
import '../models/bibit_product_detail_entity.dart';
import '../models/bibit_product_detail_factsheets_entity.dart';
import '../models/bibit_watchlist_entity.dart';

class BibitRepository {
  /// getPortpolio
  Future<BibitPortpolioData> getPortpolio() async {
    try {
      final res = await apiBibit.get('/portfolio');
      return BibitPortpolio.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getPortpolioDetail
  Future<BibitPortpolioDetailData> getPortpolioDetail(String portpolioId) async {
    try {
      final res = await apiBibit.get('/portfolio/category/$portpolioId');
      return BibitPortpolioDetail.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getPortpolioGoalDetail
  Future<BibitPortpolioGoalDetailData> getPortpolioGoalDetail(String portpolioId) async {
    try {
      final res = await apiBibit.get('/portfolio/goal/$portpolioId/detail');
      return BibitPortpolioGoalDetail.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getPortpolioGoalChart
  Future<BibitPortpolioGoalChartData> getPortpolioGoalChart(String portpolioId) async {
    try {
      final res = await apiBibit.get('/portfolio/goal/$portpolioId/chart');
      return BibitPortpolioGoalChart.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getPortpolioGoalOntrack
  Future<BibitPortpolioGoalOntrackData> getPortpolioGoalOntrack(String portpolioId) async {
    try {
      final res = await apiBibit.get('/portfolio/goal/$portpolioId/ontrack');
      return BibitPortpolioGoalOntrack.fromJson(res.body).data!;
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

  /// getBills
  Future<int> getBills() async {
    try {
      final res = await apiBibit.get('/bills');
      return res.body['data']['stamp_duty_fee'];
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getCart
  Future<BibitCartData> getCart() async {
    try {
      final res = await apiBibit.get('/carts/items');
      return BibitCart.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getHistoryMutual
  Future<BibitHistoryMutual> getHistoryMutual({
    String? portpolioId,
    String? cursor,
    int? limit = 20, // def 10, max 100
    String? method = 'all', // buy, sell, all
    String? period = 'all', // 1y, 6m, 3m, 1m, all
    bool? isDividend = false,
    bool? isStampDuty = false,
  }) async {
    try {
      final q = {
        'is_dividend': (isDividend == false ? 0 : 1).toString(),
        'is_stamp_duty': (isStampDuty == false ? 0 : 1).toString(),
        'limit': limit.toString(),
        'method': method,
        'period': period,
        'status': 'done',
      };
      if (portpolioId.isNotEmptyAndNotNull) q['category_id'] = portpolioId;
      if (cursor.isNotEmptyAndNotNull) q['cursor'] = cursor;

      final res = await apiBibit.get('/mutual-fund/orders/histories', query: q);
      return BibitHistoryMutual.fromJson(res.body);
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getHistoryStock
  Future<BibitHistoryStock> getHistoryStock({String? cursor, int? limit = 20}) async {
    try {
      final q = {'limit': limit.toString()};
      if (cursor.isNotEmptyAndNotNull) q['cursor'] = cursor ?? '';

      final res = await apiBibit.get('/stocks/orders/histories', query: q);
      return BibitHistoryStock.fromJson(res.body);
    } catch (e) {
      throw ApiException(',$e');
    }
  }

  /// getOrderDetail
  Future<BibitOrderDetailData> getOrderDetail(String orderId) async {
    try {
      final res = await apiBibit.get('/orders/$orderId');
      return BibitOrderDetail.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }
}
