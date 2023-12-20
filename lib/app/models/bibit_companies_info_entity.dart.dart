import 'dart:convert';

/// * 
/// * JSON Source: {"message":"Berhasil menampilkan data info Saham","data":{"market_hours":{"status":"close","time_left":"2023-12-20T01:45:00.562Z","formatted_time_left":"1 jam 56 menit 4 detik"},"corp_action":{"active":false,"icon":"https://assets.stockbit.com/images/corp_action_event_icon.svg","text":"Perusahaan Memiliki Corporate Action"},"icon_url":""}}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// * 
class BibitCompaniesInfo {
  String? message;
  BibitCompaniesInfoData? data;

  BibitCompaniesInfo({this.message, this.data});

  BibitCompaniesInfo.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = (json['data'] != null) ? BibitCompaniesInfoData.fromJson(json['data']) : null;
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

class BibitCompaniesInfoData {
  BibitCompaniesInfoDataMarketHours? marketHours;
  BibitCompaniesInfoDataCorpAction? corpAction;
  String? iconUrl;

  BibitCompaniesInfoData({this.marketHours, this.corpAction, this.iconUrl});

  BibitCompaniesInfoData.fromJson(Map<String, dynamic> json) {
    marketHours = (json['market_hours'] != null) ? BibitCompaniesInfoDataMarketHours.fromJson(json['market_hours']) : null;
    corpAction = (json['corp_action'] != null) ? BibitCompaniesInfoDataCorpAction.fromJson(json['corp_action']) : null;
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

class BibitCompaniesInfoDataMarketHours {
  String? status;
  String? timeLeft;
  String? formattedTimeLeft;

  BibitCompaniesInfoDataMarketHours({this.status, this.timeLeft, this.formattedTimeLeft});

  BibitCompaniesInfoDataMarketHours.fromJson(Map<String, dynamic> json) {
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

class BibitCompaniesInfoDataCorpAction {
  bool? active;
  String? icon;
  String? text;

  BibitCompaniesInfoDataCorpAction({this.active, this.icon, this.text});

  BibitCompaniesInfoDataCorpAction.fromJson(Map<String, dynamic> json) {
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
