import 'dart:convert';

/// *
/// * JSON Source: {"message":"Berhasil menampilkan data grafik harga Saham","data":{"cagr":null,"change":-10.05,"percentage":-0.14,"previous":7219.667,"latest":7209.619,"prices":[{"formatted_date":"","value":7219.667}],"xaxisopt":"intraday"}}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// *
class BibitChart {
  String? message;
  BibitChartData? data;

  BibitChart({this.message, this.data});

  BibitChart.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = (json['data'] != null) ? BibitChartData.fromJson(json['data']) : null;
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

class BibitChartData {
  dynamic cagr;
  num? change;
  num? percentage;
  num? previous;
  num? latest;
  List<BibitChartDataPrices>? prices;
  String? xaxisopt;

  BibitChartData({this.cagr, this.change, this.percentage, this.previous, this.latest, this.prices, this.xaxisopt});

  BibitChartData.fromJson(Map<String, dynamic> json) {
    cagr = json['cagr'] ?? '';
    change = json['change'] ?? 0.0;
    percentage = json['percentage'] ?? 0.0;
    previous = json['previous'] ?? 0.0;
    latest = json['latest'] ?? 0.0;
    prices = json['prices'] == null ? null : (json['prices'] as List).map((e) => BibitChartDataPrices.fromJson(e)).toList();
    xaxisopt = json['xaxisopt'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['cagr'] = cagr;
    data['change'] = change;
    data['percentage'] = percentage;
    data['previous'] = previous;
    data['latest'] = latest;
    if (prices != null) {
      data['prices'] = prices?.map((e) => e.toJson()).toList();
    }
    data['xaxisopt'] = xaxisopt;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitChartDataPrices {
  String? formattedDate;
  num? value;

  BibitChartDataPrices({this.formattedDate, this.value});

  BibitChartDataPrices.fromJson(Map<String, dynamic> json) {
    formattedDate = json['formatted_date'] ?? '';
    value = json['value'] ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['formatted_date'] = formattedDate;
    data['value'] = value;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
