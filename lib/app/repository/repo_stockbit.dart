import 'package:ex/ex.dart';

import '../core/app_api.dart';
import '../models/stockbit_chart_entity.dart';
import '../models/stockbit_companies_info_entity.dart';
import '../models/stockbit_index_indices_entity.dart';
import '../models/stockbit_product_detail_entity.dart';
import '../models/stockbit_stock_tranding_entity.dart';
import '../models/stockbit_watchlist_entity.dart';

class StockbitRepository {
  /// ws
  Future<String> getWSKey() async {
    try {
      final res = await apiBibit.get('/stocks/auth/wskey');
      return res.body['data']['wskey'];
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getProductDetail
  Future<StockbitProductDetailData> getProductDetail(String symbol) async {
    try {
      final res = await apiBibit.get('/stocks/companies/$symbol');
      return StockbitProductDetail.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getStockWatchList
  Future<List<StockbitWatchlistData>> getWatchList() async {
    try {
      final res = await apiBibit.get('/watchlists?instrument_group=2');
      return StockbitWatchlist.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getChart
  Future<StockbitChartData> getChart({String symbol = 'IHSG', String period = '1d'}) async {
    try {
      final res = await apiBibit.get('/stocks/companies/$symbol/charts?period=$period');
      return StockbitChart.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getIndeksIndices
  Future<List<StockbitIndexIndicesData>> getIndexIndices() async {
    try {
      final res = await apiBibit.get('/stocks/indices?type=main');
      return StockbitIndexIndices.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getStockTranding
  Future<List<StockbitStockTrandingData>> getStockTranding() async {
    try {
      final res = await apiBibit.get('/stocks/companies/trending');
      return StockbitStockTranding.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getCompaniesInfo
  Future<StockbitCompaniesInfoData> getCompaniesInfo({String code = 'IHSG'}) async {
    try {
      final res = await apiBibit.get('/stocks/companies/$code/info');
      return StockbitCompaniesInfo.fromJson(res.body).data!;
    } catch (e) {
      throw ApiException('$e');
    }
  }

  /// getIsFavorite
  Future<bool> getIsFavorite(String code) async {
    try {
      final res = await apiBibit.get('/stocks/companies/$code/stats');
      return res.body['data']['is_favorited'] as bool;
    } catch (e) {
      throw ApiException('$e');
    }
  }
}
