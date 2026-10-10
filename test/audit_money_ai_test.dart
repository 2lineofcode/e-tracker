import 'dart:convert';

import 'package:expense_tracker/app/helpers/helper_ai_expense.dart';
import 'package:expense_tracker/app/helpers/helper_money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatted balances keep their sign', () {
    expect('-Rp. 100.000'.moneyUnformat(), -100000);
    expect('Rp. -100.000'.moneyUnformat(), -100000);
    expect('Rp. 12.500'.moneyUnformat(), 12500);
    expect(''.moneyUnformat(), isNull);
  });

  Map<String, dynamic> response(Map<String, dynamic> fields) => {
    'choices': [
      {'message': {'content': jsonEncode({
        'note': 'Lunch', 'detail': '', 'date': '2026-10-10',
        'category': 'expense:basic:food', 'amount': 12500.0, ...fields,
      })}},
    ],
  };
  const categories = ['expense:basic:food'];

  test('numeric and plain numeric string AI amounts remain whole rupiah', () {
    expect(parseAIExpenseResponse(response({}), categories).amount, 12500);
    expect(parseAIExpenseResponse(response({'amount': '12500.0'}), categories).amount, 12500);
  });

  test('invalid AI dates, categories and money cannot be saved', () {
    for (final fields in <Map<String, dynamic>>[
      {'date': '2026-02-30'}, {'date': '2026-10-10T00:00:00Z'},
      {'category': 'unknown'}, {'amount': -10}, {'amount': 12.5},
      {'amount': 'NaN'}, {'amount': '12.500'}, {'note': ''},
      {'amount': 1000000000000001},
    ]) {
      expect(() => parseAIExpenseResponse(response(fields), categories), throwsFormatException);
    }
    expect(() => parseAIExpenseResponse({}, categories), throwsFormatException);
  });
}
