import 'dart:convert';

class BibitPortpolioDetail {
  String? message;
  BibitPortpolioDetailData? data;

  BibitPortpolioDetail({this.message, this.data});

  BibitPortpolioDetail.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = (json['data'] != null) ? BibitPortpolioDetailData.fromJson(json['data']) : null;
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

class BibitPortpolioDetailData {
  num? marketvalue;
  num? mutualFundMarketValue;
  num? sbnMarketValue;
  num? invested;
  num? profitloss;
  num? totalpending;
  num? totalporto;
  num? percentage;
  BibitPortpolioDetailDataRecurring? recurring;
  num? isContainSbn;
  List<BibitPortpolioDetailDataResults>? results;
  String? categoryname;
  num? templateid;
  num? robo;
  String? roboid;
  num? isGoal;
  num? isDefault;
  num? isPartnerCategory;
  BibitPortpolioDetailDataGoalsetting? goalsetting;
  num? isShared;
  BibitPortpolioDetailDataType? type;

  BibitPortpolioDetailData({
    this.marketvalue,
    this.mutualFundMarketValue,
    this.sbnMarketValue,
    this.invested,
    this.profitloss,
    this.totalpending,
    this.totalporto,
    this.percentage,
    this.recurring,
    this.isContainSbn,
    this.results,
    this.categoryname,
    this.templateid,
    this.robo,
    this.roboid,
    this.isGoal,
    this.isDefault,
    this.isPartnerCategory,
    this.goalsetting,
    this.isShared,
    this.type,
  });

  BibitPortpolioDetailData.fromJson(Map<String, dynamic> json) {
    marketvalue = json['marketvalue'] ?? 0.0;
    mutualFundMarketValue = json['mutual_fund_market_value'] ?? 0.0;
    sbnMarketValue = json['sbn_market_value'] ?? 0;
    invested = json['invested'] ?? 0;
    profitloss = json['profitloss'] ?? 0;
    totalpending = json['totalpending'] ?? 0;
    totalporto = json['totalporto'] ?? 0.0;
    percentage = json['percentage'] ?? 0.0;
    recurring = (json['recurring'] != null) ? BibitPortpolioDetailDataRecurring.fromJson(json['recurring']) : null;
    isContainSbn = json['is_contain_sbn'] ?? 0;
    results = json['results'] == null ? null : (json['results'] as List).map((e) => BibitPortpolioDetailDataResults.fromJson(e)).toList();
    categoryname = json['categoryname'] ?? '';
    templateid = json['templateid'] ?? 0;
    robo = json['robo'] ?? 0;
    roboid = json['roboid'] ?? '';
    isGoal = json['is_goal'] ?? 0;
    isDefault = json['is_default'] ?? 0;
    isPartnerCategory = json['is_partner_category'] ?? 0;
    goalsetting = (json['goalsetting'] != null) ? BibitPortpolioDetailDataGoalsetting.fromJson(json['goalsetting']) : null;
    isShared = json['is_shared'] ?? 0;
    type = (json['type'] != null) ? BibitPortpolioDetailDataType.fromJson(json['type']) : null;
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
    data['percentage'] = percentage;
    if (recurring != null) {
      data['recurring'] = recurring!.toJson();
    }
    data['is_contain_sbn'] = isContainSbn;
    if (results != null) {
      data['results'] = results?.map((e) => e.toJson()).toList();
    }
    data['categoryname'] = categoryname;
    data['templateid'] = templateid;
    data['robo'] = robo;
    data['roboid'] = roboid;
    data['is_goal'] = isGoal;
    data['is_default'] = isDefault;
    data['is_partner_category'] = isPartnerCategory;
    if (goalsetting != null) {
      data['goalsetting'] = goalsetting!.toJson();
    }
    data['is_shared'] = isShared;
    if (type != null) {
      data['type'] = type!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitPortpolioDetailDataRecurring {
  num? totalActiveRecurrings;
  num? totalInactiveRecurrings;
  num? status;

  BibitPortpolioDetailDataRecurring({this.totalActiveRecurrings, this.totalInactiveRecurrings, this.status});

  BibitPortpolioDetailDataRecurring.fromJson(Map<String, dynamic> json) {
    totalActiveRecurrings = json['total_active_recurrings'] ?? 0;
    totalInactiveRecurrings = json['total_inactive_recurrings'] ?? 0;
    status = json['status'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['total_active_recurrings'] = totalActiveRecurrings;
    data['total_inactive_recurrings'] = totalInactiveRecurrings;
    data['status'] = status;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitPortpolioDetailDataResults {
  String? name;
  String? robocategory;
  List<BibitPortpolioDetailDataResultsItems>? items;
  num? marketvalue;
  num? totalpending;
  num? totalporto;
  String? target;
  String? current;

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
  List<BibitPortpolioDetailDataResultsNotations>? notations;
  BibitPortpolioDetailDataResultsCorpAction? corpAction;

  BibitPortpolioDetailDataResults({
    this.name,
    this.robocategory,
    this.items,
    this.marketvalue,
    this.totalpending,
    this.totalporto,
    this.target,
    this.current,
    this.symbol,
    this.isSharia,
    this.companyName,
    this.iconUrl,
    this.marketValue,
    this.investedAmount,
    this.profitLossAmount,
    this.profitLossPercentage,
    this.averagePrice,
    this.availableLot,
    this.balanceLot,
    this.status,
    this.notations,
    this.corpAction,
  });

  BibitPortpolioDetailDataResults.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    robocategory = json['robocategory'] ?? '';
    items = json['items'] == null ? null : (json['items'] as List).map((e) => BibitPortpolioDetailDataResultsItems.fromJson(e)).toList();
    marketvalue = json['marketvalue'] ?? 0.0;
    totalpending = json['totalpending'] ?? 0;
    totalporto = json['totalporto'] ?? 0.0;
    target = json['target'] ?? '';
    current = json['current'] ?? '';

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
    notations = json['notations'] == null ? null : (json['notations'] as List).map((e) => BibitPortpolioDetailDataResultsNotations.fromJson(e)).toList();
    corpAction = (json['corp_action'] != null) ? BibitPortpolioDetailDataResultsCorpAction.fromJson(json['corp_action']) : null;
  
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['robocategory'] = robocategory;
    if (items != null) {
      data['items'] = items?.map((e) => e.toJson()).toList();
    }
    data['marketvalue'] = marketvalue;
    data['totalpending'] = totalpending;
    data['totalporto'] = totalporto;
    data['target'] = target;
    data['current'] = current;

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

    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}


class BibitPortpolioDetailDataResultsNotations {
  String? notationCode;
  String? notationDesc;
  BibitPortpolioDetailDataResultsNotationsIconUrl? iconUrl;

  BibitPortpolioDetailDataResultsNotations({this.notationCode, this.notationDesc, this.iconUrl});

  BibitPortpolioDetailDataResultsNotations.fromJson(Map<String, dynamic> json) {
    notationCode = json['notation_code'] ?? '';
    notationDesc = json['notation_desc'] ?? '';
    iconUrl = (json['icon_url'] != null) ? BibitPortpolioDetailDataResultsNotationsIconUrl.fromJson(json['icon_url']) : null;
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

class BibitPortpolioDetailDataResultsNotationsIconUrl {
  String? lightMode;
  String? darkMode;

  BibitPortpolioDetailDataResultsNotationsIconUrl({this.lightMode, this.darkMode});

  BibitPortpolioDetailDataResultsNotationsIconUrl.fromJson(Map<String, dynamic> json) {
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

class BibitPortpolioDetailDataResultsCorpAction {
  bool? active;
  String? icon;
  String? text;

  BibitPortpolioDetailDataResultsCorpAction({this.active, this.icon, this.text});

  BibitPortpolioDetailDataResultsCorpAction.fromJson(Map<String, dynamic> json) {
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


class BibitPortpolioDetailDataResultsItems {
  num? units;
  num? invested;
  String? updated;
  num? robo;
  String? roboid;
  String? categoryname;
  num? templateid;
  num? isGoal;
  BibitPortpolioDetailDataResultsItemsRecurring? recurring;
  num? estimateBuyprice;
  BibitPortpolioDetailDataResultsItemsCurrencyExchange? currencyExchange;
  BibitPortpolioDetailDataResultsItemsExitload? exitload;
  num? pending;
  num? current;
  num? avgprice;
  num? lastprice;
  num? marketvalue;
  num? profitloss;
  num? percentage;
  bool? isPartnerCategory;
  num? totalmarketvalue;
  BibitPortpolioDetailDataResultsItemsProduct? product;
  bool? isAutodebetPromo;

  BibitPortpolioDetailDataResultsItems({
    this.units,
    this.invested,
    this.updated,
    this.robo,
    this.roboid,
    this.categoryname,
    this.templateid,
    this.isGoal,
    this.recurring,
    this.estimateBuyprice,
    this.currencyExchange,
    this.exitload,
    this.pending,
    this.current,
    this.avgprice,
    this.lastprice,
    this.marketvalue,
    this.profitloss,
    this.percentage,
    this.isPartnerCategory,
    this.totalmarketvalue,
    this.product,
    this.isAutodebetPromo,
  });

  BibitPortpolioDetailDataResultsItems.fromJson(Map<String, dynamic> json) {
    units = json['units'] ?? 0.0;
    invested = json['invested'] ?? 0;
    updated = json['updated'] ?? '';
    robo = json['robo'] ?? 0;
    roboid = json['roboid'] ?? '';
    categoryname = json['categoryname'] ?? '';
    templateid = json['templateid'] ?? 0;
    isGoal = json['is_goal'] ?? 0;
    recurring = (json['recurring'] != null) ? BibitPortpolioDetailDataResultsItemsRecurring.fromJson(json['recurring']) : null;
    estimateBuyprice = json['estimate_buyprice'] ?? 0;
    currencyExchange = (json['currency_exchange'] != null) ? BibitPortpolioDetailDataResultsItemsCurrencyExchange.fromJson(json['currency_exchange']) : null;
    exitload = (json['exitload'] != null) ? BibitPortpolioDetailDataResultsItemsExitload.fromJson(json['exitload']) : null;
    pending = json['pending'] ?? 0;
    current = json['current'] ?? 0.0;
    avgprice = json['avgprice'] ?? 0.0;
    lastprice = json['lastprice'] ?? 0.0;
    marketvalue = json['marketvalue'] ?? 0.0;
    profitloss = json['profitloss'] ?? 0;
    percentage = json['percentage'] ?? 0.0;
    isPartnerCategory = json['is_partner_category'] ?? false;
    totalmarketvalue = json['totalmarketvalue'] ?? 0.0;
    product = (json['product'] != null) ? BibitPortpolioDetailDataResultsItemsProduct.fromJson(json['product']) : null;
    isAutodebetPromo = json['is_autodebet_promo'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['units'] = units;
    data['invested'] = invested;
    data['updated'] = updated;
    data['robo'] = robo;
    data['roboid'] = roboid;
    data['categoryname'] = categoryname;
    data['templateid'] = templateid;
    data['is_goal'] = isGoal;
    if (recurring != null) {
      data['recurring'] = recurring!.toJson();
    }
    data['estimate_buyprice'] = estimateBuyprice;
    if (currencyExchange != null) {
      data['currency_exchange'] = currencyExchange!.toJson();
    }
    if (exitload != null) {
      data['exitload'] = exitload!.toJson();
    }
    data['pending'] = pending;
    data['current'] = current;
    data['avgprice'] = avgprice;
    data['lastprice'] = lastprice;
    data['marketvalue'] = marketvalue;
    data['profitloss'] = profitloss;
    data['percentage'] = percentage;
    data['is_partner_category'] = isPartnerCategory;
    data['totalmarketvalue'] = totalmarketvalue;
    if (product != null) {
      data['product'] = product!.toJson();
    }
    data['is_autodebet_promo'] = isAutodebetPromo;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitPortpolioDetailDataResultsItemsRecurring {
  num? totalActiveRecurrings;
  num? totalInactiveRecurrings;
  num? status;

  BibitPortpolioDetailDataResultsItemsRecurring({this.totalActiveRecurrings, this.totalInactiveRecurrings, this.status});

  BibitPortpolioDetailDataResultsItemsRecurring.fromJson(Map<String, dynamic> json) {
    totalActiveRecurrings = json['total_active_recurrings'] ?? 0;
    totalInactiveRecurrings = json['total_inactive_recurrings'] ?? 0;
    status = json['status'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['total_active_recurrings'] = totalActiveRecurrings;
    data['total_inactive_recurrings'] = totalInactiveRecurrings;
    data['status'] = status;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitPortpolioDetailDataResultsItemsCurrencyExchange {
  num? current;
  num? invested;
  num? exchangeRate;
  String? currency;

  BibitPortpolioDetailDataResultsItemsCurrencyExchange({this.current, this.invested, this.exchangeRate, this.currency});

  BibitPortpolioDetailDataResultsItemsCurrencyExchange.fromJson(Map<String, dynamic> json) {
    current = json['current'] ?? 0;
    invested = json['invested'] ?? 0;
    exchangeRate = json['exchange_rate'] ?? 0;
    currency = json['currency'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['current'] = current;
    data['invested'] = invested;
    data['exchange_rate'] = exchangeRate;
    data['currency'] = currency;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitPortpolioDetailDataResultsItemsExitload {
  BibitPortpolioDetailDataResultsItemsExitload();

  BibitPortpolioDetailDataResultsItemsExitload.fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitPortpolioDetailDataResultsItemsProduct {
  num? productId;
  String? symbol;
  String? name;
  String? type;
  bool? sharia;
  bool? isSharia;
  bool? etf;
  bool? index;
  num? minAsset;
  num? minbuy;
  num? minsell;
  num? tradeable;
  num? notbuyable;
  BibitPortpolioDetailDataResultsItemsProductExpenseratio? expenseratio;
  String? robocategory;
  List<dynamic>? exitload;
  BibitPortpolioDetailDataResultsItemsProductInvestmentManager? investmentManager;
  BibitPortpolioDetailDataResultsItemsProductBankRedeem? bankRedeem;
  bool? isInstantRedemption;

  BibitPortpolioDetailDataResultsItemsProduct({
    this.productId,
    this.symbol,
    this.name,
    this.type,
    this.sharia,
    this.isSharia,
    this.etf,
    this.index,
    this.minAsset,
    this.minbuy,
    this.minsell,
    this.tradeable,
    this.notbuyable,
    this.expenseratio,
    this.robocategory,
    this.exitload,
    this.investmentManager,
    this.bankRedeem,
    this.isInstantRedemption,
  });

  BibitPortpolioDetailDataResultsItemsProduct.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'] ?? 0;
    symbol = json['symbol'] ?? '';
    name = json['name'] ?? '';
    type = json['type'] ?? '';
    sharia = json['sharia'] ?? false;
    isSharia = json['is_sharia'] ?? false;
    etf = json['etf'] ?? false;
    index = json['index'] ?? false;
    minAsset = json['min_asset'] ?? 0;
    minbuy = json['minbuy'] ?? 0;
    minsell = json['minsell'] ?? 0;
    tradeable = json['tradeable'] ?? 0;
    notbuyable = json['notbuyable'] ?? 0;
    expenseratio = (json['expenseratio'] != null) ? BibitPortpolioDetailDataResultsItemsProductExpenseratio.fromJson(json['expenseratio']) : null;
    robocategory = json['robocategory'] ?? '';
    exitload = json['exitload'] ?? [];
    investmentManager = (json['investment_manager'] != null) ? BibitPortpolioDetailDataResultsItemsProductInvestmentManager.fromJson(json['investment_manager']) : null;
    bankRedeem = (json['bank_redeem'] != null) ? BibitPortpolioDetailDataResultsItemsProductBankRedeem.fromJson(json['bank_redeem']) : null;
    isInstantRedemption = json['is_instant_redemption'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['product_id'] = productId;
    data['symbol'] = symbol;
    data['name'] = name;
    data['type'] = type;
    data['sharia'] = sharia;
    data['is_sharia'] = isSharia;
    data['etf'] = etf;
    data['index'] = index;
    data['min_asset'] = minAsset;
    data['minbuy'] = minbuy;
    data['minsell'] = minsell;
    data['tradeable'] = tradeable;
    data['notbuyable'] = notbuyable;
    if (expenseratio != null) {
      data['expenseratio'] = expenseratio!.toJson();
    }
    data['robocategory'] = robocategory;
    if (exitload != null) {
      data['exitload'] = exitload;
    }
    if (investmentManager != null) {
      data['investment_manager'] = investmentManager!.toJson();
    }
    if (bankRedeem != null) {
      data['bank_redeem'] = bankRedeem!.toJson();
    }
    data['is_instant_redemption'] = isInstantRedemption;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitPortpolioDetailDataResultsItemsProductExpenseratio {
  num? percentage;

  BibitPortpolioDetailDataResultsItemsProductExpenseratio({this.percentage});

  BibitPortpolioDetailDataResultsItemsProductExpenseratio.fromJson(Map<String, dynamic> json) {
    percentage = json['percentage'] ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['percentage'] = percentage;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitPortpolioDetailDataResultsItemsProductInvestmentManager {
  String? name;
  String? ojkCode;
  String? telepon;
  String? fax;
  String? email;
  String? url;

  BibitPortpolioDetailDataResultsItemsProductInvestmentManager({this.name, this.ojkCode, this.telepon, this.fax, this.email, this.url});

  BibitPortpolioDetailDataResultsItemsProductInvestmentManager.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    ojkCode = json['ojkCode'] ?? '';
    telepon = json['telepon'] ?? '';
    fax = json['fax'] ?? '';
    email = json['email'] ?? '';
    url = json['url'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['ojkCode'] = ojkCode;
    data['telepon'] = telepon;
    data['fax'] = fax;
    data['email'] = email;
    data['url'] = url;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitPortpolioDetailDataResultsItemsProductBankRedeem {
  num? id;
  String? name;
  String? color;
  String? iconUrl;

  BibitPortpolioDetailDataResultsItemsProductBankRedeem({this.id, this.name, this.color, this.iconUrl});

  BibitPortpolioDetailDataResultsItemsProductBankRedeem.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    name = json['name'] ?? '';
    color = json['color'] ?? '';
    iconUrl = json['icon_url'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['color'] = color;
    data['icon_url'] = iconUrl;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitPortpolioDetailDataGoalsetting {
  num? id;
  String? targetdate;
  num? targetamount;
  num? recurringAmount;
  num? ontrack;

  BibitPortpolioDetailDataGoalsetting({this.id, this.targetdate, this.targetamount, this.recurringAmount, this.ontrack});

  BibitPortpolioDetailDataGoalsetting.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    targetdate = json['targetdate'] ?? '';
    targetamount = json['targetamount'] ?? 0;
    recurringAmount = json['recurring_amount'] ?? 0;
    ontrack = json['ontrack'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['targetdate'] = targetdate;
    data['targetamount'] = targetamount;
    data['recurring_amount'] = recurringAmount;
    data['ontrack'] = ontrack;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitPortpolioDetailDataType {
  num? id;
  String? name;
  num? isAllowDelete;
  num? isAllowMultiple;
  num? isAllowShare;
  num? isAllowChangeIcon;
  num? isAllowChangeName;
  num? isDefault;
  num? roboType;
  List<BibitPortpolioDetailDataTypeRules>? rules;

  BibitPortpolioDetailDataType(
      {this.id, this.name, this.isAllowDelete, this.isAllowMultiple, this.isAllowShare, this.isAllowChangeIcon, this.isAllowChangeName, this.isDefault, this.roboType, this.rules});

  BibitPortpolioDetailDataType.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    name = json['name'] ?? '';
    isAllowDelete = json['is_allow_delete'] ?? 0;
    isAllowMultiple = json['is_allow_multiple'] ?? 0;
    isAllowShare = json['is_allow_share'] ?? 0;
    isAllowChangeIcon = json['is_allow_change_icon'] ?? 0;
    isAllowChangeName = json['is_allow_change_name'] ?? 0;
    isDefault = json['is_default'] ?? 0;
    roboType = json['robo_type'] ?? 0;
    rules = json['rules'] == null ? null : (json['rules'] as List).map((e) => BibitPortpolioDetailDataTypeRules.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['is_allow_delete'] = isAllowDelete;
    data['is_allow_multiple'] = isAllowMultiple;
    data['is_allow_share'] = isAllowShare;
    data['is_allow_change_icon'] = isAllowChangeIcon;
    data['is_allow_change_name'] = isAllowChangeName;
    data['is_default'] = isDefault;
    data['robo_type'] = roboType;
    if (rules != null) {
      data['rules'] = rules?.map((e) => e.toJson()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitPortpolioDetailDataTypeRules {
  num? roboType;
  List<num>? instrumentGroups;
  List<num>? productTypes;

  BibitPortpolioDetailDataTypeRules({this.roboType, this.instrumentGroups, this.productTypes});

  BibitPortpolioDetailDataTypeRules.fromJson(Map<String, dynamic> json) {
    roboType = json['robo_type'] ?? 0;
    instrumentGroups = json['instrument_groups'] == null ? null : List<num>.from(json['instrument_groups']);
    productTypes = json['product_types'] == null ? null : List<num>.from(json['product_types']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['robo_type'] = roboType;
    if (instrumentGroups != null) {
      data['instrument_groups'] = instrumentGroups;
    }
    if (productTypes != null) {
      data['product_types'] = productTypes;
    }
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
