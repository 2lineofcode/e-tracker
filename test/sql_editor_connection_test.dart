import 'dart:io';

import 'package:expense_tracker/app/modules/sql_editor/sql_editor_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('SQL editor requires an explicit session connection', () async {
    final repository = SqlEditorRepository();
    expect(repository.isConfigured, isFalse);
    await expectLater(repository.run('select 1'), throwsStateError);
    repository.configure('  https://invalid.example  ');
    expect(repository.isConfigured, isTrue);
    await expectLater(repository.run('select 1'), throwsArgumentError);
    expect(repository.isConfigured, isFalse);
    await expectLater(repository.run('select 1'), throwsStateError);
    expect(SqlEditorRepository().isConfigured, isFalse);
  });

  test('SQL credentials cannot be supplied by build defaults', () {
    final source = File('lib/app/modules/sql_editor/sql_editor_repository.dart').readAsStringSync();
    expect(source.contains('String.fromEnvironment'), isFalse);
    expect(RegExp(r'postgres(?:ql)?://[^\s]+:[^\s]+@').hasMatch(source), isFalse);
  });
}
