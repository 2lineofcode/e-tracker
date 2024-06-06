import 'package:ex_kit/ex.dart';

import '../../core/app_api.dart';
import '../../models/rpc_sum_all_month_entity.dart';
import '../../models/rpc_sum_by_category_entity.dart';
import '../../models/rpc_sum_note_times_entity.dart';
import '../../models/supa_expense_entity.dart';

class SummaryRepository {
  Future<List<SupaExpense>> getExpenses({required String year, String? month}) async {
    final fixYM = '$year${month != null ? '-${month.reformatDate(from: 'MMMM', to: 'MM')}' : ''}';
    final response = await db //
        .from('expense')
        .select('date, amount')
        .eq('user_id', db.auth.currentSession?.user.id ?? '')
        .or('date.ilike.$fixYM%')
        .order('date')
        .withConverter<List<SupaExpense>>((data) {
      return (data).map((e) => SupaExpense.fromJson(e)).toList();
    });
    return response;
  }

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
