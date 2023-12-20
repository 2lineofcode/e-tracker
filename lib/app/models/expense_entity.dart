import 'category_entity.dart';

class Expense {
  String? id;
  String? createdAt;
  String? categoryName;
  String? note;
  int? amount;
  String? date;
  String? userId;
  String? detail;
  Category? category;

  Expense({this.id, this.createdAt, this.categoryName, this.note, this.amount, this.date, this.userId, this.detail, this.category});

  Expense.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    categoryName = json['category_name'];
    note = json['note'];
    amount = json['amount'];
    date = json['date'];
    userId = json['user_id'];
    detail = json['detail'];
    category = json['category'] != null ? Category.fromJson(json['category']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['category_name'] = categoryName;
    data['note'] = note;
    data['amount'] = amount;
    data['date'] = date;
    data['user_id'] = userId;
    data['detail'] = detail;
    if (category != null) {
      data['category'] = category!.toJson();
    }
    return data;
  }
}
