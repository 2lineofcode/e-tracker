import 'package:ex/ex.dart';

import '../../core/app_base.dart';
import '../../models/rpc_sum_all_month_entity.dart';
import '../../models/rpc_sum_by_category_entity.dart';
import '../../models/rpc_sum_note_times_entity.dart';

class SummaryRepository {
  /// ------------------------------------------------------------------------
  /// ! rpc
  /// ------------------------------------------------------------------------
  Future<List<RpcSumAllMonthEntity>> getSumAllMonth({required String year}) async {
    return await db.rpc('sum_all_month', params: {
      'userid': db.auth.currentUser?.id ?? '',
      'periode': year.toInt(),
    }).withConverter<List<RpcSumAllMonthEntity>>((data) {
      return (data as List).map((e) => RpcSumAllMonthEntity.fromJson(e)).toList();
    });
  }

  Future<List<RpcSumByCategoryEntity>> getSumByCategory({required String year, String? month}) async {
    final fixYM = '$year${month != null ? '-${month.reformatDate(from: 'MMMM', to: 'MM')}' : ''}';
    return await db.rpc('sum_by_category', params: {
      'userid': db.auth.currentUser?.id ?? '',
      'periode': fixYM,
    }).withConverter<List<RpcSumByCategoryEntity>>((data) {
      return (data as List).map((e) => RpcSumByCategoryEntity.fromJson(e)).toList();
    });
  }

  Future<List<RpcSumNoteTimesEntity>> getSumNoteTimes({required String year, String? month}) async {
    final fixYM = '$year${month != null ? '-${month.reformatDate(from: 'MMMM', to: 'MM')}' : ''}';
    return await db.rpc('sum_note_times', params: {
      'userid': db.auth.currentUser?.id ?? '',
      'periode': fixYM,
    }).withConverter<List<RpcSumNoteTimesEntity>>((data) {
      return (data as List).map((e) => RpcSumNoteTimesEntity.fromJson(e)).toList();
    });
  }
}
