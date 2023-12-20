import 'dart:convert';

/// *
/// * JSON Source: {"message":"Berhasil menampilkan data Portfolio Performance Chart","data":{"change":40278,"percent":0.0003,"chart":[{"date":1702486800,"formated_date":"2023-12-14","value":145792380.16,"value_invested":143436960}],"xaxisopt":"daily"}}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// *
class BibitPerformanceChart {
  String? message;
  BibitPerformanceChartData? data;

  BibitPerformanceChart({this.message, this.data});

  BibitPerformanceChart.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = (json['data'] != null) ? BibitPerformanceChartData.fromJson(json['data']) : null;
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

class BibitPerformanceChartData {
  num? change;
  num? percent;
  List<BibitPerformanceChartDataChart>? chart;
  String? xaxisopt;

  BibitPerformanceChartData({this.change, this.percent, this.chart, this.xaxisopt});

  BibitPerformanceChartData.fromJson(Map<String, dynamic> json) {
    change = json['change'] ?? 0;
    percent = json['percent'] ?? 0.0;
    chart = json['chart'] == null ? null : (json['chart'] as List).map((e) => BibitPerformanceChartDataChart.fromJson(e)).toList();
    xaxisopt = json['xaxisopt'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['change'] = change;
    data['percent'] = percent;
    if (chart != null) {
      data['chart'] = chart?.map((e) => e.toJson()).toList();
    }
    data['xaxisopt'] = xaxisopt;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitPerformanceChartDataChart {
  num? date;
  String? formatedDate;
  num? value;
  num? valueInvested;

  BibitPerformanceChartDataChart({this.date, this.formatedDate, this.value, this.valueInvested});

  BibitPerformanceChartDataChart.fromJson(Map<String, dynamic> json) {
    date = json['date'] ?? 0;
    formatedDate = json['formated_date'] ?? '';
    value = json['value'] ?? 0.0;
    valueInvested = json['value_invested'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['formated_date'] = formatedDate;
    data['value'] = value;
    data['value_invested'] = valueInvested;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
