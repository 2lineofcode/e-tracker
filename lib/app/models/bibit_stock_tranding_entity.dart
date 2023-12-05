import 'dart:convert';

/// * 
/// * url : https://api.bibit.id/stocks/companies/trending
/// * JSON Source: {"message":"Berhasil menampilkan data list Saham Trending","data":[{"id":4425,"name":"GoTo Gojek Tokopedia Tbk.","symbol":"GOTO","price":100,"percent":-8.25688,"icon_url":"https://assets.stockbit.com/logos/companies/GOTO.png","status":"active","corp_action":{"active":false,"icon":"https://assets.stockbit.com/images/corp_action_event_icon.svg","text":"Perusahaan Memiliki Corporate Action"},"notations":[{"notation_code":"K","notation_desc":"Perusahaan Tercatat yang menerapkan Saham Dengan Hak Suara Multipel dan tercatat di Papan Ekonomi Baru","icon_url":{"light_mode":"https://assets.stockbit.com/logos/notations/light/K.png","dark_mode":"https://assets.stockbit.com/logos/notations/dark/K.png"}}],"is_favorited":1,"is_sharia":1}]}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// * 
class BibitStockTranding {
  String? message;
  List<BibitStockTrandingData>? data;

  BibitStockTranding({this.message, this.data});

  BibitStockTranding.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = json['data'] == null ? null : (json['data'] as List).map((e) => BibitStockTrandingData.fromJson(e)).toList();
  }


  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitStockTrandingData {
  num? id;
  String? name;
  String? symbol;
  num? price;
  num? percent;
  String? iconUrl;
  String? status;
  BibitStockTrandingDataCorpAction? corpAction;
  List<BibitStockTrandingDataNotations>? notations;
  num? isFavorited;
  num? isSharia;

  BibitStockTrandingData({this.id, this.name, this.symbol, this.price, this.percent, this.iconUrl, this.status, this.corpAction, this.notations, this.isFavorited, this.isSharia});

  BibitStockTrandingData.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    name = json['name'] ?? '';
    symbol = json['symbol'] ?? '';
    price = json['price'] ?? 0;
    percent = json['percent'] ?? 0.0;
    iconUrl = json['icon_url'] ?? '';
    status = json['status'] ?? '';
    corpAction = (json['corp_action'] != null) ? BibitStockTrandingDataCorpAction.fromJson(json['corp_action']) : null;
    notations = json['notations'] == null ? null : (json['notations'] as List).map((e) => BibitStockTrandingDataNotations.fromJson(e)).toList();
    isFavorited = json['is_favorited'] ?? 0;
    isSharia = json['is_sharia'] ?? 0;
  }


  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitStockTrandingDataCorpAction {
  bool? active;
  String? icon;
  String? text;

  BibitStockTrandingDataCorpAction({this.active, this.icon, this.text});

  BibitStockTrandingDataCorpAction.fromJson(Map<String, dynamic> json) {
    active = json['active'] ?? false;
    icon = json['icon'] ?? '';
    text = json['text'] ?? '';
  }


  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitStockTrandingDataNotations {
  String? notationCode;
  String? notationDesc;
  BibitStockTrandingDataNotationsIconUrl? iconUrl;

  BibitStockTrandingDataNotations({this.notationCode, this.notationDesc, this.iconUrl});

  BibitStockTrandingDataNotations.fromJson(Map<String, dynamic> json) {
    notationCode = json['notation_code'] ?? '';
    notationDesc = json['notation_desc'] ?? '';
    iconUrl = (json['icon_url'] != null) ? BibitStockTrandingDataNotationsIconUrl.fromJson(json['icon_url']) : null;
  }


  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitStockTrandingDataNotationsIconUrl {
  String? lightMode;
  String? darkMode;

  BibitStockTrandingDataNotationsIconUrl({this.lightMode, this.darkMode});

  BibitStockTrandingDataNotationsIconUrl.fromJson(Map<String, dynamic> json) {
    lightMode = json['light_mode'] ?? '';
    darkMode = json['dark_mode'] ?? '';
  }


  @override
  String toString() {
    return jsonEncode(this);
  }
}
