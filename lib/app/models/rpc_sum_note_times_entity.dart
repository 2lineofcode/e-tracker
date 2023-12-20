class RpcSumNoteTimes {
  String? period;
  String? note;
  int? times;
  int? total;

  RpcSumNoteTimes({this.period, this.note, this.times, this.total});

  RpcSumNoteTimes.fromJson(Map<String, dynamic> json) {
    period = json['period'] ?? '';
    note = json['note'] ?? '';
    times = json['times'] ?? 0;
    total = json['total'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['period'] = period;
    data['note'] = note;
    data['times'] = times;
    data['total'] = total;
    return data;
  }
}
