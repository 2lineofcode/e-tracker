import '../../core/app_base.dart';
import '../../models/category_entity.dart';
import '../../models/expense_entity.dart';

class FilteringRepository {
  Future<List<String>> getOrderList() async {
    return <String>[
      'amount',
      'note',
    ];
  }

  /// ------------------------------------------------------------------------
  /// ! category
  /// ------------------------------------------------------------------------
  Future<List<CategoryEntity>> getCategory() async {
    final response = await db //
        .from('category')
        .select()
        .eq('user_id', db.auth.currentSession?.user.id ?? '')
        .order('max_budget')
        .withConverter<List<CategoryEntity>>((data) {
      return (data).map((e) => CategoryEntity.fromJson(e)).toList();
    });
    return response;
  }

  /// ------------------------------------------------------------------------
  /// ! expense
  /// ------------------------------------------------------------------------
  Future<List<ExpenseEntity>> findExpense(
    String categoryName,
    String startDate,
    String endDate, {
    String? orderBy,
  }) async {
    var response = <ExpenseEntity>[];
    if (categoryName == '*' || categoryName == 'All') {
      response = await db
          .from('expense')
          //
          .select('*, category(*)')
          .eq('user_id', db.auth.currentSession?.user.id ?? '')
          .filter('date', 'gte', startDate)
          .filter('date', 'lte', endDate)
          .order(orderBy ?? 'amount', ascending: false)
          .withConverter<List<ExpenseEntity>>((data) {
        return (data).map((e) => ExpenseEntity.fromJson(e)).toList();
      });
    } else {
      response = await db
          .from('expense')
          .select('*, category(*)')
          .eq('user_id', db.auth.currentSession?.user.id ?? '')
          .eq('category_name', categoryName)
          .filter('date', 'gte', startDate)
          .filter('date', 'lte', endDate)
          .order(orderBy ?? 'amount', ascending: false)
          .withConverter<List<ExpenseEntity>>((data) {
        return (data).map((e) => ExpenseEntity.fromJson(e)).toList();
      });
    }
    return response;
  }
}
