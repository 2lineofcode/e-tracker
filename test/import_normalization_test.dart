import 'package:expense_tracker/app/helpers/helper_import_export.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizes common Indonesian bank CSV values', () {
    expect(HelperImportExport.normalizeImportDate('01/08/2026'), '2026-08-01');
    expect(HelperImportExport.normalizeImportAmount('Rp 12.500,00'), 12500);
    expect(HelperImportExport.normalizeImportAmount('-75.000'), -75000);
  });
}
