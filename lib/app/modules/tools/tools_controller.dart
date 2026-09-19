import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../core/app_setting.dart';
import '../../helpers/helper_money.dart';
import '../../helpers/helper_toast.dart';
import 'tools_extra.dart';

class ToolsController extends GetxController {
  ToolsController({GetStorage? storage}) : _storage = storage ?? pref;

  static const storageKey = 'tools_inputs';
  final GetStorage _storage;
  late final Map<String, String> _defaults;
  Map<String, String> _lastInputs = {};
  bool _resetting = false;
  final selectedTool = 0.obs;
  var emergencyForm = GlobalKey<FormState>();
  var retirementForm = GlobalKey<FormState>();
  final resultKey = GlobalKey();
  final emergencyExpense = TextEditingController();
  final coverageMonths = TextEditingController(text: '6');
  final emergencySaved = TextEditingController(text: '0');
  final monthlySaving = TextEditingController(text: '0');
  final retirementExpense = TextEditingController();
  final currentAge = TextEditingController(text: '30');
  final retirementAge = TextEditingController(text: '55');
  final retirementYears = TextEditingController(text: '25');
  final retirementSaved = TextEditingController(text: '0');
  final inflation = TextEditingController(text: '3');
  final growthReturn = TextEditingController(text: '0');
  final retirementReturn = TextEditingController(text: '0');
  final extraInputs = <String, TextEditingController>{
    for (final tool in extraTools)
      for (final input in tool.inputs)
        '${tool.id}.${input.key}': TextEditingController(text: input.initial),
  };
  final extraForms = {for (final tool in extraTools) tool.id: GlobalKey<FormState>()};
  final extraResults = <String, List<ToolOutput>>{};
  Map<String, num>? emergencyResult;
  Map<String, num>? retirementResult;

  Map<String, TextEditingController> get inputFields => {
    'emergencyExpense': emergencyExpense,
    'coverageMonths': coverageMonths,
    'emergencySaved': emergencySaved,
    'monthlySaving': monthlySaving,
    'retirementExpense': retirementExpense,
    'currentAge': currentAge,
    'retirementAge': retirementAge,
    'retirementYears': retirementYears,
    'retirementSaved': retirementSaved,
    'inflation': inflation,
    'growthReturn': growthReturn,
    'retirementReturn': retirementReturn,
    ...extraInputs,
  };

  @override
  void onInit() {
    super.onInit();
    _defaults = inputFields.map((key, field) => MapEntry(key, field.text));
    final saved = _storage.read<dynamic>(storageKey);
    for (final entry in inputFields.entries) {
      final value = saved is Map ? saved[entry.key] : null;
      if (value is String) entry.value.text = value;
      entry.value.addListener(saveInputs);
    }
    _lastInputs = inputFields.map((key, field) => MapEntry(key, field.text));
  }

  Future<void> saveInputs() async {
    if (_resetting) return;
    final values = inputFields.map((key, field) => MapEntry(key, field.text));
    if (mapEquals(values, _lastInputs)) return;
    _lastInputs = values;
    try {
      await _storage.write(storageKey, values);
    } catch (_) {
      _lastInputs = {};
      await HelperToast.error('Input Tools gagal disimpan');
    }
  }

  Future<void> resetInputs() async {
    FocusManager.instance.primaryFocus?.unfocus();
    _resetting = true;
    for (final entry in inputFields.entries) {
      entry.value.text = _defaults[entry.key]!;
    }
    emergencyResult = null;
    retirementResult = null;
    extraResults.clear();
    for (final tool in extraTools) {
      extraForms[tool.id] = GlobalKey<FormState>();
    }
    emergencyForm = GlobalKey<FormState>();
    retirementForm = GlobalKey<FormState>();
    _resetting = false;
    update();
    await saveInputs();
  }

  void clearResult(bool retirement) {
    if (retirement) {
      retirementResult = null;
    } else {
      emergencyResult = null;
    }
    update();
  }

  void clearExtraResult(String id) {
    extraResults.remove(id);
    update();
  }

  void calculateExtra(ExtraTool tool) {
    if (extraForms[tool.id]?.currentState?.validate() != true) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final values = <String, num>{};
    for (final input in tool.inputs) {
      final text = extraInputs['${tool.id}.${input.key}']!.text;
      values[input.key] = input.unit == 'money'
          ? text.moneyUnformat()!
          : num.parse(text.replaceAll(',', '.'));
    }
    extraResults[tool.id] = calculateExtraTool(tool, values);
    update();
  }

  void calculateEmergency() {
    if (!emergencyForm.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();
    emergencyResult = calculateEmergencyFund(
      expense: emergencyExpense.text.moneyUnformat()!,
      months: int.parse(coverageMonths.text),
      saved: emergencySaved.text.moneyUnformat()!,
      monthlySaving: monthlySaving.text.moneyUnformat()!,
    );
    update();
  }

  void calculateRetirement() {
    if (!retirementForm.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();
    retirementResult = calculateRetirementFund(
      expense: retirementExpense.text.moneyUnformat()!,
      yearsUntilRetirement: int.parse(retirementAge.text) - int.parse(currentAge.text),
      retirementYears: int.parse(retirementYears.text),
      saved: retirementSaved.text.moneyUnformat()!,
      inflation: double.parse(inflation.text.replaceAll(',', '.')) / 100,
      growthReturn: double.parse(growthReturn.text.replaceAll(',', '.')) / 100,
      retirementReturn: double.parse(retirementReturn.text.replaceAll(',', '.')) / 100,
    );
    update();
  }

  @override
  void onClose() {
    for (final field in inputFields.values) {
      field.removeListener(saveInputs);
      field.dispose();
    }
    super.onClose();
  }
}

Map<String, num> calculateEmergencyFund({
  required num expense,
  required int months,
  required num saved,
  required num monthlySaving,
}) {
  if (!expense.isFinite || expense <= 0 || expense > 999999999999 || months < 1 || months > 120 ||
      !saved.isFinite || saved < 0 || saved > 999999999999 ||
      !monthlySaving.isFinite || monthlySaving < 0 || monthlySaving > 999999999999) {
    throw ArgumentError('Invalid emergency fund inputs');
  }
  final target = expense * months;
  final remaining = math.max(0, target - saved);
  return {
    'target': target,
    'remaining': remaining,
    'coverage': saved / expense,
    'progress': (saved / target).clamp(0, 1),
    if (remaining == 0) 'months': 0
    else if (monthlySaving > 0) 'months': (remaining / monthlySaving).ceil(),
  };
}

Map<String, num> calculateRetirementFund({
  required num expense,
  required int yearsUntilRetirement,
  required int retirementYears,
  required num saved,
  required double inflation,
  double growthReturn = 0,
  double retirementReturn = 0,
}) {
  if (!expense.isFinite || expense <= 0 || expense > 999999999999 ||
      yearsUntilRetirement < 0 || yearsUntilRetirement > 100 ||
      retirementYears < 1 || retirementYears > 100 ||
      !saved.isFinite || saved < 0 || saved > 999999999999 ||
      !inflation.isFinite || inflation < 0 || inflation > 0.2 ||
      !growthReturn.isFinite || growthReturn < -0.2 || growthReturn > 0.2 ||
      !retirementReturn.isFinite || retirementReturn < -0.2 || retirementReturn > 0.2) {
    throw ArgumentError('Invalid retirement fund inputs');
  }
  final monthlyExpense = expense * math.pow(1 + inflation, yearsUntilRetirement);
  final retirementGrowth = math.pow(1 + retirementReturn, 1 / 12);
  num target = 0;
  // Withdraw at the start of each month; expenses increase once a year.
  for (var month = 0; month < retirementYears * 12; month++) {
    target += monthlyExpense * math.pow(1 + inflation, month ~/ 12) /
        math.pow(retirementGrowth, month);
  }
  final projectedSaved = saved * math.pow(1 + growthReturn, yearsUntilRetirement);
  final remaining = math.max(0, target - projectedSaved);
  final savingMonths = yearsUntilRetirement * 12;
  final monthlyGrowth = math.pow(1 + growthReturn, 1 / 12);
  num contributionFactor = 0;
  // Fixed contributions at month-end, using an effective annual return.
  for (var month = 0; month < savingMonths; month++) {
    contributionFactor = contributionFactor * monthlyGrowth + 1;
  }
  return {
    'expense': monthlyExpense,
    'target': target,
    'projectedSaved': projectedSaved,
    'remaining': remaining,
    'progress': (projectedSaved / target).clamp(0, 1),
    if (remaining == 0) 'monthlySaving': 0
    else if (savingMonths > 0) 'monthlySaving': (remaining / contributionFactor).ceilToDouble(),
  };
}
