import 'dart:convert';

import 'supa_category_entity.dart';

class SupaExpense {
  String? id;
  String? createdAt;
  String? categoryName;
  String? note;
  num? amount;
  String? date;
  String? userId;
  String? detail;

  SupaExpense({
    this.id,
    this.createdAt,
    this.categoryName,
    this.note,
    this.amount,
    this.date,
    this.userId,
    this.detail,
  });

  SupaExpense.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    categoryName = _sanitizeCategory(json['category_name']);
    note = json['note'];
    amount = json['amount'];
    date = json['date'];
    userId = json['user_id'];
    detail = json['detail'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['category_name'] = categoryName;
    data['note'] = note;
    data['amount'] = amount;
    data['date'] = date;
    data['user_id'] = userId;
    data['detail'] = detail;
    return data;
  }

  ExpenseCategory get resolvedCategory => resolveExpenseCategory(categoryName);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

String _sanitizeCategory(dynamic source) {
  final raw = source?.toString() ?? '';
  final hashIndex = raw.indexOf('#');
  if (hashIndex == -1) return raw;
  return raw.substring(0, hashIndex);
}
