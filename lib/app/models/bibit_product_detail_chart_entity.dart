import 'dart:convert';

/// * 
/// * JSON Source: {"change":-109.647310859286,"percent":-0.10868759935696404,"chart":[{"date":1514480400,"formated_date":"2017-12-29","xlabel":1514480400,"value":1008.83,"value_adjusted":1008.83}],"xaxisopt":"monthly"}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// * 
class BibitProductDetailChart {
  num? change;
  num? percent;
  List<BibitProductDetailChartChart>? chart;
  String? xaxisopt;

  BibitProductDetailChart({this.change, this.percent, this.chart, this.xaxisopt});

  BibitProductDetailChart.fromJson(Map<String, dynamic> json) {
    change = json['change'] ?? 0.0;
    percent = json['percent'] ?? 0.0;
    chart = json['chart'] == null ? null : (json['chart'] as List).map((e) => BibitProductDetailChartChart.fromJson(e)).toList();
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

class BibitProductDetailChartChart {
  num? date;
  String? formatedDate;
  num? xlabel;
  num? value;
  num? valueAdjusted;

  BibitProductDetailChartChart({this.date, this.formatedDate, this.xlabel, this.value, this.valueAdjusted});

  BibitProductDetailChartChart.fromJson(Map<String, dynamic> json) {
    date = json['date'] ?? 0;
    formatedDate = json['formated_date'] ?? '';
    xlabel = json['xlabel'] ?? 0;
    value = json['value'] ?? 0.0;
    valueAdjusted = json['value_adjusted'] ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['formated_date'] = formatedDate;
    data['xlabel'] = xlabel;
    data['value'] = value;
    data['value_adjusted'] = valueAdjusted;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
