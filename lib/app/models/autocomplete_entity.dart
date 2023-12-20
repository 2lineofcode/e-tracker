class AutoComplete {
  String? createdAt;
  String? note;
  String? userId;
  String? categoryName;
  String? amount;

  AutoComplete({
    this.createdAt,
    this.note,
    this.userId,
    this.categoryName,
    this.amount,
  });

  AutoComplete.fromJson(Map<String, dynamic> json) {
    createdAt = json['created_at'];
    note = json['note'];
    userId = json['user_id'];
    categoryName = json['category_name'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['created_at'] = createdAt;
    data['note'] = note;
    data['user_id'] = userId;
    data['category_name'] = categoryName;
    data['amount'] = amount;
    return data;
  }
}
