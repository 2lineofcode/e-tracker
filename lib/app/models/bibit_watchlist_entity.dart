class BibitWatchlist {
  String? message;
  List<BibitWatchlistData>? data;
  BibitWatchlistMeta? meta;

  BibitWatchlist({this.message, this.data, this.meta});

  BibitWatchlist.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <BibitWatchlistData>[];
      json['data'].forEach((v) {
        data!.add(BibitWatchlistData.fromJson(v));
      });
    }
    meta = json['meta'] != null ? BibitWatchlistMeta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    return data;
  }
}

class BibitWatchlistData {
  int? id;
  String? name;
  String? symbol;
  String? type;
  int? instrumentGroup;
  int? isSharia;
  InvestmentManager? investmentManager;
  double? xreturn;
  int? price;
  double? percent;
  String? iconUrl;
  List<Notations>? notations;
  String? status;

  BibitWatchlistData(
      {this.id, this.name, this.symbol, this.type, this.instrumentGroup, this.isSharia, this.investmentManager, this.xreturn, this.price, this.percent, this.iconUrl, this.notations, this.status});

  BibitWatchlistData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    symbol = json['symbol'];
    type = json['type'];
    instrumentGroup = json['instrument_group'];
    isSharia = json['is_sharia'];
    investmentManager = json['investment_manager'] != null ? InvestmentManager.fromJson(json['investment_manager']) : null;
    xreturn = json['return'];
    price = json['price'];
    percent = json['percent'];
    iconUrl = json['icon_url'];
    if (json['notations'] != null) {
      notations = <Notations>[];
      json['notations'].forEach((v) {
        notations!.add(Notations.fromJson(v));
      });
    }
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['symbol'] = symbol;
    data['type'] = type;
    data['instrument_group'] = instrumentGroup;
    data['is_sharia'] = isSharia;
    if (investmentManager != null) {
      data['investment_manager'] = investmentManager!.toJson();
    }
    data['return'] = xreturn;
    data['price'] = price;
    data['percent'] = percent;
    data['icon_url'] = iconUrl;
    if (notations != null) {
      data['notations'] = notations!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    return data;
  }
}

class InvestmentManager {
  String? ojkCode;

  InvestmentManager({this.ojkCode});

  InvestmentManager.fromJson(Map<String, dynamic> json) {
    ojkCode = json['ojk_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ojk_code'] = ojkCode;
    return data;
  }
}

class Notations {
  String? notationCode;
  String? notationDesc;
  IconUrl? iconUrl;

  Notations({this.notationCode, this.notationDesc, this.iconUrl});

  Notations.fromJson(Map<String, dynamic> json) {
    notationCode = json['notation_code'];
    notationDesc = json['notation_desc'];
    iconUrl = json['icon_url'] != null ? IconUrl.fromJson(json['icon_url']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['notation_code'] = notationCode;
    data['notation_desc'] = notationDesc;
    if (iconUrl != null) {
      data['icon_url'] = iconUrl!.toJson();
    }
    return data;
  }
}

class IconUrl {
  String? lightMode;
  String? darkMode;

  IconUrl({this.lightMode, this.darkMode});

  IconUrl.fromJson(Map<String, dynamic> json) {
    lightMode = json['light_mode'];
    darkMode = json['dark_mode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['light_mode'] = lightMode;
    data['dark_mode'] = darkMode;
    return data;
  }
}

class BibitWatchlistMeta {
  int? maxPage;

  BibitWatchlistMeta({this.maxPage});

  BibitWatchlistMeta.fromJson(Map<String, dynamic> json) {
    maxPage = json['max_page'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['max_page'] = maxPage;
    return data;
  }
}
