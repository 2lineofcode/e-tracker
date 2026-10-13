import 'dart:async';

import 'package:expense_tracker/app/helpers/expense_image_url_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rebuilds and remounts share an in-flight signed URL', () async {
    final cache = ExpenseImageUrlCache();
    final pending = Completer<String>();
    var requests = 0;
    Future<String> load() {
      requests++;
      return pending.future;
    }
    final first = cache.load('owner', 'photo', load);
    final second = cache.load('owner', 'photo', load);
    expect(identical(first, second), isTrue);
    pending.complete('signed-url');
    expect(await first, 'signed-url');
    expect(await cache.load('owner', 'photo', load), 'signed-url');
    expect(requests, 1);
  });

  test('failed signing can be retried', () async {
    final cache = ExpenseImageUrlCache();
    await expectLater(cache.load('owner', 'photo', () async {
      throw StateError('offline');
    }), throwsStateError);
    expect(await cache.load('owner', 'photo', () async => 'retry'), 'retry');
  });

  test('account changes invalidate pending and completed URLs', () async {
    final cache = ExpenseImageUrlCache();
    final pending = Completer<String>();
    final old = cache.load('first', 'photo', () => pending.future);
    final rejected = expectLater(old, throwsStateError);
    expect(await cache.load('second', 'photo', () async => 'second-url'), 'second-url');
    pending.complete('first-url');
    await rejected;
    expect(await cache.load('first', 'photo', () async => 'new-url'), 'new-url');
  });

  test('closing Home invalidates pending requests', () async {
    final cache = ExpenseImageUrlCache();
    final pending = Completer<String>();
    final old = cache.load('owner', 'photo', () => pending.future);
    final rejected = expectLater(old, throwsStateError);
    cache.clear();
    pending.complete('old-url');
    await rejected;
    expect(await cache.load('owner', 'photo', () async => 'new-url'), 'new-url');
  });

  test('cache stays bounded and retains recently viewed images', () async {
    final cache = ExpenseImageUrlCache();
    for (var index = 0; index < 32; index++) {
      await cache.load('owner', '$index', () async => 'url-$index');
    }
    expect(await cache.load('owner', '0', () async => 'unexpected'), 'url-0');
    await cache.load('owner', '32', () async => 'url-32');
    expect(await cache.load('owner', '1', () async => 'renewed'), 'renewed');
    expect(await cache.load('owner', '0', () async => 'unexpected'), 'url-0');
  });
}
