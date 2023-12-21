import 'dart:convert';

/// *
/// * JSON Source: [{"id":"a86f9bb5-d1ee-4e72-91dc-b710c28c54a7","created_at":"2023-11-19T12:50:28+00:00","name":"Family","user_id":"25aa9f27-18cb-407d-9141-ffab6a50cab8","color":"#ff6bb1e7","icon":"code=57943&family=MaterialIcons&pack=null","max_budget":500000,"is_public":true}]
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// *
class Category {
  String? id;
  String? createdAt;
  String? name;
  String? userId;
  String? color;
  String? icon;
  num? maxBudget;
  bool? isPublic;

  Category({this.id, this.createdAt, this.name, this.userId, this.color, this.icon, this.maxBudget, this.isPublic});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    name = json['name'];
    userId = json['user_id'];
    color = json['color'];
    icon = json['icon'];
    maxBudget = json['max_budget'];
    isPublic = json['is_public'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['name'] = name;
    data['user_id'] = userId;
    data['color'] = color;
    data['icon'] = icon;
    data['max_budget'] = maxBudget;
    data['is_public'] = isPublic;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
