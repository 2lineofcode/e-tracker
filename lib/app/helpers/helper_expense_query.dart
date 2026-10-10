import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/supa_expense_entity.dart';

Future<List<SupaExpense>> loadAllExpenses(
  PostgrestTransformBuilder<List<Map<String, dynamic>>> query,
) async {
  const pageSize = 1000;
  final expenses = <SupaExpense>[];
  while (true) {
    final page = await query.order('id', ascending: true).range(expenses.length, expenses.length + pageSize - 1);
    expenses.addAll(page.map(SupaExpense.fromJson));
    if (page.length < pageSize) return expenses;
  }
}
