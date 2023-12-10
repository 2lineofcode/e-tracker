class BibitChartEntity {
  String? message;
  BibitChartData? data;

  BibitChartEntity({this.message, this.data});

  BibitChartEntity.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? BibitChartData.fromJson(json['data']) : null;
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

class BibitChartData {
  num? cagr;
  num? change;
  num? percentage;
  num? previous;
  num? latest;
  List<BibitChartDataPrices>? prices;
  String? xaxisopt;

  BibitChartData({this.cagr, this.change, this.percentage, this.previous, this.latest, this.prices, this.xaxisopt});

  BibitChartData.fromJson(Map<String, dynamic> json) {
    cagr = json['cagr'];
    change = json['change'];
    percentage = json['percentage'];
    previous = json['previous'];
    latest = json['latest'];
    if (json['prices'] != null) {
      prices = <BibitChartDataPrices>[];
      json['prices'].forEach((v) {
        prices!.add(BibitChartDataPrices.fromJson(v));
      });
    }
    xaxisopt = json['xaxisopt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cagr'] = cagr;
    data['change'] = change;
    data['percentage'] = percentage;
    data['previous'] = previous;
    data['latest'] = latest;
    if (prices != null) {
      data['prices'] = prices!.map((v) => v.toJson()).toList();
    }
    data['xaxisopt'] = xaxisopt;
    return data;
  }
}

class BibitChartDataPrices {
  String? date;
  String? formattedDate;
  String? xlabel;
  String? value;
  String? percentage;
  num? change;

  BibitChartDataPrices({this.date, this.formattedDate, this.xlabel, this.value, this.percentage, this.change});

  BibitChartDataPrices.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    formattedDate = json['formatted_date'];
    xlabel = json['xlabel'];
    value = json['value'];
    percentage = json['percentage'];
    change = json['change'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['formatted_date'] = formattedDate;
    data['xlabel'] = xlabel;
    data['value'] = value;
    data['percentage'] = percentage;
    data['change'] = change;
    return data;
  }
}
