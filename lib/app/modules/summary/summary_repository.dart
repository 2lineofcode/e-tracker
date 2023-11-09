import 'package:ex/ex.dart';

import '../../core/const.dart';
import '../../models/rpc_sum_all_month_entity.dart';
import '../../models/rpc_sum_by_category_entity.dart';

class SummaryRepository {
  /// rpc
  Future<List<RpcSumAllMonthEntity>> getSumAllMonth({required String year}) async {
    return await db.rpc('sum_all_month', params: {
      'year_param': year.toInt(),
    }).withConverter<List<RpcSumAllMonthEntity>>((data) {
      return (data as List).map((e) => RpcSumAllMonthEntity.fromJson(e)).toList();
    });
  }

  Future<List<RpcSumByCategoryEntity>> getSumByCategory({required String year, String? month}) async {
    final fixYM = '$year${month != null ? '-${month.reformatDate(from: 'MMMM', to: 'MM')}' : ''}';
    return await db.rpc('sum_by_category', params: {
      'periode': fixYM,
    }).withConverter<List<RpcSumByCategoryEntity>>((data) {
      return (data as List).map((e) => RpcSumByCategoryEntity.fromJson(e)).toList();
    });
  }
}
