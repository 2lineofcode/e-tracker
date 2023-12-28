import 'dart:convert';

/// *
/// * JSON Source: {"message":"Berhasil menampilkan data Watchlist Anda","data":[{"id":13,"name":"ABF Indonesia Bond Index Fund","symbol":"RD13","type":"Obligasi","instrument_group":0,"is_sharia":0,"investment_manager":{"ojk_code":"DX002"},"return":0.07507561476165558}],"meta":{"max_page":1}}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// *
class BibitWatchlist {
  String? message;
  List<BibitWatchlistData>? data;
  BibitWatchlistMeta? meta;

  BibitWatchlist({this.message, this.data, this.meta});

  BibitWatchlist.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = json['data'] == null ? null : (json['data'] as List).map((e) => BibitWatchlistData.fromJson(e)).toList();
    meta = (json['meta'] != null) ? BibitWatchlistMeta.fromJson(json['meta']) : null;
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

class BibitWatchlistData {
  num? id;
  String? name;
  String? symbol;
  String? type;
  num? instrumentGroup;
  num? isSharia;
  BibitWatchlistDataInvestmentManager? investmentManager;
  num? xReturn;

  BibitWatchlistData({this.id, this.name, this.symbol, this.type, this.instrumentGroup, this.isSharia, this.investmentManager, this.xReturn});

  BibitWatchlistData.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    name = json['name'] ?? '';
    symbol = json['symbol'] ?? '';
    type = json['type'] ?? '';
    instrumentGroup = json['instrument_group'] ?? 0;
    isSharia = json['is_sharia'] ?? 0;
    investmentManager = (json['investment_manager'] != null) ? BibitWatchlistDataInvestmentManager.fromJson(json['investment_manager']) : null;
    xReturn = json['return'] ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['symbol'] = symbol;
    data['type'] = type;
    data['instrument_group'] = instrumentGroup;
    data['is_sharia'] = isSharia;
    if (investmentManager != null) {
      data['investment_manager'] = investmentManager!.toJson();
    }
    data['return'] = xReturn;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitWatchlistDataInvestmentManager {
  String? ojkCode;

  BibitWatchlistDataInvestmentManager({this.ojkCode});

  BibitWatchlistDataInvestmentManager.fromJson(Map<String, dynamic> json) {
    ojkCode = json['ojk_code'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['ojk_code'] = ojkCode;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitWatchlistMeta {
  num? maxPage;

  BibitWatchlistMeta({this.maxPage});

  BibitWatchlistMeta.fromJson(Map<String, dynamic> json) {
    maxPage = json['max_page'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['max_page'] = maxPage;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
