@TestOn('browser')
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
// ignore: implementation_imports
import 'package:get_storage/src/storage/html.dart';
import 'package:web/web.dart' as web;

void main() {
  const key = 'expense_tracker_wasm_storage_test';

  tearDown(() => web.window.localStorage.removeItem(key));

  test('reads legacy preferences and preserves JSON on write and reload', () async {
    final original = <String, dynamic>{
      'darkMode': true,
      'amount': 12000,
      'filters': ['food', 'transport'],
    };
    web.window.localStorage.setItem(key, jsonEncode(original));
    final storage = StorageImpl(key);
    await storage.init();
    expect(storage.read<bool>('darkMode'), true);
    expect(storage.read<List<dynamic>>('filters'), ['food', 'transport']);

    storage.write('amount', 15000);
    await storage.flush();
    final reloaded = StorageImpl(key);
    await reloaded.init();
    expect(reloaded.read<int>('amount'), 15000);
    expect(reloaded.read<bool>('darkMode'), true);
    expect(jsonDecode(web.window.localStorage.getItem(key)!), {...original, 'amount': 15000});
    reloaded.clear();
    expect(web.window.localStorage.getItem(key), isNull);
  });

  test('invalid stored JSON is reported without overwriting it', () async {
    web.window.localStorage.setItem(key, '{invalid');
    await expectLater(StorageImpl(key).init(), throwsFormatException);
    expect(web.window.localStorage.getItem(key), '{invalid');
  });
}
