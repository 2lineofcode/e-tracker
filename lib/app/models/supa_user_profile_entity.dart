import 'dart:convert';

/// *
/// * JSON Source: [{"id":"25aa9f27-18cb-407d-9141-ffab6a50cab8","updated_at":"null","username":"null","full_name":"Aditya Pratama","avatar_url":"null","income":"null"}]
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// *
class SupaUserProfile {
  String? id;
  String? updatedAt;
  String? username;
  String? fullName;
  String? avatarUrl;
  String? income;
  String? age;
  String? balance;
  num? ecoDay;
  num? averageDay;
  num? spenderDay;

  SupaUserProfile({
    this.id,
    this.updatedAt,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.income,
    this.age,
    this.balance,
    this.ecoDay,
    this.averageDay,
    this.spenderDay,
  });

  SupaUserProfile.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    updatedAt = json['updated_at'] ?? '';
    username = json['username'] ?? '';
    fullName = json['full_name'] ?? '';
    avatarUrl = json['avatar_url'];
    income = json['income'] ?? '';
    age = json['age'] ?? '';
    balance = json['balance'] ?? '';
    ecoDay = json['eco_day'] ?? 0;
    averageDay = json['average_day'] ?? 0;
    spenderDay = json['spender_day'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['updated_at'] = updatedAt;
    data['username'] = username;
    data['full_name'] = fullName;
    data['avatar_url'] = avatarUrl;
    data['income'] = income;
    data['age'] = age;
    data['balance'] = balance;
    data['eco_day'] = ecoDay;
    data['average_day'] = averageDay;
    data['spender_day'] = spenderDay;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
