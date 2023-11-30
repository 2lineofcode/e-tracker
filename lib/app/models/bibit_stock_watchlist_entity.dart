import 'dart:convert';

/// * 
/// * url : https://api.bibit.id/watchlists?instrument_group=2
/// * JSON Source: {"message":"Berhasil menampilkan data Watchlist Anda","data":[{"id":4547,"name":"Astra International Tbk.","symbol":"ASII","type":"Saham","instrument_group":2,"is_sharia":1,"corp_action":{"active":false},"price":5750,"percent":0,"icon_url":"https://assets.stockbit.com/logos/companies/ASII.png","notations":[null],"status":"active"}],"meta":{"max_page":1}}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// * 
class BibitStockWatchlist {
  String? message;
  List<BibitStockWatchlistData>? data;
  BibitStockWatchlistMeta? meta;

  BibitStockWatchlist({this.message, this.data, this.meta});

  BibitStockWatchlist.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = json['data'] == null ? null : (json['data'] as List).map((e) => BibitStockWatchlistData.fromJson(e)).toList();
    meta = (json['meta'] != null) ? BibitStockWatchlistMeta.fromJson(json['meta']) : null;
  }


  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitStockWatchlistData {
  num? id;
  String? name;
  String? symbol;
  String? type;
  num? instrumentGroup;
  num? isSharia;
  BibitStockWatchlistDataCorpAction? corpAction;
  num? price;
  num? percent;
  String? iconUrl;
  List<dynamic>? notations;
  String? status;

  BibitStockWatchlistData({this.id, this.name, this.symbol, this.type, this.instrumentGroup, this.isSharia, this.corpAction, this.price, this.percent, this.iconUrl, this.notations, this.status});

  BibitStockWatchlistData.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    name = json['name'] ?? '';
    symbol = json['symbol'] ?? '';
    type = json['type'] ?? '';
    instrumentGroup = json['instrument_group'] ?? 0;
    isSharia = json['is_sharia'] ?? 0;
    corpAction = (json['corp_action'] != null) ? BibitStockWatchlistDataCorpAction.fromJson(json['corp_action']) : null;
    price = json['price'] ?? 0;
    percent = json['percent'] ?? 0;
    iconUrl = json['icon_url'] ?? '';
    notations = json['notations'] ?? [];
    status = json['status'] ?? '';
  }


  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitStockWatchlistDataCorpAction {
  bool? active;

  BibitStockWatchlistDataCorpAction({this.active});

  BibitStockWatchlistDataCorpAction.fromJson(Map<String, dynamic> json) {
    active = json['active'] ?? false;
  }


  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitStockWatchlistMeta {
  num? maxPage;

  BibitStockWatchlistMeta({this.maxPage});

  BibitStockWatchlistMeta.fromJson(Map<String, dynamic> json) {
    maxPage = json['max_page'] ?? 0;
  }


  @override
  String toString() {
    return jsonEncode(this);
  }
}
