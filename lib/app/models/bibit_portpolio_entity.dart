class BibitPortpolio {
  String? message;
  BibitPortpolioData? data;

  BibitPortpolio({this.message, this.data});

  BibitPortpolio.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? BibitPortpolioData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
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
  List<BibitPortpolioResult>? result;
  BibitPortpolioLimit? limit;

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
    marketvalue = json['marketvalue'];
    mutualFundMarketValue = json['mutual_fund_market_value'];
    sbnMarketValue = json['sbn_market_value'];
    invested = json['invested'];
    profitloss = json['profitloss'];
    totalpending = json['totalpending'];
    totalporto = json['totalporto'];
    tradingBalance = json['trading_balance'];
    percentage = json['percentage'];
    if (json['result'] != null) {
      result = <BibitPortpolioResult>[];
      json['result'].forEach((v) {
        result!.add(BibitPortpolioResult.fromJson(v));
      });
    }
    limit = json['limit'] != null ? BibitPortpolioLimit.fromJson(json['limit']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
      data['result'] = result!.map((v) => v.toJson()).toList();
    }
    if (limit != null) {
      data['limit'] = limit!.toJson();
    }
    return data;
  }
}

class BibitPortpolioResult {
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
  BibitPortpolioType? type;
  num? items;
  BibitPortpolioGoalsetting? goalsetting;
  num? tradingBalance;

  BibitPortpolioResult(
      {this.id,
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
      this.goalsetting,
      this.tradingBalance});

  BibitPortpolioResult.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    robo = json['robo'];
    roboid = json['roboid'];
    isGoal = json['is_goal'];
    isDefault = json['is_default'];
    templateid = json['templateid'];
    isShared = json['is_shared'];
    pending = json['pending'];
    totalporto = json['totalporto'];
    isPartnerCategory = json['is_partner_category'];
    created = json['created'];
    marketvalue = json['marketvalue'];
    mutualFundMarketValue = json['mutual_fund_market_value'];
    sbnMarketValue = json['sbn_market_value'];
    invested = json['invested'];
    profitloss = json['profitloss'];
    percentage = json['percentage'];
    type = json['type'] != null ? BibitPortpolioType.fromJson(json['type']) : null;
    items = json['items'];
    goalsetting = json['goalsetting'] != null ? BibitPortpolioGoalsetting.fromJson(json['goalsetting']) : null;
    tradingBalance = json['trading_balance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
    if (goalsetting != null) {
      data['goalsetting'] = goalsetting!.toJson();
    }
    data['trading_balance'] = tradingBalance;
    return data;
  }
}

class BibitPortpolioType {
  num? id;
  String? name;

  BibitPortpolioType({this.id, this.name});

  BibitPortpolioType.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class BibitPortpolioGoalsetting {
  num? id;
  String? targetdate;
  num? targetamount;
  num? recurringAmount;
  num? ontrack;

  BibitPortpolioGoalsetting({this.id, this.targetdate, this.targetamount, this.recurringAmount, this.ontrack});

  BibitPortpolioGoalsetting.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    targetdate = json['targetdate'];
    targetamount = json['targetamount'];
    recurringAmount = json['recurring_amount'];
    ontrack = json['ontrack'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['targetdate'] = targetdate;
    data['targetamount'] = targetamount;
    data['recurring_amount'] = recurringAmount;
    data['ontrack'] = ontrack;
    return data;
  }
}

class BibitPortpolioLimit {
  num? max;
  num? left;

  BibitPortpolioLimit({this.max, this.left});

  BibitPortpolioLimit.fromJson(Map<String, dynamic> json) {
    max = json['max'];
    left = json['left'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['max'] = max;
    data['left'] = left;
    return data;
  }
}
