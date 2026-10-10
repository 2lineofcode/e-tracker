import 'package:expense_tracker/app/helpers/expense_backup_csv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final row = <String, dynamic>{
    'id': '7882954d-ed53-4eab-a70d-2fc983cc4492',
    'user_id': 'owner',
    'date': '2026-10-10',
    'category_name': 'notes',
    'note': 'A note, with "quotes"\nand a newline',
    'detail': '',
    'amount': 0,
    'created_at': '2026-10-10T10:00:00Z',
    'updated_at': '2026-10-10T11:00:00Z',
    'image_path': 'owner/image.png',
    'source_recurring_id': '6fb10de1-f03e-4ab0-a646-566889e5775d',
  };

  test('backup preserves zero notes and transaction metadata', () {
    expect(ExpenseBackupCsv.decode(ExpenseBackupCsv.encode([row]), 'owner'), [row]);
  });

  test('backup preserves separate identical transactions', () {
    final other = {...row, 'id': '600c0b43-d68a-4565-824e-e110f273730d'};
    expect(ExpenseBackupCsv.decode(ExpenseBackupCsv.encode([row, other]), 'owner'), [row, other]);
  });

  test('old backup restores zero notes without changing text', () {
    final csv = 'date,category_name,note,detail,amount,created_at\n2026-10-10,notes,mixed CASE,,0,2026-10-10T10:00:00Z';
    final restored = ExpenseBackupCsv.decode(csv, 'owner').single;
    expect(restored['amount'], 0);
    expect(restored['note'], 'mixed CASE');
    expect(restored['id'], isNotEmpty);
  });

  test('invalid backup rows reject the entire backup', () {
    for (final invalid in [
      {...row, 'date': '2026-02-30'},
      {...row, 'amount': '-1'},
      {...row, 'amount': 'Infinity'},
      {...row, 'amount': '12.5'},
      {...row, 'created_at': 'broken'},
    ]) {
      expect(() => ExpenseBackupCsv.decode(ExpenseBackupCsv.encode([row, invalid]), 'owner'), throwsFormatException);
    }
    expect(() => ExpenseBackupCsv.decode(ExpenseBackupCsv.encode([row, row]), 'owner'), throwsFormatException);
    expect(() => ExpenseBackupCsv.decode('date,note\n2026-10-10,note', 'owner'), throwsFormatException);
  });

  test('empty backup retains schema and supports empty accounts', () {
    expect(ExpenseBackupCsv.decode(ExpenseBackupCsv.encode([]), 'owner'), isEmpty);
  });
}
