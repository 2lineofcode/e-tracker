import 'dart:convert';

/// * 
/// * JSON Source: {"message":"Berhasil menampilkan data Portfolio Allocation","data":[{"name":"Pasar Uang","items":2,"totalporto":7522475.640000001,"current":"0.05","profitloss":376978}]}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// * 
class BibitPerformanceAllocation {
  String? message;
  List<BibitPerformanceAllocationData>? data;

  BibitPerformanceAllocation({this.message, this.data});

  BibitPerformanceAllocation.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = json['data'] == null ? null : (json['data'] as List).map((e) => BibitPerformanceAllocationData.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data?.map((e) => e.toJson()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitPerformanceAllocationData {
  String? name;
  int? items;
  double? totalporto;
  String? current;
  int? profitloss;

  BibitPerformanceAllocationData({this.name, this.items, this.totalporto, this.current, this.profitloss});

  BibitPerformanceAllocationData.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    items = json['items'] ?? 0;
    totalporto = json['totalporto'] ?? 0.0;
    current = json['current'] ?? '';
    profitloss = json['profitloss'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['items'] = items;
    data['totalporto'] = totalporto;
    data['current'] = current;
    data['profitloss'] = profitloss;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
