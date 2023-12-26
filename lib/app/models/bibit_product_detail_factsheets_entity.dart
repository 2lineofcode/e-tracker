import 'dart:convert';

/// * 
/// * JSON Source: {"message":"Successfully retrieve data","data":[{"name":"BNI-AM INDEKS IDX 30_MEI_2019.pdf","file":"https://assets.bibit.id/factsheets/BNI-AMINDEKSIDX30_MEI_2019.pdf","date":"2019-05-30"}]}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// * 
class BibitProductDetailFactsheets {
  String? message;
  List<BibitProductDetailFactsheetsData>? data;

  BibitProductDetailFactsheets({this.message, this.data});

  BibitProductDetailFactsheets.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = json['data'] == null ? null : (json['data'] as List).map((e) => BibitProductDetailFactsheetsData.fromJson(e)).toList();
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

class BibitProductDetailFactsheetsData {
  String? name;
  String? file;
  String? date;

  BibitProductDetailFactsheetsData({this.name, this.file, this.date});

  BibitProductDetailFactsheetsData.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    file = json['file'] ?? '';
    date = json['date'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['file'] = file;
    data['date'] = date;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
