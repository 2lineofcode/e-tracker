import 'dart:convert';

/// *
/// * JSON Source: {"message":"Berhasil menampilkan data Saham Terkait GOTO","data":[{"name":"PT DCI Indonesia Tbk","symbol":"DCII","percent":0,"icon_url":"https://assets.stockbit.com/logos/companies/DCII.png"}]}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// *
class StockbitRelated {
  String? message;
  List<StockbitRelatedData>? data;

  StockbitRelated({this.message, this.data});

  StockbitRelated.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = json['data'] == null ? null : (json['data'] as List).map((e) => StockbitRelatedData.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data?.map((e) => e.toJson()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class StockbitRelatedData {
  String? name;
  String? symbol;
  num? percent;
  String? iconUrl;

  StockbitRelatedData({this.name, this.symbol, this.percent, this.iconUrl});

  StockbitRelatedData.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    symbol = json['symbol'] ?? '';
    percent = json['percent'] ?? 0;
    iconUrl = json['icon_url'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['symbol'] = symbol;
    data['percent'] = percent;
    data['icon_url'] = iconUrl;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
