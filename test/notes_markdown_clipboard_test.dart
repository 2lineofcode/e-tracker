import 'package:expense_tracker/app/modules/notes/notes_markdown_clipboard.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps plain text as plain clipboard data', () {
    expect(markdownToParchmentDelta('ordinary text'), isNull);
  });

  test('converts inline markdown without adding a line break', () {
    final delta = markdownToParchmentDelta(
      'Pay **a** now with [bank](https://example.com)',
    )!;
    final operations = delta.toList();

    expect(operations.last.data, 'bank');
    expect(operations.last.attributes, {'a': 'https://example.com'});
    expect(
      operations.any(
        (operation) =>
            operation.data == 'a' && operation.attributes?['b'] == true,
      ),
      isTrue,
    );
  });

  test('converts markdown blocks and table to a valid document', () {
    final delta = markdownToParchmentDelta('''
# Plan
- [x] Done
- Todo

> Quote

```dart
print('ok');
```

| Name | Value |
| --- | --- |
| A | B |
''')!;
    final operations = delta.toList();
    final table = operations
        .map((operation) => operation.data)
        .whereType<Map>()
        .firstWhere((data) => data['_type'] == 'table');

    expect(
      operations.any(
        (operation) => operation.attributes?['heading'] == 1,
      ),
      isTrue,
    );
    expect(
      operations.any(
        (operation) =>
            operation.attributes?['block'] == 'cl' &&
            operation.attributes?['checked'] == true,
      ),
      isTrue,
    );
    expect(
      operations.any(
        (operation) => operation.attributes?['block'] == 'quote',
      ),
      isTrue,
    );
    expect(
      operations.any(
        (operation) => operation.attributes?['block'] == 'code',
      ),
      isTrue,
    );
    expect(table['rows'], [
      ['Name', 'Value'],
      ['A', 'B'],
    ]);

    final document = ParchmentDocument.fromJson(
      operations.map((operation) => operation.toJson()).toList(),
    );
    document.close();
  });

  test('pastes a markdown table into an empty editor line', () {
    final controller = FleatherController();
    addTearDown(controller.dispose);
    final delta = markdownToParchmentDelta(
      '''
| Name | Value |
| --- | --- |
| A | B |
''',
      replaceTrailingBreak: true,
    )!;

    controller.compose(delta, source: ChangeSource.local);

    expect(
      controller.document
          .toDelta()
          .map((operation) => operation.data)
          .whereType<Map>()
          .any((data) => data['_type'] == 'table'),
      isTrue,
    );
  });
}
