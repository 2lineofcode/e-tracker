import 'dart:convert';

/// *
/// * JSON Source: [{"created_at":"2023-11-25T17:51:17.280823+00:00","note":"Ambil Uang","user_id":"25aa9f27-18cb-407d-9141-ffab6a50cab8","category_name":"Notes","amount":"0","id":"0a31aa19-291f-4dce-8f83-551c5fca6dc4"}]
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// *
class SupaAutoComplete {
  String? createdAt;
  String? note;
  String? userId;
  String? categoryName;
  String? amount;
  String? id;

  SupaAutoComplete({this.createdAt, this.note, this.userId, this.categoryName, this.amount, this.id});

  SupaAutoComplete.fromJson(Map<String, dynamic> json) {
    createdAt = json['created_at'];
    note = json['note'];
    userId = json['user_id'];
    categoryName = json['category_name'];
    amount = json['amount'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['created_at'] = createdAt;
    data['note'] = note;
    data['user_id'] = userId;
    data['category_name'] = categoryName;
    data['amount'] = amount;
    data['id'] = id;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
