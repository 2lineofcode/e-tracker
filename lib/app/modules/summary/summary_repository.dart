import 'package:ex_kit/ex.dart';

import '../../core/app_api.dart';
import '../../core/const.dart';
import '../../models/rpc_sum_all_month_entity.dart';
import '../../models/rpc_sum_note_times_entity.dart';
import '../../models/supa_category_entity.dart';
import '../../models/supa_error_log_entity.dart';
import '../../models/supa_expense_entity.dart';
import '../../models/supa_notes_entity.dart';
import '../../models/supa_recurring_expense_entity.dart';
import '../../models/supa_user_profile_entity.dart';

class SummaryRepository {
  String get _userId {
    final userId = currentUserId;
    if (userId == null) throw StateError('User not authenticated');
    return userId;
  }

  static List<String> expenseSearchKeywords(String query) {
    const ignoredWords = {
      'aku',
      'saya',
      'gue',
      'kalo',
      'kalau',
      'kapan',
      'when',
      'tanggal',
      'tahun',
      'bulan',
      'berapa',
      'ditotal',
      'total',
      'udah',
      'sudah',
      'habis',
      'uang',
      'untuk',
      'all',
      'time',
      'selama',
      'sepanjang',
      'semua',
      'apa',
      'aja',
      'saja',
      'hari',
      'today',
      'kemarin',
      'yesterday',
      'ini',
      'periode',
      'dashboard',
      'milikku',
      'punyaku',
      'pernah',
      'terakhir',
      'pertama',
      'beli',
      'membeli',
      'dibeli',
      'belanja',
      'bayar',
      'membayar',
      'transaksi',
      'pengeluaran',
      'expense',
      'purchase',
      'payment',
      'yang',
      'dan',
      'di',
      'ke',
      'dari',
    };
    return query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .map((word) => word.replaceAll(RegExp('[^a-z0-9]'), ''))
        .where((word) => word.length >= 3 && !ignoredWords.contains(word))
        .take(3)
        .toList();
  }

  Future<List<SupaExpense>> getAllExpenses({
    String? query,
    String? startDate,
    String? endDate,
  }) async {
    if (currentUserId == null) return [];

    const pageSize = 1000;
    final expenses = <SupaExpense>[];
    final keywords = query == null ? null : expenseSearchKeywords(query);
    if (query != null && (keywords == null || keywords.isEmpty)) return [];
    var offset = 0;

    while (true) {
      var request = db
          .from('expense')
          .select()
          .eq('user_id', currentUserId!);
      if (startDate != null) request = request.gte('date', startDate);
      if (endDate != null) request = request.lte('date', endDate);
      for (final keyword in keywords ?? <String>[]) {
        request = request.or(
          'note.ilike.%$keyword%,detail.ilike.%$keyword%,category_name.ilike.%$keyword%',
        );
      }

      final response = await request
          .order('date')
          .order('id')
          .range(offset, offset + pageSize - 1)
          .withConverter<List<SupaExpense>>(
            (data) => data.map((e) => SupaExpense.fromJson(e)).toList(),
          );
      logD(
        'Agent expense page loaded: offset=$offset, rows=${response.length}',
      );
      expenses.addAll(response);
      if (response.length < pageSize) return expenses;
      offset += response.length;
    }
  }

  Future<List<SupaExpense>> getExpenses(DateTime start, DateTime end) async {
    if (currentUserId == null) return [];
    final response =
        await db //
            .from('expense')
            // .select()
            .select('date, amount, category_name, note')
            .eq('user_id', currentUserId!)
            .gte('date', start.toStringEx(format: yMd))
            .lt('date', end.toStringEx(format: yMd))
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

  Future<List<SupaNotes>> getNotes() async {
    if (currentUserId == null) return [];
    return await db
        .from('notes')
        .select()
        .eq('user_id', currentUserId!)
        .order('updated_at', ascending: false)
        .limit(100)
        .withConverter<List<SupaNotes>>(
          (data) => data.map((e) => SupaNotes.fromJson(e)).toList(),
        );
  }

  Future<List<SupaErrorLog>> getErrorLogs() async {
    if (currentUserId == null) return [];
    return await db
        .from('error_log')
        .select('id, created_at, user_id, page, action, stack')
        .eq('user_id', currentUserId!)
        .order('created_at', ascending: false)
        .limit(100)
        .withConverter<List<SupaErrorLog>>(
          (data) => data.map((e) => SupaErrorLog.fromJson(e)).toList(),
        );
  }

  Future<List<Map<String, dynamic>>> getMemories() async {
    return await db
        .from('agent_memory')
        .select('id, key, value, created_at, updated_at')
        .eq('user_id', _userId)
        .order('updated_at', ascending: false)
        .limit(100);
  }

  Future<Map<String, dynamic>> saveMemory(String key, String value) async {
    return await db
        .from('agent_memory')
        .upsert(
          {
            'user_id': _userId,
            'key': key,
            'value': value,
            'updated_at': DateTime.now().toIso8601String(),
          },
          onConflict: 'user_id,key',
        )
        .select('id, key, value, created_at, updated_at')
        .single();
  }

  Future<bool> deleteMemory(String key) async {
    final deleted = await db
        .from('agent_memory')
        .delete()
        .eq('user_id', _userId)
        .eq('key', key)
        .select('id')
        .maybeSingle();
    return deleted != null;
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

  /// ------------------------------------------------------------------------
  /// ! rpc
  /// ------------------------------------------------------------------------
  Future<List<RpcSumAllMonth>> getSumAllMonth({
    required String year,
    required int startDay,
  }) async {
    if (currentUserId == null) return [];
    return await db
        .rpc(
          'sum_all_month',
          params: {
            'userid': currentUserId!,
            'periode': year.toInt(),
            'start_day': startDay,
          },
        )
        .withConverter<List<RpcSumAllMonth>>((data) {
          return (data as List).map((e) => RpcSumAllMonth.fromJson(e)).toList();
        });
  }

  Future<List<RpcSumNoteTimes>> getSumNoteTimes({
    required DateTime start,
    required DateTime end,
    required int startDay,
  }) async {
    if (currentUserId == null) return [];
    return await db
        .rpc(
          'sum_note_times',
          params: {
            'userid': currentUserId!,
            'start_date': start.toStringEx(format: yMd),
            'end_date': end.toStringEx(format: yMd),
            'start_day': startDay,
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

    if (response.isEmpty) return 0;
    return response.first.income ?? 0;
  }
}
