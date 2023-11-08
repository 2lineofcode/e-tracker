import '../../core/const.dart';
import '../../models/autocomplete_entity.dart';
import '../../models/category_entity.dart';
import '../../models/expense_entity.dart';

class HomeRepository {
  // ------------------------------------------------------------------------
  // category
  // ------------------------------------------------------------------------
  Future<List<CategoryEntity>> getCategory() async {
    final response = await db.from('category').select().order('id', ascending: true).withConverter<List<CategoryEntity>>((data) {
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

  Future<void> deleteCategory(int id) async {
    final response = await db.from('category').delete().match({'id': id});
    return response;
  }

  // ------------------------------------------------------------------------
  // expense
  // ------------------------------------------------------------------------
  Future<List<ExpenseEntity>> getExpenseAll() async {
    final response = await db.from('expense').select().order('date').withConverter<List<ExpenseEntity>>((data) {
      return (data as List).map((e) => ExpenseEntity.fromJson(e)).toList();
    });
    return response;
  }

  Future<List<ExpenseEntity>> getExpense(String date) async {
    final response = await db.from('expense').select().eq('date', date).order('amount').withConverter<List<ExpenseEntity>>((data) {
      return (data as List).map((e) => ExpenseEntity.fromJson(e)).toList();
    });
    return response;
  }

  Future<List<ExpenseEntity>> findExpense(String name) async {
    final response = await db.from('expense').select().ilike('note', '%$name%').order('date').withConverter<List<ExpenseEntity>>((data) {
      return (data as List).map((e) => ExpenseEntity.fromJson(e)).toList();
    });
    return response;
  }

  Future<int> getCount1Month(String date) async {
    final response = await db.from('expense').select('amount, date').like('date', '%$date%');
    num x = 0;
    for (var element in (response as List)) {
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

  // ------------------------------------------------------------------------
  // autocomplete
  // ------------------------------------------------------------------------
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

  Future<void> addAutoComplete(
    String note, {
    String? categoryName,
    String? amount,
  }) async {
    final response = await db.from('autocomplete').upsert({
      'note': note,
      'category_name': categoryName,
      'amount': amount,
    });
    return response;
  }
}
