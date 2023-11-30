import 'dart:io';

import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/app_base.dart';
import '../../models/bibit_portpolio_entity.dart';
import '../../models/bibit_portpolio_performance_chart_entity.dart';
import '../../models/bibit_watchlist_entity.dart';
import '../../models/cnbc_entity.dart';

class BibitRepository {
  List<Map<String, Object>> menuList() {
    return [
      {'icon': CupertinoIcons.home, 'name': 'Home'},
      {'icon': CupertinoIcons.app_badge_fill, 'name': 'Portfolio'},
      {'icon': CupertinoIcons.flame_fill, 'name': 'Explore'},
    ];
  }

  ///ihsg
  Future<CnbcMarketEntity> getIHSG() async {
    try {
      final res = await ExHttp().post(
        dotenv.get('CNBC_IHSG_URL'),
        header: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.authorizationHeader: dotenv.get('CNBC_DEFAULT_TOKEN'),
        },
      );
      return CnbcMarketEntity.fromJson(res.body);
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
}
