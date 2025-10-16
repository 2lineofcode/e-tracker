import '../../core/app_api.dart';
import '../../models/supa_category_entity.dart';
import '../../models/supa_expense_entity.dart';

class FilteringRepository {
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

  /// ------------------------------------------------------------------------
  /// ! expense
  /// ------------------------------------------------------------------------
  Future<List<SupaExpense>> findExpense(
    String categoryName,
    String startDate,
    String endDate, {
    String? orderBy,
  }) async {
    if (currentUserId == null) return [];
    var response = <SupaExpense>[];
    if (categoryName == '*' || categoryName == 'All') {
      response = await db
          .from('expense')
          //
          .select('*, category(*)')
          .eq('user_id', currentUserId!)
          .filter('date', 'gte', startDate)
          .filter('date', 'lte', endDate)
          .order(orderBy ?? 'amount', ascending: false)
          .withConverter<List<SupaExpense>>((data) {
        return (data).map((e) => SupaExpense.fromJson(e)).toList();
      });
    } else {
      response = await db
          .from('expense')
          .select('*, category(*)')
          .eq('user_id', currentUserId!)
          .eq('category_name', '$categoryName#${db.auth.currentSession?.user.email}')
          .filter('date', 'gte', startDate)
          .filter('date', 'lte', endDate)
          .order(orderBy ?? 'amount', ascending: false)
          .withConverter<List<SupaExpense>>((data) {
        return (data).map((e) => SupaExpense.fromJson(e)).toList();
      });
    }
    return response;
  }
}
