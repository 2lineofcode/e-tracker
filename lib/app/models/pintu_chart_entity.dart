import 'dart:convert';

/// * 
/// * JSON Source: {"code":"success","message":"","payload":{"chart":[{"pair":"eth/idr","open":"36133217","high":"36153784","low":"36106036","close":"36110164","block":1704048300}]}}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// * 
class PintuChart {
  String? code;
  String? message;
  PintuChartPayload? payload;

  PintuChart({this.code, this.message, this.payload});

  PintuChart.fromJson(Map<String, dynamic> json) {
    code = json['code'] ?? '';
    message = json['message'] ?? '';
    payload = (json['payload'] != null) ? PintuChartPayload.fromJson(json['payload']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['code'] = code;
    data['message'] = message;
    if (payload != null) {
      data['payload'] = payload!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class PintuChartPayload {
  List<PintuChartPayloadChart>? chart;

  PintuChartPayload({this.chart});

  PintuChartPayload.fromJson(Map<String, dynamic> json) {
    chart = json['chart'] == null ? null : (json['chart'] as List).map((e) => PintuChartPayloadChart.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (chart != null) {
      data['chart'] = chart?.map((e) => e.toJson()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class PintuChartPayloadChart {
  String? pair;
  String? open;
  String? high;
  String? low;
  String? close;
  num? block;

  PintuChartPayloadChart({this.pair, this.open, this.high, this.low, this.close, this.block});

  PintuChartPayloadChart.fromJson(Map<String, dynamic> json) {
    pair = json['pair'] ?? '';
    open = json['open'] ?? '';
    high = json['high'] ?? '';
    low = json['low'] ?? '';
    close = json['close'] ?? '';
    block = json['block'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['pair'] = pair;
    data['open'] = open;
    data['high'] = high;
    data['low'] = low;
    data['close'] = close;
    data['block'] = block;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
