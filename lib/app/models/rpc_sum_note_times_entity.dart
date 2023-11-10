class RpcSumNoteTimesEntity {
  String? period;
  String? note;
  int? times;
  int? total;

  RpcSumNoteTimesEntity({this.period, this.note, this.times, this.total});

  RpcSumNoteTimesEntity.fromJson(Map<String, dynamic> json) {
    period = json['period'];
    note = json['note'];
    times = json['times'];
    total = json['total'];
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
