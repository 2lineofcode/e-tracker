import 'dart:convert';

/// * 
/// * JSON Source: {"message":"Berhasil menampilkan data Cart Items","data":{"total_amount":42000000,"checkoutable":[{"category_id":2133949,"portfolio_name":"Dana Pensiun","portfolio_robo":1,"portfolio_status":1,"portfolio_partner":1,"template_id":2,"is_use_cashback":0,"robo_id":"RO1597249162QIQMXZTJ4NBO","items":[{"item_id":2553064,"amount":7280000,"selected":"RD1766","is_single":0,"is_product_bonus":0,"product":{"id":1766,"name":"TRIM Kas 2 Kelas A","symbol":"RD1766","minbuy":10000,"notbuyable":0,"tradeable":1,"robocategory":"moneymarket","type":"Pasar Uang","investment_manager":{"name":"PT Trimegah Asset Management","ojk_code":"LG002"},"is_sharia":false},"created_at":"2023-12-29T16:22:31.000Z","updated_at":"2023-12-29T16:22:50.000Z"}],"total_amount":40000000,"total_products":3}],"not_checkoutable":[null]}}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// * 
class BibitCart {
  String? message;
  BibitCartData? data;

  BibitCart({this.message, this.data});

  BibitCart.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = (json['data'] != null) ? BibitCartData.fromJson(json['data']) : null;
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

class BibitCartData {
  num? totalAmount;
  List<BibitCartDataCheckoutable>? checkoutable;
  List<dynamic>? notCheckoutable;

  BibitCartData({this.totalAmount, this.checkoutable, this.notCheckoutable});

  BibitCartData.fromJson(Map<String, dynamic> json) {
    totalAmount = json['total_amount'] ?? 0;
    checkoutable = json['checkoutable'] == null ? null : (json['checkoutable'] as List).map((e) => BibitCartDataCheckoutable.fromJson(e)).toList();
    notCheckoutable = json['not_checkoutable'] ?? [];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['total_amount'] = totalAmount;
    if (checkoutable != null) {
      data['checkoutable'] = checkoutable?.map((e) => e.toJson()).toList();
    }
    if (notCheckoutable != null) {
      data['notCheckoutable'] = notCheckoutable;
    }
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitCartDataCheckoutable {
  num? categoryId;
  String? portfolioName;
  num? portfolioRobo;
  num? portfolioStatus;
  num? portfolioPartner;
  num? templateId;
  num? isUseCashback;
  String? roboId;
  List<BibitCartDataCheckoutableItems>? items;
  num? totalAmount;
  num? totalProducts;

  BibitCartDataCheckoutable({this.categoryId, this.portfolioName, this.portfolioRobo, this.portfolioStatus, this.portfolioPartner, this.templateId, this.isUseCashback, this.roboId, this.items, this.totalAmount, this.totalProducts});

  BibitCartDataCheckoutable.fromJson(Map<String, dynamic> json) {
    categoryId = json['category_id'] ?? 0;
    portfolioName = json['portfolio_name'] ?? '';
    portfolioRobo = json['portfolio_robo'] ?? 0;
    portfolioStatus = json['portfolio_status'] ?? 0;
    portfolioPartner = json['portfolio_partner'] ?? 0;
    templateId = json['template_id'] ?? 0;
    isUseCashback = json['is_use_cashback'] ?? 0;
    roboId = json['robo_id'] ?? '';
    items = json['items'] == null ? null : (json['items'] as List).map((e) => BibitCartDataCheckoutableItems.fromJson(e)).toList();
    totalAmount = json['total_amount'] ?? 0;
    totalProducts = json['total_products'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['category_id'] = categoryId;
    data['portfolio_name'] = portfolioName;
    data['portfolio_robo'] = portfolioRobo;
    data['portfolio_status'] = portfolioStatus;
    data['portfolio_partner'] = portfolioPartner;
    data['template_id'] = templateId;
    data['is_use_cashback'] = isUseCashback;
    data['robo_id'] = roboId;
    if (items != null) {
      data['items'] = items?.map((e) => e.toJson()).toList();
    }
    data['total_amount'] = totalAmount;
    data['total_products'] = totalProducts;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitCartDataCheckoutableItems {
  num? itemId;
  num? amount;
  String? selected;
  num? isSingle;
  num? isProductBonus;
  BibitCartDataCheckoutableItemsProduct? product;
  String? createdAt;
  String? updatedAt;

  BibitCartDataCheckoutableItems({this.itemId, this.amount, this.selected, this.isSingle, this.isProductBonus, this.product, this.createdAt, this.updatedAt});

  BibitCartDataCheckoutableItems.fromJson(Map<String, dynamic> json) {
    itemId = json['item_id'] ?? 0;
    amount = json['amount'] ?? 0;
    selected = json['selected'] ?? '';
    isSingle = json['is_single'] ?? 0;
    isProductBonus = json['is_product_bonus'] ?? 0;
    product = (json['product'] != null) ? BibitCartDataCheckoutableItemsProduct.fromJson(json['product']) : null;
    createdAt = json['created_at'] ?? '';
    updatedAt = json['updated_at'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['item_id'] = itemId;
    data['amount'] = amount;
    data['selected'] = selected;
    data['is_single'] = isSingle;
    data['is_product_bonus'] = isProductBonus;
    if (product != null) {
      data['product'] = product!.toJson();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitCartDataCheckoutableItemsProduct {
  num? id;
  String? name;
  String? symbol;
  num? minbuy;
  num? notbuyable;
  num? tradeable;
  String? robocategory;
  String? type;
  BibitCartDataCheckoutableItemsProductInvestmentManager? investmentManager;
  bool? isSharia;

  BibitCartDataCheckoutableItemsProduct({this.id, this.name, this.symbol, this.minbuy, this.notbuyable, this.tradeable, this.robocategory, this.type, this.investmentManager, this.isSharia});

  BibitCartDataCheckoutableItemsProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    name = json['name'] ?? '';
    symbol = json['symbol'] ?? '';
    minbuy = json['minbuy'] ?? 0;
    notbuyable = json['notbuyable'] ?? 0;
    tradeable = json['tradeable'] ?? 0;
    robocategory = json['robocategory'] ?? '';
    type = json['type'] ?? '';
    investmentManager = (json['investment_manager'] != null) ? BibitCartDataCheckoutableItemsProductInvestmentManager.fromJson(json['investment_manager']) : null;
    isSharia = json['is_sharia'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['symbol'] = symbol;
    data['minbuy'] = minbuy;
    data['notbuyable'] = notbuyable;
    data['tradeable'] = tradeable;
    data['robocategory'] = robocategory;
    data['type'] = type;
    if (investmentManager != null) {
      data['investment_manager'] = investmentManager!.toJson();
    }
    data['is_sharia'] = isSharia;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitCartDataCheckoutableItemsProductInvestmentManager {
  String? name;
  String? ojkCode;

  BibitCartDataCheckoutableItemsProductInvestmentManager({this.name, this.ojkCode});

  BibitCartDataCheckoutableItemsProductInvestmentManager.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    ojkCode = json['ojk_code'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['ojk_code'] = ojkCode;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
