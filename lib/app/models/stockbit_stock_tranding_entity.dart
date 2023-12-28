import 'dart:convert';

/// *
/// * JSON Source: {"message":"Berhasil menampilkan data list Saham Trending","data":[{"id":6203,"name":"Barito Renewables Energy Tbk.","symbol":"BREN","price":7550,"percent":-1.30719,"icon_url":"https://assets.stockbit.com/logos/companies/BREN.png","status":"active","corp_action":{"active":false,"icon":"https://assets.stockbit.com/images/corp_action_event_icon.svg","text":"Perusahaan Memiliki Corporate Action"},"notations":[null],"is_favorited":0,"is_sharia":0}]}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// *
class StockbitStockTranding {
  String? message;
  List<StockbitStockTrandingData>? data;

  StockbitStockTranding({this.message, this.data});

  StockbitStockTranding.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = json['data'] == null ? null : (json['data'] as List).map((e) => StockbitStockTrandingData.fromJson(e)).toList();
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

class StockbitStockTrandingData {
  num? id;
  String? name;
  String? symbol;
  num? price;
  num? percent;
  String? iconUrl;
  String? status;
  StockbitStockTrandingDataCorpAction? corpAction;
  List<dynamic>? notations;
  num? isFavorited;
  num? isSharia;

  StockbitStockTrandingData({this.id, this.name, this.symbol, this.price, this.percent, this.iconUrl, this.status, this.corpAction, this.notations, this.isFavorited, this.isSharia});

  StockbitStockTrandingData.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    name = json['name'] ?? '';
    symbol = json['symbol'] ?? '';
    price = json['price'] ?? 0;
    percent = json['percent'] ?? 0.0;
    iconUrl = json['icon_url'] ?? '';
    status = json['status'] ?? '';
    corpAction = (json['corp_action'] != null) ? StockbitStockTrandingDataCorpAction.fromJson(json['corp_action']) : null;
    notations = json['notations'] ?? [];
    isFavorited = json['is_favorited'] ?? 0;
    isSharia = json['is_sharia'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['symbol'] = symbol;
    data['price'] = price;
    data['percent'] = percent;
    data['icon_url'] = iconUrl;
    data['status'] = status;
    if (corpAction != null) {
      data['corp_action'] = corpAction!.toJson();
    }
    if (notations != null) {
      data['notations'] = notations;
    }
    data['is_favorited'] = isFavorited;
    data['is_sharia'] = isSharia;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class StockbitStockTrandingDataCorpAction {
  bool? active;
  String? icon;
  String? text;

  StockbitStockTrandingDataCorpAction({this.active, this.icon, this.text});

  StockbitStockTrandingDataCorpAction.fromJson(Map<String, dynamic> json) {
    active = json['active'] ?? false;
    icon = json['icon'] ?? '';
    text = json['text'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['active'] = active;
    data['icon'] = icon;
    data['text'] = text;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
