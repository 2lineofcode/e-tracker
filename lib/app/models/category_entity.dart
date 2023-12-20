class Category {
  String? id;
  String? createdAt;
  String? name;
  String? userId;
  String? color;
  String? icon;
  int? maxBudget;
  bool? isPublic;

  Category({
    this.id,
    this.createdAt,
    this.name,
    this.userId,
    this.color,
    this.icon,
    this.maxBudget,
    this.isPublic,
  });

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
    final Map<String, dynamic> data = <String, dynamic>{};
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
}
