import 'dart:convert';

/// * 
/// * JSON Source: {"message":"Berhasil menampilkan data detail Saham BBRI","data":{"id":4327,"symbol":"BBRI","name":"Bank Rakyat Indonesia (Persero) Tbk.","price":5625,"change":0,"percent":0,"price_updated_at":"2023-12-27T21:05:46.000Z","status":"active","type":"Saham","sub_sector":"Bank","is_acceleration":false,"is_buyable":true,"is_sellable":true,"is_stock_e_ipo":false,"is_sharia":0,"ipo_date":"2003-11-10","market_hours":{"status":"close","time_left":"2023-12-28T01:45:00.220Z","formatted_time_left":"0 jam 17 menit 39 detik"},"notations":[{"notation_code":"K","notation_desc":"Perusahaan Tercatat yang menerapkan Saham Dengan Hak Suara Multipel dan tercatat di Papan Ekonomi Baru","icon_url":{"light_mode":"https://assets.stockbit.com/logos/notations/light/K.png","dark_mode":"https://assets.stockbit.com/logos/notations/dark/K.png"}}],"corp_action":{"active":true,"type":"dividend","info":{"company_id":"59","company_symbol":"BBRI","dividend_created":"2023-12-19","dividend_cumdate":"2023-12-29","dividend_datahash":"7ca69c2c01c7e558401b086eb3380bd2","dividend_exdate":"2024-01-02","dividend_id":"114247","dividend_iqp_id":"","dividend_lastupdate":"2023-12-19","dividend_lock":0,"dividend_paydate":"2024-01-18","dividend_recdate":"2024-01-03","dividend_value":"84","lastprice":"","event_note":"","dividend_value_formatted":"Rp 84","lastprice_formatted":"","dividend_currency":"CURRENCY_IDR"}},"key_stats":{"open":5625,"high":5625,"low":5625,"pe_annualised":"14.53","pe_ttm":"15.22","dividend_ttm":"288.22","volume":"0","avg_volume":"137.15 M","market_cap":"852,503 B","pbv_ratio":"2.78","dividend_yield":"5.12%","net_profit_margin":"30.12%","debt_to_equity":"0.02","total_debt":"5,413 B","total_cash":"24,132 B"},"analyst_rating":{"price_target":{"best_target":6369,"best_low_target":5200,"best_high_target":7000,"current_price":5625},"recommendation":"Buy","total_buy":33,"total_sell":0,"total_hold":1,"total_analyst":34,"last_updated":"27 Dec 23"},"company_about":{"background":"PT Bank Rakyat Indonesia (Persero) Tbk. atau BBRI merupakan BUMN yang bergerak di bidang usaha perbankan, Bank terbesar di Segmen Usaha Mikro, Kecil dan Menengah (UMKM) dengan layanan micro banking terbesar di Indonesia maupun di dunia, Selain fokus pada segmen UMKM, BRI juga terus mengembangkan berbagai produk consumer banking dan layanan institusional bagi masyarakat perkotaan. Melalui layanan e-banking yang didukung oleh 24.684 unit ATM serta 284.426 unit EDC yang tersebar di seluruh pelosok Indonesia, BRI bertekad untuk terus mendukung peningkatan efisiensi kegiatan perekonomian nasional sekaligus meningkatkan kenyamanan dan kemudahan transaksi nasabah sesuai perkembangan kebutuhan jasa layanan perbankan seluruh lapisan masyarakat Indonesia. BRI mengoperasikan 8 jenjang kantor pelayanan, terdiri dari Kantor Pusat, 19 Kantor Wilayah, 468 Kantor Cabang (termasuk 3 Unit Kerja Luar Negeri), 610 Kantor Cabang Pembantu, 992 Kantor Kas, 5.381 BRI Unit, 2.069 Teras BRI, dan 638 Teras BRI Keliling. Entitas anak: PT Bank BRISyariah Tbk, PT Bank Agroniaga Tbk dan BRIngin Remittance Co. Ltd. entitas asosiasi PT BTMU-BRI Finance."},"icon_url":"https://assets.stockbit.com/logos/companies/BBRI.png"}}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// * 
class StockbitProductDetail {
  String? message;
  StockbitProductDetailData? data;

  StockbitProductDetail({this.message, this.data});

  StockbitProductDetail.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = (json['data'] != null) ? StockbitProductDetailData.fromJson(json['data']) : null;
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

class StockbitProductDetailData {
  num? id;
  String? symbol;
  String? name;
  num? price;
  num? change;
  num? percent;
  String? priceUpdatedAt;
  String? status;
  String? type;
  String? subSector;
  bool? isAcceleration;
  bool? isBuyable;
  bool? isSellable;
  bool? isStockEIpo;
  num? isSharia;
  String? ipoDate;
  StockbitProductDetailDataMarketHours? marketHours;
  List<StockbitProductDetailDataNotations>? notations;
  StockbitProductDetailDataCorpAction? corpAction;
  StockbitProductDetailDataKeyStats? keyStats;
  StockbitProductDetailDataAnalystRating? analystRating;
  StockbitProductDetailDataCompanyAbout? companyAbout;
  String? iconUrl;

  StockbitProductDetailData({this.id, this.symbol, this.name, this.price, this.change, this.percent, this.priceUpdatedAt, this.status, this.type, this.subSector, this.isAcceleration, this.isBuyable, this.isSellable, this.isStockEIpo, this.isSharia, this.ipoDate, this.marketHours, this.notations, this.corpAction, this.keyStats, this.analystRating, this.companyAbout, this.iconUrl, });

  StockbitProductDetailData.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    symbol = json['symbol'] ?? '';
    name = json['name'] ?? '';
    price = json['price'] ?? 0;
    change = json['change'] ?? 0;
    percent = json['percent'] ?? 0;
    priceUpdatedAt = json['price_updated_at'] ?? '';
    status = json['status'] ?? '';
    type = json['type'] ?? '';
    subSector = json['sub_sector'] ?? '';
    isAcceleration = json['is_acceleration'] ?? false;
    isBuyable = json['is_buyable'] ?? false;
    isSellable = json['is_sellable'] ?? false;
    isStockEIpo = json['is_stock_e_ipo'] ?? false;
    isSharia = json['is_sharia'] ?? 0;
    ipoDate = json['ipo_date'] ?? '';
    marketHours = (json['market_hours'] != null) ? StockbitProductDetailDataMarketHours.fromJson(json['market_hours']) : null;
    notations = json['notations'] == null ? null : (json['notations'] as List).map((e) => StockbitProductDetailDataNotations.fromJson(e)).toList();
    corpAction = (json['corp_action'] != null) ? StockbitProductDetailDataCorpAction.fromJson(json['corp_action']) : null;
    keyStats = (json['key_stats'] != null) ? StockbitProductDetailDataKeyStats.fromJson(json['key_stats']) : null;
    analystRating = (json['analyst_rating'] != null) ? StockbitProductDetailDataAnalystRating.fromJson(json['analyst_rating']) : null;
    companyAbout = (json['company_about'] != null) ? StockbitProductDetailDataCompanyAbout.fromJson(json['company_about']) : null;
    iconUrl = json['icon_url'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['symbol'] = symbol;
    data['name'] = name;
    data['price'] = price;
    data['change'] = change;
    data['percent'] = percent;
    data['price_updated_at'] = priceUpdatedAt;
    data['status'] = status;
    data['type'] = type;
    data['sub_sector'] = subSector;
    data['is_acceleration'] = isAcceleration;
    data['is_buyable'] = isBuyable;
    data['is_sellable'] = isSellable;
    data['is_stock_e_ipo'] = isStockEIpo;
    data['is_sharia'] = isSharia;
    data['ipo_date'] = ipoDate;
    if (marketHours != null) {
      data['market_hours'] = marketHours!.toJson();
    }
    if (notations != null) {
      data['notations'] = notations?.map((e) => e.toJson()).toList();
    }
    if (corpAction != null) {
      data['corp_action'] = corpAction!.toJson();
    }
    if (keyStats != null) {
      data['key_stats'] = keyStats!.toJson();
    }
    if (analystRating != null) {
      data['analyst_rating'] = analystRating!.toJson();
    }
    if (companyAbout != null) {
      data['company_about'] = companyAbout!.toJson();
    }
    data['icon_url'] = iconUrl;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class StockbitProductDetailDataMarketHours {
  String? status;
  String? timeLeft;
  String? formattedTimeLeft;

  StockbitProductDetailDataMarketHours({this.status, this.timeLeft, this.formattedTimeLeft});

  StockbitProductDetailDataMarketHours.fromJson(Map<String, dynamic> json) {
    status = json['status'] ?? '';
    timeLeft = json['time_left'] ?? '';
    formattedTimeLeft = json['formatted_time_left'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['status'] = status;
    data['time_left'] = timeLeft;
    data['formatted_time_left'] = formattedTimeLeft;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class StockbitProductDetailDataNotations {
  String? notationCode;
  String? notationDesc;
  StockbitProductDetailDataNotationsIconUrl? iconUrl;

  StockbitProductDetailDataNotations({this.notationCode, this.notationDesc, this.iconUrl});

  StockbitProductDetailDataNotations.fromJson(Map<String, dynamic> json) {
    notationCode = json['notation_code'] ?? '';
    notationDesc = json['notation_desc'] ?? '';
    iconUrl = (json['icon_url'] != null) ? StockbitProductDetailDataNotationsIconUrl.fromJson(json['icon_url']) : null;
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

class StockbitProductDetailDataNotationsIconUrl {
  String? lightMode;
  String? darkMode;

  StockbitProductDetailDataNotationsIconUrl({this.lightMode, this.darkMode});

  StockbitProductDetailDataNotationsIconUrl.fromJson(Map<String, dynamic> json) {
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

class StockbitProductDetailDataCorpAction {
  bool? active;
  String? type;
  StockbitProductDetailDataCorpActionInfo? info;

  StockbitProductDetailDataCorpAction({this.active, this.type, this.info});

  StockbitProductDetailDataCorpAction.fromJson(Map<String, dynamic> json) {
    active = json['active'] ?? false;
    type = json['type'] ?? '';
    info = (json['info'] != null) ? StockbitProductDetailDataCorpActionInfo.fromJson(json['info']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['active'] = active;
    data['type'] = type;
    if (info != null) {
      data['info'] = info!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class StockbitProductDetailDataCorpActionInfo {
  String? companyId;
  String? companySymbol;
  String? dividendCreated;
  String? dividendCumdate;
  String? dividendDatahash;
  String? dividendExdate;
  String? dividendId;
  String? dividendIqpId;
  String? dividendLastupdate;
  num? dividendLock;
  String? dividendPaydate;
  String? dividendRecdate;
  String? dividendValue;
  String? lastprice;
  String? eventNote;
  String? dividendValueFormatted;
  String? lastpriceFormatted;
  String? dividendCurrency;

  StockbitProductDetailDataCorpActionInfo({this.companyId, this.companySymbol, this.dividendCreated, this.dividendCumdate, this.dividendDatahash, this.dividendExdate, this.dividendId, this.dividendIqpId, this.dividendLastupdate, this.dividendLock, this.dividendPaydate, this.dividendRecdate, this.dividendValue, this.lastprice, this.eventNote, this.dividendValueFormatted, this.lastpriceFormatted, this.dividendCurrency, });

  StockbitProductDetailDataCorpActionInfo.fromJson(Map<String, dynamic> json) {
    companyId = json['company_id'] ?? '';
    companySymbol = json['company_symbol'] ?? '';
    dividendCreated = json['dividend_created'] ?? '';
    dividendCumdate = json['dividend_cumdate'] ?? '';
    dividendDatahash = json['dividend_datahash'] ?? '';
    dividendExdate = json['dividend_exdate'] ?? '';
    dividendId = json['dividend_id'] ?? '';
    dividendIqpId = json['dividend_iqp_id'] ?? '';
    dividendLastupdate = json['dividend_lastupdate'] ?? '';
    dividendLock = json['dividend_lock'] ?? 0;
    dividendPaydate = json['dividend_paydate'] ?? '';
    dividendRecdate = json['dividend_recdate'] ?? '';
    dividendValue = json['dividend_value'] ?? '';
    lastprice = json['lastprice'] ?? '';
    eventNote = json['event_note'] ?? '';
    dividendValueFormatted = json['dividend_value_formatted'] ?? '';
    lastpriceFormatted = json['lastprice_formatted'] ?? '';
    dividendCurrency = json['dividend_currency'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['company_id'] = companyId;
    data['company_symbol'] = companySymbol;
    data['dividend_created'] = dividendCreated;
    data['dividend_cumdate'] = dividendCumdate;
    data['dividend_datahash'] = dividendDatahash;
    data['dividend_exdate'] = dividendExdate;
    data['dividend_id'] = dividendId;
    data['dividend_iqp_id'] = dividendIqpId;
    data['dividend_lastupdate'] = dividendLastupdate;
    data['dividend_lock'] = dividendLock;
    data['dividend_paydate'] = dividendPaydate;
    data['dividend_recdate'] = dividendRecdate;
    data['dividend_value'] = dividendValue;
    data['lastprice'] = lastprice;
    data['event_note'] = eventNote;
    data['dividend_value_formatted'] = dividendValueFormatted;
    data['lastprice_formatted'] = lastpriceFormatted;
    data['dividend_currency'] = dividendCurrency;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class StockbitProductDetailDataKeyStats {
  num? open;
  num? high;
  num? low;
  String? peAnnualised;
  String? peTtm;
  String? dividendTtm;
  String? volume;
  String? avgVolume;
  String? marketCap;
  String? pbvRatio;
  String? dividendYield;
  String? netProfitMargin;
  String? debtToEquity;
  String? totalDebt;
  String? totalCash;

  StockbitProductDetailDataKeyStats({this.open, this.high, this.low, this.peAnnualised, this.peTtm, this.dividendTtm, this.volume, this.avgVolume, this.marketCap, this.pbvRatio, this.dividendYield, this.netProfitMargin, this.debtToEquity, this.totalDebt, this.totalCash});

  StockbitProductDetailDataKeyStats.fromJson(Map<String, dynamic> json) {
    open = json['open'] ?? 0;
    high = json['high'] ?? 0;
    low = json['low'] ?? 0;
    peAnnualised = json['pe_annualised'] ?? '';
    peTtm = json['pe_ttm'] ?? '';
    dividendTtm = json['dividend_ttm'] ?? '';
    volume = json['volume'] ?? '';
    avgVolume = json['avg_volume'] ?? '';
    marketCap = json['market_cap'] ?? '';
    pbvRatio = json['pbv_ratio'] ?? '';
    dividendYield = json['dividend_yield'] ?? '';
    netProfitMargin = json['net_profit_margin'] ?? '';
    debtToEquity = json['debt_to_equity'] ?? '';
    totalDebt = json['total_debt'] ?? '';
    totalCash = json['total_cash'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['open'] = open;
    data['high'] = high;
    data['low'] = low;
    data['pe_annualised'] = peAnnualised;
    data['pe_ttm'] = peTtm;
    data['dividend_ttm'] = dividendTtm;
    data['volume'] = volume;
    data['avg_volume'] = avgVolume;
    data['market_cap'] = marketCap;
    data['pbv_ratio'] = pbvRatio;
    data['dividend_yield'] = dividendYield;
    data['net_profit_margin'] = netProfitMargin;
    data['debt_to_equity'] = debtToEquity;
    data['total_debt'] = totalDebt;
    data['total_cash'] = totalCash;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class StockbitProductDetailDataAnalystRating {
  StockbitProductDetailDataAnalystRatingPriceTarget? priceTarget;
  String? recommendation;
  num? totalBuy;
  num? totalSell;
  num? totalHold;
  num? totalAnalyst;
  String? lastUpdated;

  StockbitProductDetailDataAnalystRating({this.priceTarget, this.recommendation, this.totalBuy, this.totalSell, this.totalHold, this.totalAnalyst, this.lastUpdated});

  StockbitProductDetailDataAnalystRating.fromJson(Map<String, dynamic> json) {
    priceTarget = (json['price_target'] != null) ? StockbitProductDetailDataAnalystRatingPriceTarget.fromJson(json['price_target']) : null;
    recommendation = json['recommendation'] ?? '';
    totalBuy = json['total_buy'] ?? 0;
    totalSell = json['total_sell'] ?? 0;
    totalHold = json['total_hold'] ?? 0;
    totalAnalyst = json['total_analyst'] ?? 0;
    lastUpdated = json['last_updated'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (priceTarget != null) {
      data['price_target'] = priceTarget!.toJson();
    }
    data['recommendation'] = recommendation;
    data['total_buy'] = totalBuy;
    data['total_sell'] = totalSell;
    data['total_hold'] = totalHold;
    data['total_analyst'] = totalAnalyst;
    data['last_updated'] = lastUpdated;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class StockbitProductDetailDataAnalystRatingPriceTarget {
  num? bestTarget;
  num? bestLowTarget;
  num? bestHighTarget;
  num? currentPrice;

  StockbitProductDetailDataAnalystRatingPriceTarget({this.bestTarget, this.bestLowTarget, this.bestHighTarget, this.currentPrice});

  StockbitProductDetailDataAnalystRatingPriceTarget.fromJson(Map<String, dynamic> json) {
    bestTarget = json['best_target'] ?? 0;
    bestLowTarget = json['best_low_target'] ?? 0;
    bestHighTarget = json['best_high_target'] ?? 0;
    currentPrice = json['current_price'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['best_target'] = bestTarget;
    data['best_low_target'] = bestLowTarget;
    data['best_high_target'] = bestHighTarget;
    data['current_price'] = currentPrice;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class StockbitProductDetailDataCompanyAbout {
  String? background;

  StockbitProductDetailDataCompanyAbout({this.background});

  StockbitProductDetailDataCompanyAbout.fromJson(Map<String, dynamic> json) {
    background = json['background'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['background'] = background;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
