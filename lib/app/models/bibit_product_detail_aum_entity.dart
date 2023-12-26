import 'dart:convert';

/// * 
/// * JSON Source: {"change":-112601142934.26001,"percent":-0.0656101336723468,"chart":[{"date":1667235600,"formated_date":"2022-11-01","xlabel":1667235600,"value":1716215722049.64}],"xaxisopt":"daily"}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// * 
class BibitProductDetailAum {
  num? change;
  num? percent;
  List<BibitProductDetailAumChart>? chart;
  String? xaxisopt;

  BibitProductDetailAum({this.change, this.percent, this.chart, this.xaxisopt});

  BibitProductDetailAum.fromJson(Map<String, dynamic> json) {
    change = json['change'] ?? 0.0;
    percent = json['percent'] ?? 0.0;
    chart = json['chart'] == null ? null : (json['chart'] as List).map((e) => BibitProductDetailAumChart.fromJson(e)).toList();
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

class BibitProductDetailAumChart {
  num? date;
  String? formatedDate;
  num? xlabel;
  num? value;

  BibitProductDetailAumChart({this.date, this.formatedDate, this.xlabel, this.value});

  BibitProductDetailAumChart.fromJson(Map<String, dynamic> json) {
    date = json['date'] ?? 0;
    formatedDate = json['formated_date'] ?? '';
    xlabel = json['xlabel'] ?? 0;
    value = json['value'] ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['formated_date'] = formatedDate;
    data['xlabel'] = xlabel;
    data['value'] = value;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
