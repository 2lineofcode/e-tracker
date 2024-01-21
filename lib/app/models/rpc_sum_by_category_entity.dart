import 'dart:convert';

import '../core/app_api.dart';

/// *
/// * JSON Source: [{"period":"2023","category_id":"69dffbb4-c1a7-43cc-9fdc-a82e9fce66cf","category_name":"Food","category_color":"#ffe0e7e2","category_icon":"code=58566&family=FontAwesomeSolid&pack=font_awesome_flutter","max_budget":"1000000","total":"5339000","use_percentage":534,"remaining_budget":"-4339000"}]
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// *
class RpcSumByCategory {
  String? period;
  String? categoryId;
  String? categoryName;
  String? categoryColor;
  String? categoryIcon;
  int? maxBudget;
  int? total;
  int? usePercentage;
  int? remainingBudget;

  RpcSumByCategory({this.period, this.categoryId, this.categoryName, this.categoryColor, this.categoryIcon, this.maxBudget, this.total, this.usePercentage, this.remainingBudget});

  RpcSumByCategory.fromJson(Map<String, dynamic> json) {
    period = json['period'] ?? '';
    categoryId = json['category_id'] ?? '';
    // categoryName = json['category_name'] ?? '';
    categoryName = json['category_name'].toString().replaceAll('#${db.auth.currentUser!.email!}', '');
    categoryColor = json['category_color'] ?? '';
    categoryIcon = json['category_icon'] ?? '';
    maxBudget = json['max_budget'] ?? 0;
    total = json['total'] ?? 0;
    usePercentage = json['use_percentage'] ?? 0;
    remainingBudget = json['remaining_budget'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['period'] = period;
    data['category_id'] = categoryId;
    data['category_name'] = categoryName;
    data['category_color'] = categoryColor;
    data['category_icon'] = categoryIcon;
    data['max_budget'] = maxBudget;
    data['total'] = total;
    data['use_percentage'] = usePercentage;
    data['remaining_budget'] = remainingBudget;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
