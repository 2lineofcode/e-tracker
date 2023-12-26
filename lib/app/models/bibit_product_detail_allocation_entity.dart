import 'dart:convert';

/// * 
/// * JSON Source: {"message":"Berhasil menampilkan data detail asset","data":{"currency_exchange":{"currency":"IDR","exchange_rate":1,"invested_amount":0,"average_price":0,"pending_amount":0,"market_value":0,"total_portfolio":0},"market_value":43727242.31,"invested_amount":44576460,"pending_amount":0,"total_invested_amount":44576460,"total_portfolio":43727242.31,"profit_loss_amount":-849217,"profit_loss_percentage":-0.0191,"average_price":860.2382,"units":51818.7383,"product":{"identifier":"RD337","group":"MUTUAL_FUND","label":"Saham","name":"BNI-AM Indeks IDX30","icon":{"code":"NI002"},"is_sharia":0,"meta":{"is_instant_redemption":0}},"portfolio_placements":[{"portfolio_id":2133949,"portfolio_position":0,"portfolio_name":"Dana Pensiun","portfolio_template_id":2,"is_partner_category":0,"is_sellable":1,"units":33952.6133,"invested_amount":28370000,"market_value":28650912.73,"profit_loss_amount":280913}]}}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// * 
class BibitProductDetailAllocation {
  String? message;
  BibitProductDetailAllocationData? data;

  BibitProductDetailAllocation({this.message, this.data});

  BibitProductDetailAllocation.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = (json['data'] != null) ? BibitProductDetailAllocationData.fromJson(json['data']) : null;
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

class BibitProductDetailAllocationData {
  BibitProductDetailAllocationDataCurrencyExchange? currencyExchange;
  num? marketValue;
  num? investedAmount;
  num? pendingAmount;
  num? totalInvestedAmount;
  num? totalPortfolio;
  num? profitLossAmount;
  num? profitLossPercentage;
  num? averagePrice;
  num? units;
  BibitProductDetailAllocationDataProduct? product;
  List<BibitProductDetailAllocationDataPortfolioPlacements>? portfolioPlacements;

  BibitProductDetailAllocationData({this.currencyExchange, this.marketValue, this.investedAmount, this.pendingAmount, this.totalInvestedAmount, this.totalPortfolio, this.profitLossAmount, this.profitLossPercentage, this.averagePrice, this.units, this.product, this.portfolioPlacements});

  BibitProductDetailAllocationData.fromJson(Map<String, dynamic> json) {
    currencyExchange = (json['currency_exchange'] != null) ? BibitProductDetailAllocationDataCurrencyExchange.fromJson(json['currency_exchange']) : null;
    marketValue = json['market_value'] ?? 0.0;
    investedAmount = json['invested_amount'] ?? 0;
    pendingAmount = json['pending_amount'] ?? 0;
    totalInvestedAmount = json['total_invested_amount'] ?? 0;
    totalPortfolio = json['total_portfolio'] ?? 0.0;
    profitLossAmount = json['profit_loss_amount'] ?? 0;
    profitLossPercentage = json['profit_loss_percentage'] ?? 0.0;
    averagePrice = json['average_price'] ?? 0.0;
    units = json['units'] ?? 0.0;
    product = (json['product'] != null) ? BibitProductDetailAllocationDataProduct.fromJson(json['product']) : null;
    portfolioPlacements = json['portfolio_placements'] == null ? null : (json['portfolio_placements'] as List).map((e) => BibitProductDetailAllocationDataPortfolioPlacements.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (currencyExchange != null) {
      data['currency_exchange'] = currencyExchange!.toJson();
    }
    data['market_value'] = marketValue;
    data['invested_amount'] = investedAmount;
    data['pending_amount'] = pendingAmount;
    data['total_invested_amount'] = totalInvestedAmount;
    data['total_portfolio'] = totalPortfolio;
    data['profit_loss_amount'] = profitLossAmount;
    data['profit_loss_percentage'] = profitLossPercentage;
    data['average_price'] = averagePrice;
    data['units'] = units;
    if (product != null) {
      data['product'] = product!.toJson();
    }
    if (portfolioPlacements != null) {
      data['portfolio_placements'] = portfolioPlacements?.map((e) => e.toJson()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitProductDetailAllocationDataCurrencyExchange {
  String? currency;
  num? exchangeRate;
  num? investedAmount;
  num? averagePrice;
  num? pendingAmount;
  num? marketValue;
  num? totalPortfolio;

  BibitProductDetailAllocationDataCurrencyExchange({this.currency, this.exchangeRate, this.investedAmount, this.averagePrice, this.pendingAmount, this.marketValue, this.totalPortfolio});

  BibitProductDetailAllocationDataCurrencyExchange.fromJson(Map<String, dynamic> json) {
    currency = json['currency'] ?? '';
    exchangeRate = json['exchange_rate'] ?? 0;
    investedAmount = json['invested_amount'] ?? 0;
    averagePrice = json['average_price'] ?? 0;
    pendingAmount = json['pending_amount'] ?? 0;
    marketValue = json['market_value'] ?? 0;
    totalPortfolio = json['total_portfolio'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['currency'] = currency;
    data['exchange_rate'] = exchangeRate;
    data['invested_amount'] = investedAmount;
    data['average_price'] = averagePrice;
    data['pending_amount'] = pendingAmount;
    data['market_value'] = marketValue;
    data['total_portfolio'] = totalPortfolio;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitProductDetailAllocationDataProduct {
  String? identifier;
  String? group;
  String? label;
  String? name;
  BibitProductDetailAllocationDataProductIcon? icon;
  num? isSharia;
  BibitProductDetailAllocationDataProductMeta? meta;

  BibitProductDetailAllocationDataProduct({this.identifier, this.group, this.label, this.name, this.icon, this.isSharia, this.meta});

  BibitProductDetailAllocationDataProduct.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'] ?? '';
    group = json['group'] ?? '';
    label = json['label'] ?? '';
    name = json['name'] ?? '';
    icon = (json['icon'] != null) ? BibitProductDetailAllocationDataProductIcon.fromJson(json['icon']) : null;
    isSharia = json['is_sharia'] ?? 0;
    meta = (json['meta'] != null) ? BibitProductDetailAllocationDataProductMeta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['group'] = group;
    data['label'] = label;
    data['name'] = name;
    if (icon != null) {
      data['icon'] = icon!.toJson();
    }
    data['is_sharia'] = isSharia;
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

class BibitProductDetailAllocationDataProductIcon {
  String? code;

  BibitProductDetailAllocationDataProductIcon({this.code});

  BibitProductDetailAllocationDataProductIcon.fromJson(Map<String, dynamic> json) {
    code = json['code'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['code'] = code;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitProductDetailAllocationDataProductMeta {
  num? isInstantRedemption;

  BibitProductDetailAllocationDataProductMeta({this.isInstantRedemption});

  BibitProductDetailAllocationDataProductMeta.fromJson(Map<String, dynamic> json) {
    isInstantRedemption = json['is_instant_redemption'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['is_instant_redemption'] = isInstantRedemption;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitProductDetailAllocationDataPortfolioPlacements {
  num? portfolioId;
  num? portfolioPosition;
  String? portfolioName;
  num? portfolioTemplateId;
  num? isPartnerCategory;
  num? isSellable;
  num? units;
  num? investedAmount;
  num? marketValue;
  num? profitLossAmount;

  BibitProductDetailAllocationDataPortfolioPlacements({this.portfolioId, this.portfolioPosition, this.portfolioName, this.portfolioTemplateId, this.isPartnerCategory, this.isSellable, this.units, this.investedAmount, this.marketValue, this.profitLossAmount});

  BibitProductDetailAllocationDataPortfolioPlacements.fromJson(Map<String, dynamic> json) {
    portfolioId = json['portfolio_id'] ?? 0;
    portfolioPosition = json['portfolio_position'] ?? 0;
    portfolioName = json['portfolio_name'] ?? '';
    portfolioTemplateId = json['portfolio_template_id'] ?? 0;
    isPartnerCategory = json['is_partner_category'] ?? 0;
    isSellable = json['is_sellable'] ?? 0;
    units = json['units'] ?? 0.0;
    investedAmount = json['invested_amount'] ?? 0;
    marketValue = json['market_value'] ?? 0.0;
    profitLossAmount = json['profit_loss_amount'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['portfolio_id'] = portfolioId;
    data['portfolio_position'] = portfolioPosition;
    data['portfolio_name'] = portfolioName;
    data['portfolio_template_id'] = portfolioTemplateId;
    data['is_partner_category'] = isPartnerCategory;
    data['is_sellable'] = isSellable;
    data['units'] = units;
    data['invested_amount'] = investedAmount;
    data['market_value'] = marketValue;
    data['profit_loss_amount'] = profitLossAmount;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
