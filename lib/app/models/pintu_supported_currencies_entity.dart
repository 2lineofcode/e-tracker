import 'dart:convert';

/// * 
/// * https://api.pintu.co.id/v2/wallet/supportedCurrencies
/// * JSON Source: {"code":"success","message":"","payload":[{"currency_id":13,"currencyGroup":"IDR","color":"#B13932","currencySymbol":"Rp","name":"Rupiah Token","logo":"https://s3-ap-southeast-1.amazonaws.com/static.pintu.co.id/assets/images/logo/circle_IDRT.svg","decimal_point":0,"listingDate":"2020-09-15T09:43:42Z","wallets":[{"currency_id":11,"currencyGroup":"IDR","tokenSymbol":"IDRT","decimal_point":2,"tokenType":"ERC-20","blockchain":"Ethereum","explorer":"https://etherscan.io/tx/","listingDate":"2020-09-15T09:43:43Z","blockchainName":"Ethereum","logo":"https://s3.ap-southeast-1.amazonaws.com/static.pintu.co.id/assets/images/logo/blockchain/ERC-20.svg"}],"is_limit_order_enabled":false}]}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// * 
class PintuSupportedCurrencies {
  String? code;
  String? message;
  List<PintuSupportedCurrenciesPayload>? payload;

  PintuSupportedCurrencies({this.code, this.message, this.payload});

  PintuSupportedCurrencies.fromJson(Map<String, dynamic> json) {
    code = json['code'] ?? '';
    message = json['message'] ?? '';
    payload = json['payload'] == null ? null : (json['payload'] as List).map((e) => PintuSupportedCurrenciesPayload.fromJson(e)).toList();
  }


  @override
  String toString() {
    return jsonEncode(this);
  }
}

class PintuSupportedCurrenciesPayload {
  num? currencyId;
  String? currencyGroup;
  String? color;
  String? currencySymbol;
  String? name;
  String? logo;
  num? decimalPoint;
  String? listingDate;
  List<PintuSupportedCurrenciesPayloadWallets>? wallets;
  bool? isLimitOrderEnabled;

  PintuSupportedCurrenciesPayload({this.currencyId, this.currencyGroup, this.color, this.currencySymbol, this.name, this.logo, this.decimalPoint, this.listingDate, this.wallets, this.isLimitOrderEnabled});

  PintuSupportedCurrenciesPayload.fromJson(Map<String, dynamic> json) {
    currencyId = json['currency_id'] ?? 0;
    currencyGroup = json['currencyGroup'] ?? '';
    color = json['color'] ?? '';
    currencySymbol = json['currencySymbol'] ?? '';
    name = json['name'] ?? '';
    logo = json['logo'] ?? '';
    decimalPoint = json['decimal_point'] ?? 0;
    listingDate = json['listingDate'] ?? '';
    wallets = json['wallets'] == null ? null : (json['wallets'] as List).map((e) => PintuSupportedCurrenciesPayloadWallets.fromJson(e)).toList();
    isLimitOrderEnabled = json['is_limit_order_enabled'] ?? false;
  }


  @override
  String toString() {
    return jsonEncode(this);
  }
}

class PintuSupportedCurrenciesPayloadWallets {
  num? currencyId;
  String? currencyGroup;
  String? tokenSymbol;
  num? decimalPoint;
  String? tokenType;
  String? blockchain;
  String? explorer;
  String? listingDate;
  String? blockchainName;
  String? logo;

  PintuSupportedCurrenciesPayloadWallets({this.currencyId, this.currencyGroup, this.tokenSymbol, this.decimalPoint, this.tokenType, this.blockchain, this.explorer, this.listingDate, this.blockchainName, this.logo});

  PintuSupportedCurrenciesPayloadWallets.fromJson(Map<String, dynamic> json) {
    currencyId = json['currency_id'] ?? 0;
    currencyGroup = json['currencyGroup'] ?? '';
    tokenSymbol = json['tokenSymbol'] ?? '';
    decimalPoint = json['decimal_point'] ?? 0;
    tokenType = json['tokenType'] ?? '';
    blockchain = json['blockchain'] ?? '';
    explorer = json['explorer'] ?? '';
    listingDate = json['listingDate'] ?? '';
    blockchainName = json['blockchainName'] ?? '';
    logo = json['logo'] ?? '';
  }


  @override
  String toString() {
    return jsonEncode(this);
  }
}
