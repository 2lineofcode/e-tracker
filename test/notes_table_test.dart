import 'dart:convert';

import 'package:expense_tracker/app/models/supa_notes_entity.dart';
import 'package:expense_tracker/app/modules/notes/notes_controller.dart';
import 'package:expense_tracker/app/modules/notes/notes_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('table insert and edit keep its data', (tester) async {
    Get.put(NotesRepository());
    final controller = NotesController();
    addTearDown(() {
      controller.onClose();
      Get.reset();
    });

    controller.isPreviewMode.value = false;
    controller.insertTable(2, 3);

    final inserted =
        controller.fleatherController.document.toDelta().first.data;
    final tableId = (inserted as Map)['id'] as String;
    expect(inserted['_type'], 'table');
    expect(inserted['rows'], [
      ['', '', ''],
      ['', '', ''],
    ]);

    controller.openNote(SupaNotes(
      id: 'note-id',
      title: '',
      content: jsonEncode(controller.fleatherController.document.toJson()),
    ));
    controller.isPreviewMode.value = false;
    expect(controller.hasDirtyChange.value, isFalse);

    controller.updateTable(tableId, [
      ['Date', 'Note', 'Amount'],
      ['2026-07-30', 'Lunch', '50000'],
    ]);

    expect(controller.hasDirtyChange.value, isTrue);
    expect(controller.tableRows(tableId), [
      ['Date', 'Note', 'Amount'],
      ['2026-07-30', 'Lunch', '50000'],
    ]);
    expect(
      (controller.fleatherController.document.toDelta().first.data as Map)['rows'],
      [
        ['', '', ''],
        ['', '', ''],
      ],
    );
    controller.updateTable(tableId, [
      ['Date', 'Note', 'Amount'],
      ['2026-07-30', 'Dinner', '75000'],
    ]);
    expect(controller.tableRows(tableId), [
      ['Date', 'Note', 'Amount'],
      ['2026-07-30', 'Dinner', '75000'],
    ]);
    expect(controller.fleatherController.getSelectionStyle().isEmpty, isTrue);
    await tester.pump(Duration(milliseconds: 500));
  });

  testWidgets('note stats exclude title and table content', (tester) async {
    Get.put(NotesRepository());
    final controller = NotesController();
    addTearDown(() {
      controller.onClose();
      Get.reset();
    });

    controller.tfTitle.text = 'Ignored title';
    controller.fleatherController.replaceText(0, 0, 'one two');
    controller.insertTable(2, 2);

    expect(controller.characterCount, 7);
    expect(controller.wordCount, 2);
    await tester.pump(Duration(milliseconds: 500));
  });

  testWidgets('pinned notes stay above recent notes', (tester) async {
    Get.put<NotesRepository>(_FakeNotesRepository());
    final controller = NotesController();
    addTearDown(() {
      controller.onClose();
      Get.reset();
    });

    await controller.loadNotes();

    expect(controller.notesList.map((note) => note.id), [
      'pinned',
      'recent',
      'older',
    ]);
    expect(controller.selectedNote.value?.id, 'pinned');
    await tester.pump(Duration(milliseconds: 500));
  });
}

class _FakeNotesRepository extends NotesRepository {
  @override
  Future<List<SupaNotes>> getNotes() async {
    return [
      SupaNotes(
        id: 'recent',
        updatedAt: '2026-07-30T10:00:00',
      ),
      SupaNotes(
        id: 'older',
        updatedAt: '2026-07-29T10:00:00',
      ),
      SupaNotes(
        id: 'pinned',
        updatedAt: '2026-07-28T10:00:00',
        isPinned: true,
      ),
    ];
  }
}
