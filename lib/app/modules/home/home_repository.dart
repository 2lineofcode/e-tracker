import 'package:ex_kit/ex.dart';

import '../../core/app_api.dart';
import '../../core/const.dart';
import '../../models/rpc_sum_by_category_entity.dart';
import '../../models/supa_autocomplete_entity.dart';
import '../../models/supa_category_entity.dart';
import '../../models/supa_expense_entity.dart';
import '../../models/supa_user_profile_entity.dart';

class HomeRepository {
  /// ------------------------------------------------------------------------
  /// ! category
  /// ------------------------------------------------------------------------
  Future<List<SupaCategory>> getCategory() async {
    if (currentUserId == null) return [];
    final response = await db //
        .from('category')
        .select()
        .eq('user_id', currentUserId!)
        .order('max_budget')
        .withConverter<List<SupaCategory>>((data) {
      return (data).map((e) => SupaCategory.fromJson(e)).toList();
    });
    return response;
  }

  Future<void> addCategory(SupaCategory categoryEntity) async {
    final response = await db.from('category').insert(categoryEntity.toJson());
    return response;
  }

  Future<void> editCategory(SupaCategory categoryEntity) async {
    if (currentUserId == null) return;
    final response = await db.from('category').update(categoryEntity.toJson()).match({
      'id': categoryEntity.id ?? '',
      'user_id': currentUserId!,
    });
    return response;
  }

  Future<void> deleteCategory(String id) async {
    if (currentUserId == null) return;
    final response = await db.from('category').delete().match({
      'id': id,
      'user_id': currentUserId!,
    });
    return response;
  }

  /// ------------------------------------------------------------------------
  /// ! expense
  /// ------------------------------------------------------------------------
  // get all list: for calendar painting
  Future<List<SupaExpense>> getExpenseAll({String period = ''}) async {
    if (currentUserId == null) return [];
    final response = await db //
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
    final response = await db //
        .from('expense')
        .select('*, category(*)')
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
    
    if (startDate == null && endDate == null) {
      response = await db //
          .from('expense')
          .select('*, category(color, icon)')
          .eq('user_id', currentUserId!)
          .or('note.ilike.%$name%, category_name.ilike.%$name%, detail.ilike.%$name%')
          .order('date')
          .withConverter<List<SupaExpense>>((data) {
        return (data).map((e) => SupaExpense.fromJson(e)).toList();
      });
    } else {
      startDate = startDate?.toDateEx(format: yMd).subtract(1.days).toStringEx(format: yMd);
      print('findExpense: $name | sd = $startDate | ed = $endDate');
      response = await db //
          .from('expense')
          .select('*, category(color, icon)')
          .eq('user_id', currentUserId!)
          .or('note.ilike.%$name%, category_name.ilike.%$name%, detail.ilike.%$name%')
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
      final response = await db //
          .from('expense')
          .select('*, category(color, icon)')
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
      final response = await db //
          .from('expense')
          .select('*, category(color, icon)')
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
    final response = await db //
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
    final response = await db //
        .from('expense')
        .insert(entity.toJson());
    return response;
  }

  Future<void> editExpense(SupaExpense entity) async {
    final response = await db //
        .from('expense')
        .update(entity.toJson())
        .match({'id': entity.id ?? ''});
    return response;
  }

  Future<void> deleteExpense(String id) async {
    if (currentUserId == null) return;
    final response = await db //
        .from('expense')
        .delete()
        .match({'id': id, 'user_id': currentUserId!});
    return response;
  }

  /// ------------------------------------------------------------------------
  /// ! autocomplete
  /// ------------------------------------------------------------------------
  Future<List<String>> findAutoCompleteStringNote(String note) async {
    if (currentUserId == null) return [];
    final response = await db //
        .from('autocomplete')
        .select()
        .eq('user_id', currentUserId!)
        .ilike('note', '%$note%')
        .withConverter<List<String>>((data) {
      return (data).map((e) => e['note'].toString()).toList();
    });
    return response;
  }

  Future<List<SupaAutoComplete>> findAutoCompleteFullObject(String note) async {
    if (currentUserId == null) return [];
    final response = await db //
        .from('autocomplete')
        .select()
        .eq('user_id', currentUserId!)
        .eq('note', '$note')
        .withConverter<List<SupaAutoComplete>>((data) {
      return (data).map((e) => SupaAutoComplete.fromJson(e)).toList();
    });
    return response;
  }

  Future<void> addAutoComplete(SupaAutoComplete autocompleteEntity) async {
    final response = await db.from('autocomplete').upsert(autocompleteEntity.toJson());
    return response;
  }

  Future<List<SupaUserProfile>> getUserProfile() async {
    if (currentUserId == null) return [];
    final response = await db //
        .from('profiles')
        .select()
        .eq('id', currentUserId!)
        .withConverter<List<SupaUserProfile>>((data) {
      return (data).map((e) => SupaUserProfile.fromJson(e)).toList();
    });
    return response;
  }

  /// ------------------------------------------------------------------------
  /// ! rpc
  /// ------------------------------------------------------------------------
  Future<List<dynamic>> rpcGetSpenderDay(DateTime focusedDay) async {
    if (currentUserId == null) return [];
    final fixYM = focusedDay.toStringEx(format: yM);
    final result = await db.rpc('get_spender_day', params: {
      'userid': currentUserId!,
      'periode': fixYM,
    }).order('total', ascending: false);
    return result;
  }

  Future<List<RpcSumByCategory>> rpcSumByCategory(DateTime focusedDay) async {
    if (currentUserId == null) return [];
    final fixYM = focusedDay.toStringEx(format: yMd).removeLast(3);
    final res = await db
        .rpc('sum_by_category', params: {
          'userid': currentUserId!,
          'periode': fixYM,
        })
        .order('use_percentage', ascending: false)
        .withConverter<List<RpcSumByCategory>>((data) {
          return (data as List).map((e) => RpcSumByCategory.fromJson(e)).toList();
        });
    return res;
  }
}
