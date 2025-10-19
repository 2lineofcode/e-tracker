class SupaGoals {
  String? id;
  String? createdAt;
  String? updatedAt;
  String? userId;
  String? title;
  int? amount;
  int? target;
  String? icon;
  String? releaseDate;

  SupaGoals({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.title,
    this.amount,
    this.target,
    this.icon,
    this.releaseDate,
  });

  SupaGoals.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    userId = json['user_id'];
    title = json['title'];
    amount = (json['amount'] ?? 0) is int ? json['amount'] : (json['amount'] as num?)?.toInt();
    target = (json['target'] ?? 0) is int ? json['target'] : (json['target'] as num?)?.toInt();
    icon = json['icon'];
    releaseDate = json['release_date'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['user_id'] = userId;
    data['title'] = title;
    data['amount'] = amount;
    data['target'] = target;
    data['icon'] = icon;
    data['release_date'] = releaseDate;
    return data;
  }
}
