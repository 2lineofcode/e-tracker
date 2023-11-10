class RpcSumByCategoryEntity {
  String? period;
  String? categoryId;
  String? categoryName;
  String? categoryColor;
  String? categoryIcon;
  int? maxBudget;
  int? total;
  int? usePercentage;
  int? remainingBudget;

  RpcSumByCategoryEntity({
    this.period = '',
    this.categoryId = '',
    this.categoryName = '',
    this.categoryColor = '',
    this.categoryIcon = '',
    this.maxBudget = 0,
    this.total = 0,
    this.usePercentage = 0,
    this.remainingBudget = 0,
  });

  RpcSumByCategoryEntity.fromJson(Map<String, dynamic> json) {
    period = json['period'];
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    categoryColor = json['category_color'];
    categoryIcon = json['category_icon'];
    maxBudget = json['max_budget'];
    total = json['total'];
    usePercentage = json['use_percentage'];
    remainingBudget = json['remaining_budget'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
}
