class SupaBudgets {
  String? id;
  String? createdAt;
  String? userId;
  String? categoryCode;
  int? amount;

  SupaBudgets({
    this.id,
    this.createdAt,
    this.userId,
    this.categoryCode,
    this.amount,
  });

  SupaBudgets.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    userId = json['user_id'];
    categoryCode = json['category_name'];
    amount = (json['amount'] ?? 0) is int ? json['amount'] : (json['amount'] as num?)?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['user_id'] = userId;
    data['category_name'] = categoryCode;
    data['amount'] = amount;
    return data;
  }
}
