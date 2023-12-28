import 'dart:convert';

/// *
/// * JSON Source: {"message":"Berhasil menampilkan Riwayat Transaksi","data":{"is_have_transaction":1,"is_have_stamp_duty_transaction":1,"is_have_dividend_transaction":1,"transactions":[{"portfolio_id":12139248,"templateid":5,"name":"Mobil","is_robo":1,"code":"B1020505XL4YQ","method":"buy","ordertime":"2023-03-27T11:19:02.000Z","amount":8400000,"unit":6671.8558,"price":1259.02,"payment_status":2,"payment_date":"2023-03-27T11:19:15.000Z","approval_date":"2023-03-27T11:19:20.000Z","status":"accept","expiredtime":"2023-03-28T11:19:02.000Z","exporteddate":"2023-03-27T22:29:02.000Z","mi_approved_date":"2023-03-28T10:33:06.000Z","importstatusdate":"2023-03-29T11:44:38.000Z","unitimportdate":"2023-03-29T12:32:55.000Z","lastupdate":"2023-03-29T12:32:55.000Z","payment_id":36920019,"type":3,"is_recurring":0,"is_disbursement_instant_redemption":false,"nav":1259.02,"estAmount":8400000,"estUnit":6531.93259667649,"product":{"name":"Sucorinvest Stable Fund","type":"Obligasi","sharia":false,"etf":false,"index":false,"exitload":[null],"robo_category":"fixincome","currency_exchange":{"exchange_rate":1,"currency":"IDR"},"investment_manager":{"name":"PT Sucorinvest Asset Management","ojkCode":"GAMA2"},"bank":{"bank":"BCA","id":31,"account":"4992175391","name":"Reksa Dana Pendapatan Tetap Sucorinvest Stable Fund"},"bank_redeem":{"id":31,"name":"BCA","color":"#0b71b9","icon_url":"https://assets.bibit.id/icons/banks/BCA_05042023142023.svg"}},"estimate_unit":6671.8558,"symbol":"RD3561","timeline":{"order":"2023-03-27T11:19:15.000Z","payment":"2023-03-27T11:19:15.000Z","process":"2023-03-27T11:19:20.000Z","incoming":"2023-03-28T10:33:06.000Z","expire":"2023-03-28T11:19:02.000Z","finish":"2023-03-28T13:54:08.000Z"},"has_upload_once":0,"has_upload_all":false,"total_amount":8400000,"payment_method":"jago","payment_method_name":"Jago","payment_method_icon":"https://assets.bibit.id/images/payments/jago-circle.svg","can_recharge_payment":true,"invoice_number":"PI1020505N4WZ2","bank":{"bank_name":"INDONESIA EXIMBANK"},"items":[{"code":"B1020505C5MT9","method":"buy","ordertime":"2023-03-06T23:09:16.000Z","amount":230000,"unit":135.9241,"price":1692.12,"payment_status":2,"payment_date":"2023-03-06T23:09:28.000Z","approval_date":"2023-03-06T23:09:31.000Z","status":"accept","expiredtime":"2023-03-07T23:09:16.000Z","exporteddate":"2023-03-07T05:01:10.000Z","mi_approved_date":"2023-03-07T11:27:43.000Z","importstatusdate":"2023-03-08T10:36:05.000Z","unitimportdate":"2023-03-08T11:08:13.000Z","lastupdate":"2023-03-08T11:08:13.000Z","payment_id":36322216,"type":3,"is_recurring":0,"is_disbursement_instant_redemption":false,"nav":1692.12,"estAmount":230000,"estUnit":131.79533902918408,"product":{"name":"Sucorinvest Money Market Fund","type":"Pasar Uang","sharia":false,"etf":false,"index":false,"exitload":[null],"robo_category":"moneymarket","currency_exchange":{"exchange_rate":1,"currency":"IDR"},"investment_manager":{"name":"PT Sucorinvest Asset Management","ojkCode":"GAMA2","telepon":"+62 21 5363020","fax":"+62 21 5363019","email":"-","url":"www.sucorinvest.com/id/asset-management"},"bank":{"bank":"BCA","id":31,"account":"4585677575","name":"Reksa Dana Sucorinvest Money Market Fund"},"bank_redeem":{"id":31,"name":"BCA","color":"#0b71b9","icon_url":"https://assets.bibit.id/icons/banks/BCA_05042023142023.svg"}},"estimate_unit":135.9241,"symbol":"RD1657","timeline":{"order":"2023-03-06T23:09:28.000Z","payment":"2023-03-06T23:09:28.000Z","process":"2023-03-06T23:09:31.000Z","incoming":"2023-03-07T11:27:43.000Z","expire":"2023-03-07T23:09:16.000Z","finish":"2023-03-07T13:52:03.000Z"},"has_upload_once":0}],"is_partner_category":false,"suggest_create_recurring":true,"convenience_fee":0,"stamp_duty_fee":0}]},"meta":{"cursor":{"next_cursor":"bmV4dF9fNjM3MTM5NzlfXzIwMjMtMDEtMDQgMjI6MTE6MTY="}}}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// *
class BibitHistoryMutual {
  String? message;
  BibitHistoryMutualData? data;
  BibitHistoryMeta? meta;

  BibitHistoryMutual({this.message, this.data, this.meta});

  BibitHistoryMutual.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = (json['data'] != null) ? BibitHistoryMutualData.fromJson(json['data']) : null;
    meta = (json['meta'] != null) ? BibitHistoryMeta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
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

class BibitHistoryMutualData {
  num? isHaveTransaction;
  num? isHaveStampDutyTransaction;
  num? isHaveDividendTransaction;
  List<BibitHistoryMutualDataTransactions>? transactions;

  BibitHistoryMutualData({this.isHaveTransaction, this.isHaveStampDutyTransaction, this.isHaveDividendTransaction, this.transactions});

  BibitHistoryMutualData.fromJson(Map<String, dynamic> json) {
    isHaveTransaction = json['is_have_transaction'] ?? 0;
    isHaveStampDutyTransaction = json['is_have_stamp_duty_transaction'] ?? 0;
    isHaveDividendTransaction = json['is_have_dividend_transaction'] ?? 0;
    transactions = json['transactions'] == null ? null : (json['transactions'] as List).map((e) => BibitHistoryMutualDataTransactions.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['is_have_transaction'] = isHaveTransaction;
    data['is_have_stamp_duty_transaction'] = isHaveStampDutyTransaction;
    data['is_have_dividend_transaction'] = isHaveDividendTransaction;
    if (transactions != null) {
      data['transactions'] = transactions?.map((e) => e.toJson()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitHistoryMutualDataTransactions {
  num? portfolioId;
  num? templateid;
  String? name;
  num? isRobo;
  String? code;
  String? method;
  String? ordertime;
  num? amount;
  num? unit;
  num? price;
  num? paymentStatus;
  String? paymentDate;
  String? approvalDate;
  String? status;
  String? expiredtime;
  String? exporteddate;
  String? miApprovedDate;
  String? importstatusdate;
  String? unitimportdate;
  String? lastupdate;
  num? paymentId;
  num? type;
  num? isRecurring;
  bool? isDisbursementInstantRedemption;
  num? nav;
  num? estAmount;
  num? estUnit;
  BibitHistoryMutualDataTransactionsProduct? product;
  num? estimateUnit;
  String? symbol;
  BibitHistoryMutualDataTransactionsTimeline? timeline;
  num? hasUploadOnce;
  bool? hasUploadAll;
  num? totalAmount;
  String? paymentMethod;
  String? paymentMethodName;
  String? paymentMethodIcon;
  bool? canRechargePayment;
  String? invoiceNumber;
  BibitHistoryMutualDataTransactionsBank? bank;
  List<BibitHistoryMutualDataTransactionsItems>? items;
  bool? isPartnerCategory;
  bool? suggestCreateRecurring;
  num? convenienceFee;
  num? stampDutyFee;

  BibitHistoryMutualDataTransactions({
    this.portfolioId,
    this.templateid,
    this.name,
    this.isRobo,
    this.code,
    this.method,
    this.ordertime,
    this.amount,
    this.unit,
    this.price,
    this.paymentStatus,
    this.paymentDate,
    this.approvalDate,
    this.status,
    this.expiredtime,
    this.exporteddate,
    this.miApprovedDate,
    this.importstatusdate,
    this.unitimportdate,
    this.lastupdate,
    this.paymentId,
    this.type,
    this.isRecurring,
    this.isDisbursementInstantRedemption,
    this.nav,
    this.estAmount,
    this.estUnit,
    this.product,
    this.estimateUnit,
    this.symbol,
    this.timeline,
    this.hasUploadOnce,
    this.hasUploadAll,
    this.totalAmount,
    this.paymentMethod,
    this.paymentMethodName,
    this.paymentMethodIcon,
    this.canRechargePayment,
    this.invoiceNumber,
    this.bank,
    this.items,
    this.isPartnerCategory,
    this.suggestCreateRecurring,
    this.convenienceFee,
    this.stampDutyFee,
  });

  BibitHistoryMutualDataTransactions.fromJson(Map<String, dynamic> json) {
    portfolioId = json['portfolio_id'] ?? 0;
    templateid = json['templateid'] ?? 0;
    name = json['name'] ?? '';
    isRobo = json['is_robo'] ?? 0;
    code = json['code'] ?? '';
    method = json['method'] ?? '';
    ordertime = json['ordertime'] ?? '';
    amount = json['amount'] ?? 0;
    unit = json['unit'] ?? 0.0;
    price = json['price'] ?? 0.0;
    paymentStatus = json['payment_status'] ?? 0;
    paymentDate = json['payment_date'] ?? '';
    approvalDate = json['approval_date'] ?? '';
    status = json['status'] ?? '';
    expiredtime = json['expiredtime'] ?? '';
    exporteddate = json['exporteddate'] ?? '';
    miApprovedDate = json['mi_approved_date'] ?? '';
    importstatusdate = json['importstatusdate'] ?? '';
    unitimportdate = json['unitimportdate'] ?? '';
    lastupdate = json['lastupdate'] ?? '';
    paymentId = json['payment_id'] ?? 0;
    type = json['type'] ?? 0;
    isRecurring = json['is_recurring'] ?? 0;
    isDisbursementInstantRedemption = json['is_disbursement_instant_redemption'] ?? false;
    nav = json['nav'] ?? 0.0;
    estAmount = json['estAmount'] ?? 0;
    estUnit = json['estUnit'] ?? 0.0;
    product = (json['product'] != null) ? BibitHistoryMutualDataTransactionsProduct.fromJson(json['product']) : null;
    estimateUnit = json['estimate_unit'] ?? 0.0;
    symbol = json['symbol'] ?? '';
    timeline = (json['timeline'] != null) ? BibitHistoryMutualDataTransactionsTimeline.fromJson(json['timeline']) : null;
    hasUploadOnce = json['has_upload_once'] ?? 0;
    hasUploadAll = json['has_upload_all'] ?? false;
    totalAmount = json['total_amount'] ?? 0;
    paymentMethod = json['payment_method'] ?? '';
    paymentMethodName = json['payment_method_name'] ?? '';
    paymentMethodIcon = json['payment_method_icon'] ?? '';
    canRechargePayment = json['can_recharge_payment'] ?? false;
    invoiceNumber = json['invoice_number'] ?? '';
    bank = (json['bank'] != null) ? BibitHistoryMutualDataTransactionsBank.fromJson(json['bank']) : null;
    items = json['items'] == null ? null : (json['items'] as List).map((e) => BibitHistoryMutualDataTransactionsItems.fromJson(e)).toList();
    isPartnerCategory = json['is_partner_category'] ?? false;
    suggestCreateRecurring = json['suggest_create_recurring'] ?? false;
    convenienceFee = json['convenience_fee'] ?? 0;
    stampDutyFee = json['stamp_duty_fee'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['portfolio_id'] = portfolioId;
    data['templateid'] = templateid;
    data['name'] = name;
    data['is_robo'] = isRobo;
    data['code'] = code;
    data['method'] = method;
    data['ordertime'] = ordertime;
    data['amount'] = amount;
    data['unit'] = unit;
    data['price'] = price;
    data['payment_status'] = paymentStatus;
    data['payment_date'] = paymentDate;
    data['approval_date'] = approvalDate;
    data['status'] = status;
    data['expiredtime'] = expiredtime;
    data['exporteddate'] = exporteddate;
    data['mi_approved_date'] = miApprovedDate;
    data['importstatusdate'] = importstatusdate;
    data['unitimportdate'] = unitimportdate;
    data['lastupdate'] = lastupdate;
    data['payment_id'] = paymentId;
    data['type'] = type;
    data['is_recurring'] = isRecurring;
    data['is_disbursement_instant_redemption'] = isDisbursementInstantRedemption;
    data['nav'] = nav;
    data['estAmount'] = estAmount;
    data['estUnit'] = estUnit;
    if (product != null) {
      data['product'] = product!.toJson();
    }
    data['estimate_unit'] = estimateUnit;
    data['symbol'] = symbol;
    if (timeline != null) {
      data['timeline'] = timeline!.toJson();
    }
    data['has_upload_once'] = hasUploadOnce;
    data['has_upload_all'] = hasUploadAll;
    data['total_amount'] = totalAmount;
    data['payment_method'] = paymentMethod;
    data['payment_method_name'] = paymentMethodName;
    data['payment_method_icon'] = paymentMethodIcon;
    data['can_recharge_payment'] = canRechargePayment;
    data['invoice_number'] = invoiceNumber;
    if (bank != null) {
      data['bank'] = bank!.toJson();
    }
    if (items != null) {
      data['items'] = items?.map((e) => e.toJson()).toList();
    }
    data['is_partner_category'] = isPartnerCategory;
    data['suggest_create_recurring'] = suggestCreateRecurring;
    data['convenience_fee'] = convenienceFee;
    data['stamp_duty_fee'] = stampDutyFee;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitHistoryMutualDataTransactionsProduct {
  String? name;
  String? type;
  bool? sharia;
  bool? etf;
  bool? index;
  List<dynamic>? exitload;
  String? roboCategory;
  BibitHistoryMutualDataTransactionsProductCurrencyExchange? currencyExchange;
  BibitHistoryMutualDataTransactionsProductInvestmentManager? investmentManager;
  BibitHistoryMutualDataTransactionsProductBank? bank;
  BibitHistoryMutualDataTransactionsProductBankRedeem? bankRedeem;

  BibitHistoryMutualDataTransactionsProduct(
      {this.name, this.type, this.sharia, this.etf, this.index, this.exitload, this.roboCategory, this.currencyExchange, this.investmentManager, this.bank, this.bankRedeem});

  BibitHistoryMutualDataTransactionsProduct.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    type = json['type'] ?? '';
    sharia = json['sharia'] ?? false;
    etf = json['etf'] ?? false;
    index = json['index'] ?? false;
    exitload = json['exitload'] ?? [];
    roboCategory = json['robo_category'] ?? '';
    currencyExchange = (json['currency_exchange'] != null) ? BibitHistoryMutualDataTransactionsProductCurrencyExchange.fromJson(json['currency_exchange']) : null;
    investmentManager = (json['investment_manager'] != null) ? BibitHistoryMutualDataTransactionsProductInvestmentManager.fromJson(json['investment_manager']) : null;
    bank = (json['bank'] != null) ? BibitHistoryMutualDataTransactionsProductBank.fromJson(json['bank']) : null;
    bankRedeem = (json['bank_redeem'] != null) ? BibitHistoryMutualDataTransactionsProductBankRedeem.fromJson(json['bank_redeem']) : null;
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

class BibitHistoryMutualDataTransactionsProductCurrencyExchange {
  num? exchangeRate;
  String? currency;

  BibitHistoryMutualDataTransactionsProductCurrencyExchange({this.exchangeRate, this.currency});

  BibitHistoryMutualDataTransactionsProductCurrencyExchange.fromJson(Map<String, dynamic> json) {
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

class BibitHistoryMutualDataTransactionsProductInvestmentManager {
  String? name;
  String? ojkCode;

  BibitHistoryMutualDataTransactionsProductInvestmentManager({this.name, this.ojkCode});

  BibitHistoryMutualDataTransactionsProductInvestmentManager.fromJson(Map<String, dynamic> json) {
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

class BibitHistoryMutualDataTransactionsProductBank {
  String? bank;
  num? id;
  String? account;
  String? name;

  BibitHistoryMutualDataTransactionsProductBank({this.bank, this.id, this.account, this.name});

  BibitHistoryMutualDataTransactionsProductBank.fromJson(Map<String, dynamic> json) {
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

class BibitHistoryMutualDataTransactionsProductBankRedeem {
  num? id;
  String? name;
  String? color;
  String? iconUrl;

  BibitHistoryMutualDataTransactionsProductBankRedeem({this.id, this.name, this.color, this.iconUrl});

  BibitHistoryMutualDataTransactionsProductBankRedeem.fromJson(Map<String, dynamic> json) {
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

class BibitHistoryMutualDataTransactionsTimeline {
  String? order;
  String? payment;
  String? process;
  String? incoming;
  String? expire;
  String? finish;

  BibitHistoryMutualDataTransactionsTimeline({this.order, this.payment, this.process, this.incoming, this.expire, this.finish});

  BibitHistoryMutualDataTransactionsTimeline.fromJson(Map<String, dynamic> json) {
    order = json['order'] ?? '';
    payment = json['payment'] ?? '';
    process = json['process'] ?? '';
    incoming = json['incoming'] ?? '';
    expire = json['expire'] ?? '';
    finish = json['finish'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['order'] = order;
    data['payment'] = payment;
    data['process'] = process;
    data['incoming'] = incoming;
    data['expire'] = expire;
    data['finish'] = finish;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitHistoryMutualDataTransactionsBank {
  String? bankName;

  BibitHistoryMutualDataTransactionsBank({this.bankName});

  BibitHistoryMutualDataTransactionsBank.fromJson(Map<String, dynamic> json) {
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

class BibitHistoryMutualDataTransactionsItems {
  String? code;
  String? method;
  String? ordertime;
  num? amount;
  num? unit;
  num? price;
  num? paymentStatus;
  String? paymentDate;
  String? approvalDate;
  String? status;
  String? expiredtime;
  String? exporteddate;
  String? miApprovedDate;
  String? importstatusdate;
  String? unitimportdate;
  String? lastupdate;
  num? paymentId;
  num? type;
  num? isRecurring;
  bool? isDisbursementInstantRedemption;
  num? nav;
  num? estAmount;
  num? estUnit;
  BibitHistoryMutualDataTransactionsItemsProduct? product;
  num? estimateUnit;
  String? symbol;
  BibitHistoryMutualDataTransactionsItemsTimeline? timeline;
  num? hasUploadOnce;

  BibitHistoryMutualDataTransactionsItems({
    this.code,
    this.method,
    this.ordertime,
    this.amount,
    this.unit,
    this.price,
    this.paymentStatus,
    this.paymentDate,
    this.approvalDate,
    this.status,
    this.expiredtime,
    this.exporteddate,
    this.miApprovedDate,
    this.importstatusdate,
    this.unitimportdate,
    this.lastupdate,
    this.paymentId,
    this.type,
    this.isRecurring,
    this.isDisbursementInstantRedemption,
    this.nav,
    this.estAmount,
    this.estUnit,
    this.product,
    this.estimateUnit,
    this.symbol,
    this.timeline,
    this.hasUploadOnce,
  });

  BibitHistoryMutualDataTransactionsItems.fromJson(Map<String, dynamic> json) {
    code = json['code'] ?? '';
    method = json['method'] ?? '';
    ordertime = json['ordertime'] ?? '';
    amount = json['amount'] ?? 0;
    unit = json['unit'] ?? 0.0;
    price = json['price'] ?? 0.0;
    paymentStatus = json['payment_status'] ?? 0;
    paymentDate = json['payment_date'] ?? '';
    approvalDate = json['approval_date'] ?? '';
    status = json['status'] ?? '';
    expiredtime = json['expiredtime'] ?? '';
    exporteddate = json['exporteddate'] ?? '';
    miApprovedDate = json['mi_approved_date'] ?? '';
    importstatusdate = json['importstatusdate'] ?? '';
    unitimportdate = json['unitimportdate'] ?? '';
    lastupdate = json['lastupdate'] ?? '';
    paymentId = json['payment_id'] ?? 0;
    type = json['type'] ?? 0;
    isRecurring = json['is_recurring'] ?? 0;
    isDisbursementInstantRedemption = json['is_disbursement_instant_redemption'] ?? false;
    nav = json['nav'] ?? 0.0;
    estAmount = json['estAmount'] ?? 0;
    estUnit = json['estUnit'] ?? 0.0;
    product = (json['product'] != null) ? BibitHistoryMutualDataTransactionsItemsProduct.fromJson(json['product']) : null;
    estimateUnit = json['estimate_unit'] ?? 0.0;
    symbol = json['symbol'] ?? '';
    timeline = (json['timeline'] != null) ? BibitHistoryMutualDataTransactionsItemsTimeline.fromJson(json['timeline']) : null;
    hasUploadOnce = json['has_upload_once'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['code'] = code;
    data['method'] = method;
    data['ordertime'] = ordertime;
    data['amount'] = amount;
    data['unit'] = unit;
    data['price'] = price;
    data['payment_status'] = paymentStatus;
    data['payment_date'] = paymentDate;
    data['approval_date'] = approvalDate;
    data['status'] = status;
    data['expiredtime'] = expiredtime;
    data['exporteddate'] = exporteddate;
    data['mi_approved_date'] = miApprovedDate;
    data['importstatusdate'] = importstatusdate;
    data['unitimportdate'] = unitimportdate;
    data['lastupdate'] = lastupdate;
    data['payment_id'] = paymentId;
    data['type'] = type;
    data['is_recurring'] = isRecurring;
    data['is_disbursement_instant_redemption'] = isDisbursementInstantRedemption;
    data['nav'] = nav;
    data['estAmount'] = estAmount;
    data['estUnit'] = estUnit;
    if (product != null) {
      data['product'] = product!.toJson();
    }
    data['estimate_unit'] = estimateUnit;
    data['symbol'] = symbol;
    if (timeline != null) {
      data['timeline'] = timeline!.toJson();
    }
    data['has_upload_once'] = hasUploadOnce;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitHistoryMutualDataTransactionsItemsProduct {
  String? name;
  String? type;
  bool? sharia;
  bool? etf;
  bool? index;
  List<dynamic>? exitload;
  String? roboCategory;
  BibitHistoryMutualDataTransactionsItemsProductCurrencyExchange? currencyExchange;
  BibitHistoryMutualDataTransactionsItemsProductInvestmentManager? investmentManager;
  BibitHistoryMutualDataTransactionsItemsProductBank? bank;
  BibitHistoryMutualDataTransactionsItemsProductBankRedeem? bankRedeem;

  BibitHistoryMutualDataTransactionsItemsProduct(
      {this.name, this.type, this.sharia, this.etf, this.index, this.exitload, this.roboCategory, this.currencyExchange, this.investmentManager, this.bank, this.bankRedeem});

  BibitHistoryMutualDataTransactionsItemsProduct.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    type = json['type'] ?? '';
    sharia = json['sharia'] ?? false;
    etf = json['etf'] ?? false;
    index = json['index'] ?? false;
    exitload = json['exitload'] ?? [];
    roboCategory = json['robo_category'] ?? '';
    currencyExchange = (json['currency_exchange'] != null) ? BibitHistoryMutualDataTransactionsItemsProductCurrencyExchange.fromJson(json['currency_exchange']) : null;
    investmentManager = (json['investment_manager'] != null) ? BibitHistoryMutualDataTransactionsItemsProductInvestmentManager.fromJson(json['investment_manager']) : null;
    bank = (json['bank'] != null) ? BibitHistoryMutualDataTransactionsItemsProductBank.fromJson(json['bank']) : null;
    bankRedeem = (json['bank_redeem'] != null) ? BibitHistoryMutualDataTransactionsItemsProductBankRedeem.fromJson(json['bank_redeem']) : null;
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

class BibitHistoryMutualDataTransactionsItemsProductCurrencyExchange {
  num? exchangeRate;
  String? currency;

  BibitHistoryMutualDataTransactionsItemsProductCurrencyExchange({this.exchangeRate, this.currency});

  BibitHistoryMutualDataTransactionsItemsProductCurrencyExchange.fromJson(Map<String, dynamic> json) {
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

class BibitHistoryMutualDataTransactionsItemsProductInvestmentManager {
  String? name;
  String? ojkCode;
  String? telepon;
  String? fax;
  String? email;
  String? url;

  BibitHistoryMutualDataTransactionsItemsProductInvestmentManager({this.name, this.ojkCode, this.telepon, this.fax, this.email, this.url});

  BibitHistoryMutualDataTransactionsItemsProductInvestmentManager.fromJson(Map<String, dynamic> json) {
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

class BibitHistoryMutualDataTransactionsItemsProductBank {
  String? bank;
  num? id;
  String? account;
  String? name;

  BibitHistoryMutualDataTransactionsItemsProductBank({this.bank, this.id, this.account, this.name});

  BibitHistoryMutualDataTransactionsItemsProductBank.fromJson(Map<String, dynamic> json) {
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

class BibitHistoryMutualDataTransactionsItemsProductBankRedeem {
  num? id;
  String? name;
  String? color;
  String? iconUrl;

  BibitHistoryMutualDataTransactionsItemsProductBankRedeem({this.id, this.name, this.color, this.iconUrl});

  BibitHistoryMutualDataTransactionsItemsProductBankRedeem.fromJson(Map<String, dynamic> json) {
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

class BibitHistoryMutualDataTransactionsItemsTimeline {
  String? order;
  String? payment;
  String? process;
  String? incoming;
  String? expire;
  String? finish;

  BibitHistoryMutualDataTransactionsItemsTimeline({this.order, this.payment, this.process, this.incoming, this.expire, this.finish});

  BibitHistoryMutualDataTransactionsItemsTimeline.fromJson(Map<String, dynamic> json) {
    order = json['order'] ?? '';
    payment = json['payment'] ?? '';
    process = json['process'] ?? '';
    incoming = json['incoming'] ?? '';
    expire = json['expire'] ?? '';
    finish = json['finish'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['order'] = order;
    data['payment'] = payment;
    data['process'] = process;
    data['incoming'] = incoming;
    data['expire'] = expire;
    data['finish'] = finish;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitHistoryMeta {
  BibitHistoryMetaCursor? cursor;

  BibitHistoryMeta({this.cursor});

  BibitHistoryMeta.fromJson(Map<String, dynamic> json) {
    cursor = (json['cursor'] != null) ? BibitHistoryMetaCursor.fromJson(json['cursor']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (cursor != null) {
      data['cursor'] = cursor!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitHistoryMetaCursor {
  String? nextCursor;

  BibitHistoryMetaCursor({this.nextCursor});

  BibitHistoryMetaCursor.fromJson(Map<String, dynamic> json) {
    nextCursor = json['next_cursor'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['next_cursor'] = nextCursor;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
