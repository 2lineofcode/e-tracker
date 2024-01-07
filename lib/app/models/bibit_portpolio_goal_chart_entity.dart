import 'dart:convert';

class BibitPortpolioGoalChart {
  String? message;
  BibitPortpolioGoalChartData? data;

  BibitPortpolioGoalChart({this.message, this.data});

  BibitPortpolioGoalChart.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = (json['data'] != null) ? BibitPortpolioGoalChartData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitPortpolioGoalChartData {
  num? isShared;
  num? targetamount;
  List<BibitPortpolioGoalChartDataGoal>? goal;
  List<BibitPortpolioGoalChartDataProgress>? progress;

  BibitPortpolioGoalChartData({this.isShared, this.targetamount, this.goal, this.progress});

  BibitPortpolioGoalChartData.fromJson(Map<String, dynamic> json) {
    isShared = json['is_shared'] ?? 0;
    targetamount = json['targetamount'] ?? 0;
    goal = json['goal'] == null ? null : (json['goal'] as List).map((e) => BibitPortpolioGoalChartDataGoal.fromJson(e)).toList();
    progress = json['progress'] == null ? null : (json['progress'] as List).map((e) => BibitPortpolioGoalChartDataProgress.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['is_shared'] = isShared;
    data['targetamount'] = targetamount;
    if (goal != null) {
      data['goal'] = goal?.map((e) => e.toJson()).toList();
    }
    if (progress != null) {
      data['progress'] = progress?.map((e) => e.toJson()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitPortpolioGoalChartDataGoal {
  num? value;
  String? date;

  BibitPortpolioGoalChartDataGoal({this.value, this.date});

  BibitPortpolioGoalChartDataGoal.fromJson(Map<String, dynamic> json) {
    value = json['value'] ?? 0;
    date = json['date'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['value'] = value;
    data['date'] = date;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitPortpolioGoalChartDataProgress {
  String? date;
  num? value;

  BibitPortpolioGoalChartDataProgress({this.date, this.value});

  BibitPortpolioGoalChartDataProgress.fromJson(Map<String, dynamic> json) {
    date = json['date'] ?? '';
    value = json['value'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['value'] = value;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
