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
  String? imageUrl;

  SupaExpense({
    this.id,
    this.createdAt,
    this.categoryName,
    this.note,
    this.amount,
    this.date,
    this.userId,
    this.detail,
    this.imageUrl,
  });

  SupaExpense.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    categoryName = _sanitizeCategory(json['category_name']);
    note = json['note'];
    amount = json['amount'];
    date = _sanitizeDate(json['date']);
    userId = json['user_id'];
    detail = json['detail'];
    imageUrl = json['image_url'];
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
    data['image_url'] = imageUrl;
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

String _sanitizeDate(dynamic source) {
  final raw = source?.toString() ?? '';
  if (RegExp(r'^\d{8}$').hasMatch(raw)) {
    return '${raw.substring(0, 4)}-${raw.substring(4, 6)}-${raw.substring(6, 8)}';
  }
  return raw;
}
