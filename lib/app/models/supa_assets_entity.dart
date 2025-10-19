class SupaAssets {
  String? id;
  String? createdAt;
  String? updatedAt;
  String? userId;
  String? title;
  int? amount;

  SupaAssets({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.title,
    this.amount,
  });

  SupaAssets.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    userId = json['user_id'];
    title = json['title'];
    amount = (json['amount'] ?? 0) is int ? json['amount'] : (json['amount'] as num?)?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['user_id'] = userId;
    data['title'] = title;
    data['amount'] = amount;
    return data;
  }
}
