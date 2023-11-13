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

  Future<List<CategoryEntity>> getCategory() async {
    final response = await db.from('category').select().order('max_budget').withConverter<List<CategoryEntity>>((data) {
      return (data as List).map((e) => CategoryEntity.fromJson(e)).toList();
    });
    return response;
  }

  Future<List<ExpenseEntity>> findExpense(
    String categoryName,
    String startDate,
    String endDate, {
    String? orderBy,
  }) async {
    final response = await db
        .from('expense')
        .select()
        .eq('category_name', categoryName)
        .filter('date', 'gte', startDate)
        .filter('date', 'lte', endDate)
        .order(orderBy ?? 'amount', ascending: false)
        .withConverter<List<ExpenseEntity>>((data) {
      return (data as List).map((e) => ExpenseEntity.fromJson(e)).toList();
    });
    return response;
  }
}
