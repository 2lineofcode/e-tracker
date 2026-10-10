import 'dart:async';

import 'package:expense_tracker/app/models/supa_notes_entity.dart';
import 'package:expense_tracker/app/modules/notes/notes_controller.dart';
import 'package:expense_tracker/app/modules/notes/notes_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/shared_preferences'),
      (call) async => call.method == 'getAll' ? <String, Object>{} : true,
    );
    await Supabase.initialize(
      url: 'https://test.supabase.co',
      publishableKey: 'test-key',
      httpClient: MockClient((_) async => http.Response('{}', 200)),
      authOptions: FlutterAuthClientOptions(
        localStorage: EmptyLocalStorage(),
        autoRefreshToken: false,
        detectSessionInUri: false,
      ),
      debug: false,
    );
  });
  tearDownAll(() async => Supabase.instance.dispose());

  testWidgets('edits made while a save waits remain dirty', (tester) async {
    final repository = _PendingNotesRepository();
    Get.put<NotesRepository>(repository);
    final controller = NotesController();
    await controller.onInit();
    await tester.pumpWidget(ToastificationWrapper(child: GetMaterialApp(home: const Scaffold())));
    controller.enterEditMode();
    controller.tfTitle.text = 'Submitted';
    controller.fleatherController.replaceText(0, 0, 'First');
    final saving = controller.saveNote();
    expect(controller.isSaving.value, isTrue);
    controller.tfTitle.text = 'Still editing';
    controller.fleatherController.replaceText(0, 0, 'New ');
    repository.complete.complete();
    await saving;
    expect(repository.saved?.title, 'Submitted');
    expect(controller.tfTitle.text, 'Still editing');
    expect(controller.hasDirtyChange.value, isTrue);
    expect(controller.isPreviewMode.value, isFalse);
    expect(controller.isSaving.value, isFalse);
    await tester.pump(const Duration(seconds: 3));
    controller.onClose();
    Get.reset();
  });
  testWidgets('a note deleted elsewhere stays dirty when save affects zero rows', (tester) async {
    final repository = _DeletedNotesRepository();
    Get.put<NotesRepository>(repository);
    final controller = NotesController();
    await controller.onInit();
    await tester.pumpWidget(ToastificationWrapper(child: GetMaterialApp(home: const Scaffold())));
    controller.enterEditMode();
    controller.tfTitle.text = 'Unsaved change';
    await controller.saveNote();
    expect(controller.tfTitle.text, 'Unsaved change');
    expect(controller.hasDirtyChange.value, isTrue);
    expect(controller.isPreviewMode.value, isFalse);
    expect(controller.isSaving.value, isFalse);
    await tester.pump(const Duration(seconds: 3));
    controller.onClose();
    Get.reset();
  });

}

class _PendingNotesRepository extends NotesRepository {
  final complete = Completer<void>();
  SupaNotes? saved;

  @override
  Future<List<SupaNotes>> getNotes() async => saved == null ? [] : [saved!];

  @override
  Future<void> addNotes(SupaNotes entity) async {
    await complete.future;
    saved = entity;
  }
}

class _DeletedNotesRepository extends NotesRepository {
  @override
  Future<List<SupaNotes>> getNotes() async => [SupaNotes(id: 'deleted-note', title: 'Saved title', content: 'Saved content')];

  @override
  Future<void> updateNotes(SupaNotes entity) async {
    throw const PostgrestException(message: 'Cannot coerce the result to a single JSON object', code: 'PGRST116', details: 'The result contains 0 rows');
  }
}
