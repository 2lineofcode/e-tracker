import 'package:expense_tracker/app/modules/widgets/widget_expense_image_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  Uint8List receipt() => img.encodePng(img.Image(width: 100, height: 400));

  testWidgets('preview supports zoom, rotation and keyboard reset', (tester) async {
    final bytes = receipt();
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.runAsync(() => precacheImage(MemoryImage(bytes), tester.element(find.byType(SizedBox))));
    await tester.pumpWidget(MaterialApp(home: ExpenseImagePreview(bytes: bytes)));
    await tester.pumpAndSettle();
    final viewer = tester.widget<InteractiveViewer>(find.byType(InteractiveViewer));
    expect(viewer.transformationController!.value.getMaxScaleOnAxis(), 1);
    await tester.tap(find.byType(InteractiveViewer));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byType(InteractiveViewer));
    await tester.pumpAndSettle();
    expect(viewer.transformationController!.value.getMaxScaleOnAxis(), closeTo(3, 0.01));
    await tester.sendKeyEvent(LogicalKeyboardKey.digit0);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Zoom in (+)'));
    await tester.pumpAndSettle();
    expect(viewer.transformationController!.value.getMaxScaleOnAxis(), closeTo(1.5, 0.01));
    await tester.tap(find.byTooltip('Putar'));
    await tester.pumpAndSettle();
    expect(tester.widget<RotatedBox>(find.byType(RotatedBox)).quarterTurns, 1);
    expect(viewer.transformationController!.value.getMaxScaleOnAxis(), 1);
    await tester.tap(find.byTooltip('Zoom in (+)'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.digit0);
    await tester.pumpAndSettle();
    expect(viewer.transformationController!.value.getMaxScaleOnAxis(), 1);
    tester.view.physicalSize = const Size(600, 900);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpAndSettle();
    expect(viewer.transformationController!.value.getMaxScaleOnAxis(), 1);
  });

  testWidgets('failed load retries once and Escape returns to the transaction', (tester) async {
    var loads = 0;
    final bytes = receipt();
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) => Scaffold(
      body: TextButton(onPressed: () => ExpenseImagePreview.show(context,
        loadImage: () async {
          loads++;
          if (loads == 1) throw StateError('Unavailable');
          return bytes;
        },
      ), child: const Text('Preview')),
    ))));
    await tester.runAsync(() => precacheImage(MemoryImage(bytes), tester.element(find.byType(Scaffold))));
    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();
    expect(find.text('Gambar tidak bisa dibuka'), findsOneWidget);
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsOneWidget);
    await tester.tap(find.byTooltip('Zoom in (+)'));
    await tester.pumpAndSettle();
    expect(loads, 2);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(ExpenseImagePreview), findsNothing);
    expect(find.text('Preview'), findsOneWidget);
  });
}
