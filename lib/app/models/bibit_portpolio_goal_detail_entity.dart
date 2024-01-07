import 'dart:convert';

class BibitPortpolioGoalDetail {
  String? message;
  BibitPortpolioGoalDetailData? data;

  BibitPortpolioGoalDetail({this.message, this.data});

  BibitPortpolioGoalDetail.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = (json['data'] != null) ? BibitPortpolioGoalDetailData.fromJson(json['data']) : null;
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

class BibitPortpolioGoalDetailData {
  String? created;
  num? id;
  String? startdate;
  num? startamount;
  String? targetdate;
  num? targetamount;
  num? targetamountThismonth;
  num? recurringAmount;
  num? isRecurringAmountDeviated;
  BibitPortpolioGoalDetailDataPortfolio? portfolio;
  num? marketvalue;
  num? totalporto;
  num? totalpending;

  BibitPortpolioGoalDetailData({this.created, this.id, this.startdate, this.startamount, this.targetdate, this.targetamount, this.targetamountThismonth, this.recurringAmount, this.isRecurringAmountDeviated, this.portfolio, this.marketvalue, this.totalporto, this.totalpending});

  BibitPortpolioGoalDetailData.fromJson(Map<String, dynamic> json) {
    created = json['created'] ?? '';
    id = json['id'] ?? 0;
    startdate = json['startdate'] ?? '';
    startamount = json['startamount'] ?? 0;
    targetdate = json['targetdate'] ?? '';
    targetamount = json['targetamount'] ?? 0;
    targetamountThismonth = json['targetamount_thismonth'] ?? 0;
    recurringAmount = json['recurring_amount'] ?? 0;
    isRecurringAmountDeviated = json['is_recurring_amount_deviated'] ?? 0;
    portfolio = (json['portfolio'] != null) ? BibitPortpolioGoalDetailDataPortfolio.fromJson(json['portfolio']) : null;
    marketvalue = json['marketvalue'] ?? 0.0;
    totalporto = json['totalporto'] ?? 0.0;
    totalpending = json['totalpending'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['created'] = created;
    data['id'] = id;
    data['startdate'] = startdate;
    data['startamount'] = startamount;
    data['targetdate'] = targetdate;
    data['targetamount'] = targetamount;
    data['targetamount_thismonth'] = targetamountThismonth;
    data['recurring_amount'] = recurringAmount;
    data['is_recurring_amount_deviated'] = isRecurringAmountDeviated;
    if (portfolio != null) {
      data['portfolio'] = portfolio!.toJson();
    }
    data['marketvalue'] = marketvalue;
    data['totalporto'] = totalporto;
    data['totalpending'] = totalpending;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class BibitPortpolioGoalDetailDataPortfolio {
  String? name;
  num? id;
  num? isRobo;
  num? isGoal;
  String? robocode;
  num? templateid;

  BibitPortpolioGoalDetailDataPortfolio({this.name, this.id, this.isRobo, this.isGoal, this.robocode, this.templateid});

  BibitPortpolioGoalDetailDataPortfolio.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    id = json['id'] ?? 0;
    isRobo = json['is_robo'] ?? 0;
    isGoal = json['is_goal'] ?? 0;
    robocode = json['robocode'] ?? '';
    templateid = json['templateid'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['id'] = id;
    data['is_robo'] = isRobo;
    data['is_goal'] = isGoal;
    data['robocode'] = robocode;
    data['templateid'] = templateid;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
