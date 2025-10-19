import 'package:ex_kit/ex.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../env.g.dart';
import '../../core/app_api.dart';
import '../../helpers/helpers.dart';
import '../../models/rpc_sum_all_month_entity.dart';
import '../../models/rpc_sum_note_times_entity.dart';
import '../../models/supa_category_entity.dart';
import '../../models/supa_cron_entity.dart';
import '../../models/supa_expense_entity.dart';
import '../../models/supa_user_profile_entity.dart';

class SummaryRepository {
  Future<List<SupaExpense>> getExpenses({required String year, String? month}) async {
    if (currentUserId == null) return [];
    final fixYM = '$year${month != null ? '-${month.reformatDate(from: 'MMMM', to: 'MM')}' : ''}';
    final response =
        await db //
            .from('expense')
            // .select()
            .select('date, amount, category_name, note')
            .eq('user_id', currentUserId!)
            .or('date.ilike.$fixYM%')
            .order('date')
            .withConverter<List<SupaExpense>>((data) {
              return (data).map((e) => SupaExpense.fromJson(e)).toList();
            });
    return response;
  }

  Future<List<ExpenseCategory>> getCategory() async {
    return expenseCategoryList;
  }

  Future<List<SupaUserProfile>> getUserProfile() async {
    if (currentUserId == null) return [];
    final response =
        await db //
            .from('profiles')
            .select()
            .eq('id', currentUserId!)
            .withConverter<List<SupaUserProfile>>((data) {
              return (data).map((e) => SupaUserProfile.fromJson(e)).toList();
            });
    return response;
  }


  Future<List<SupaCron>> getCron() async {
    final sb = SupabaseClient(Env.supabaseUrl, Env.supabaseServiceRole);
    final res =
        await sb //
            .schema('cron')
            .from('job')
            .select()
            .or('command.ilike.%${db.auth.currentSession?.user.id}%')
            .withConverter<List<SupaCron>>((data) {
              return (data).map((e) => SupaCron.fromJson(e)).toList();
            });
    return res;
  }

  /// ------------------------------------------------------------------------
  /// ! rpc
  /// ------------------------------------------------------------------------
  Future<List<RpcSumAllMonth>> getSumAllMonth({required String year}) async {
    if (currentUserId == null) return [];
    return await db
        .rpc(
          'sum_all_month',
          params: {
            'userid': currentUserId!,
            'periode': year.toInt(),
          },
        )
        .withConverter<List<RpcSumAllMonth>>((data) {
          return (data as List).map((e) => RpcSumAllMonth.fromJson(e)).toList();
        });
  }

  Future<List<RpcSumNoteTimes>> getSumNoteTimes({required String year, String? month}) async {
    if (currentUserId == null) return [];
    final fixYM = '$year${month != null ? '-${month.reformatDate(from: 'MMMM', to: 'MM')}' : ''}';
    return await db
        .rpc(
          'sum_note_times',
          params: {
            'userid': currentUserId!,
            'periode': fixYM,
          },
        )
        .withConverter<List<RpcSumNoteTimes>>((data) {
          return (data as List).map((e) => RpcSumNoteTimes.fromJson(e)).toList();
        });
  }

  Future<int> getIncome() async {
    if (currentUserId == null) return 0;
    final response =
        await db //
            .from('profiles')
            .select()
            .eq('id', currentUserId!)
            .withConverter<List<SupaUserProfile>>((data) {
              return (data).map((e) => SupaUserProfile.fromJson(e)).toList();
            });

    int o = response[0].income?.moneyUnformat() ?? 0;
    return o;
  }
}
