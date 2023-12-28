import 'dart:convert';

/// *
/// * JSON Source: {"message":"Successfully retrieve data product detail","query":"RD337","data":{"id":337,"symbol":"RD337","name":"BNI-AM Indeks IDX30","type":"Saham","profile":"","tradeable":1,"notbuyable":0,"status":1,"dividend_date":null,"robocategory":"equity","bank_redeem":{"id":12,"name":"STANDARD CHARTERED","color":"#0072AA","icon_url":"https://assets.bibit.id/icons/banks/Standard_Chartered_05042023140038.svg"},"released_date":"2017-12-28","currency_exchange":{"exchange_rate":1,"currency":"IDR"},"is_has_dividend":true,"min_asset":10000,"minbuy":10000,"minsell":10000,"executive":{},"fee":{"subscription":{"value":0,"max_value":null,"type":"percent","currency":"IDR"},"redemption":{"value":0,"max_value":null,"type":"percent","currency":"IDR"},"transfer":{"value":0,"max_value":null,"type":"percent","currency":"IDR"},"switch":{"value":2,"max_value":null,"type":"percent","currency":"IDR"}},"asset":[{"name":"Kas & Deposito","percentage":1}],"holding":[{"symbol":"BBRI","name":"Bank Rakyat Indonesia (Persero) Tbk.","annualDividend":0,"date":"2023-11-30","clickable":1,"company_id":4327,"product_type":"Saham","serie_id":null}],"bank":[{"bank":"BCA","id":31,"account":"4585637549","name":"Reksa Dana Indeks BNI-AM Indeks IDX30"}],"exitload":[null],"investment_manager":{"name":"PT BNI Asset Management","ojkCode":"NI002","telepon":"+62 21 29969646","fax":"+62 21 29969647","email":"corsec@bni-am.co.id","url":"www.bni-am.co.id"},"custodian_bank":{"name":"STANDARD CHARTERED","ojkCode":"SCBJK"},"sharia":false,"etf":false,"index":true,"is_instant_redemption":false,"aum":{"value":1603614579115.38,"date":"2023-11-01"},"shareholders":[null],"expenseratio":{"percentage":0.0157},"avg_yield":{"date":null,"percentage":null},"cagr":{"1y":0.005404054230993438,"3y":-0.005873610077785196,"5y":-0.019943521523584695,"10y":null,"all":-0.029170123391069724},"cagr_adjusted":{"1y":0.03951704878212503,"3y":0.012269335320671981,"5y":-0.007415154183184058,"10y":null,"all":-0.018847593382272487},"simplereturn":{"1d":0.0009480357883508983,"1m":0.02833037083931922,"3m":-0.0066447136304833565,"ytd":0.042047403978606734,"1y":0.03951704878212503,"3y":0.03726146271354058,"5y":-0.03652998789256123,"10y":null,"all":-0.10784260330255346},"changesvalue":{"1d":0.7999999999999545,"1m":23.269999999999982,"3m":-5.649999999999977,"ytd":35.238667852351,"1y":33.198667852351036,"3y":32.034052109458,"5y":-34.12485348971495,"10y":null,"all":-108.79485348971502},"nav":{"date":"2023-12-27","value":844.65},"riskprofile":"High","maxdrawdown":{"1y":-0.13031492124189914,"3y":-0.2228623649078194,"5y":-0.4505307898804197,"10y":-0.48795625971269374,"all":-0.48795625971269374},"maxdrawdown_adjusted":{"1y":-0.1008068222561956,"3y":-0.1957748129721058,"5y":-0.445422035770232,"10y":-0.4831954732762356,"all":-0.4831954732762356}}}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// *
class BibitProductDetail {
  String? message;
  String? query;
  BibitProductDetailData? data;

  BibitProductDetail({this.message, this.query, this.data});

  BibitProductDetail.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    query = json['query'] ?? '';
    data = (json['data'] != null) ? BibitProductDetailData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    data['query'] = query;
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

class BibitProductDetailData {
  num? id;
  String? symbol;
  String? name;
  String? type;
  String? profile;
  num? tradeable;
  num? notbuyable;
  num? status;
  dynamic dividendDate;
  String? robocategory;
  BibitProductDetailDataBankRedeem? bankRedeem;
  String? releasedDate;
  BibitProductDetailDataCurrencyExchange? currencyExchange;
  bool? isHasDividend;
  num? minAsset;
  num? minbuy;
  num? minsell;
  BibitProductDetailDataExecutive? executive;
  BibitProductDetailDataFee? fee;
  List<BibitProductDetailDataAsset>? asset;
  List<BibitProductDetailDataHolding>? holding;
  List<BibitProductDetailDataBank>? bank;
  List<dynamic>? exitload;
  BibitProductDetailDataInvestmentManager? investmentManager;
  BibitProductDetailDataCustodianBank? custodianBank;
  bool? sharia;
  bool? etf;
  bool? index;
  bool? isInstantRedemption;
  BibitProductDetailDataAum? aum;
  List<dynamic>? shareholders;
  BibitProductDetailDataExpenseratio? expenseratio;
  BibitProductDetailDataAvgYield? avgYield;
  BibitProductDetailDataCagr? cagr;
  BibitProductDetailDataCagrAdjusted? cagrAdjusted;
  BibitProductDetailDataSimplereturn? simplereturn;
  BibitProductDetailDataChangesvalue? changesvalue;
  BibitProductDetailDataNav? nav;
  String? riskprofile;
  BibitProductDetailDataMaxdrawdown? maxdrawdown;
  BibitProductDetailDataMaxdrawdownAdjusted? maxdrawdownAdjusted;

  BibitProductDetailData({
    this.id,
    this.symbol,
    this.name,
    this.type,
    this.profile,
    this.tradeable,
    this.notbuyable,
    this.status,
    this.dividendDate,
    this.robocategory,
    this.bankRedeem,
    this.releasedDate,
    this.currencyExchange,
    this.isHasDividend,
    this.minAsset,
    this.minbuy,
    this.minsell,
    this.executive,
    this.fee,
    this.asset,
    this.holding,
    this.bank,
    this.exitload,
    this.investmentManager,
    this.custodianBank,
    this.sharia,
    this.etf,
    this.index,
    this.isInstantRedemption,
    this.aum,
    this.shareholders,
    this.expenseratio,
    this.avgYield,
    this.cagr,
    this.cagrAdjusted,
    this.simplereturn,
    this.changesvalue,
    this.nav,
    this.riskprofile,
    this.maxdrawdown,
    this.maxdrawdownAdjusted,
  });

  BibitProductDetailData.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    symbol = json['symbol'] ?? '';
    name = json['name'] ?? '';
    type = json['type'] ?? '';
    profile = json['profile'] ?? '';
    tradeable = json['tradeable'] ?? 0;
    notbuyable = json['notbuyable'] ?? 0;
    status = json['status'] ?? 0;
    dividendDate = json['dividend_date'] ?? '';
    robocategory = json['robocategory'] ?? '';
    bankRedeem = (json['bank_redeem'] != null) ? BibitProductDetailDataBankRedeem.fromJson(json['bank_redeem']) : null;
    releasedDate = json['released_date'] ?? '';
    currencyExchange = (json['currency_exchange'] != null) ? BibitProductDetailDataCurrencyExchange.fromJson(json['currency_exchange']) : null;
    isHasDividend = json['is_has_dividend'] ?? false;
    minAsset = json['min_asset'] ?? 0;
    minbuy = json['minbuy'] ?? 0;
    minsell = json['minsell'] ?? 0;
    executive = (json['executive'] != null) ? BibitProductDetailDataExecutive.fromJson(json['executive']) : null;
    fee = (json['fee'] != null) ? BibitProductDetailDataFee.fromJson(json['fee']) : null;
    asset = json['asset'] == null ? null : (json['asset'] as List).map((e) => BibitProductDetailDataAsset.fromJson(e)).toList();
    holding = json['holding'] == null ? null : (json['holding'] as List).map((e) => BibitProductDetailDataHolding.fromJson(e)).toList();
    bank = json['bank'] == null ? null : (json['bank'] as List).map((e) => BibitProductDetailDataBank.fromJson(e)).toList();
    exitload = json['exitload'] ?? [];
    investmentManager = (json['investment_manager'] != null) ? BibitProductDetailDataInvestmentManager.fromJson(json['investment_manager']) : null;
    custodianBank = (json['custodian_bank'] != null) ? BibitProductDetailDataCustodianBank.fromJson(json['custodian_bank']) : null;
    sharia = json['sharia'] ?? false;
    etf = json['etf'] ?? false;
    index = json['index'] ?? false;
    isInstantRedemption = json['is_instant_redemption'] ?? false;
    aum = (json['aum'] != null) ? BibitProductDetailDataAum.fromJson(json['aum']) : null;
    shareholders = json['shareholders'] ?? [];
    expenseratio = (json['expenseratio'] != null) ? BibitProductDetailDataExpenseratio.fromJson(json['expenseratio']) : null;
    avgYield = (json['avg_yield'] != null) ? BibitProductDetailDataAvgYield.fromJson(json['avg_yield']) : null;
    cagr = (json['cagr'] != null) ? BibitProductDetailDataCagr.fromJson(json['cagr']) : null;
    cagrAdjusted = (json['cagr_adjusted'] != null) ? BibitProductDetailDataCagrAdjusted.fromJson(json['cagr_adjusted']) : null;
    simplereturn = (json['simplereturn'] != null) ? BibitProductDetailDataSimplereturn.fromJson(json['simplereturn']) : null;
    changesvalue = (json['changesvalue'] != null) ? BibitProductDetailDataChangesvalue.fromJson(json['changesvalue']) : null;
    nav = (json['nav'] != null) ? BibitProductDetailDataNav.fromJson(json['nav']) : null;
    riskprofile = json['riskprofile'] ?? '';
    maxdrawdown = (json['maxdrawdown'] != null) ? BibitProductDetailDataMaxdrawdown.fromJson(json['maxdrawdown']) : null;
    maxdrawdownAdjusted = (json['maxdrawdown_adjusted'] != null) ? BibitProductDetailDataMaxdrawdownAdjusted.fromJson(json['maxdrawdown_adjusted']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['symbol'] = symbol;
    data['name'] = name;
    data['type'] = type;
    data['profile'] = profile;
    data['tradeable'] = tradeable;
    data['notbuyable'] = notbuyable;
    data['status'] = status;
    data['dividend_date'] = dividendDate;
    data['robocategory'] = robocategory;
    if (bankRedeem != null) {
      data['bank_redeem'] = bankRedeem!.toJson();
    }
    data['released_date'] = releasedDate;
    if (currencyExchange != null) {
      data['currency_exchange'] = currencyExchange!.toJson();
    }
    data['is_has_dividend'] = isHasDividend;
    data['min_asset'] = minAsset;
    data['minbuy'] = minbuy;
    data['minsell'] = minsell;
    if (executive != null) {
      data['executive'] = executive!.toJson();
    }
    if (fee != null) {
      data['fee'] = fee!.toJson();
    }
    if (asset != null) {
      data['asset'] = asset?.map((e) => e.toJson()).toList();
    }
    if (holding != null) {
      data['holding'] = holding?.map((e) => e.toJson()).toList();
    }
    if (bank != null) {
      data['bank'] = bank?.map((e) => e.toJson()).toList();
    }
    if (exitload != null) {
      data['exitload'] = exitload;
    }
    if (investmentManager != null) {
      data['investment_manager'] = investmentManager!.toJson();
    }
    if (custodianBank != null) {
      data['custodian_bank'] = custodianBank!.toJson();
    }
    data['sharia'] = sharia;
    data['etf'] = etf;
    data['index'] = index;
    data['is_instant_redemption'] = isInstantRedemption;
    if (aum != null) {
      data['aum'] = aum!.toJson();
    }
    if (shareholders != null) {
      data['shareholders'] = shareholders;
    }
    if (expenseratio != null) {
      data['expenseratio'] = expenseratio!.toJson();
    }
    if (avgYield != null) {
      data['avg_yield'] = avgYield!.toJson();
    }
    if (cagr != null) {
      data['cagr'] = cagr!.toJson();
    }
    if (cagrAdjusted != null) {
      data['cagr_adjusted'] = cagrAdjusted!.toJson();
    }
    if (simplereturn != null) {
      data['simplereturn'] = simplereturn!.toJson();
    }
    if (changesvalue != null) {
      data['changesvalue'] = changesvalue!.toJson();
    }
    if (nav != null) {
      data['nav'] = nav!.toJson();
    }
    data['riskprofile'] = riskprofile;
    if (maxdrawdown != null) {
      data['maxdrawdown'] = maxdrawdown!.toJson();
    }
    if (maxdrawdownAdjusted != null) {
      data['maxdrawdown_adjusted'] = maxdrawdownAdjusted!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitProductDetailDataBankRedeem {
  num? id;
  String? name;
  String? color;
  String? iconUrl;

  BibitProductDetailDataBankRedeem({this.id, this.name, this.color, this.iconUrl});

  BibitProductDetailDataBankRedeem.fromJson(Map<String, dynamic> json) {
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

class BibitProductDetailDataCurrencyExchange {
  num? exchangeRate;
  String? currency;

  BibitProductDetailDataCurrencyExchange({this.exchangeRate, this.currency});

  BibitProductDetailDataCurrencyExchange.fromJson(Map<String, dynamic> json) {
    exchangeRate = json['exchange_rate'] ?? 0;
    currency = json['currency'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['exchange_rate'] = exchangeRate;
    data['currency'] = currency;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitProductDetailDataExecutive {
  BibitProductDetailDataExecutive();

  BibitProductDetailDataExecutive.fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitProductDetailDataFee {
  BibitProductDetailDataFeeSubscription? subscription;
  BibitProductDetailDataFeeRedemption? redemption;
  BibitProductDetailDataFeeTransfer? transfer;
  BibitProductDetailDataFeeSwitch? xSwitch;

  BibitProductDetailDataFee({this.subscription, this.redemption, this.transfer, this.xSwitch});

  BibitProductDetailDataFee.fromJson(Map<String, dynamic> json) {
    subscription = (json['subscription'] != null) ? BibitProductDetailDataFeeSubscription.fromJson(json['subscription']) : null;
    redemption = (json['redemption'] != null) ? BibitProductDetailDataFeeRedemption.fromJson(json['redemption']) : null;
    transfer = (json['transfer'] != null) ? BibitProductDetailDataFeeTransfer.fromJson(json['transfer']) : null;
    xSwitch = (json['switch'] != null) ? BibitProductDetailDataFeeSwitch.fromJson(json['switch']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (subscription != null) {
      data['subscription'] = subscription!.toJson();
    }
    if (redemption != null) {
      data['redemption'] = redemption!.toJson();
    }
    if (transfer != null) {
      data['transfer'] = transfer!.toJson();
    }
    if (xSwitch != null) {
      data['switch'] = xSwitch!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitProductDetailDataFeeSubscription {
  num? value;
  dynamic maxValue;
  String? type;
  String? currency;

  BibitProductDetailDataFeeSubscription({this.value, this.maxValue, this.type, this.currency});

  BibitProductDetailDataFeeSubscription.fromJson(Map<String, dynamic> json) {
    value = json['value'] ?? 0;
    maxValue = json['max_value'] ?? '';
    type = json['type'] ?? '';
    currency = json['currency'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['value'] = value;
    data['max_value'] = maxValue;
    data['type'] = type;
    data['currency'] = currency;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitProductDetailDataFeeRedemption {
  num? value;
  dynamic maxValue;
  String? type;
  String? currency;

  BibitProductDetailDataFeeRedemption({this.value, this.maxValue, this.type, this.currency});

  BibitProductDetailDataFeeRedemption.fromJson(Map<String, dynamic> json) {
    value = json['value'] ?? 0;
    maxValue = json['max_value'] ?? '';
    type = json['type'] ?? '';
    currency = json['currency'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['value'] = value;
    data['max_value'] = maxValue;
    data['type'] = type;
    data['currency'] = currency;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitProductDetailDataFeeTransfer {
  num? value;
  dynamic maxValue;
  String? type;
  String? currency;

  BibitProductDetailDataFeeTransfer({this.value, this.maxValue, this.type, this.currency});

  BibitProductDetailDataFeeTransfer.fromJson(Map<String, dynamic> json) {
    value = json['value'] ?? 0;
    maxValue = json['max_value'] ?? '';
    type = json['type'] ?? '';
    currency = json['currency'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['value'] = value;
    data['max_value'] = maxValue;
    data['type'] = type;
    data['currency'] = currency;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitProductDetailDataFeeSwitch {
  num? value;
  dynamic maxValue;
  String? type;
  String? currency;

  BibitProductDetailDataFeeSwitch({this.value, this.maxValue, this.type, this.currency});

  BibitProductDetailDataFeeSwitch.fromJson(Map<String, dynamic> json) {
    value = json['value'] ?? 0;
    maxValue = json['max_value'] ?? '';
    type = json['type'] ?? '';
    currency = json['currency'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['value'] = value;
    data['max_value'] = maxValue;
    data['type'] = type;
    data['currency'] = currency;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitProductDetailDataAsset {
  String? name;
  num? percentage;

  BibitProductDetailDataAsset({this.name, this.percentage});

  BibitProductDetailDataAsset.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    percentage = json['percentage'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['percentage'] = percentage;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitProductDetailDataHolding {
  String? symbol;
  String? name;
  num? annualDividend;
  String? date;
  num? clickable;
  num? companyId;
  String? productType;
  dynamic serieId;

  BibitProductDetailDataHolding({this.symbol, this.name, this.annualDividend, this.date, this.clickable, this.companyId, this.productType, this.serieId});

  BibitProductDetailDataHolding.fromJson(Map<String, dynamic> json) {
    symbol = json['symbol'] ?? '';
    name = json['name'] ?? '';
    annualDividend = json['annualDividend'] ?? 0;
    date = json['date'] ?? '';
    clickable = json['clickable'] ?? 0;
    companyId = json['company_id'] ?? 0;
    productType = json['product_type'] ?? '';
    serieId = json['serie_id'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['symbol'] = symbol;
    data['name'] = name;
    data['annualDividend'] = annualDividend;
    data['date'] = date;
    data['clickable'] = clickable;
    data['company_id'] = companyId;
    data['product_type'] = productType;
    data['serie_id'] = serieId;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitProductDetailDataBank {
  String? bank;
  num? id;
  String? account;
  String? name;

  BibitProductDetailDataBank({this.bank, this.id, this.account, this.name});

  BibitProductDetailDataBank.fromJson(Map<String, dynamic> json) {
    bank = json['bank'] ?? '';
    id = json['id'] ?? 0;
    account = json['account'] ?? '';
    name = json['name'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['bank'] = bank;
    data['id'] = id;
    data['account'] = account;
    data['name'] = name;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitProductDetailDataInvestmentManager {
  String? name;
  String? ojkCode;
  String? telepon;
  String? fax;
  String? email;
  String? url;

  BibitProductDetailDataInvestmentManager({this.name, this.ojkCode, this.telepon, this.fax, this.email, this.url});

  BibitProductDetailDataInvestmentManager.fromJson(Map<String, dynamic> json) {
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

class BibitProductDetailDataCustodianBank {
  String? name;
  String? ojkCode;

  BibitProductDetailDataCustodianBank({this.name, this.ojkCode});

  BibitProductDetailDataCustodianBank.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    ojkCode = json['ojkCode'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['ojkCode'] = ojkCode;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitProductDetailDataAum {
  num? value;
  String? date;

  BibitProductDetailDataAum({this.value, this.date});

  BibitProductDetailDataAum.fromJson(Map<String, dynamic> json) {
    value = json['value'] ?? 0.0;
    date = json['date'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['value'] = value;
    data['date'] = date;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitProductDetailDataExpenseratio {
  num? percentage;

  BibitProductDetailDataExpenseratio({this.percentage});

  BibitProductDetailDataExpenseratio.fromJson(Map<String, dynamic> json) {
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

class BibitProductDetailDataAvgYield {
  dynamic date;
  dynamic percentage;

  BibitProductDetailDataAvgYield({this.date, this.percentage});

  BibitProductDetailDataAvgYield.fromJson(Map<String, dynamic> json) {
    date = json['date'] ?? '';
    percentage = json['percentage'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['percentage'] = percentage;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitProductDetailDataCagr {
  num? x1y;
  num? x3y;
  num? x5y;
  dynamic x10y;
  num? all;

  BibitProductDetailDataCagr({this.x1y, this.x3y, this.x5y, this.x10y, this.all});

  BibitProductDetailDataCagr.fromJson(Map<String, dynamic> json) {
    x1y = json['1y'] ?? 0.0;
    x3y = json['3y'] ?? 0.0;
    x5y = json['5y'] ?? 0.0;
    x10y = json['10y'] ?? '';
    all = json['all'] ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['1y'] = x1y;
    data['3y'] = x3y;
    data['5y'] = x5y;
    data['10y'] = x10y;
    data['all'] = all;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitProductDetailDataCagrAdjusted {
  num? x1y;
  num? x3y;
  num? x5y;
  dynamic x10y;
  num? all;

  BibitProductDetailDataCagrAdjusted({this.x1y, this.x3y, this.x5y, this.x10y, this.all});

  BibitProductDetailDataCagrAdjusted.fromJson(Map<String, dynamic> json) {
    x1y = json['1y'] ?? 0.0;
    x3y = json['3y'] ?? 0.0;
    x5y = json['5y'] ?? 0.0;
    x10y = json['10y'] ?? '';
    all = json['all'] ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['1y'] = x1y;
    data['3y'] = x3y;
    data['5y'] = x5y;
    data['10y'] = x10y;
    data['all'] = all;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitProductDetailDataSimplereturn {
  num? x1d;
  num? x1m;
  num? x3m;
  num? ytd;
  num? x1y;
  num? x3y;
  num? x5y;
  dynamic x10y;
  num? all;

  BibitProductDetailDataSimplereturn({this.x1d, this.x1m, this.x3m, this.ytd, this.x1y, this.x3y, this.x5y, this.x10y, this.all});

  BibitProductDetailDataSimplereturn.fromJson(Map<String, dynamic> json) {
    x1d = json['1d'] ?? 0.0;
    x1m = json['1m'] ?? 0.0;
    x3m = json['3m'] ?? 0.0;
    ytd = json['ytd'] ?? 0.0;
    x1y = json['1y'] ?? 0.0;
    x3y = json['3y'] ?? 0.0;
    x5y = json['5y'] ?? 0.0;
    x10y = json['10y'] ?? '';
    all = json['all'] ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['1d'] = x1d;
    data['1m'] = x1m;
    data['3m'] = x3m;
    data['ytd'] = ytd;
    data['1y'] = x1y;
    data['3y'] = x3y;
    data['5y'] = x5y;
    data['10y'] = x10y;
    data['all'] = all;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitProductDetailDataChangesvalue {
  num? x1d;
  num? x1m;
  num? x3m;
  num? ytd;
  num? x1y;
  num? x3y;
  num? x5y;
  dynamic x10y;
  num? all;

  BibitProductDetailDataChangesvalue({this.x1d, this.x1m, this.x3m, this.ytd, this.x1y, this.x3y, this.x5y, this.x10y, this.all});

  BibitProductDetailDataChangesvalue.fromJson(Map<String, dynamic> json) {
    x1d = json['1d'] ?? 0.0;
    x1m = json['1m'] ?? 0.0;
    x3m = json['3m'] ?? 0.0;
    ytd = json['ytd'] ?? 0.0;
    x1y = json['1y'] ?? 0.0;
    x3y = json['3y'] ?? 0.0;
    x5y = json['5y'] ?? 0.0;
    x10y = json['10y'] ?? '';
    all = json['all'] ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['1d'] = x1d;
    data['1m'] = x1m;
    data['3m'] = x3m;
    data['ytd'] = ytd;
    data['1y'] = x1y;
    data['3y'] = x3y;
    data['5y'] = x5y;
    data['10y'] = x10y;
    data['all'] = all;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitProductDetailDataNav {
  String? date;
  num? value;

  BibitProductDetailDataNav({this.date, this.value});

  BibitProductDetailDataNav.fromJson(Map<String, dynamic> json) {
    date = json['date'] ?? '';
    value = json['value'] ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['value'] = value;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitProductDetailDataMaxdrawdown {
  num? x1y;
  num? x3y;
  num? x5y;
  num? x10y;
  num? all;

  BibitProductDetailDataMaxdrawdown({this.x1y, this.x3y, this.x5y, this.x10y, this.all});

  BibitProductDetailDataMaxdrawdown.fromJson(Map<String, dynamic> json) {
    x1y = json['1y'] ?? 0.0;
    x3y = json['3y'] ?? 0.0;
    x5y = json['5y'] ?? 0.0;
    x10y = json['10y'] ?? 0.0;
    all = json['all'] ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['1y'] = x1y;
    data['3y'] = x3y;
    data['5y'] = x5y;
    data['10y'] = x10y;
    data['all'] = all;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitProductDetailDataMaxdrawdownAdjusted {
  num? x1y;
  num? x3y;
  num? x5y;
  num? x10y;
  num? all;

  BibitProductDetailDataMaxdrawdownAdjusted({this.x1y, this.x3y, this.x5y, this.x10y, this.all});

  BibitProductDetailDataMaxdrawdownAdjusted.fromJson(Map<String, dynamic> json) {
    x1y = json['1y'] ?? 0.0;
    x3y = json['3y'] ?? 0.0;
    x5y = json['5y'] ?? 0.0;
    x10y = json['10y'] ?? 0.0;
    all = json['all'] ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['1y'] = x1y;
    data['3y'] = x3y;
    data['5y'] = x5y;
    data['10y'] = x10y;
    data['all'] = all;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
