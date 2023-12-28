import 'dart:convert';

/// *
/// * JSON Source: {"message":"Berhasil menampilkan data Watchlist Anda","data":[{"id":4547,"name":"Astra International Tbk.","symbol":"ASII","type":"Saham","instrument_group":2,"is_sharia":1,"corp_action":{"active":false},"price":5600,"percent":0.9009009009009009,"icon_url":"https://assets.stockbit.com/logos/companies/ASII.png","notations":[null],"status":"active"}],"meta":{"max_page":1}}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// *
class StockbitWatchlist {
  String? message;
  List<StockbitWatchlistData>? data;
  StockbitWatchlistMeta? meta;

  StockbitWatchlist({this.message, this.data, this.meta});

  StockbitWatchlist.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = json['data'] == null ? null : (json['data'] as List).map((e) => StockbitWatchlistData.fromJson(e)).toList();
    meta = (json['meta'] != null) ? StockbitWatchlistMeta.fromJson(json['meta']) : null;
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

class StockbitWatchlistData {
  num? id;
  String? name;
  String? symbol;
  String? type;
  num? instrumentGroup;
  num? isSharia;
  StockbitWatchlistDataCorpAction? corpAction;
  num? price;
  num? percent;
  String? iconUrl;
  List<dynamic>? notations;
  String? status;

  StockbitWatchlistData({this.id, this.name, this.symbol, this.type, this.instrumentGroup, this.isSharia, this.corpAction, this.price, this.percent, this.iconUrl, this.notations, this.status});

  StockbitWatchlistData.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    name = json['name'] ?? '';
    symbol = json['symbol'] ?? '';
    type = json['type'] ?? '';
    instrumentGroup = json['instrument_group'] ?? 0;
    isSharia = json['is_sharia'] ?? 0;
    corpAction = (json['corp_action'] != null) ? StockbitWatchlistDataCorpAction.fromJson(json['corp_action']) : null;
    price = json['price'] ?? 0;
    percent = json['percent'] ?? 0.0;
    iconUrl = json['icon_url'] ?? '';
    notations = json['notations'] ?? [];
    status = json['status'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['symbol'] = symbol;
    data['type'] = type;
    data['instrument_group'] = instrumentGroup;
    data['is_sharia'] = isSharia;
    if (corpAction != null) {
      data['corp_action'] = corpAction!.toJson();
    }
    data['price'] = price;
    data['percent'] = percent;
    data['icon_url'] = iconUrl;
    if (notations != null) {
      data['notations'] = notations;
    }
    data['status'] = status;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class StockbitWatchlistDataCorpAction {
  bool? active;

  StockbitWatchlistDataCorpAction({this.active});

  StockbitWatchlistDataCorpAction.fromJson(Map<String, dynamic> json) {
    active = json['active'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['active'] = active;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class StockbitWatchlistMeta {
  num? maxPage;

  StockbitWatchlistMeta({this.maxPage});

  StockbitWatchlistMeta.fromJson(Map<String, dynamic> json) {
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
