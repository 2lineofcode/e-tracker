class BibitPerformanceChartEntity {
  String? message;
  BibitPerformanceChartData? data;

  BibitPerformanceChartEntity({this.message, this.data});

  BibitPerformanceChartEntity.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? BibitPerformanceChartData.fromJson(json['data']) : null;
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

class BibitPerformanceChartData {
  num? change;
  num? percent;
  List<Chart>? chart;
  String? xaxisopt;

  BibitPerformanceChartData({this.change, this.percent, this.chart, this.xaxisopt});

  BibitPerformanceChartData.fromJson(Map<String, dynamic> json) {
    change = json['change'];
    percent = json['percent'];
    if (json['chart'] != null) {
      chart = <Chart>[];
      json['chart'].forEach((v) {
        chart!.add(Chart.fromJson(v));
      });
    }
    xaxisopt = json['xaxisopt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['change'] = change;
    data['percent'] = percent;
    if (chart != null) {
      data['chart'] = chart!.map((v) => v.toJson()).toList();
    }
    data['xaxisopt'] = xaxisopt;
    return data;
  }
}

class Chart {
  num? date;
  String? formatedDate;
  num? value;
  num? valueInvested;

  Chart({this.date, this.formatedDate, this.value, this.valueInvested});

  Chart.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    formatedDate = json['formated_date'];
    value = json['value'];
    valueInvested = json['value_invested'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['formated_date'] = formatedDate;
    data['value'] = value;
    data['value_invested'] = valueInvested;
    return data;
  }
}
