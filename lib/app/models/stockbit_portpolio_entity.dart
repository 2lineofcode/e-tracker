import 'dart:convert';

/// * 
/// * JSON Source: {"message":"Berhasil menampilkan portofolio","data":{"symbol":"GOTO","is_sharia":1,"company_name":"GoTo Gojek Tokopedia Tbk.","icon_url":"https://assets.stockbit.com/logos/companies/GOTO.png","market_value":85000,"invested_amount":188188,"profit_loss_amount":-103188,"profit_loss_percentage":-0.5483240164091228,"average_price":188.188,"available_lot":10,"balance_lot":10,"status":"active","notations":[{"notation_code":"K","notation_desc":"Perusahaan Tercatat yang menerapkan Saham Dengan Hak Suara Multipel dan tercatat di Papan Ekonomi Baru","icon_url":{"light_mode":"https://assets.stockbit.com/logos/notations/light/K.png","dark_mode":"https://assets.stockbit.com/logos/notations/dark/K.png"}}],"corp_action":{"active":false,"icon":"https://assets.stockbit.com/images/corp_action_event_icon.svg","text":"Perusahaan Memiliki Corporate Action"},"available_share":1000,"balance_share":1000,"stock_on_hand":1000},"meta":{"is_maintenance":0}}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// * 
class StockbitPortpolio {
  String? message;
  StockbitPortpolioData? data;
  StockbitPortpolioMeta? meta;

  StockbitPortpolio({this.message, this.data, this.meta});

  StockbitPortpolio.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = (json['data'] != null) ? StockbitPortpolioData.fromJson(json['data']) : null;
    meta = (json['meta'] != null) ? StockbitPortpolioMeta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
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

class StockbitPortpolioData {
  String? symbol;
  num? isSharia;
  String? companyName;
  String? iconUrl;
  num? marketValue;
  num? investedAmount;
  num? profitLossAmount;
  num? profitLossPercentage;
  num? averagePrice;
  num? availableLot;
  num? balanceLot;
  String? status;
  List<StockbitPortpolioDataNotations>? notations;
  StockbitPortpolioDataCorpAction? corpAction;
  num? availableShare;
  num? balanceShare;
  num? stockOnHand;

  StockbitPortpolioData({this.symbol, this.isSharia, this.companyName, this.iconUrl, this.marketValue, this.investedAmount, this.profitLossAmount, this.profitLossPercentage, this.averagePrice, this.availableLot, this.balanceLot, this.status, this.notations, this.corpAction, this.availableShare, this.balanceShare, this.stockOnHand});

  StockbitPortpolioData.fromJson(Map<String, dynamic> json) {
    symbol = json['symbol'] ?? '';
    isSharia = json['is_sharia'] ?? 0;
    companyName = json['company_name'] ?? '';
    iconUrl = json['icon_url'] ?? '';
    marketValue = json['market_value'] ?? 0;
    investedAmount = json['invested_amount'] ?? 0;
    profitLossAmount = json['profit_loss_amount'] ?? 0;
    profitLossPercentage = json['profit_loss_percentage'] ?? 0.0;
    averagePrice = json['average_price'] ?? 0.0;
    availableLot = json['available_lot'] ?? 0;
    balanceLot = json['balance_lot'] ?? 0;
    status = json['status'] ?? '';
    notations = json['notations'] == null ? null : (json['notations'] as List).map((e) => StockbitPortpolioDataNotations.fromJson(e)).toList();
    corpAction = (json['corp_action'] != null) ? StockbitPortpolioDataCorpAction.fromJson(json['corp_action']) : null;
    availableShare = json['available_share'] ?? 0;
    balanceShare = json['balance_share'] ?? 0;
    stockOnHand = json['stock_on_hand'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['symbol'] = symbol;
    data['is_sharia'] = isSharia;
    data['company_name'] = companyName;
    data['icon_url'] = iconUrl;
    data['market_value'] = marketValue;
    data['invested_amount'] = investedAmount;
    data['profit_loss_amount'] = profitLossAmount;
    data['profit_loss_percentage'] = profitLossPercentage;
    data['average_price'] = averagePrice;
    data['available_lot'] = availableLot;
    data['balance_lot'] = balanceLot;
    data['status'] = status;
    if (notations != null) {
      data['notations'] = notations?.map((e) => e.toJson()).toList();
    }
    if (corpAction != null) {
      data['corp_action'] = corpAction!.toJson();
    }
    data['available_share'] = availableShare;
    data['balance_share'] = balanceShare;
    data['stock_on_hand'] = stockOnHand;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class StockbitPortpolioDataNotations {
  String? notationCode;
  String? notationDesc;
  StockbitPortpolioDataNotationsIconUrl? iconUrl;

  StockbitPortpolioDataNotations({this.notationCode, this.notationDesc, this.iconUrl});

  StockbitPortpolioDataNotations.fromJson(Map<String, dynamic> json) {
    notationCode = json['notation_code'] ?? '';
    notationDesc = json['notation_desc'] ?? '';
    iconUrl = (json['icon_url'] != null) ? StockbitPortpolioDataNotationsIconUrl.fromJson(json['icon_url']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['notation_code'] = notationCode;
    data['notation_desc'] = notationDesc;
    if (iconUrl != null) {
      data['icon_url'] = iconUrl!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class StockbitPortpolioDataNotationsIconUrl {
  String? lightMode;
  String? darkMode;

  StockbitPortpolioDataNotationsIconUrl({this.lightMode, this.darkMode});

  StockbitPortpolioDataNotationsIconUrl.fromJson(Map<String, dynamic> json) {
    lightMode = json['light_mode'] ?? '';
    darkMode = json['dark_mode'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['light_mode'] = lightMode;
    data['dark_mode'] = darkMode;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class StockbitPortpolioDataCorpAction {
  bool? active;
  String? icon;
  String? text;

  StockbitPortpolioDataCorpAction({this.active, this.icon, this.text});

  StockbitPortpolioDataCorpAction.fromJson(Map<String, dynamic> json) {
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

class StockbitPortpolioMeta {
  num? isMaintenance;

  StockbitPortpolioMeta({this.isMaintenance});

  StockbitPortpolioMeta.fromJson(Map<String, dynamic> json) {
    isMaintenance = json['is_maintenance'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['is_maintenance'] = isMaintenance;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
