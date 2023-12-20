import 'dart:convert';

/// * 
/// * JSON Source: {"message":"Berhasil menampilkan data Portfolio Performance","data":{"marketvalue":146146269.59,"mutual_fund_market_value":145841769.59,"sbn_market_value":0,"invested":144109632,"profitloss":2036644,"totalpending":0,"totalporto":146146269.59,"trading_balance":0,"percentage":0.0141,"limit":{"max":12,"left":7},"additional_parameters":{"invested":143436960,"total_deposit":212067500,"total_withdrawal":71000757.56,"profitloss_realized":2370217.03}}}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// * 
class BibitPerformance {
  String? message;
  BibitPerformanceData? data;

  BibitPerformance({this.message, this.data});

  BibitPerformance.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = (json['data'] != null) ? BibitPerformanceData.fromJson(json['data']) : null;
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

class BibitPerformanceData {
  double? marketvalue;
  double? mutualFundMarketValue;
  int? sbnMarketValue;
  int? invested;
  int? profitloss;
  int? totalpending;
  double? totalporto;
  int? tradingBalance;
  double? percentage;
  BibitPerformanceDataLimit? limit;
  BibitPerformanceDataAdditionalParameters? additionalParameters;

  BibitPerformanceData({this.marketvalue, this.mutualFundMarketValue, this.sbnMarketValue, this.invested, this.profitloss, this.totalpending, this.totalporto, this.tradingBalance, this.percentage, this.limit, this.additionalParameters});

  BibitPerformanceData.fromJson(Map<String, dynamic> json) {
    marketvalue = json['marketvalue'] ?? 0.0;
    mutualFundMarketValue = json['mutual_fund_market_value'] ?? 0.0;
    sbnMarketValue = json['sbn_market_value'] ?? 0;
    invested = json['invested'] ?? 0;
    profitloss = json['profitloss'] ?? 0;
    totalpending = json['totalpending'] ?? 0;
    totalporto = json['totalporto'] ?? 0.0;
    tradingBalance = json['trading_balance'] ?? 0;
    percentage = json['percentage'] ?? 0.0;
    limit = (json['limit'] != null) ? BibitPerformanceDataLimit.fromJson(json['limit']) : null;
    additionalParameters = (json['additional_parameters'] != null) ? BibitPerformanceDataAdditionalParameters.fromJson(json['additional_parameters']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['marketvalue'] = marketvalue;
    data['mutual_fund_market_value'] = mutualFundMarketValue;
    data['sbn_market_value'] = sbnMarketValue;
    data['invested'] = invested;
    data['profitloss'] = profitloss;
    data['totalpending'] = totalpending;
    data['totalporto'] = totalporto;
    data['trading_balance'] = tradingBalance;
    data['percentage'] = percentage;
    if (limit != null) {
      data['limit'] = limit!.toJson();
    }
    if (additionalParameters != null) {
      data['additional_parameters'] = additionalParameters!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitPerformanceDataLimit {
  int? max;
  int? left;

  BibitPerformanceDataLimit({this.max, this.left});

  BibitPerformanceDataLimit.fromJson(Map<String, dynamic> json) {
    max = json['max'] ?? 0;
    left = json['left'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['max'] = max;
    data['left'] = left;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitPerformanceDataAdditionalParameters {
  int? invested;
  int? totalDeposit;
  double? totalWithdrawal;
  double? profitlossRealized;

  BibitPerformanceDataAdditionalParameters({this.invested, this.totalDeposit, this.totalWithdrawal, this.profitlossRealized});

  BibitPerformanceDataAdditionalParameters.fromJson(Map<String, dynamic> json) {
    invested = json['invested'] ?? 0;
    totalDeposit = json['total_deposit'] ?? 0;
    totalWithdrawal = json['total_withdrawal'] ?? 0.0;
    profitlossRealized = json['profitloss_realized'] ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['invested'] = invested;
    data['total_deposit'] = totalDeposit;
    data['total_withdrawal'] = totalWithdrawal;
    data['profitloss_realized'] = profitlossRealized;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
