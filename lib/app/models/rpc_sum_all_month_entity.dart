class RpcSumAllMonth {
  String? period;
  int? total;

  RpcSumAllMonth({this.period, this.total});

  RpcSumAllMonth.fromJson(Map<String, dynamic> json) {
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
