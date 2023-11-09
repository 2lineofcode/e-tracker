class RpcSumAllMonthEntity {
  String? period;
  int? total;

  RpcSumAllMonthEntity({
    this.period = '',
    this.total = 0,
  });

  RpcSumAllMonthEntity.fromJson(Map<String, dynamic> json) {
    period = json['period'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['period'] = period;
    data['total'] = total;
    return data;
  }
}
