/// * 
/// * JSON Source: {"message":"Berhasil menampilkan data list Indeks Saham","data":[{"id":1,"symbol":"IDX30","name":"IDX30","percent":0.03179937262915768,"change":0.15500000000002956,"price":487.586,"is_sharia":0}]}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// * 
class BibitIndexIndices {
  String? message;
  List<BibitIndexIndicesData>? data;

  BibitIndexIndices({this.message, this.data});

  BibitIndexIndices.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = json['data'] == null ? null : (json['data'] as List).map((e) => BibitIndexIndicesData.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data?.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class BibitIndexIndicesData {
  num? id;
  String? symbol;
  String? name;
  num? percent;
  num? change;
  num? price;
  num? isSharia;

  BibitIndexIndicesData({this.id, this.symbol, this.name, this.percent, this.change, this.price, this.isSharia});

  BibitIndexIndicesData.fromJson(Map<String, dynamic> json) {
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
}
