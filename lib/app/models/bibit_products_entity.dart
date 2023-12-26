import 'dart:convert';

/// *
/// * JSON Source: {"message":"Berhasil menampilkan hasil pencarian produk","data":[{"id":4419,"symbol":"BNII","name":"Bank Maybank Indonesia Tbk.","type":"Saham","instrument_group":2,"icon_url":"https://assets.stockbit.com/logos/companies/BNII.png","is_favorited":0,"is_sharia":false}],"meta":{"current_page":1,"is_next_page_available":true,"total_records":19}}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// *
class BibitProducts {
  String? message;
  List<BibitProductsData>? data;
  BibitProductsMeta? meta;

  BibitProducts({this.message, this.data, this.meta});

  BibitProducts.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = json['data'] == null ? null : (json['data'] as List).map((e) => BibitProductsData.fromJson(e)).toList();
    meta = (json['meta'] != null) ? BibitProductsMeta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data?.map((e) => e.toJson()).toList();
    }
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitProductsData {
  num? id;
  String? symbol;
  String? name;
  String? type;
  num? instrumentGroup;
  String? iconUrl;
  num? isFavorited;
  bool? isSharia;

  BibitProductsData({this.id, this.symbol, this.name, this.type, this.instrumentGroup, this.iconUrl, this.isFavorited, this.isSharia});

  BibitProductsData.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    symbol = json['symbol'] ?? '';
    name = json['name'] ?? '';
    type = json['type'] ?? '';
    instrumentGroup = json['instrument_group'] ?? 0;
    iconUrl = json['icon_url'] ?? '';
    isFavorited = json['is_favorited'] ?? 0;
    isSharia = json['is_sharia'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['symbol'] = symbol;
    data['name'] = name;
    data['type'] = type;
    data['instrument_group'] = instrumentGroup;
    data['icon_url'] = iconUrl;
    data['is_favorited'] = isFavorited;
    data['is_sharia'] = isSharia;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitProductsMeta {
  num? currentPage;
  bool? isNextPageAvailable;
  num? totalRecords;

  BibitProductsMeta({this.currentPage, this.isNextPageAvailable, this.totalRecords});

  BibitProductsMeta.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'] ?? 0;
    isNextPageAvailable = json['is_next_page_available'] ?? false;
    totalRecords = json['total_records'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['is_next_page_available'] = isNextPageAvailable;
    data['total_records'] = totalRecords;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
