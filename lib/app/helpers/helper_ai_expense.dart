import 'dart:convert';

import 'package:intl/intl.dart';

import '../models/supa_expense_entity.dart';

SupaExpense parseAIExpenseResponse(dynamic payload, List<String> categoryCodes) {
  if (payload is! Map || payload['choices'] is! List ||
      (payload['choices'] as List).isEmpty) {
    throw FormatException('Respons AI tidak valid');
  }
  final choice = (payload['choices'] as List).first;
  if (choice is! Map || choice['message'] is! Map ||
      (choice['message'] as Map)['content'] is! String) {
    throw FormatException('Respons AI tidak valid');
  }
  final value = jsonDecode((choice['message'] as Map)['content'] as String);
  if (value is! Map || value['note'] is! String ||
      (value['note'] as String).trim().isEmpty ||
      value['detail'] is! String || value['date'] is! String ||
      !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value['date'] as String) ||
      !categoryCodes.contains(value['category'])) {
    throw FormatException('Detail pengeluaran AI tidak valid');
  }
  DateFormat('yyyy-MM-dd').parseStrict(value['date'] as String);
  final rawAmount = value['amount'];
  final amount = rawAmount is num
      ? rawAmount
      : rawAmount is String ? num.tryParse(rawAmount) : null;
  if (amount == null || !amount.isFinite || amount < 0 ||
      amount > 1000000000000000 || amount != amount.truncateToDouble()) {
    throw FormatException('Nominal pengeluaran AI tidak valid');
  }
  return SupaExpense(
    note: (value['note'] as String).trim(),
    detail: value['detail'] as String,
    categoryName: value['category'] as String,
    amount: amount.toInt(),
    date: value['date'] as String,
  );
}
