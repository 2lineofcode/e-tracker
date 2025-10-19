import '../../core/app_api.dart';
import '../../models/supa_category_entity.dart';
import '../../models/supa_expense_entity.dart';

class FilteringRepository {
  Future<List<SupaExpense>> findExpense(
    String categoryCode,
    String startDate,
    String endDate, {
    String? orderBy,
  }) async {
    if (currentUserId == null) return [];

    final response = await db
        .from('expense')
        .select()
        .eq('user_id', currentUserId!)
        .filter('date', 'gte', startDate)
        .filter('date', 'lte', endDate)
        .order(orderBy ?? 'amount', ascending: false)
        .withConverter<List<SupaExpense>>((data) {
          return (data).map((e) => SupaExpense.fromJson(e)).toList();
        });

    if (categoryCode == '*' || categoryCode == 'All') {
      return response;
    }

    final category = resolveExpenseCategory(categoryCode);
    return response.where((element) => element.resolvedCategory.code == category.code).toList();
  }
}
