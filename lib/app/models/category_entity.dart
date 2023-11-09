class CategoryEntity {
  String? id;
  String? createdAt;
  String? name;
  int? userId;
  String? color;
  String? icon;
  int? maxBudget;

  CategoryEntity({
    this.id,
    this.createdAt,
    this.name,
    this.userId,
    this.color,
    this.icon,
    this.maxBudget,
  });

  CategoryEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    name = json['name'];
    userId = json['user_id'];
    color = json['color'];
    icon = json['icon'];
    maxBudget = json['max_budget'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['name'] = name;
    data['user_id'] = userId;
    data['color'] = color;
    data['icon'] = icon;
    data['max_budget'] = maxBudget;
    return data;
  }
}
