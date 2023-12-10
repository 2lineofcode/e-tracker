import 'dart:convert';

/// *
/// * JSON Source: [{"name":"Ethereum","symbol":"eth/idr","last":"34194875","day":"-1.76","week":"9.86","month":"18.23","year":"72.13"}]
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// *
class PintuListCrypto {
  String? name;
  String? symbol;
  String? logo;
  String? color;

  String? last;
  String? day;
  String? week;
  String? month;
  String? year;

  PintuListCrypto({this.name, this.symbol, this.logo, this.color, this.last, this.day, this.week, this.month, this.year});

  PintuListCrypto.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    symbol = json['symbol'] ?? '';
    logo = json['logo'] ?? '';
    color = json['color'] ?? '';
    last = json['last'] ?? '';
    day = json['day'] ?? '';
    week = json['week'] ?? '';
    month = json['month'] ?? '';
    year = json['year'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['symbol'] = symbol;
    data['logo'] = logo;
    data['color'] = color;
    data['last'] = last;
    data['day'] = day;
    data['week'] = week;
    data['month'] = month;
    data['year'] = year;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
