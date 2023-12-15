import 'package:ex/ex.dart';

import '../../core/app_base.dart';
import '../../core/const.dart';
import '../../models/autocomplete_entity.dart';
import '../../models/category_entity.dart';
import '../../models/expense_entity.dart';
import '../../models/rpc_sum_by_category_entity.dart';

class HomeRepository {
  /// ------------------------------------------------------------------------
  /// ! category
  /// ------------------------------------------------------------------------
  Future<List<CategoryEntity>> getCategory() async {
    final response = await db.from('category').select().order('max_budget').withConverter<List<CategoryEntity>>((data) {
      return (data as List).map((e) => CategoryEntity.fromJson(e)).toList();
    });
    return response;
  }

  Future<void> addCategory(CategoryEntity categoryEntity) async {
    final response = await db.from('category').upsert(categoryEntity.toJson());
    return response;
  }

  Future<void> editCategory(CategoryEntity categoryEntity) async {
    final response = await db.from('category').update(categoryEntity.toJson()).match({'id': categoryEntity.id});
    return response;
  }

  Future<void> deleteCategory(String id) async {
    final response = await db.from('category').delete().match({'id': id});
    return response;
  }

  /// ------------------------------------------------------------------------
  /// ! expense
  /// ------------------------------------------------------------------------
  // get all list: for calendar painting
  Future<List<ExpenseEntity>> getExpenseAll({String period = ''}) async {
    final response = await db //
        .from('expense')
        .select('date, amount')
        .or('date.ilike.$period%')
        .order('date')
        .withConverter<List<ExpenseEntity>>((data) {
      return (data as List).map((e) => ExpenseEntity.fromJson(e)).toList();
    });
    return response;
  }

  // get list by @date
  Future<List<ExpenseEntity>> getExpense(String date) async {
    final response = await db //
        .from('expense')
        .select('*, category(*)')
        .eq('date', date)
        .order('amount')
        .withConverter<List<ExpenseEntity>>((data) {
      return (data as List).map((e) => ExpenseEntity.fromJson(e)).toList();
    });
    return response;
  }

  // find list by @note or @category.name
  Future<List<ExpenseEntity>> findExpense(String name) async {
    final response = await db //
        .from('expense')
        .select('*, category(color, icon)')
        .or('note.ilike.%$name%, category_name.ilike.%$name%')
        .order('date')
        .withConverter<List<ExpenseEntity>>((data) {
      return (data as List).map((e) => ExpenseEntity.fromJson(e)).toList();
    });
    return response;
  }

  // get sum by @date [1month]
  Future<int> getCount1Month(String date) async {
    final response = await db.from('expense').select('amount, date').like('date', '%$date%');
    num x = 0;
    for (var element in response) {
      x += element['amount'] ?? 0;
    }
    return x.toInt();
  }

  Future<void> addExpense(ExpenseEntity entity) async {
    final response = await db.from('expense').insert(entity.toJson());
    return response;
  }

  Future<void> editExpense(ExpenseEntity entity) async {
    final response = await db.from('expense').update(entity.toJson()).match({'id': entity.id});
    return response;
  }

  Future<void> deleteExpense(String id) async {
    final response = await db.from('expense').delete().match({'id': id});
    return response;
  }

  /// ------------------------------------------------------------------------
  /// ! autocomplete
  /// ------------------------------------------------------------------------
  Future<List<String>> findAutoCompleteStringNote(String note) async {
    final response = await db.from('autocomplete').select().ilike('note', '%$note%').withConverter<List<String>>((data) {
      return (data as List).map((e) => e['note'].toString()).toList();
    });
    return response;
  }

  Future<List<AutoCompleteEntity>> findAutoCompleteFullObject(String note) async {
    final response = await db.from('autocomplete').select().eq('note', '$note').withConverter<List<AutoCompleteEntity>>((data) {
      return (data as List).map((e) => AutoCompleteEntity.fromJson(e)).toList();
    });
    return response;
  }

  Future<void> addAutoComplete(String note, {String? categoryName, String? amount}) async {
    final response = await db.from('autocomplete').upsert({
      'note': note,
      'category_name': categoryName,
      'amount': amount,
    });
    return response;
  }

  /// ------------------------------------------------------------------------
  /// ! rpc
  /// ------------------------------------------------------------------------
  Future<List<dynamic>> rpcGetSpenderDay(DateTime focusedDay) async {
    final fixYM = focusedDay.toStringEx(format: yMd).removeLast(3);
    final result = await db.rpc('get_spender_day', params: {'periode': fixYM}).order('total', ascending: false);
    return result;
  }

  Future<List<RpcSumByCategoryEntity>> rpcSumByCategory(DateTime focusedDay) async {
    final fixYM = focusedDay.toStringEx(format: yMd).removeLast(3);
    final res = await db //
        .rpc('sum_by_category', params: {'periode': fixYM})
        .order('use_percentage', ascending: false)
        .withConverter<List<RpcSumByCategoryEntity>>((data) {
          return (data as List).map((e) => RpcSumByCategoryEntity.fromJson(e)).toList();
        });
    return res;
  }
}
