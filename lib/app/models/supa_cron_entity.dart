import 'dart:convert';

/// *
/// * JSON Source: [{"jobid":12,"schedule":"0 0 7 * *","command":" insert into expense (note, category_name, amount, date, user_id) values ('Tagihan Indihome', 'Bill', 250000, current_date, '25aa9f27-18cb-407d-9141-ffab6a50cab8') ","nodename":"localhost","nodeport":5432,"database":"postgres","username":"postgres","active":true,"jobname":"indihome"}]
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// *
class SupaCron {
  num? jobid;
  String? schedule;
  String? command;
  String? nodename;
  num? nodeport;
  String? database;
  String? username;
  bool? active;
  String? jobname;

  SupaCron({this.jobid, this.schedule, this.command, this.nodename, this.nodeport, this.database, this.username, this.active, this.jobname});

  SupaCron.fromJson(Map<String, dynamic> json) {
    jobid = json['jobid'] ?? 0;
    schedule = json['schedule'] ?? '';
    command = json['command'] ?? '';
    nodename = json['nodename'] ?? '';
    nodeport = json['nodeport'] ?? 0;
    database = json['database'] ?? '';
    username = json['username'] ?? '';
    active = json['active'] ?? false;
    jobname = json['jobname'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['jobid'] = jobid;
    data['schedule'] = schedule;
    data['command'] = command;
    data['nodename'] = nodename;
    data['nodeport'] = nodeport;
    data['database'] = database;
    data['username'] = username;
    data['active'] = active;
    data['jobname'] = jobname;
    return data;
  }

  static List<SupaCron> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => SupaCron.fromJson(map)).toList();
  }

  SupaCron copyWith({
    num? jobid,
    String? schedule,
    String? command,
    String? nodename,
    num? nodeport,
    String? database,
    String? username,
    bool? active,
    String? jobname,
  }) =>
      SupaCron(
        jobid: jobid ?? this.jobid,
        schedule: schedule ?? this.schedule,
        command: command ?? this.command,
        nodename: nodename ?? this.nodename,
        nodeport: nodeport ?? this.nodeport,
        database: database ?? this.database,
        username: username ?? this.username,
        active: active ?? this.active,
        jobname: jobname ?? this.jobname,
      );

  @override
  String toString() {
    return jsonEncode(this);
  }
}
