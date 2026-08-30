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
  int? income;
  int? birthYear;
  int? balance;
  num? ecoDay;
  num? averageDay;
  num? spenderDay;
  num? paymentDay;

  SupaUserProfile({
    this.id,
    this.updatedAt,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.income,
    this.birthYear,
    this.balance,
    this.ecoDay,
    this.averageDay,
    this.spenderDay,
    this.paymentDay,
  });

  SupaUserProfile.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    updatedAt = json['updated_at'] ?? '';
    username = json['username'] ?? '';
    fullName = json['full_name'] ?? '';
    avatarUrl = json['avatar_url'];
    income = (json['income'] as num?)?.toInt() ?? 0;
    birthYear = (json['birth_year'] as num?)?.toInt();
    balance = (json['balance'] as num?)?.toInt() ?? 0;
    ecoDay = json['eco_day'] ?? 0;
    averageDay = json['average_day'] ?? 0;
    spenderDay = json['spender_day'] ?? 0;
    paymentDay = json['pay_day'] ?? 28;
  }

  int? get calculatedAge {
    if (birthYear == null) return null;
    return DateTime.now().year - birthYear!;
  }

  String get birthYearInput {
    return birthYear?.toString() ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    if (updatedAt != null) data['updated_at'] = updatedAt;
    if (username != null) data['username'] = username;
    if (fullName != null) data['full_name'] = fullName;
    if (avatarUrl != null) data['avatar_url'] = avatarUrl;
    if (income != null) data['income'] = income;
    if (birthYear != null) data['birth_year'] = birthYear;
    if (balance != null) data['balance'] = balance;
    if (ecoDay != null) data['eco_day'] = ecoDay;
    if (averageDay != null) data['average_day'] = averageDay;
    if (spenderDay != null) data['spender_day'] = spenderDay;
    if (paymentDay != null) data['pay_day'] = paymentDay;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
