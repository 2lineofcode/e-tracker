import 'dart:convert';

/// * 
/// * JSON Source: {"message":"Berhasil menampilkan data Dividend History","data":[{"id":193,"value":29,"date":"2023-08-24T17:00:00.000Z"}]}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// * 
class BibitProductDetailDividend {
  String? message;
  List<BibitProductDetailDividendData>? data;

  BibitProductDetailDividend({this.message, this.data});

  BibitProductDetailDividend.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = json['data'] == null ? null : (json['data'] as List).map((e) => BibitProductDetailDividendData.fromJson(e)).toList();
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

class BibitProductDetailDividendData {
  num? id;
  num? value;
  String? date;

  BibitProductDetailDividendData({this.id, this.value, this.date});

  BibitProductDetailDividendData.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    value = json['value'] ?? 0;
    date = json['date'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['value'] = value;
    data['date'] = date;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
