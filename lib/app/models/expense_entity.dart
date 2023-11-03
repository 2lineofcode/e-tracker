class ExpenseEntity {
  int? id;
  String? createdAt;
  String? categoryName;
  String? note;
  int? amount;
  String? date;
  bool? isSelected;

  ExpenseEntity({this.id, this.createdAt, this.categoryName, this.note, this.amount, this.date, this.isSelected});

  ExpenseEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    categoryName = json['category_name'];
    note = json['note'];
    amount = json['amount'];
    date = json['date'];
    isSelected = json['isSelected'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['category_name'] = categoryName;
    data['note'] = note;
    data['amount'] = amount;
    data['date'] = date;
    return data;
  }
}
