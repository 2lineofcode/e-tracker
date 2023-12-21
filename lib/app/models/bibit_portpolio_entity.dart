import 'dart:convert';

/// *
/// * JSON Source: {"message":"Success retreive your portfolio","data":{"marketvalue":146155104.54999998,"mutual_fund_market_value":145854604.54999998,"sbn_market_value":0,"invested":144109632,"profitloss":2045478,"totalpending":0,"totalporto":146155104.54999998,"trading_balance":0,"percentage":0.0142,"result":[{"id":2133948,"name":"Dana Darurat","robo":0,"roboid":"0","is_goal":0,"is_default":1,"templateid":1,"is_shared":0,"pending":0,"totalporto":0,"is_partner_category":0,"created":"2020-08-12T16:20:04.000Z","marketvalue":0,"mutual_fund_market_value":0,"sbn_market_value":0,"invested":0,"profitloss":0,"percentage":0,"type":{"id":4,"name":"Bibit Tabungan"},"items":0}],"limit":{"max":12,"left":7}}}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// *
class BibitPortpolio {
  String? message;
  BibitPortpolioData? data;

  BibitPortpolio({this.message, this.data});

  BibitPortpolio.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = (json['data'] != null) ? BibitPortpolioData.fromJson(json['data']) : null;
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

class BibitPortpolioData {
  num? marketvalue;
  num? mutualFundMarketValue;
  num? sbnMarketValue;
  num? invested;
  num? profitloss;
  num? totalpending;
  num? totalporto;
  num? tradingBalance;
  num? percentage;
  List<BibitPortpolioDataResult>? result;
  BibitPortpolioDataLimit? limit;

  BibitPortpolioData(
      {this.marketvalue,
      this.mutualFundMarketValue,
      this.sbnMarketValue,
      this.invested,
      this.profitloss,
      this.totalpending,
      this.totalporto,
      this.tradingBalance,
      this.percentage,
      this.result,
      this.limit});

  BibitPortpolioData.fromJson(Map<String, dynamic> json) {
    marketvalue = json['marketvalue'] ?? 0.0;
    mutualFundMarketValue = json['mutual_fund_market_value'] ?? 0.0;
    sbnMarketValue = json['sbn_market_value'] ?? 0;
    invested = json['invested'] ?? 0;
    profitloss = json['profitloss'] ?? 0;
    totalpending = json['totalpending'] ?? 0;
    totalporto = json['totalporto'] ?? 0.0;
    tradingBalance = json['trading_balance'] ?? 0;
    percentage = json['percentage'] ?? 0.0;
    result = json['result'] == null ? null : (json['result'] as List).map((e) => BibitPortpolioDataResult.fromJson(e)).toList();
    limit = (json['limit'] != null) ? BibitPortpolioDataLimit.fromJson(json['limit']) : null;
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
    if (result != null) {
      data['result'] = result?.map((e) => e.toJson()).toList();
    }
    if (limit != null) {
      data['limit'] = limit!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitPortpolioDataResult {
  num? id;
  String? name;
  num? robo;
  String? roboid;
  num? isGoal;
  num? isDefault;
  num? templateid;
  num? isShared;
  num? pending;
  num? totalporto;
  num? isPartnerCategory;
  String? created;
  num? marketvalue;
  num? mutualFundMarketValue;
  num? sbnMarketValue;
  num? invested;
  num? profitloss;
  num? percentage;
  BibitPortpolioDataResultType? type;
  num? items;

  BibitPortpolioDataResult({
    this.id,
    this.name,
    this.robo,
    this.roboid,
    this.isGoal,
    this.isDefault,
    this.templateid,
    this.isShared,
    this.pending,
    this.totalporto,
    this.isPartnerCategory,
    this.created,
    this.marketvalue,
    this.mutualFundMarketValue,
    this.sbnMarketValue,
    this.invested,
    this.profitloss,
    this.percentage,
    this.type,
    this.items,
  });

  BibitPortpolioDataResult.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    name = json['name'] ?? '';
    robo = json['robo'] ?? 0;
    roboid = json['roboid'] ?? '';
    isGoal = json['is_goal'] ?? 0;
    isDefault = json['is_default'] ?? 0;
    templateid = json['templateid'] ?? 0;
    isShared = json['is_shared'] ?? 0;
    pending = json['pending'] ?? 0;
    totalporto = json['totalporto'] ?? 0;
    isPartnerCategory = json['is_partner_category'] ?? 0;
    created = json['created'] ?? '';
    marketvalue = json['marketvalue'] ?? 0;
    mutualFundMarketValue = json['mutual_fund_market_value'] ?? 0;
    sbnMarketValue = json['sbn_market_value'] ?? 0;
    invested = json['invested'] ?? 0;
    profitloss = json['profitloss'] ?? 0;
    percentage = json['percentage'] ?? 0;
    type = (json['type'] != null) ? BibitPortpolioDataResultType.fromJson(json['type']) : null;
    items = json['items'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['robo'] = robo;
    data['roboid'] = roboid;
    data['is_goal'] = isGoal;
    data['is_default'] = isDefault;
    data['templateid'] = templateid;
    data['is_shared'] = isShared;
    data['pending'] = pending;
    data['totalporto'] = totalporto;
    data['is_partner_category'] = isPartnerCategory;
    data['created'] = created;
    data['marketvalue'] = marketvalue;
    data['mutual_fund_market_value'] = mutualFundMarketValue;
    data['sbn_market_value'] = sbnMarketValue;
    data['invested'] = invested;
    data['profitloss'] = profitloss;
    data['percentage'] = percentage;
    if (type != null) {
      data['type'] = type!.toJson();
    }
    data['items'] = items;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitPortpolioDataResultType {
  num? id;
  String? name;

  BibitPortpolioDataResultType({this.id, this.name});

  BibitPortpolioDataResultType.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    name = json['name'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitPortpolioDataLimit {
  num? max;
  num? left;

  BibitPortpolioDataLimit({this.max, this.left});

  BibitPortpolioDataLimit.fromJson(Map<String, dynamic> json) {
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
