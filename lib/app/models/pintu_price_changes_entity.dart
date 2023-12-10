import 'dart:convert';

/// * 
/// * url: https://api.pintu.co.id/v2/trade/price-changes
/// * image: https://s3-ap-southeast-1.amazonaws.com/static.pintu.co.id/assets/images/logo/circle_{code}.svg
/// * JSON Source: {"code":"success","message":"","payload":[{"pair":"kava/idr","latestPrice":"12508","day":"0.75","week":"5.72","month":"17.89","year":"-11.16"}]}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// * 
class PintuPriceChanges {
  String? code;
  String? message;
  List<PintuPriceChangesPayload>? payload;

  PintuPriceChanges({this.code, this.message, this.payload});

  PintuPriceChanges.fromJson(Map<String, dynamic> json) {
    code = json['code'] ?? '';
    message = json['message'] ?? '';
    payload = json['payload'] == null ? null : (json['payload'] as List).map((e) => PintuPriceChangesPayload.fromJson(e)).toList();
  }


  @override
  String toString() {
    return jsonEncode(this);
  }
}

class PintuPriceChangesPayload {
  String? pair;
  String? latestPrice;
  String? day;
  String? week;
  String? month;
  String? year;

  PintuPriceChangesPayload({this.pair, this.latestPrice, this.day, this.week, this.month, this.year});

  PintuPriceChangesPayload.fromJson(Map<String, dynamic> json) {
    pair = json['pair'] ?? '';
    latestPrice = json['latestPrice'] ?? '';
    day = json['day'] ?? '';
    week = json['week'] ?? '';
    month = json['month'] ?? '';
    year = json['year'] ?? '';
  }


  @override
  String toString() {
    return jsonEncode(this);
  }
}
