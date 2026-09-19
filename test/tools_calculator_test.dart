import 'dart:io';
import 'dart:math' as math;

import 'package:expense_tracker/app/modules/tools/tools_controller.dart';
import 'package:expense_tracker/app/modules/tools/tools_extra.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('tools restore all input drafts and reset only their own storage', () async {
    final directory = await Directory.systemTemp.createTemp('tools_storage_test_');
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => directory.path);
    final storage = GetStorage('tools_test_${directory.path.split('/').last}', directory.path);
    await storage.initStorage;
    addTearDown(() async {
      await storage.queue.add(() async {});
      await pumpEventQueue();
      await directory.delete(recursive: true);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });
    await storage.write('unrelated', 'preserve');
    final first = ToolsController(storage: storage)..onInit();
    final defaults = first.inputFields.map((key, field) => MapEntry(key, field.text));
    for (final entry in first.inputFields.entries) {
      entry.value.text = '${entry.key} draft';
    }
    first.inflation.text = '3,';
    first.coverageMonths.text = '12';
    final drafts = first.inputFields.map((key, field) => MapEntry(key, field.text));
    expect(storage.read(ToolsController.storageKey), drafts);
    first.onClose();

    final reopened = ToolsController(storage: storage)..onInit();
    expect(reopened.inputFields.map((key, field) => MapEntry(key, field.text)), drafts);
    await reopened.resetInputs();
    expect(storage.read(ToolsController.storageKey), defaults);
    expect(storage.read('unrelated'), 'preserve');
    reopened.onClose();

    final reset = ToolsController(storage: storage)..onInit();
    expect(reset.inputFields.map((key, field) => MapEntry(key, field.text)), defaults);
    reset.onClose();
  });

  test('emergency fund rounds saving duration up and clamps funded targets', () {
    expect(calculateEmergencyFund(
      expense: 5000000, months: 6, saved: 5000000, monthlySaving: 3000000,
    ), {'target': 30000000, 'remaining': 25000000, 'months': 9, 'coverage': 1, 'progress': 1 / 6});
    expect(calculateEmergencyFund(
      expense: 5000000, months: 6, saved: 40000000, monthlySaving: 3000000,
    ), {'target': 30000000, 'remaining': 0, 'months': 0, 'coverage': 8, 'progress': 1});
    expect(calculateEmergencyFund(
      expense: 5000000, months: 6, saved: 0, monthlySaving: 0,
    )['months'], isNull);
    expect(calculateEmergencyFund(
      expense: 5000000, months: 6, saved: 30000000, monthlySaving: 0,
    )['months'], 0);
    expect(() => calculateEmergencyFund(
      expense: 5000000, months: 6, saved: 0, monthlySaving: -1,
    ), throwsArgumentError);
  });

  test('retirement includes inflation before and throughout retirement', () {
    final flat = calculateRetirementFund(
      expense: 5000000, yearsUntilRetirement: 25,
      retirementYears: 20, saved: 300000000, inflation: 0,
    );
    expect(flat['target'], 1200000000);
    expect(flat['remaining'], 900000000);
    expect(flat['monthlySaving'], 3000000);

    final inflated = calculateRetirementFund(
      expense: 1000000, yearsUntilRetirement: 1,
      retirementYears: 2, saved: 0, inflation: 0.1,
    );
    expect(inflated['expense'], closeTo(1100000, 0.01));
    expect(inflated['target'], closeTo(27720000, 0.01));

    final funded = calculateRetirementFund(
      expense: 1000000, yearsUntilRetirement: 1,
      retirementYears: 1, saved: 20000000, inflation: 0,
    );
    expect(funded['remaining'], 0);
    expect(funded['monthlySaving'], 0);
    expect(calculateRetirementFund(
      expense: 1000000, yearsUntilRetirement: 0,
      retirementYears: 20, saved: 0, inflation: 0.03,
    )['monthlySaving'], isNull);
    expect(() => calculateRetirementFund(
      expense: 1000000, yearsUntilRetirement: 25,
      retirementYears: 20, saved: 0, inflation: double.nan,
    ), throwsArgumentError);
  });

  test('retirement contributions fund monthly withdrawals with positive or negative returns', () {
    for (final rate in [0.06, 0.0, -0.02]) {
      final result = calculateRetirementFund(
        expense: 5000000, yearsUntilRetirement: 20,
        retirementYears: 25, saved: 100000000, inflation: 0.03,
        growthReturn: rate, retirementReturn: rate,
      );
      final monthlyGrowth = math.pow(1 + rate, 1 / 12);
      num balance = 100000000;
      for (var month = 0; month < 240; month++) {
        balance = balance * monthlyGrowth + result['monthlySaving']!;
      }
      expect(balance, greaterThanOrEqualTo(result['target']! - 0.01));
      balance = result['target']!;
      for (var month = 0; month < 300; month++) {
        balance -= result['expense']! * math.pow(1.03, month ~/ 12);
        expect(balance, greaterThanOrEqualTo(-0.1));
        balance *= monthlyGrowth;
      }
      expect(balance, closeTo(0, 0.1));
    }
  });

  test('retirement rejects invalid rates and supports an already funded retirement', () {
    expect(() => calculateRetirementFund(
      expense: 1000000, yearsUntilRetirement: 25,
      retirementYears: 20, saved: 0, inflation: 0.03, growthReturn: -1,
    ), throwsArgumentError);
    final funded = calculateRetirementFund(
      expense: 1000000, yearsUntilRetirement: 0,
      retirementYears: 1, saved: 12000000, inflation: 0,
    );
    expect(funded['monthlySaving'], 0);
    expect(funded['progress'], 1);
  });

  List<ToolOutput> calculate(String id, Map<String, num> values) =>
      calculateExtraTool(extraTools.firstWhere((tool) => tool.id == id), values);

  test('saving rounds monthly contributions up and handles a funded target', () {
    expect(calculate('saving', {'target': 100, 'saved': 0, 'months': 3}).last.value, 34);
    expect(calculate('saving', {'target': 100, 'saved': 200, 'months': 3}).last.value, 0);
  });

  test('loan amortization repays the principal and handles zero interest', () {
    final interestFree = calculate('loan', {'principal': 12000000, 'rate': 0, 'months': 12});
    expect(interestFree.first.value, 1000000);
    expect(interestFree[1].value, 0);
    final loan = calculate('loan', {'principal': 12000000, 'rate': 12, 'months': 12});
    num balance = 12000000;
    for (var month = 0; month < 12; month++) {
      balance = balance * 1.01 - (loan.first.value as num);
    }
    expect(balance, closeTo(0, 0.01));
    expect(loan[2].value as num, closeTo(12000000 + (loan[1].value as num), 0.01));
  });

  test('debt payoff handles partial final payment and non-amortizing payments', () {
    final debt = calculate('debt', {'balance': 1000, 'rate': 0, 'payment': 300, 'extra': 200});
    expect(debt.first.value, 2);
    expect(debt[2].value, 1000);
    expect(debt[3].value, 4);
    final blocked = calculate('debt', {'balance': 120000, 'rate': 12, 'payment': 100, 'extra': 0});
    expect(blocked.first.value, isA<String>());
    final rescued = calculate('debt', {'balance': 120000, 'rate': 12, 'payment': 100, 'extra': 20000});
    expect(rescued.first.value, isA<num>());
    expect(rescued.last.value, isA<String>());
    final positive = calculate('debt', {'balance': 1000000, 'rate': 12, 'payment': 100000, 'extra': 50000});
    expect(positive.last.value as num, greaterThan(0));
  });

  test('investment uses effective annual growth and month-end contributions', () {
    final flat = calculate('investment', {'initial': 1000, 'monthly': 100, 'years': 2, 'rate': 0});
    expect(flat.first.value, 3400);
    expect(flat.last.value, 0);
    expect(calculate('investment', {'initial': 1000, 'monthly': 0, 'years': 1, 'rate': 10}).first.value as num, closeTo(1100, 0.001));
    expect(calculate('investment', {'initial': 1000, 'monthly': 0, 'years': 1, 'rate': -10}).last.value as num, closeTo(-100, 0.001));
  });

  test('education compounds cost and supports immediate funding', () {
    final later = calculate('education', {'cost': 10000000, 'years': 2, 'rate': 10, 'saved': 0});
    expect(later.first.value as num, closeTo(12100000, 0.01));
    expect(later.last.value, 504167);
    expect(calculate('education', {'cost': 10000000, 'years': 0, 'rate': 10, 'saved': 0}).last.value, 'Perlu dana langsung');
    expect(calculate('education', {'cost': 10000000, 'years': 0, 'rate': 10, 'saved': 10000000}).last.value, 0);
  });

  test('house includes purchase fees in the down-payment target', () {
    final house = calculate('house', {'price': 1000000000, 'down': 20, 'fees': 50000000, 'saved': 100000000, 'months': 30});
    expect(house.first.value, 250000000);
    expect(house[2].value, 5000000);
    expect(house.last.value, 800000000);
  });

  test('budget distinguishes surplus and deficit without double counting', () {
    final budget = calculate('budget', {'income': 10000000, 'needs': 4000000, 'debt': 2000000, 'saving': 3000000});
    expect(budget.first.value, 1000000);
    expect(budget[2].value, 30);
    final deficit = calculate('budget', {'income': 10000000, 'needs': 9000000, 'debt': 2000000, 'saving': 0});
    expect(deficit.first.label, 'Defisit bulanan');
    expect(deficit.first.value, 1000000);
  });

  test('cost per use applies frequency and duration', () {
    final usage = calculate('usage', {'price': 1200000, 'frequency': 10, 'months': 12});
    expect(usage.first.value, 10000);
    expect(usage[1].value, 120);
    expect(usage.last.value, 100000);
  });

  test('every extra calculator rejects missing, non-finite and out-of-range inputs', () {
    for (final tool in extraTools) {
      final values = {for (final input in tool.inputs) input.key: math.max(input.min, 1)};
      expect(() => calculateExtraTool(tool, values), returnsNormally);
      for (final input in tool.inputs) {
        for (final invalid in [double.nan, double.infinity, input.min - 1, input.max + 1]) {
          expect(() => calculateExtraTool(tool, {...values, input.key: invalid}), throwsArgumentError);
        }
        final missing = {...values}..remove(input.key);
        expect(() => calculateExtraTool(tool, missing), throwsArgumentError);
      }
    }
    expect(() => calculate('usage', {'price': 1000, 'frequency': 1.5, 'months': 12}), throwsArgumentError);
  });

}
