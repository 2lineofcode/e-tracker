import 'package:flutter_test/flutter_test.dart';
// re_editor uses this transitive dependency for syntax highlighting.
// ignore: depend_on_referenced_packages
import 'package:isolate_manager/isolate_manager.dart';

int _double(int value) => value * 2;

void main() {
  test('editor isolate manager computes and stops across runtimes', () async {
    final manager = IsolateManager<int, int>.create(_double, concurrent: 1);
    try {
      expect(await manager.compute(21).timeout(const Duration(seconds: 10)), 42);
    } finally {
      await manager.stop();
    }
  });
}
