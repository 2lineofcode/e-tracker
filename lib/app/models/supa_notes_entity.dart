class SupaNotes {
  String? id;
  String? createdAt;
  String? updatedAt;
  String? userId;
  String? title;
  String? content;

  SupaNotes({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.title,
    this.content,
  });

  SupaNotes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    userId = json['user_id'];
    title = json['title'];
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['user_id'] = userId;
    data['title'] = title;
    data['content'] = content;
    return data;
  }
}
