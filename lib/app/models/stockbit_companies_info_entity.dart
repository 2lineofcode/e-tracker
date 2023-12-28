import 'dart:convert';

/// * 
/// * JSON Source: {"message":"Berhasil menampilkan data info Saham","data":{"market_hours":{"status":"open","time_left":"2023-12-28T02:40:43.693Z","formatted_time_left":"0 jam 0 menit 0 detik"},"corp_action":{"active":false,"icon":"https://assets.stockbit.com/images/corp_action_event_icon.svg","text":"Perusahaan Memiliki Corporate Action"},"icon_url":""}}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// * 
class StockbitCompaniesInfo {
  String? message;
  StockbitCompaniesInfoData? data;

  StockbitCompaniesInfo({this.message, this.data});

  StockbitCompaniesInfo.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = (json['data'] != null) ? StockbitCompaniesInfoData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class StockbitCompaniesInfoData {
  StockbitCompaniesInfoDataMarketHours? marketHours;
  StockbitCompaniesInfoDataCorpAction? corpAction;
  String? iconUrl;

  StockbitCompaniesInfoData({this.marketHours, this.corpAction, this.iconUrl});

  StockbitCompaniesInfoData.fromJson(Map<String, dynamic> json) {
    marketHours = (json['market_hours'] != null) ? StockbitCompaniesInfoDataMarketHours.fromJson(json['market_hours']) : null;
    corpAction = (json['corp_action'] != null) ? StockbitCompaniesInfoDataCorpAction.fromJson(json['corp_action']) : null;
    iconUrl = json['icon_url'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (marketHours != null) {
      data['market_hours'] = marketHours!.toJson();
    }
    if (corpAction != null) {
      data['corp_action'] = corpAction!.toJson();
    }
    data['icon_url'] = iconUrl;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class StockbitCompaniesInfoDataMarketHours {
  String? status;
  String? timeLeft;
  String? formattedTimeLeft;

  StockbitCompaniesInfoDataMarketHours({this.status, this.timeLeft, this.formattedTimeLeft});

  StockbitCompaniesInfoDataMarketHours.fromJson(Map<String, dynamic> json) {
    status = json['status'] ?? '';
    timeLeft = json['time_left'] ?? '';
    formattedTimeLeft = json['formatted_time_left'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['status'] = status;
    data['time_left'] = timeLeft;
    data['formatted_time_left'] = formattedTimeLeft;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class StockbitCompaniesInfoDataCorpAction {
  bool? active;
  String? icon;
  String? text;

  StockbitCompaniesInfoDataCorpAction({this.active, this.icon, this.text});

  StockbitCompaniesInfoDataCorpAction.fromJson(Map<String, dynamic> json) {
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
