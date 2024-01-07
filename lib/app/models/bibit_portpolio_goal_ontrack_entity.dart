import 'dart:convert';

class BibitPortpolioGoalOntrack {
  String? message;
  BibitPortpolioGoalOntrackData? data;

  BibitPortpolioGoalOntrack({this.message, this.data});

  BibitPortpolioGoalOntrack.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = (json['data'] != null) ? BibitPortpolioGoalOntrackData.fromJson(json['data']) : null;
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

class BibitPortpolioGoalOntrackData {
  num? isShared;
  num? ontrack;
  num? targetAmountOnTrack;
  BibitPortpolioGoalOntrackDataOutput? output;

  BibitPortpolioGoalOntrackData({this.isShared, this.ontrack, this.targetAmountOnTrack, this.output});

  BibitPortpolioGoalOntrackData.fromJson(Map<String, dynamic> json) {
    isShared = json['is_shared'] ?? 0;
    ontrack = json['ontrack'] ?? 0;
    targetAmountOnTrack = json['target_amount_on_track'] ?? 0;
    output = (json['output'] != null) ? BibitPortpolioGoalOntrackDataOutput.fromJson(json['output']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['is_shared'] = isShared;
    data['ontrack'] = ontrack;
    data['target_amount_on_track'] = targetAmountOnTrack;
    if (output != null) {
      data['output'] = output!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitPortpolioGoalOntrackDataOutput {
  BibitPortpolioGoalOntrackDataOutputProgress? progress;
  BibitPortpolioGoalOntrackDataOutputGoal? goal;

  BibitPortpolioGoalOntrackDataOutput({this.progress, this.goal});

  BibitPortpolioGoalOntrackDataOutput.fromJson(Map<String, dynamic> json) {
    progress = (json['progress'] != null) ? BibitPortpolioGoalOntrackDataOutputProgress.fromJson(json['progress']) : null;
    goal = (json['goal'] != null) ? BibitPortpolioGoalOntrackDataOutputGoal.fromJson(json['goal']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (progress != null) {
      data['progress'] = progress!.toJson();
    }
    if (goal != null) {
      data['goal'] = goal!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitPortpolioGoalOntrackDataOutputProgress {
  String? date;
  num? value;

  BibitPortpolioGoalOntrackDataOutputProgress({this.date, this.value});

  BibitPortpolioGoalOntrackDataOutputProgress.fromJson(Map<String, dynamic> json) {
    date = json['date'] ?? '';
    value = json['value'] ?? 0.0;
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

class BibitPortpolioGoalOntrackDataOutputGoal {
  num? value;
  String? date;

  BibitPortpolioGoalOntrackDataOutputGoal({this.value, this.date});

  BibitPortpolioGoalOntrackDataOutputGoal.fromJson(Map<String, dynamic> json) {
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
