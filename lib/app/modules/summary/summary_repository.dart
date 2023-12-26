import 'package:ex/ex.dart';

import '../../core/app_api.dart';
import '../../models/rpc_sum_all_month_entity.dart';
import '../../models/rpc_sum_by_category_entity.dart';
import '../../models/rpc_sum_note_times_entity.dart';

class SummaryRepository {
  /// ------------------------------------------------------------------------
  /// ! rpc
  /// ------------------------------------------------------------------------
  Future<List<RpcSumAllMonth>> getSumAllMonth({required String year}) async {
    return await db.rpc('sum_all_month', params: {
      'userid': db.auth.currentSession?.user.id ?? '',
      'periode': year.toInt(),
    }).withConverter<List<RpcSumAllMonth>>((data) {
      return (data as List).map((e) => RpcSumAllMonth.fromJson(e)).toList();
    });
  }

  Future<List<RpcSumByCategory>> getSumByCategory({required String year, String? month}) async {
    final fixYM = '$year${month != null ? '-${month.reformatDate(from: 'MMMM', to: 'MM')}' : ''}';
    return await db.rpc('sum_by_category', params: {
      'userid': db.auth.currentSession?.user.id ?? '',
      'periode': fixYM,
    }).withConverter<List<RpcSumByCategory>>((data) {
      return (data as List).map((e) => RpcSumByCategory.fromJson(e)).toList();
    });
  }

  Future<List<RpcSumNoteTimes>> getSumNoteTimes({required String year, String? month}) async {
    final fixYM = '$year${month != null ? '-${month.reformatDate(from: 'MMMM', to: 'MM')}' : ''}';
    return await db.rpc('sum_note_times', params: {
      'userid': db.auth.currentSession?.user.id ?? '',
      'periode': fixYM,
    }).withConverter<List<RpcSumNoteTimes>>((data) {
      return (data as List).map((e) => RpcSumNoteTimes.fromJson(e)).toList();
    });
  }
}
