import 'package:ex/ex.dart';

import '../../core/app_api.dart';
import '../../core/const.dart';
import '../../models/autocomplete_entity.dart';
import '../../models/category_entity.dart';
import '../../models/expense_entity.dart';
import '../../models/rpc_sum_by_category_entity.dart';

class HomeRepository {
  /// ------------------------------------------------------------------------
  /// ! category
  /// ------------------------------------------------------------------------
  Future<List<Category>> getCategory() async {
    final response = await db //
        .from('category')
        .select()
        .eq('user_id', db.auth.currentSession?.user.id ?? '')
        .order('max_budget')
        .withConverter<List<Category>>((data) {
      return (data).map((e) => Category.fromJson(e)).toList();
    });
    return response;
  }

  Future<void> addCategory(Category categoryEntity) async {
    final response = await db.from('category').insert(categoryEntity.toJson());
    return response;
  }

  Future<void> editCategory(Category categoryEntity) async {
    final response = await db.from('category').update(categoryEntity.toJson()).match({
      'id': categoryEntity.id,
      'user_id': db.auth.currentSession?.user.id ?? '',
    });
    return response;
  }

  Future<void> deleteCategory(String id) async {
    final response = await db.from('category').delete().match({
      'id': id,
      'user_id': db.auth.currentSession?.user.id ?? '',
    });
    return response;
  }

  /// ------------------------------------------------------------------------
  /// ! expense
  /// ------------------------------------------------------------------------
  // get all list: for calendar painting
  Future<List<Expense>> getExpenseAll({String period = ''}) async {
    final response = await db //
        .from('expense')
        .select('date, amount')
        .eq('user_id', db.auth.currentSession?.user.id ?? '')
        .or('date.ilike.$period%')
        .order('date')
        .withConverter<List<Expense>>((data) {
      return (data).map((e) => Expense.fromJson(e)).toList();
    });
    return response;
  }

  // get list by @date
  Future<List<Expense>> getExpense(String date) async {
    final response = await db //
        .from('expense')
        .select('*, category(*)')
        .eq('user_id', db.auth.currentSession?.user.id ?? '')
        .eq('date', date)
        .order('amount')
        .withConverter<List<Expense>>((data) {
      return (data).map((e) => Expense.fromJson(e)).toList();
    });
    return response;
  }

  // find list by @note or @category.name
  Future<List<Expense>> findExpense(String name) async {
    final response = await db //
        .from('expense')
        .select('*, category(color, icon)')
        .eq('user_id', db.auth.currentSession?.user.id ?? '')
        .or('note.ilike.%$name%, category_name.ilike.%$name%')
        .order('date')
        .withConverter<List<Expense>>((data) {
      return (data).map((e) => Expense.fromJson(e)).toList();
    });
    return response;
  }

  // get sum by @date [1month]
  Future<int?> getCount1Month(String date) async {
    final response = await db //
        .from('expense')
        .select('amount, date')
        .eq('user_id', db.auth.currentSession?.user.id ?? '')
        .like('date', '%$date%');
    num x = 0;
    for (var element in response) {
      x += element['amount'] ?? 0;
    }
    return x.toInt();
  }

  Future<void> addExpense(Expense entity) async {
    final response = await db //
        .from('expense')
        .insert(entity.toJson());
    return response;
  }

  Future<void> editExpense(Expense entity) async {
    final response = await db //
        .from('expense')
        .update(entity.toJson())
        .match({'id': entity.id});
    return response;
  }

  Future<void> deleteExpense(String id) async {
    final response = await db //
        .from('expense')
        .delete()
        .match({'id': id, 'user_id': db.auth.currentSession?.user.id ?? ''});
    return response;
  }

  /// ------------------------------------------------------------------------
  /// ! autocomplete
  /// ------------------------------------------------------------------------
  Future<List<String>> findAutoCompleteStringNote(String note) async {
    final response = await db //
        .from('autocomplete')
        .select()
        .eq('user_id', db.auth.currentSession?.user.id ?? '')
        .ilike('note', '%$note%')
        .withConverter<List<String>>((data) {
      return (data).map((e) => e['note'].toString()).toList();
    });
    return response;
  }

  Future<List<AutoComplete>> findAutoCompleteFullObject(String note) async {
    final response = await db //
        .from('autocomplete')
        .select()
        .eq('user_id', db.auth.currentSession?.user.id ?? '')
        .eq('note', '$note')
        .withConverter<List<AutoComplete>>((data) {
      return (data).map((e) => AutoComplete.fromJson(e)).toList();
    });
    return response;
  }

  Future<void> addAutoComplete(String note, {String? categoryName, String? amount}) async {
    final response = await db.from('autocomplete').upsert({
      'note': note,
      'category_name': categoryName,
      'amount': amount,
      'user_id': db.auth.currentSession?.user.id,
    });
    return response;
  }

  /// ------------------------------------------------------------------------
  /// ! rpc
  /// ------------------------------------------------------------------------
  Future<List<dynamic>> rpcGetSpenderDay(DateTime focusedDay) async {
    final fixYM = focusedDay.toStringEx(format: yMd).removeLast(3);
    final result = await db.rpc('get_spender_day', params: {
      'userid': db.auth.currentSession?.user.id ?? '',
      'periode': fixYM,
    }).order('total', ascending: false);
    return result;
  }

  Future<List<RpcSumByCategory>> rpcSumByCategory(DateTime focusedDay) async {
    final fixYM = focusedDay.toStringEx(format: yMd).removeLast(3);
    final res = await db
        .rpc('sum_by_category', params: {
          'userid': db.auth.currentSession?.user.id ?? '',
          'periode': fixYM,
        })
        .order('use_percentage', ascending: false)
        .withConverter<List<RpcSumByCategory>>((data) {
          return (data as List).map((e) => RpcSumByCategory.fromJson(e)).toList();
        });
    return res;
  }
}
