// ignore_for_file: avoid_relative_lib_imports

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../lib/app/helpers/helper_expense_query.dart';
import '../lib/app/models/supa_expense_entity.dart';
import '../lib/app/models/supa_recurring_expense_entity.dart';
import '../lib/app/modules/home/home_repository.dart';

void main() {
  test('loads every expense past the API limit in a stable order', () async {
    final offsets = <int>[];
    final client = MockClient((request) async {
      expect(request.url.queryParameters['order'], 'date.asc.nullslast,id.asc.nullslast');
      final offset = int.parse(request.url.queryParameters['offset']!);
      final limit = int.parse(request.url.queryParameters['limit']!);
      offsets.add(offset);
      final count = (1501 - offset).clamp(0, limit);
      return http.Response(jsonEncode(List.generate(count, (index) => {
        'id': '${offset + index}',
        'date': '2026-10-10',
        'amount': 20000,
        'category_name': offset + index == 1500 ? 'Makan (Restaurants, Gofood)#old' : 'notes',
      })), 200, headers: {'content-type': 'application/json'}, request: request);
    });
    final db = SupabaseClient('https://test.supabase.co', 'test-key', httpClient: client);
    final rows = await loadAllExpenses(db.from('expense').select().order('date', ascending: true));
    expect(offsets, [0, 1000]);
    expect(rows.length, 1501);
    expect(rows.fold<num>(0, (sum, row) => sum + row.amount!), 30020000);
    expect(rows.where((row) => row.resolvedCategory.code == 'expense:basic:food').single.id, '1500');
    await db.dispose();
  });

  test('bulk duplicate checks retain date, amount and normalized note matching', () {
    final rows = [
      SupaExpense(date: '2026-10-10', amount: 20000, note: '  Coffee   SHOP '),
      SupaExpense(date: '2026-10-11', amount: 20000, note: 'Coffee shop'),
      SupaExpense(date: '2026-10-10', amount: 30000, note: 'Coffee shop'),
      SupaExpense(date: '2026-10-10', amount: 20000, note: 'Dinner'),
    ];
    expect(HomeRepository.potentialDuplicateCount(rows, [
      SupaExpense(date: '2026-10-10', amount: 20000, note: 'Coffee shop Jakarta'),
    ]), 1);
    expect(HomeRepository.potentialDuplicateCount(rows, []), 0);
  });

  test('paid recurring bills advance to the next cycle', () {
    final recurring = SupaRecurringExpense(dueDay: 10, intervalMonths: 1, startMonth: 1);
    expect(recurring.nextRun(from: DateTime(2026, 10, 10)), DateTime(2026, 10, 10));
    recurring.lastRunDate = '2026-10-10';
    expect(recurring.nextRun(from: DateTime(2026, 10, 10)), DateTime(2026, 11, 10));
    recurring.dueDay = 31;
    recurring.lastRunDate = '2026-02-28';
    expect(recurring.nextRun(from: DateTime(2026, 2, 28)), DateTime(2026, 3, 31));
    recurring.intervalMonths = 12;
    recurring.startMonth = 2;
    expect(recurring.nextRun(from: DateTime(2026, 2, 28)), DateTime(2027, 2, 28));
  });
}
