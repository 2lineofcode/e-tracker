import 'dart:convert';

/// *
/// * JSON Source: {"message":"Berhasil menampilkan data berita Saham","data":[{"id":13402333,"title":"Andre Soelistyo Jual 100 Juta Saham GOTO Buat Bayar Utang","source":"cnbcindonesia.com","source_url":"https://www.cnbcindonesia.com/market/20231228085405-17-500818/andre-soelistyo-jual-100-juta-saham-goto-buat-bayar-utang","created_at":"48 menit yang lalu","image":"https://awsimages.detik.net.id/visual/2022/05/27/ceo-goto-andre-soelistyo-1_169.png?w=715&q=90"}]}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// *
class StockbitNews {
  String? message;
  List<StockbitNewsData>? data;

  StockbitNews({this.message, this.data});

  StockbitNews.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = json['data'] == null ? null : (json['data'] as List).map((e) => StockbitNewsData.fromJson(e)).toList();
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

class StockbitNewsData {
  num? id;
  String? title;
  String? source;
  String? sourceUrl;
  String? createdAt;
  String? image;

  StockbitNewsData({this.id, this.title, this.source, this.sourceUrl, this.createdAt, this.image});

  StockbitNewsData.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    title = json['title'] ?? '';
    source = json['source'] ?? '';
    sourceUrl = json['source_url'] ?? '';
    createdAt = json['created_at'] ?? '';
    image = json['image'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['source'] = source;
    data['source_url'] = sourceUrl;
    data['created_at'] = createdAt;
    data['image'] = image;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
