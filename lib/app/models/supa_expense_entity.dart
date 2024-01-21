import 'dart:convert';

import '../core/app_api.dart';
import 'supa_category_entity.dart';

/// *
/// * JSON Source: [{"id":"96e5666c-44c6-4211-9269-7f8d0635b534","created_at":"2023-11-09T16:40:57+00:00","category_name":"Jajan","note":"Kopi Ss","amount":14000,"date":"2023-11-09","user_id":"25aa9f27-18cb-407d-9141-ffab6a50cab8","detail":""}]
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// *
class SupaExpense {
  String? id;
  String? createdAt;
  String? categoryName;
  String? note;
  num? amount;
  String? date;
  String? userId;
  String? detail;
  SupaCategory? category;

  SupaExpense({this.id, this.createdAt, this.categoryName, this.note, this.amount, this.date, this.userId, this.detail, this.category});

  SupaExpense.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    // categoryName = json['category_name'];
    categoryName = json['category_name'].toString().replaceAll('#${db.auth.currentUser!.email!}', '');
    note = json['note'];
    amount = json['amount'];
    date = json['date'];
    userId = json['user_id'];
    detail = json['detail'];
    category = json['category'] != null ? SupaCategory.fromJson(json['category']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    // data['category_name'] = categoryName;
    data['category_name'] = '$categoryName#${db.auth.currentUser!.email}';
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

  @override
  String toString() {
    return jsonEncode(this);
  }
}
