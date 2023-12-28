import 'dart:convert';

/// *
/// * JSON Source: {"message":"Berhasil menampilkan Daftar Transaksi","data":[{"type":"HISTORY","summary":{"action":"DIV","symbol":"SRTG","status":"Success","total_amount":7500,"company_icon_url":"https://assets.stockbit.com/logos/companies/SRTG.png","display_as":"SRTG","label":"Penerimaan Dividend","created_date":"14 Jun 2023"},"details":{"action":"DIV","symbol":"SRTG","company_name":"Saratoga Investama Sedaya Tbk.","company_icon_url":"https://assets.stockbit.com/logos/companies/SRTG.png","created_date":"14 Jun 2023","dividend_type":"Cash","total_holding":100,"dividend_per_share":75,"dividend_ratio":"","amount":7500,"tax_percentage":0,"tax_amount":0,"total_amount":7500,"is_sharia":1}}],"meta":{"max_page":2}}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// *
class BibitHistoryStock {
  String? message;
  List<BibitHistoryStockData>? data;
  BibitHistoryStockMeta? meta;

  BibitHistoryStock({this.message, this.data, this.meta});

  BibitHistoryStock.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = json['data'] == null ? null : (json['data'] as List).map((e) => BibitHistoryStockData.fromJson(e)).toList();
    meta = (json['meta'] != null) ? BibitHistoryStockMeta.fromJson(json['meta']) : null;
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

class BibitHistoryStockData {
  String? type;
  BibitHistoryStockDataSummary? summary;
  BibitHistoryStockDataDetails? details;

  BibitHistoryStockData({this.type, this.summary, this.details});

  BibitHistoryStockData.fromJson(Map<String, dynamic> json) {
    type = json['type'] ?? '';
    summary = (json['summary'] != null) ? BibitHistoryStockDataSummary.fromJson(json['summary']) : null;
    details = (json['details'] != null) ? BibitHistoryStockDataDetails.fromJson(json['details']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['type'] = type;
    if (summary != null) {
      data['summary'] = summary!.toJson();
    }
    if (details != null) {
      data['details'] = details!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitHistoryStockDataSummary {
  String? action;
  String? symbol;
  String? status;
  num? totalAmount;
  String? companyIconUrl;
  String? displayAs;
  String? label;
  String? createdDate;

  BibitHistoryStockDataSummary({this.action, this.symbol, this.status, this.totalAmount, this.companyIconUrl, this.displayAs, this.label, this.createdDate});

  BibitHistoryStockDataSummary.fromJson(Map<String, dynamic> json) {
    action = json['action'] ?? '';
    symbol = json['symbol'] ?? '';
    status = json['status'] ?? '';
    totalAmount = json['total_amount'] ?? 0;
    companyIconUrl = json['company_icon_url'] ?? '';
    displayAs = json['display_as'] ?? '';
    label = json['label'] ?? '';
    createdDate = json['created_date'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['action'] = action;
    data['symbol'] = symbol;
    data['status'] = status;
    data['total_amount'] = totalAmount;
    data['company_icon_url'] = companyIconUrl;
    data['display_as'] = displayAs;
    data['label'] = label;
    data['created_date'] = createdDate;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitHistoryStockDataDetails {
  String? action;
  String? symbol;
  String? companyName;
  String? companyIconUrl;
  String? createdDate;
  String? dividendType;
  num? totalHolding;
  num? dividendPerShare;
  String? dividendRatio;
  num? amount;
  num? taxPercentage;
  num? taxAmount;
  num? totalAmount;
  num? isSharia;

  BibitHistoryStockDataDetails(
      {this.action,
      this.symbol,
      this.companyName,
      this.companyIconUrl,
      this.createdDate,
      this.dividendType,
      this.totalHolding,
      this.dividendPerShare,
      this.dividendRatio,
      this.amount,
      this.taxPercentage,
      this.taxAmount,
      this.totalAmount,
      this.isSharia});

  BibitHistoryStockDataDetails.fromJson(Map<String, dynamic> json) {
    action = json['action'] ?? '';
    symbol = json['symbol'] ?? '';
    companyName = json['company_name'] ?? '';
    companyIconUrl = json['company_icon_url'] ?? '';
    createdDate = json['created_date'] ?? '';
    dividendType = json['dividend_type'] ?? '';
    totalHolding = json['total_holding'] ?? 0;
    dividendPerShare = json['dividend_per_share'] ?? 0;
    dividendRatio = json['dividend_ratio'] ?? '';
    amount = json['amount'] ?? 0;
    taxPercentage = json['tax_percentage'] ?? 0;
    taxAmount = json['tax_amount'] ?? 0;
    totalAmount = json['total_amount'] ?? 0;
    isSharia = json['is_sharia'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['action'] = action;
    data['symbol'] = symbol;
    data['company_name'] = companyName;
    data['company_icon_url'] = companyIconUrl;
    data['created_date'] = createdDate;
    data['dividend_type'] = dividendType;
    data['total_holding'] = totalHolding;
    data['dividend_per_share'] = dividendPerShare;
    data['dividend_ratio'] = dividendRatio;
    data['amount'] = amount;
    data['tax_percentage'] = taxPercentage;
    data['tax_amount'] = taxAmount;
    data['total_amount'] = totalAmount;
    data['is_sharia'] = isSharia;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitHistoryStockMeta {
  num? maxPage;

  BibitHistoryStockMeta({this.maxPage});

  BibitHistoryStockMeta.fromJson(Map<String, dynamic> json) {
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
