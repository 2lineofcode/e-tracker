import 'dart:convert';

/// *
/// * JSON Source: [{"id":"asd","created_at":"","user_email":"asd","page":"","action":""}]
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// *
class SupaErrorLog {
  String? id;
  String? createdAt;
  String? userEmail;
  String? page;
  String? action;
  String? stack;

  SupaErrorLog({this.id, this.createdAt, this.userEmail, this.page, this.action, this.stack});

  SupaErrorLog.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    createdAt = json['created_at'] ?? '';
    userEmail = json['user_email'] ?? '';
    page = json['page'] ?? '';
    action = json['action'] ?? '';
    stack = json['stack'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['user_email'] = userEmail;
    data['page'] = page;
    data['action'] = action;
    data['stack'] = stack;
    return data;
  }

  static List<SupaErrorLog> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => SupaErrorLog.fromJson(map)).toList();
  }

  SupaErrorLog copyWith({
    String? id,
    String? createdAt,
    String? userEmail,
    String? page,
    String? action,
    String? stack,
  }) =>
      SupaErrorLog(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        userEmail: userEmail ?? this.userEmail,
        page: page ?? this.page,
        action: action ?? this.action,
        stack: stack ?? this.stack,
      );

  @override
  String toString() {
    return jsonEncode(this);
  }
}
