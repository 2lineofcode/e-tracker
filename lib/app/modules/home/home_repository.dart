import 'package:ex_kit/ex.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../env.g.dart';
import '../../core/app_api.dart';
import '../../core/const.dart';
import '../../helpers/helpers.dart';
import '../../models/supa_assets_entity.dart';
import '../../models/supa_budgets_entity.dart';
import '../../models/supa_category_entity.dart';
import '../../models/supa_cron_entity.dart';
import '../../models/supa_expense_entity.dart';
import '../../models/supa_goals_entity.dart';
import '../../models/supa_notes_entity.dart';
import '../../models/supa_user_profile_entity.dart';

class HomeRepository {
  // ────────────────────────────────────────────────────────────────
  // ! expense
  // ────────────────────────────────────────────────────────────────
  // get all list: for calendar painting
  Future<List<SupaExpense>> getExpenseAll({String period = ''}) async {
    if (currentUserId == null) return [];
    final response =
        await db //
            .from('expense')
            .select('date, amount')
            .eq('user_id', currentUserId!)
            .or('date.ilike.$period%')
            .order('date')
            .withConverter<List<SupaExpense>>((data) {
              return (data).map((e) => SupaExpense.fromJson(e)).toList();
            });
    return response;
  }

  // get list by @date
  Future<List<SupaExpense>> getExpense(String date) async {
    if (currentUserId == null) return [];
    final response =
        await db //
            .from('expense')
            .select()
            .eq('user_id', currentUserId!)
            .eq('date', date)
            .order('amount')
            .withConverter<List<SupaExpense>>((data) {
              return (data).map((e) => SupaExpense.fromJson(e)).toList();
            });
    return response;
  }

  // find list by @note or @category.name
  Future<List<SupaExpense>> findExpense(String name, {String? startDate, String? endDate}) async {
    final List<SupaExpense> response;

    if (currentUserId == null) return [];

    final categoryMatch = resolveExpenseCategory(name);
    final filters = <String>['note.ilike.%$name%', 'detail.ilike.%$name%'];

    if (categoryMatch != unknownExpenseCategory) {
      filters.add('category_name.ilike.%${categoryMatch.code}%');
      filters.add('category_name.ilike.%${categoryMatch.label}%');
    } else {
      filters.add('category_name.ilike.%$name%');
    }

    final filterString = filters.join(',');

    if (startDate == null && endDate == null) {
      response =
          await db //
              .from('expense')
              .select()
              .eq('user_id', currentUserId!)
              .or(filterString)
              .order('date')
              .withConverter<List<SupaExpense>>((data) {
                return (data).map((e) => SupaExpense.fromJson(e)).toList();
              });
    } else {
      startDate = startDate?.toDateEx(format: yMd).subtract(1.days).toStringEx(format: yMd);
      print('findExpense: $name | sd = $startDate | ed = $endDate');
      response =
          await db //
              .from('expense')
              .select()
              .eq('user_id', currentUserId!)
              .or(filterString)
              .or('date.gte.$startDate% and date.lte.$endDate%')
              .order('date')
              .withConverter<List<SupaExpense>>((data) {
                return (data).map((e) => SupaExpense.fromJson(e)).toList();
              });
    }
    return response;
  }

  // find list by date
  Future<List<SupaExpense>> findExpenseByDateRange(String date) async {
    if (currentUserId == null) return [];

    if (date.isNotEmpty && date.length <= 3) {
      final dateA = DateTime.now().subtract(Duration(days: date.toInt()! - 1)).toStringEx(format: yMd);
      final dateB = DateTime.now().toStringEx(format: yMd);
      final response =
          await db //
              .from('expense')
              .select()
              .eq('user_id', currentUserId!)
              .gte('date', dateA)
              .lte('date', dateB)
              .order('date')
              .withConverter<List<SupaExpense>>((data) {
                return (data).map((e) => SupaExpense.fromJson(e)).toList();
              });
      return response;
    }
    if (date.length > 11) {
      final dateA = date.substring(0, 10);
      final dateB = date.substring(11);
      final response =
          await db //
              .from('expense')
              .select()
              .eq('user_id', currentUserId!)
              .gte('date', dateA)
              .lte('date', dateB)
              .order('date')
              .withConverter<List<SupaExpense>>((data) {
                return (data).map((e) => SupaExpense.fromJson(e)).toList();
              });
      return response;
    }

    return findExpense(date);
  }

  // get sum by @date [1month]
  Future<int?> getCount1Month(String date) async {
    if (currentUserId == null) return 0;
    final response =
        await db //
            .from('expense')
            .select('amount, date')
            .eq('user_id', currentUserId!)
            .like('date', '%$date%');
    num x = 0;
    for (var element in response) {
      x += element['amount'] ?? 0;
    }
    return x.toInt();
  }

  Future<void> addExpense(SupaExpense entity) async {
    final response =
        await db //
            .from('expense')
            .insert(entity.toJson());
    return response;
  }

  Future<void> editExpense(SupaExpense entity) async {
    final response =
        await db //
            .from('expense')
            .update(entity.toJson())
            .match({'id': entity.id ?? ''});
    return response;
  }

  Future<void> deleteExpense(String id) async {
    if (currentUserId == null) return;
    final response =
        await db //
            .from('expense')
            .delete()
            .match({'id': id, 'user_id': currentUserId!});
    return response;
  }

  Future<List<SupaExpense>> findPotentialDuplicate({
    required String date,
    required String note,
    required num amount,
    String? excludeId,
  }) async {
    if (currentUserId == null) return [];

    final response =
        await db //
            .from('expense')
            .select()
            .eq('user_id', currentUserId!)
            .eq('date', date)
            .eq('amount', amount)
            .withConverter<List<SupaExpense>>((data) {
              return (data).map((e) => SupaExpense.fromJson(e)).toList();
            });

    String normalize(String value) => value.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
    final normalizedNote = normalize(note);

    return response.where((expense) {
      if (excludeId != null && expense.id == excludeId) return false;
      final candidate = normalize(expense.note ?? '');
      return candidate == normalizedNote || candidate.contains(normalizedNote) || normalizedNote.contains(candidate);
    }).toList();
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

  // ────────────────────────────────────────────────────────────────
  // ! budgets
  // ────────────────────────────────────────────────────────────────
  Future<List<SupaBudgets>> getBudgets() async {
    if (currentUserId == null) return [];
    final response =
        await db //
            .from('budgets')
            .select()
            .eq('user_id', currentUserId!)
            .order('amount')
            .withConverter<List<SupaBudgets>>((data) {
              return (data).map((e) => SupaBudgets.fromJson(e)).toList();
            });
    return response;
  }

  Future<Map<String, num>> getMonthlyExpenseByBudgets(DateTime dateTime) async {
    if (currentUserId == null) return {};

    final firstDay = DateTime(dateTime.year, dateTime.month, 1);
    final nextMonth = DateTime(dateTime.year, dateTime.month + 1, 1);
    final startDate = firstDay.toStringEx(format: yMd);
    final endDate = nextMonth.toStringEx(format: yMd);

    final response =
        await db //
            .from('expense')
            .select('category_name, amount, date')
            .eq('user_id', currentUserId!)
            .gte('date', startDate)
            .lt('date', endDate)
            .order('date')
            .withConverter<List<SupaExpense>>(
              (data) => (data).map((e) => SupaExpense.fromJson(e)).toList(),
            );

    final totals = <String, num>{};
    for (final expense in response) {
      final categoryCode = expense.resolvedCategory.code;
      final amount = expense.amount ?? 0;
      totals[categoryCode] = (totals[categoryCode] ?? 0) + amount;
    }

    return totals;
  }

  Future<bool> checkDuplicateBudgets(String categoyName) async {
    if (currentUserId == null) return false;
    final response =
        await db //
            .from('budgets')
            .select()
            .eq('user_id', currentUserId!)
            .eq('category_name', categoyName)
            .withConverter<List<SupaBudgets>>((data) {
              return (data).map((e) => SupaBudgets.fromJson(e)).toList();
            });
    return response.isNotEmpty;
  }

  Future<void> addBudgets(SupaBudgets entity) async {
    if (currentUserId == null) return;
    if (await checkDuplicateBudgets(entity.categoryCode ?? '')) {
      await HelperToast.warn('Budget already exist');
      return;
    }
    final response =
        await db //
            .from('budgets')
            .upsert(entity.toJson());
    await HelperToast.success('Budget saved');
    return response;
  }

  Future<void> deleteBudgets(String id) async {
    if (currentUserId == null) return;
    final response =
        await db //
            .from('budgets')
            .delete()
            .match({'id': id, 'user_id': currentUserId!});
    return response;
  }

  Future<void> updateBudgets(SupaBudgets entity) async {
    if (currentUserId == null) return;
    final response =
        await db //
            .from('budgets')
            .update(entity.toJson())
            .match({'id': entity.id ?? ''});
    return response;
  }

  // ────────────────────────────────────────────────────────────────
  // ! assets
  // ────────────────────────────────────────────────────────────────
  Future<List<SupaAssets>> getAssets() async {
    if (currentUserId == null) return [];
    final response =
        await db //
            .from('assets')
            .select()
            .eq('user_id', currentUserId!)
            .order('amount')
            .withConverter<List<SupaAssets>>((data) {
              return (data).map((e) => SupaAssets.fromJson(e)).toList();
            });
    return response;
  }

  Future<void> addAssets(SupaAssets entity) async {
    if (currentUserId == null) return;
    final response =
        await db //
            .from('assets')
            .upsert(entity.toJson());
    return response;
  }

  Future<void> updateAssets(SupaAssets entity) async {
    if (currentUserId == null) return;
    final response =
        await db //
            .from('assets')
            .update(entity.toJson())
            .match({'id': entity.id ?? ''});
    return response;
  }

  Future<void> deleteAssets(String id) async {
    if (currentUserId == null) return;
    final response =
        await db //
            .from('assets')
            .delete()
            .match({'id': id, 'user_id': currentUserId!});
    return response;
  }

  // ────────────────────────────────────────────────────────────────
  // ! goals
  // ────────────────────────────────────────────────────────────────
  Future<List<SupaGoals>> getGoals() async {
    if (currentUserId == null) return [];
    final response =
        await db //
            .from('goals')
            .select()
            .eq('user_id', currentUserId!)
            .order('target')
            .withConverter<List<SupaGoals>>((data) {
              return (data).map((e) => SupaGoals.fromJson(e)).toList();
            });
    return response;
  }

  Future<void> addGoals(SupaGoals entity) async {
    if (currentUserId == null) return;
    final response =
        await db //
            .from('goals')
            .upsert(entity.toJson());
    return response;
  }

  Future<void> updateGoals(SupaGoals entity) async {
    if (currentUserId == null) return;
    final response =
        await db //
            .from('goals')
            .update(entity.toJson())
            .match({'id': entity.id ?? ''});
    return response;
  }

  Future<void> deleteGoals(String id) async {
    if (currentUserId == null) return;
    final response =
        await db //
            .from('goals')
            .delete()
            .match({'id': id, 'user_id': currentUserId!});
    return response;
  }

  // ────────────────────────────────────────────────────────────────
  // ⵌ notes
  // ────────────────────────────────────────────────────────────────
  Future<List<SupaNotes>> getNotes() async {
    if (currentUserId == null) return [];
    final response =
        await db //
            .from('notes')
            .select()
            .eq('user_id', currentUserId!)
            .withConverter<List<SupaNotes>>((data) {
              return (data).map((e) => SupaNotes.fromJson(e)).toList();
            });
    return response;
  }

  Future<void> addNotes(SupaNotes entity) async {
    if (currentUserId == null) return;
    final response =
        await db //
            .from('notes')
            .upsert(entity.toJson());
    return response;
  }

  Future<void> updateNotes(SupaNotes entity) async {
    if (currentUserId == null) return;
    final response =
        await db //
            .from('notes')
            .update(entity.toJson())
            .match({'id': entity.id ?? ''});
    return response;
  }

  Future<void> deleteNotes(String id) async {
    if (currentUserId == null) return;
    final response =
        await db //
            .from('notes')
            .delete()
            .match({'id': id, 'user_id': currentUserId!});
    return response;
  }

  // ────────────────────────────────────────────────────────────────
  // ! rpc
  // ────────────────────────────────────────────────────────────────
  Future<List<dynamic>> rpcGetSpenderDay(DateTime focusedDay) async {
    if (currentUserId == null) return [];
    final fixYM = focusedDay.toStringEx(format: yM);
    final result = await db
        .rpc(
          'get_spender_day',
          params: {
            'userid': currentUserId!,
            'periode': fixYM,
          },
        )
        .order('total', ascending: false);
    return result;
  }

  Future<List<SupaCron>> getCron() async {
    if (currentUserId == null) return [];
    final sb = SupabaseClient(Env.supabaseUrl, Env.supabaseServiceRole);
    return await sb
        .schema('cron')
        .from('job')
        .select()
        .or('command.ilike.%$currentUserId%')
        .withConverter<List<SupaCron>>((data) {
          return (data).map((e) => SupaCron.fromJson(e)).toList();
        });
  }
}
