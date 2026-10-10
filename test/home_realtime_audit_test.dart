// ignore_for_file: avoid_relative_lib_imports

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../lib/app/modules/home/home_rt.dart';

void main() {
  test('a raw delete for a row outside the seed queues a refresh', () async {
    HomeRT.onExpenseRTEvent(PostgresChangePayload(
      schema: 'public',
      table: 'expense',
      commitTimestamp: DateTime(2026, 10, 10),
      eventType: PostgresChangeEvent.delete,
      newRecord: const {},
      oldRecord: const {'id': 'not-in-first-1000-rows'},
      errors: null,
    ));
    expect(HomeRT.rtExpenseDebounce?.isActive, isTrue);
    await HomeRT.dispose();
    expect(HomeRT.rtExpenseDebounce, isNull);
  });
}
