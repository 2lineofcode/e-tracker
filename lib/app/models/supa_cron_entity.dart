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

  SupaCron({
    this.jobid,
    this.schedule,
    this.command,
    this.nodename,
    this.nodeport,
    this.database,
    this.username,
    this.active,
    this.jobname,
  });

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
  }) => SupaCron(
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

class SupaCronSchedule {
  const SupaCronSchedule({
    required this.dueDay,
    required this.monthField,
    required this.repeatMonths,
  });

  final int dueDay;
  final String monthField;
  final int repeatMonths;

  String get label {
    return switch (repeatMonths) {
      1 => 'Every month',
      12 => 'Every year',
      _ => 'Every $repeatMonths months',
    };
  }

  DateTime nextRun({DateTime? from}) {
    final now = from ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var offset = 0; offset <= 36; offset++) {
      final cursor = DateTime(now.year, now.month + offset, 1);
      if (!_isAllowedMonth(cursor.month)) continue;

      final maxDay = DateTime(cursor.year, cursor.month + 1, 0).day;
      final candidate = DateTime(
        cursor.year,
        cursor.month,
        dueDay.clamp(1, maxDay),
      );
      if (!candidate.isBefore(today)) return candidate;
    }

    return today;
  }

  int remainingDays({DateTime? from}) {
    final now = from ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return nextRun(from: now).difference(today).inDays;
  }

  bool _isAllowedMonth(int month) {
    if (monthField == '*') return true;
    if (monthField.startsWith('*/')) {
      final interval = int.tryParse(monthField.substring(2)) ?? repeatMonths;
      return ((month - 1) % interval) == 0;
    }

    final months = monthField
        .split(',')
        .map((value) => int.tryParse(value.trim()))
        .whereType<int>()
        .toSet();
    if (months.isEmpty) return true;
    return months.contains(month);
  }

  static SupaCronSchedule? parse(String? schedule) {
    final match = RegExp(
      r'^0\s+0\s+(\d{1,2})\s+([^\s]+)\s+\*$',
    ).firstMatch(schedule ?? '');
    if (match == null) return null;

    final dueDay = int.tryParse(match.group(1) ?? '');
    if (dueDay == null) return null;

    final monthField = match.group(2) ?? '*';
    return SupaCronSchedule(
      dueDay: dueDay,
      monthField: monthField,
      repeatMonths: _repeatMonthsFromField(monthField),
    );
  }

  static int _repeatMonthsFromField(String monthField) {
    if (monthField == '*') return 1;
    if (monthField.startsWith('*/')) {
      return int.tryParse(monthField.substring(2)) ?? 1;
    }

    final months =
        monthField
            .split(',')
            .map((value) => int.tryParse(value.trim()))
            .whereType<int>()
            .toList()
          ..sort();
    if (months.length < 2) return 12;
    return months[1] - months[0];
  }
}
