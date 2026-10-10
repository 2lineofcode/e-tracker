import 'package:ex_kit/ex.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_api.dart';
import '../../core/const.dart';
import '../../helpers/helper_expense_query.dart';
import '../../helpers/helpers.dart';
import '../../models/supa_assets_entity.dart';
import '../../models/supa_budgets_entity.dart';
import '../../models/supa_category_entity.dart';
import '../../models/supa_expense_entity.dart';
import '../../models/supa_goals_entity.dart';
import '../../models/supa_notes_entity.dart';
import '../../models/supa_recurring_expense_entity.dart';
import '../../models/supa_user_profile_entity.dart';

class HomeRepository {
  // ────────────────────────────────────────────────────────────────
  // ! expense
  // ────────────────────────────────────────────────────────────────
  // get all list: for calendar painting
  Future<List<SupaExpense>> getExpenseAll(DateTime start, DateTime end) async {
    if (currentUserId == null) return [];
    return await loadAllExpenses(db
        .from('expense')
        .select('date, amount')
        .eq('user_id', currentUserId!)
        .gte('date', start.toStringEx(format: yMd))
        .lt('date', end.toStringEx(format: yMd))
        .order('date'));
  }

  // get list by @date
  Future<List<SupaExpense>> getExpense(String date) async {
    if (currentUserId == null) return [];
    final response =
        await loadAllExpenses(db //
            .from('expense')
            .select()
            .eq('user_id', currentUserId!)
            .eq('date', date)
            .order('amount'));
    return response;
  }

  Future<List<SupaExpense>> getRecentExpenses({int limit = 200}) async {
    if (currentUserId == null) return [];
    return await db
        .from('expense')
        .select('date, amount, category_name, note, detail, created_at')
        .eq('user_id', currentUserId!)
        .gt('amount', 0)
        .order('date', ascending: false)
        .order('created_at', ascending: false)
        .limit(limit)
        .withConverter<List<SupaExpense>>(
          (data) => data.map((e) => SupaExpense.fromJson(e)).toList(),
        );
  }

  Future<List<SupaExpense>> getBudgetSuggestionExpenses(
    DateTime targetMonth,
    int startDay,
  ) async {
    if (currentUserId == null) return [];
    final start = expensePeriodForMonth(
      targetMonth.year,
      targetMonth.month - 3,
      startDay,
    ).start;
    final end = expensePeriodForMonth(
      targetMonth.year,
      targetMonth.month,
      startDay,
    ).start;
    return await loadAllExpenses(db
        .from('expense')
        .select('date, amount, category_name')
        .eq('user_id', currentUserId!)
        .gte('date', start.toStringEx(format: yMd))
        .lt('date', end.toStringEx(format: yMd))
        .order('date'));
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
          await loadAllExpenses(db //
              .from('expense')
              .select()
              .eq('user_id', currentUserId!)
              .or(filterString)
              .order('date'));
    } else {
      response =
          await loadAllExpenses(db //
              .from('expense')
              .select()
              .eq('user_id', currentUserId!)
              .or(filterString)
              .gte('date', startDate)
              .lte('date', endDate)
              .order('date'));
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

    return await loadAllExpenses(db
        .from('expense')
        .select()
        .eq('user_id', currentUserId!)
        .or(filters.join(','))
        .order('date'));
  }

  Future<List<SupaExpense>> findExpenseText(String text) async {
    if (currentUserId == null || text.isEmpty) return [];

    return await loadAllExpenses(db
        .from('expense')
        .select()
        .eq('user_id', currentUserId!)
        .or('note.ilike.%$text%,detail.ilike.%$text%')
        .order('date'));
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

    return await loadAllExpenses(query
        .order('date'));
  }

  // find list by date
  Future<List<SupaExpense>> findExpenseByDateRange(String date) async {
    if (currentUserId == null) return [];

    if (date.isNotEmpty && date.length <= 3) {
      final dateA = DateTime.now().subtract(Duration(days: date.toInt()! - 1)).toStringEx(format: yMd);
      final dateB = DateTime.now().toStringEx(format: yMd);
      final response =
          await loadAllExpenses(db //
              .from('expense')
              .select()
              .eq('user_id', currentUserId!)
              .gte('date', dateA)
              .lte('date', dateB)
              .order('date'));
      return response;
    }
    if (date.length > 11) {
      final dateA = date.substring(0, 10);
      final dateB = date.substring(11);
      final response =
          await loadAllExpenses(db //
              .from('expense')
              .select()
              .eq('user_id', currentUserId!)
              .gte('date', dateA)
              .lte('date', dateB)
              .order('date'));
      return response;
    }

    return findExpense(date);
  }

  // get sum by date range
  Future<int> getExpenseTotal(DateTime start, DateTime end) async {
    if (currentUserId == null) return 0;
    final response = await loadAllExpenses(db
        .from('expense')
        .select('amount')
        .eq('user_id', currentUserId!)
        .gte('date', start.toStringEx(format: yMd))
        .lt('date', end.toStringEx(format: yMd)));
    return response.fold<num>(0, (sum, expense) => sum + (expense.amount ?? 0)).toInt();
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
    if (currentUserId == null) throw StateError('User not authenticated');
    await db
        .from('expense')
        .update(entity.toJson())
        .match({'id': entity.id ?? '', 'user_id': currentUserId!})
        .select('id')
        .single();
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
        await loadAllExpenses(db //
            .from('expense')
            .select()
            .eq('user_id', currentUserId!)
            .eq('date', date)
            .eq('amount', amount));

    String normalize(String value) => value.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
    final normalizedNote = normalize(note);

    return response.where((expense) {
      if (excludeId != null && expense.id == excludeId) return false;
      final candidate = normalize(expense.note ?? '');
      return candidate == normalizedNote || candidate.contains(normalizedNote) || normalizedNote.contains(candidate);
    }).toList();
  }

  Future<int> countPotentialDuplicates(List<SupaExpense> expenses) async {
    if (currentUserId == null || expenses.isEmpty) return 0;
    final dates = expenses.map((expense) => expense.date!).toList()..sort();
    final candidates = await loadAllExpenses(db
        .from('expense')
        .select('date, amount, note')
        .eq('user_id', currentUserId!)
        .gte('date', dates.first)
        .lte('date', dates.last));
    return potentialDuplicateCount(expenses, candidates);
  }

  static int potentialDuplicateCount(List<SupaExpense> expenses, List<SupaExpense> candidates) {
    String normalize(String value) => value.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
    final notesByTransaction = <(String?, num?), List<String>>{};
    for (final candidate in candidates) {
      notesByTransaction.putIfAbsent((candidate.date, candidate.amount), () => [])
          .add(normalize(candidate.note ?? ''));
    }
    return expenses.where((expense) {
      final note = normalize(expense.note ?? '');
      return (notesByTransaction[(expense.date, expense.amount)] ?? []).any(
        (candidate) => candidate == note || candidate.contains(note) || note.contains(candidate),
      );
    }).length;
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

  Future<Map<String, num>> getExpenseByBudgets(
    DateTime start,
    DateTime end,
  ) async {
    if (currentUserId == null) return {};

    final response =
        await loadAllExpenses(db //
            .from('expense')
            .select('category_name, amount, date')
            .eq('user_id', currentUserId!)
            .gte('date', start.toStringEx(format: yMd))
            .lt('date', end.toStringEx(format: yMd))
            .order('date'));

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
  Future<List<dynamic>> rpcGetSpenderDay(DateTime start, DateTime end) async {
    if (currentUserId == null) return [];
    final result = await db
        .rpc(
          'get_spender_day',
          params: {
            'userid': currentUserId!,
            'start_date': start.toStringEx(format: yMd),
            'end_date': end.toStringEx(format: yMd),
          },
        )
        .order('total', ascending: false);
    return result;
  }

  Future<List<SupaRecurringExpense>> getRecurringExpenses() async {
    if (currentUserId == null) return [];
    return await db
        .from('recurring_expenses')
        .select()
        .eq('user_id', currentUserId!)
        .isFilter('archived_at', null)
        .order('created_at')
        .withConverter<List<SupaRecurringExpense>>(
          (data) => data.map((e) => SupaRecurringExpense.fromJson(e)).toList(),
        );
  }
}
