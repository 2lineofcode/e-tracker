import 'package:expense_tracker/app/helpers/helper_import_export.dart';
import 'package:expense_tracker/app/models/supa_expense_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SupaExpense expense(String id, {String note = 'Coffee'}) => SupaExpense(id: id, date: '2026-10-10', note: note, amount: 20000);

  test('identical bank transactions are flagged without dropping either row', () {
    final incoming = [expense('first'), expense('second')];
    expect(HelperImportExport.possibleImportDuplicates([], incoming), {'second'});
    expect(incoming.map((item) => item.id), ['first', 'second']);
  });

  test('existing matches are flagged using normalized notes', () {
    final incoming = [expense('new', note: '  COFFEE  ')];
    expect(HelperImportExport.possibleImportDuplicates([expense('existing')], incoming), {'new'});
    expect(incoming.length, 1);
  });
}
