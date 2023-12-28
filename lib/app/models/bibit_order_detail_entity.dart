import 'dart:convert';

/// *
/// * JSON Source: {"message":"Berhasil menampilkan data order details","data":{"method":"buy","is_cart":false,"payment":{"payment_method":"manual","payment_method_name":"Bank BCA","payment_method_icon":"https://assets.bibit.id/images/payments/bca-circle.svg","can_recharge_payment":true},"convenience_fee":0,"total_amount":1453429.06,"order_at":"2023-08-30T05:22:03.000Z","updated_at":"2023-08-30T05:22:03.000Z","suggest_create_recurring":false,"bank":{"bank_name":"INDONESIA EXIMBANK"},"portfolios":[{"portfolio_id":2133949,"portfolio_name":"Dana Pensiun","template_id":2,"is_partner_category":0,"is_robo":1,"items":[{"code":"B1020505MJXAS","type":8,"amount":1453429.06,"est_amount":1453429.06,"unit":1700.4938,"price":854.71,"status":"accept","nav":854.71,"estimate_unit":1700.4938,"symbol":"RD337","product":{"name":"BNI-AM Indeks IDX30","type":"Saham","sharia":false,"etf":false,"index":true,"exitload":[null],"robo_category":"equity","currency_exchange":{"exchange_rate":1,"currency":"IDR"},"investment_manager":{"name":"PT BNI Asset Management","telepon":"+62 21 29969646","fax":"+62 21 29969647","email":"corsec@bni-am.co.id","url":"www.bni-am.co.id","ojk_code":"NI002"},"bank":{"bank":"BCA","id":31,"account":"4585637549","name":"Reksa Dana Indeks BNI-AM Indeks IDX30"},"bank_redeem":{"id":12,"name":"STANDARD CHARTERED","color":"#0072AA","icon_url":"https://assets.bibit.id/icons/banks/Standard_Chartered_05042023140038.svg"}},"timeline":{"finish":"2023-08-30T05:22:03.000Z"},"has_upload_once":0,"is_disbursement_instant_redemption":false}]}],"is_disbursement_instant_redemption":false,"amount":1453429.06}}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// *
class BibitOrderDetail {
  String? message;
  BibitOrderDetailData? data;

  BibitOrderDetail({this.message, this.data});

  BibitOrderDetail.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = (json['data'] != null) ? BibitOrderDetailData.fromJson(json['data']) : null;
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

class BibitOrderDetailData {
  String? method;
  bool? isCart;
  BibitOrderDetailDataPayment? payment;
  num? convenienceFee;
  num? totalAmount;
  String? orderAt;
  String? updatedAt;
  bool? suggestCreateRecurring;
  BibitOrderDetailDataBank? bank;
  List<BibitOrderDetailDataPortfolios>? portfolios;
  bool? isDisbursementInstantRedemption;
  num? amount;

  BibitOrderDetailData(
      {this.method,
      this.isCart,
      this.payment,
      this.convenienceFee,
      this.totalAmount,
      this.orderAt,
      this.updatedAt,
      this.suggestCreateRecurring,
      this.bank,
      this.portfolios,
      this.isDisbursementInstantRedemption,
      this.amount});

  BibitOrderDetailData.fromJson(Map<String, dynamic> json) {
    method = json['method'] ?? '';
    isCart = json['is_cart'] ?? false;
    payment = (json['payment'] != null) ? BibitOrderDetailDataPayment.fromJson(json['payment']) : null;
    convenienceFee = json['convenience_fee'] ?? 0;
    totalAmount = json['total_amount'] ?? 0.0;
    orderAt = json['order_at'] ?? '';
    updatedAt = json['updated_at'] ?? '';
    suggestCreateRecurring = json['suggest_create_recurring'] ?? false;
    bank = (json['bank'] != null) ? BibitOrderDetailDataBank.fromJson(json['bank']) : null;
    portfolios = json['portfolios'] == null ? null : (json['portfolios'] as List).map((e) => BibitOrderDetailDataPortfolios.fromJson(e)).toList();
    isDisbursementInstantRedemption = json['is_disbursement_instant_redemption'] ?? false;
    amount = json['amount'] ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['method'] = method;
    data['is_cart'] = isCart;
    if (payment != null) {
      data['payment'] = payment!.toJson();
    }
    data['convenience_fee'] = convenienceFee;
    data['total_amount'] = totalAmount;
    data['order_at'] = orderAt;
    data['updated_at'] = updatedAt;
    data['suggest_create_recurring'] = suggestCreateRecurring;
    if (bank != null) {
      data['bank'] = bank!.toJson();
    }
    if (portfolios != null) {
      data['portfolios'] = portfolios?.map((e) => e.toJson()).toList();
    }
    data['is_disbursement_instant_redemption'] = isDisbursementInstantRedemption;
    data['amount'] = amount;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitOrderDetailDataPayment {
  String? paymentMethod;
  String? paymentMethodName;
  String? paymentMethodIcon;
  bool? canRechargePayment;

  BibitOrderDetailDataPayment({this.paymentMethod, this.paymentMethodName, this.paymentMethodIcon, this.canRechargePayment});

  BibitOrderDetailDataPayment.fromJson(Map<String, dynamic> json) {
    paymentMethod = json['payment_method'] ?? '';
    paymentMethodName = json['payment_method_name'] ?? '';
    paymentMethodIcon = json['payment_method_icon'] ?? '';
    canRechargePayment = json['can_recharge_payment'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['payment_method'] = paymentMethod;
    data['payment_method_name'] = paymentMethodName;
    data['payment_method_icon'] = paymentMethodIcon;
    data['can_recharge_payment'] = canRechargePayment;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitOrderDetailDataBank {
  String? bankName;

  BibitOrderDetailDataBank({this.bankName});

  BibitOrderDetailDataBank.fromJson(Map<String, dynamic> json) {
    bankName = json['bank_name'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['bank_name'] = bankName;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitOrderDetailDataPortfolios {
  num? portfolioId;
  String? portfolioName;
  num? templateId;
  num? isPartnerCategory;
  num? isRobo;
  List<BibitOrderDetailDataPortfoliosItems>? items;

  BibitOrderDetailDataPortfolios({this.portfolioId, this.portfolioName, this.templateId, this.isPartnerCategory, this.isRobo, this.items});

  BibitOrderDetailDataPortfolios.fromJson(Map<String, dynamic> json) {
    portfolioId = json['portfolio_id'] ?? 0;
    portfolioName = json['portfolio_name'] ?? '';
    templateId = json['template_id'] ?? 0;
    isPartnerCategory = json['is_partner_category'] ?? 0;
    isRobo = json['is_robo'] ?? 0;
    items = json['items'] == null ? null : (json['items'] as List).map((e) => BibitOrderDetailDataPortfoliosItems.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['portfolio_id'] = portfolioId;
    data['portfolio_name'] = portfolioName;
    data['template_id'] = templateId;
    data['is_partner_category'] = isPartnerCategory;
    data['is_robo'] = isRobo;
    if (items != null) {
      data['items'] = items?.map((e) => e.toJson()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitOrderDetailDataPortfoliosItems {
  String? code;
  num? type;
  num? amount;
  num? estAmount;
  num? unit;
  num? price;
  String? status;
  num? nav;
  num? estimateUnit;
  String? symbol;
  BibitOrderDetailDataPortfoliosItemsProduct? product;
  BibitOrderDetailDataPortfoliosItemsTimeline? timeline;
  num? hasUploadOnce;
  bool? isDisbursementInstantRedemption;

  BibitOrderDetailDataPortfoliosItems(
      {this.code,
      this.type,
      this.amount,
      this.estAmount,
      this.unit,
      this.price,
      this.status,
      this.nav,
      this.estimateUnit,
      this.symbol,
      this.product,
      this.timeline,
      this.hasUploadOnce,
      this.isDisbursementInstantRedemption});

  BibitOrderDetailDataPortfoliosItems.fromJson(Map<String, dynamic> json) {
    code = json['code'] ?? '';
    type = json['type'] ?? 0;
    amount = json['amount'] ?? 0.0;
    estAmount = json['est_amount'] ?? 0.0;
    unit = json['unit'] ?? 0.0;
    price = json['price'] ?? 0.0;
    status = json['status'] ?? '';
    nav = json['nav'] ?? 0.0;
    estimateUnit = json['estimate_unit'] ?? 0.0;
    symbol = json['symbol'] ?? '';
    product = (json['product'] != null) ? BibitOrderDetailDataPortfoliosItemsProduct.fromJson(json['product']) : null;
    timeline = (json['timeline'] != null) ? BibitOrderDetailDataPortfoliosItemsTimeline.fromJson(json['timeline']) : null;
    hasUploadOnce = json['has_upload_once'] ?? 0;
    isDisbursementInstantRedemption = json['is_disbursement_instant_redemption'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['code'] = code;
    data['type'] = type;
    data['amount'] = amount;
    data['est_amount'] = estAmount;
    data['unit'] = unit;
    data['price'] = price;
    data['status'] = status;
    data['nav'] = nav;
    data['estimate_unit'] = estimateUnit;
    data['symbol'] = symbol;
    if (product != null) {
      data['product'] = product!.toJson();
    }
    if (timeline != null) {
      data['timeline'] = timeline!.toJson();
    }
    data['has_upload_once'] = hasUploadOnce;
    data['is_disbursement_instant_redemption'] = isDisbursementInstantRedemption;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitOrderDetailDataPortfoliosItemsProduct {
  String? name;
  String? type;
  bool? sharia;
  bool? etf;
  bool? index;
  List<dynamic>? exitload;
  String? roboCategory;
  BibitOrderDetailDataPortfoliosItemsProductCurrencyExchange? currencyExchange;
  BibitOrderDetailDataPortfoliosItemsProductInvestmentManager? investmentManager;
  BibitOrderDetailDataPortfoliosItemsProductBank? bank;
  BibitOrderDetailDataPortfoliosItemsProductBankRedeem? bankRedeem;

  BibitOrderDetailDataPortfoliosItemsProduct(
      {this.name, this.type, this.sharia, this.etf, this.index, this.exitload, this.roboCategory, this.currencyExchange, this.investmentManager, this.bank, this.bankRedeem});

  BibitOrderDetailDataPortfoliosItemsProduct.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    type = json['type'] ?? '';
    sharia = json['sharia'] ?? false;
    etf = json['etf'] ?? false;
    index = json['index'] ?? false;
    exitload = json['exitload'] ?? [];
    roboCategory = json['robo_category'] ?? '';
    currencyExchange = (json['currency_exchange'] != null) ? BibitOrderDetailDataPortfoliosItemsProductCurrencyExchange.fromJson(json['currency_exchange']) : null;
    investmentManager = (json['investment_manager'] != null) ? BibitOrderDetailDataPortfoliosItemsProductInvestmentManager.fromJson(json['investment_manager']) : null;
    bank = (json['bank'] != null) ? BibitOrderDetailDataPortfoliosItemsProductBank.fromJson(json['bank']) : null;
    bankRedeem = (json['bank_redeem'] != null) ? BibitOrderDetailDataPortfoliosItemsProductBankRedeem.fromJson(json['bank_redeem']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['type'] = type;
    data['sharia'] = sharia;
    data['etf'] = etf;
    data['index'] = index;
    if (exitload != null) {
      data['exitload'] = exitload;
    }
    data['robo_category'] = roboCategory;
    if (currencyExchange != null) {
      data['currency_exchange'] = currencyExchange!.toJson();
    }
    if (investmentManager != null) {
      data['investment_manager'] = investmentManager!.toJson();
    }
    if (bank != null) {
      data['bank'] = bank!.toJson();
    }
    if (bankRedeem != null) {
      data['bank_redeem'] = bankRedeem!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitOrderDetailDataPortfoliosItemsProductCurrencyExchange {
  num? exchangeRate;
  String? currency;

  BibitOrderDetailDataPortfoliosItemsProductCurrencyExchange({this.exchangeRate, this.currency});

  BibitOrderDetailDataPortfoliosItemsProductCurrencyExchange.fromJson(Map<String, dynamic> json) {
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

class BibitOrderDetailDataPortfoliosItemsProductInvestmentManager {
  String? name;
  String? telepon;
  String? fax;
  String? email;
  String? url;
  String? ojkCode;

  BibitOrderDetailDataPortfoliosItemsProductInvestmentManager({this.name, this.telepon, this.fax, this.email, this.url, this.ojkCode});

  BibitOrderDetailDataPortfoliosItemsProductInvestmentManager.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    telepon = json['telepon'] ?? '';
    fax = json['fax'] ?? '';
    email = json['email'] ?? '';
    url = json['url'] ?? '';
    ojkCode = json['ojk_code'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['telepon'] = telepon;
    data['fax'] = fax;
    data['email'] = email;
    data['url'] = url;
    data['ojk_code'] = ojkCode;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitOrderDetailDataPortfoliosItemsProductBank {
  String? bank;
  num? id;
  String? account;
  String? name;

  BibitOrderDetailDataPortfoliosItemsProductBank({this.bank, this.id, this.account, this.name});

  BibitOrderDetailDataPortfoliosItemsProductBank.fromJson(Map<String, dynamic> json) {
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

class BibitOrderDetailDataPortfoliosItemsProductBankRedeem {
  num? id;
  String? name;
  String? color;
  String? iconUrl;

  BibitOrderDetailDataPortfoliosItemsProductBankRedeem({this.id, this.name, this.color, this.iconUrl});

  BibitOrderDetailDataPortfoliosItemsProductBankRedeem.fromJson(Map<String, dynamic> json) {
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

class BibitOrderDetailDataPortfoliosItemsTimeline {
  String? finish;

  BibitOrderDetailDataPortfoliosItemsTimeline({this.finish});

  BibitOrderDetailDataPortfoliosItemsTimeline.fromJson(Map<String, dynamic> json) {
    finish = json['finish'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['finish'] = finish;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
