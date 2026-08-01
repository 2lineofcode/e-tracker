import 'package:ex_kit/ex.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    String containsFilter(String value) {
      final escaped = value.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
      return '"%$escaped%"';
    }

    final categoryMatch = resolveExpenseCategory(name);
    final filters = <String>[
      'note.ilike.${containsFilter(name)}',
      'detail.ilike.${containsFilter(name)}',
    ];

    if (categoryMatch != unknownExpenseCategory) {
      filters.add('category_name.ilike.${containsFilter(categoryMatch.code)}');
      filters.add('category_name.ilike.${containsFilter(categoryMatch.label)}');
    } else {
      filters.add('category_name.ilike.${containsFilter(name)}');
    }

    final filterString = filters.join(',');

    if (startDate == null || endDate == null) {
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
      response =
          await db //
              .from('expense')
              .select()
              .eq('user_id', currentUserId!)
              .or(filterString)
              .gte('date', startDate)
              .lte('date', endDate)
              .order('date')
              .withConverter<List<SupaExpense>>((data) {
                return (data).map((e) => SupaExpense.fromJson(e)).toList();
              });
    }
    return response;
  }

  Future<List<SupaExpense>> findExpenseByCategory(String name) async {
    if (currentUserId == null || name.isEmpty) return [];

    final query = name.toLowerCase();
    final matches = expenseCategoryList.where((category) {
      return category.code.toLowerCase().contains(query) ||
          category.label.toLowerCase().contains(query) ||
          category.groupLabel.toLowerCase().contains(query);
    }).toList();
    final filters = matches.isEmpty
        ? ['category_name.ilike.%$name%']
        : matches
            .map((category) => 'category_name.ilike.%${category.code}%')
            .toList();

    return await db
        .from('expense')
        .select()
        .eq('user_id', currentUserId!)
        .or(filters.join(','))
        .order('date')
        .withConverter<List<SupaExpense>>((data) {
          return (data).map((e) => SupaExpense.fromJson(e)).toList();
        });
  }

  Future<List<SupaExpense>> findExpenseText(String text) async {
    if (currentUserId == null || text.isEmpty) return [];

    return await db
        .from('expense')
        .select()
        .eq('user_id', currentUserId!)
        .or('note.ilike.%$text%,detail.ilike.%$text%')
        .order('date')
        .withConverter<List<SupaExpense>>((data) {
          return (data).map((e) => SupaExpense.fromJson(e)).toList();
        });
  }

  Future<List<SupaExpense>> findExpenseByMinimumAmount(
    num amount, {
    String? startDate,
    String? endDate,
  }) async {
    if (currentUserId == null) return [];

    var query = db
        .from('expense')
        .select()
        .eq('user_id', currentUserId!)
        .gte('amount', amount);

    if (startDate != null) query = query.gte('date', startDate);
    if (endDate != null) query = query.lte('date', endDate);

    return await query
        .order('date')
        .withConverter<List<SupaExpense>>((data) {
          return (data).map((e) => SupaExpense.fromJson(e)).toList();
        });
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

  Future<int> getExpenseTotal(DateTime start, DateTime end) async {
    if (currentUserId == null) return 0;
    final response = await db
        .from('expense')
        .select('amount')
        .eq('user_id', currentUserId!)
        .gte('date', start.toStringEx(format: yMd))
        .lte('date', end.toStringEx(format: yMd));
    return response.fold<num>(0, (sum, item) => sum + (item['amount'] ?? 0)).toInt();
  }

  Future<void> addExpense(SupaExpense entity) async {
    final response =
        await db //
            .from('expense')
            .insert(entity.toJson());
    return response;
  }

  Future<void> addExpenses(List<SupaExpense> entities) async {
    await db
        .from('expense')
        .insert(entities.map((entity) => entity.toJson()).toList());
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
      await HelperToast.warn('Budget kategori ini sudah ada');
      return;
    }
    final response =
        await db //
            .from('budgets')
            .upsert(entity.toJson());
    await HelperToast.success('Budget disimpan');
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

  Future<List<SupaAssetSnapshot>> getAssetSnapshots() async {
    if (currentUserId == null) return [];
    try {
      return await db
          .from('asset_snapshots')
          .select()
          .eq('user_id', currentUserId!)
          .order('snapshot_date', ascending: false)
          .limit(24)
          .withConverter<List<SupaAssetSnapshot>>(
            (data) => data.reversed
                .map((e) => SupaAssetSnapshot.fromJson(e))
                .toList(),
          );
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST205') return [];
      rethrow;
    }
  }

  Future<void> saveAssetSnapshot(num amount) async {
    if (currentUserId == null) return;
    final now = DateTime.now();
    try {
      await db.from('asset_snapshots').upsert({
        'user_id': currentUserId,
        'snapshot_date': DateTime(now.year, now.month).toIso8601String().substring(0, 10),
        'amount': amount,
      }, onConflict: 'user_id,snapshot_date');
    } on PostgrestException catch (e) {
      if (e.code != 'PGRST205') rethrow;
    }
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
    return await db.rpc('get_expense_cron').withConverter<List<SupaCron>>((data) {
      return (data as List).map((e) => SupaCron.fromJson(e)).toList();
    });
  }
}
