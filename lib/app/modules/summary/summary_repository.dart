import '../../../const.dart';
import '../../models/category_entity.dart';

class SummaryRepository {
  Future<List<CategoryEntity>> getCategory() async {
    final response = await db.from('category').select().order('id', ascending: true).withConverter<List<CategoryEntity>>((data) {
      return (data as List).map((e) => CategoryEntity.fromJson(e)).toList();
    });
    return response;
  }

  Future<int> getCount1Month(String date) async {
    final response = await db.from('expense').select('amount').like('date', '%$date%');
    num x = 0;
    for (var element in (response as List)) {
      x += element['amount'] ?? 0;
    }
    return x.toInt();
  }

  Future<int> getCount1Year(String date) async {
    final response = await db.from('expense').select('amount').like('date', '%$date%');
    num x = 0;
    for (var element in (response as List)) {
      x += element['amount'] ?? 0;
    }
    return x.toInt();
  }

  Future<int?> getByCategory(String categoryName, String date) async {
    final response = await db.from('expense').select('amount, category_name').eq('category_name', categoryName).ilike('date', '%$date%');
    num x = 0;
    for (var element in (response as List)) {
      x += element['amount'] ?? 0;
    }
    return x.toInt();
  }
}
