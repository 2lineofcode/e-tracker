import 'dart:convert';

/// *
/// * JSON Source: {"message":"Berhasil menampilkan data list Indeks Saham","data":[{"id":1,"symbol":"IDX30","name":"IDX30","percent":0.8187707462237594,"change":4.02800000000002,"price":495.985,"is_sharia":0}]}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// *
class StockbitIndexIndices {
  String? message;
  List<StockbitIndexIndicesData>? data;

  StockbitIndexIndices({this.message, this.data});

  StockbitIndexIndices.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = json['data'] == null ? null : (json['data'] as List).map((e) => StockbitIndexIndicesData.fromJson(e)).toList();
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

class StockbitIndexIndicesData {
  num? id;
  String? symbol;
  String? name;
  num? percent;
  num? change;
  num? price;
  num? isSharia;

  StockbitIndexIndicesData({this.id, this.symbol, this.name, this.percent, this.change, this.price, this.isSharia});

  StockbitIndexIndicesData.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    symbol = json['symbol'] ?? '';
    name = json['name'] ?? '';
    percent = json['percent'] ?? 0.0;
    change = json['change'] ?? 0.0;
    price = json['price'] ?? 0.0;
    isSharia = json['is_sharia'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['symbol'] = symbol;
    data['name'] = name;
    data['percent'] = percent;
    data['change'] = change;
    data['price'] = price;
    data['is_sharia'] = isSharia;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
