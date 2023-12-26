import 'dart:convert';

/// *
/// * JSON Source: {"message":"Successfully retrieve data product detail","query":"RD337","data":{"id":337,"symbol":"RD337","name":"BNI-AM Indeks IDX30","type":"Saham","profile":"","tradeable":1,"notbuyable":0,"status":1,"dividend_date":null,"robocategory":"equity","bank_redeem":{"id":12,"name":"STANDARD CHARTERED","color":"#0072AA","icon_url":"https://assets.bibit.id/icons/banks/Standard_Chartered_05042023140038.svg"},"released_date":"2017-12-28","currency_exchange":{"exchange_rate":1,"currency":"IDR"},"is_has_dividend":true,"min_asset":10000,"minbuy":10000,"minsell":10000,"executive":{},"fee":{"subscription":{"value":0,"max_value":null,"type":"percent","currency":"IDR"},"redemption":{"value":0,"max_value":null,"type":"percent","currency":"IDR"},"transfer":{"value":0,"max_value":null,"type":"percent","currency":"IDR"},"switch":{"value":2,"max_value":null,"type":"percent","currency":"IDR"}},"asset":[{"name":"Kas & Deposito","percentage":1}],"holding":[{"symbol":"BBRI","name":"Bank Rakyat Indonesia (Persero) Tbk.","annualDividend":0,"date":"2023-11-30","clickable":1,"company_id":4327,"product_type":"Saham","serie_id":null}],"bank":[{"bank":"BCA","id":31,"account":"4585637549","name":"Reksa Dana Indeks BNI-AM Indeks IDX30"}],"exitload":[null],"investment_manager":{"name":"PT BNI Asset Management","ojkCode":"NI002","telepon":"+62 21 29969646","fax":"+62 21 29969647","email":"corsec@bni-am.co.id","url":"www.bni-am.co.id"},"custodian_bank":{"name":"STANDARD CHARTERED","ojkCode":"SCBJK"},"sharia":false,"etf":false,"index":true,"is_instant_redemption":false,"aum":{"value":1603614579115.38,"date":"2023-11-01"},"shareholders":[null],"expenseratio":{"percentage":0.0157},"avg_yield":{"date":null,"percentage":null},"cagr":{"1y":0.0000948125674058442,"3y":-0.007475074913743662,"5y":-0.02025716126619892,"10y":null,"all":-0.029363063304796988},"cagr_adjusted":{"1y":0.03402766647639632,"3y":0.010638643527889124,"5y":-0.007732803280355194,"10y":null,"all":-0.019045693616357773},"simplereturn":{"1d":0.002995257508944249,"1m":0.03991570749020279,"3m":-0.021679902614341162,"ytd":0.04106044142230236,"1y":0.03402766647639632,"3y":0.03225667688151357,"5y":-0.03807066001185955,"10y":null,"all":-0.10868759935696404},"changesvalue":{"1d":2.519999999999982,"1m":32.389999999999986,"3m":-18.699999999999932,"ytd":34.41152414278895,"1y":28.711524142789017,"3y":27.83944754935908,"5y":-35.587310859285935,"10y":null,"all":-109.647310859286},"nav":{"date":"2023-12-22","value":843.85},"riskprofile":"High","maxdrawdown":{"1y":-0.13031492124189914,"3y":-0.2228623649078194,"5y":-0.4505307898804197,"10y":-0.48795625971269374,"all":-0.48795625971269374},"maxdrawdown_adjusted":{"1y":-0.1008068222561956,"3y":-0.1957748129721058,"5y":-0.445422035770232,"10y":-0.4831954732762356,"all":-0.4831954732762356}}}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// *
class BibitProductDetailMutual {
  String? message;
  String? query;
  BibitProductDetailMutualData? data;

  BibitProductDetailMutual({this.message, this.query, this.data});

  BibitProductDetailMutual.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    query = json['query'] ?? '';
    data = (json['data'] != null) ? BibitProductDetailMutualData.fromJson(json['data']) : null;
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

class BibitProductDetailMutualData {
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
  BibitProductDetailMutualDataBankRedeem? bankRedeem;
  String? releasedDate;
  BibitProductDetailMutualDataCurrencyExchange? currencyExchange;
  bool? isHasDividend;
  num? minAsset;
  num? minbuy;
  num? minsell;
  BibitProductDetailMutualDataExecutive? executive;
  BibitProductDetailMutualDataFee? fee;
  List<BibitProductDetailMutualDataAsset>? asset;
  List<BibitProductDetailMutualDataHolding>? holding;
  List<BibitProductDetailMutualDataBank>? bank;
  List<dynamic>? exitload;
  BibitProductDetailMutualDataInvestmentManager? investmentManager;
  BibitProductDetailMutualDataCustodianBank? custodianBank;
  bool? sharia;
  bool? etf;
  bool? index;
  bool? isInstantRedemption;
  BibitProductDetailMutualDataAum? aum;
  List<dynamic>? shareholders;
  BibitProductDetailMutualDataExpenseratio? expenseratio;
  BibitProductDetailMutualDataAvgYield? avgYield;
  BibitProductDetailMutualDataCagr? cagr;
  BibitProductDetailMutualDataCagrAdjusted? cagrAdjusted;
  BibitProductDetailMutualDataSimplereturn? simplereturn;
  BibitProductDetailMutualDataChangesvalue? changesvalue;
  BibitProductDetailMutualDataNav? nav;
  String? riskprofile;
  BibitProductDetailMutualDataMaxdrawdown? maxdrawdown;
  BibitProductDetailMutualDataMaxdrawdownAdjusted? maxdrawdownAdjusted;

  BibitProductDetailMutualData({
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

  BibitProductDetailMutualData.fromJson(Map<String, dynamic> json) {
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
    bankRedeem = (json['bank_redeem'] != null) ? BibitProductDetailMutualDataBankRedeem.fromJson(json['bank_redeem']) : null;
    releasedDate = json['released_date'] ?? '';
    currencyExchange = (json['currency_exchange'] != null) ? BibitProductDetailMutualDataCurrencyExchange.fromJson(json['currency_exchange']) : null;
    isHasDividend = json['is_has_dividend'] ?? false;
    minAsset = json['min_asset'] ?? 0;
    minbuy = json['minbuy'] ?? 0;
    minsell = json['minsell'] ?? 0;
    executive = (json['executive'] != null) ? BibitProductDetailMutualDataExecutive.fromJson(json['executive']) : null;
    fee = (json['fee'] != null) ? BibitProductDetailMutualDataFee.fromJson(json['fee']) : null;
    asset = json['asset'] == null ? null : (json['asset'] as List).map((e) => BibitProductDetailMutualDataAsset.fromJson(e)).toList();
    holding = json['holding'] == null ? null : (json['holding'] as List).map((e) => BibitProductDetailMutualDataHolding.fromJson(e)).toList();
    bank = json['bank'] == null ? null : (json['bank'] as List).map((e) => BibitProductDetailMutualDataBank.fromJson(e)).toList();
    exitload = json['exitload'] ?? [];
    investmentManager = (json['investment_manager'] != null) ? BibitProductDetailMutualDataInvestmentManager.fromJson(json['investment_manager']) : null;
    custodianBank = (json['custodian_bank'] != null) ? BibitProductDetailMutualDataCustodianBank.fromJson(json['custodian_bank']) : null;
    sharia = json['sharia'] ?? false;
    etf = json['etf'] ?? false;
    index = json['index'] ?? false;
    isInstantRedemption = json['is_instant_redemption'] ?? false;
    aum = (json['aum'] != null) ? BibitProductDetailMutualDataAum.fromJson(json['aum']) : null;
    shareholders = json['shareholders'] ?? [];
    expenseratio = (json['expenseratio'] != null) ? BibitProductDetailMutualDataExpenseratio.fromJson(json['expenseratio']) : null;
    avgYield = (json['avg_yield'] != null) ? BibitProductDetailMutualDataAvgYield.fromJson(json['avg_yield']) : null;
    cagr = (json['cagr'] != null) ? BibitProductDetailMutualDataCagr.fromJson(json['cagr']) : null;
    cagrAdjusted = (json['cagr_adjusted'] != null) ? BibitProductDetailMutualDataCagrAdjusted.fromJson(json['cagr_adjusted']) : null;
    simplereturn = (json['simplereturn'] != null) ? BibitProductDetailMutualDataSimplereturn.fromJson(json['simplereturn']) : null;
    changesvalue = (json['changesvalue'] != null) ? BibitProductDetailMutualDataChangesvalue.fromJson(json['changesvalue']) : null;
    nav = (json['nav'] != null) ? BibitProductDetailMutualDataNav.fromJson(json['nav']) : null;
    riskprofile = json['riskprofile'] ?? '';
    maxdrawdown = (json['maxdrawdown'] != null) ? BibitProductDetailMutualDataMaxdrawdown.fromJson(json['maxdrawdown']) : null;
    maxdrawdownAdjusted = (json['maxdrawdown_adjusted'] != null) ? BibitProductDetailMutualDataMaxdrawdownAdjusted.fromJson(json['maxdrawdown_adjusted']) : null;
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

class BibitProductDetailMutualDataBankRedeem {
  num? id;
  String? name;
  String? color;
  String? iconUrl;

  BibitProductDetailMutualDataBankRedeem({this.id, this.name, this.color, this.iconUrl});

  BibitProductDetailMutualDataBankRedeem.fromJson(Map<String, dynamic> json) {
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

class BibitProductDetailMutualDataCurrencyExchange {
  num? exchangeRate;
  String? currency;

  BibitProductDetailMutualDataCurrencyExchange({this.exchangeRate, this.currency});

  BibitProductDetailMutualDataCurrencyExchange.fromJson(Map<String, dynamic> json) {
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

class BibitProductDetailMutualDataExecutive {
  BibitProductDetailMutualDataExecutive();

  BibitProductDetailMutualDataExecutive.fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitProductDetailMutualDataFee {
  BibitProductDetailMutualDataFeeSubscription? subscription;
  BibitProductDetailMutualDataFeeRedemption? redemption;
  BibitProductDetailMutualDataFeeTransfer? transfer;
  BibitProductDetailMutualDataFeeSwitch? xSwitch;

  BibitProductDetailMutualDataFee({this.subscription, this.redemption, this.transfer, this.xSwitch});

  BibitProductDetailMutualDataFee.fromJson(Map<String, dynamic> json) {
    subscription = (json['subscription'] != null) ? BibitProductDetailMutualDataFeeSubscription.fromJson(json['subscription']) : null;
    redemption = (json['redemption'] != null) ? BibitProductDetailMutualDataFeeRedemption.fromJson(json['redemption']) : null;
    transfer = (json['transfer'] != null) ? BibitProductDetailMutualDataFeeTransfer.fromJson(json['transfer']) : null;
    xSwitch = (json['switch'] != null) ? BibitProductDetailMutualDataFeeSwitch.fromJson(json['switch']) : null;
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

class BibitProductDetailMutualDataFeeSubscription {
  num? value;
  dynamic maxValue;
  String? type;
  String? currency;

  BibitProductDetailMutualDataFeeSubscription({this.value, this.maxValue, this.type, this.currency});

  BibitProductDetailMutualDataFeeSubscription.fromJson(Map<String, dynamic> json) {
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

class BibitProductDetailMutualDataFeeRedemption {
  num? value;
  dynamic maxValue;
  String? type;
  String? currency;

  BibitProductDetailMutualDataFeeRedemption({this.value, this.maxValue, this.type, this.currency});

  BibitProductDetailMutualDataFeeRedemption.fromJson(Map<String, dynamic> json) {
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

class BibitProductDetailMutualDataFeeTransfer {
  num? value;
  dynamic maxValue;
  String? type;
  String? currency;

  BibitProductDetailMutualDataFeeTransfer({this.value, this.maxValue, this.type, this.currency});

  BibitProductDetailMutualDataFeeTransfer.fromJson(Map<String, dynamic> json) {
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

class BibitProductDetailMutualDataFeeSwitch {
  num? value;
  dynamic maxValue;
  String? type;
  String? currency;

  BibitProductDetailMutualDataFeeSwitch({this.value, this.maxValue, this.type, this.currency});

  BibitProductDetailMutualDataFeeSwitch.fromJson(Map<String, dynamic> json) {
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

class BibitProductDetailMutualDataAsset {
  String? name;
  num? percentage;

  BibitProductDetailMutualDataAsset({this.name, this.percentage});

  BibitProductDetailMutualDataAsset.fromJson(Map<String, dynamic> json) {
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

class BibitProductDetailMutualDataHolding {
  String? symbol;
  String? name;
  num? annualDividend;
  String? date;
  num? clickable;
  num? companyId;
  String? productType;
  dynamic serieId;

  BibitProductDetailMutualDataHolding({this.symbol, this.name, this.annualDividend, this.date, this.clickable, this.companyId, this.productType, this.serieId});

  BibitProductDetailMutualDataHolding.fromJson(Map<String, dynamic> json) {
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

class BibitProductDetailMutualDataBank {
  String? bank;
  num? id;
  String? account;
  String? name;

  BibitProductDetailMutualDataBank({this.bank, this.id, this.account, this.name});

  BibitProductDetailMutualDataBank.fromJson(Map<String, dynamic> json) {
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

class BibitProductDetailMutualDataInvestmentManager {
  String? name;
  String? ojkCode;
  String? telepon;
  String? fax;
  String? email;
  String? url;

  BibitProductDetailMutualDataInvestmentManager({this.name, this.ojkCode, this.telepon, this.fax, this.email, this.url});

  BibitProductDetailMutualDataInvestmentManager.fromJson(Map<String, dynamic> json) {
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

class BibitProductDetailMutualDataCustodianBank {
  String? name;
  String? ojkCode;

  BibitProductDetailMutualDataCustodianBank({this.name, this.ojkCode});

  BibitProductDetailMutualDataCustodianBank.fromJson(Map<String, dynamic> json) {
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

class BibitProductDetailMutualDataAum {
  num? value;
  String? date;

  BibitProductDetailMutualDataAum({this.value, this.date});

  BibitProductDetailMutualDataAum.fromJson(Map<String, dynamic> json) {
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

class BibitProductDetailMutualDataExpenseratio {
  num? percentage;

  BibitProductDetailMutualDataExpenseratio({this.percentage});

  BibitProductDetailMutualDataExpenseratio.fromJson(Map<String, dynamic> json) {
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

class BibitProductDetailMutualDataAvgYield {
  dynamic date;
  dynamic percentage;

  BibitProductDetailMutualDataAvgYield({this.date, this.percentage});

  BibitProductDetailMutualDataAvgYield.fromJson(Map<String, dynamic> json) {
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

class BibitProductDetailMutualDataCagr {
  num? x1y;
  num? x3y;
  num? x5y;
  dynamic x10y;
  num? all;

  BibitProductDetailMutualDataCagr({this.x1y, this.x3y, this.x5y, this.x10y, this.all});

  BibitProductDetailMutualDataCagr.fromJson(Map<String, dynamic> json) {
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

class BibitProductDetailMutualDataCagrAdjusted {
  num? x1y;
  num? x3y;
  num? x5y;
  dynamic x10y;
  num? all;

  BibitProductDetailMutualDataCagrAdjusted({this.x1y, this.x3y, this.x5y, this.x10y, this.all});

  BibitProductDetailMutualDataCagrAdjusted.fromJson(Map<String, dynamic> json) {
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

class BibitProductDetailMutualDataSimplereturn {
  num? x1d;
  num? x1m;
  num? x3m;
  num? ytd;
  num? x1y;
  num? x3y;
  num? x5y;
  dynamic x10y;
  num? all;

  BibitProductDetailMutualDataSimplereturn({this.x1d, this.x1m, this.x3m, this.ytd, this.x1y, this.x3y, this.x5y, this.x10y, this.all});

  BibitProductDetailMutualDataSimplereturn.fromJson(Map<String, dynamic> json) {
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

class BibitProductDetailMutualDataChangesvalue {
  num? x1d;
  num? x1m;
  num? x3m;
  num? ytd;
  num? x1y;
  num? x3y;
  num? x5y;
  dynamic x10y;
  num? all;

  BibitProductDetailMutualDataChangesvalue({this.x1d, this.x1m, this.x3m, this.ytd, this.x1y, this.x3y, this.x5y, this.x10y, this.all});

  BibitProductDetailMutualDataChangesvalue.fromJson(Map<String, dynamic> json) {
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

class BibitProductDetailMutualDataNav {
  String? date;
  num? value;

  BibitProductDetailMutualDataNav({this.date, this.value});

  BibitProductDetailMutualDataNav.fromJson(Map<String, dynamic> json) {
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

class BibitProductDetailMutualDataMaxdrawdown {
  num? x1y;
  num? x3y;
  num? x5y;
  num? x10y;
  num? all;

  BibitProductDetailMutualDataMaxdrawdown({this.x1y, this.x3y, this.x5y, this.x10y, this.all});

  BibitProductDetailMutualDataMaxdrawdown.fromJson(Map<String, dynamic> json) {
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

class BibitProductDetailMutualDataMaxdrawdownAdjusted {
  num? x1y;
  num? x3y;
  num? x5y;
  num? x10y;
  num? all;

  BibitProductDetailMutualDataMaxdrawdownAdjusted({this.x1y, this.x3y, this.x5y, this.x10y, this.all});

  BibitProductDetailMutualDataMaxdrawdownAdjusted.fromJson(Map<String, dynamic> json) {
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
