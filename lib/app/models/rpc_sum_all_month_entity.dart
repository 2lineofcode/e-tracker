class RpcSumAllMonthEntity {
  String? period;
  int? total;

  RpcSumAllMonthEntity({this.period, this.total});

  RpcSumAllMonthEntity.fromJson(Map<String, dynamic> json) {
    period = json['period'] ?? '';
    total = json['total'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['period'] = period;
    data['total'] = total;
    return data;
  }
}
