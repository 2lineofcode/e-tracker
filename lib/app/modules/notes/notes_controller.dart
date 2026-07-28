import 'dart:convert';

import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:uuid/v4.dart';

import '../../core/app_api.dart';
import '../../helpers/helpers.dart';
import '../../models/supa_notes_entity.dart';
import '../home/home_controller.dart';
import 'notes_repository.dart';

class NotesController extends GetxController {
  final repo = Get.find<NotesRepository>();

  final notesList = <SupaNotes>[].obs;
  final filteredNotes = <SupaNotes>[].obs;
  final selectedNote = Rxn<SupaNotes>();

  final tfSearch = TextEditingController();
  final tfTitle = TextEditingController();
  final quillController = QuillController.basic();

  final isLoading = false.obs;
  final isSaving = false.obs;
  final isPreviewMode = true.obs;
  final hasDirtyChange = false.obs;
  bool _isApplyingNote = false;

  @override
  Future<void> onInit() async {
    super.onInit();
    tfSearch.addListener(_filterNotes);
    tfTitle.addListener(_markDirty);
    quillController.addListener(_markDirty);
    _syncQuillReadOnly();
    await loadNotes();
  }

  @override
  void onClose() {
    tfSearch.removeListener(_filterNotes);
    tfTitle.removeListener(_markDirty);
    quillController.removeListener(_markDirty);
    tfSearch.dispose();
    tfTitle.dispose();
    quillController.dispose();
    super.onClose();
  }

  Future<void> loadNotes() async {
    try {
      isLoading.value = true;
      final notes = await repo.getNotes();
      notesList.assignAll(notes);
      _filterNotes();

      if (selectedNote.value == null && notes.isNotEmpty) {
        openNote(notes.first, markClean: true);
      }
    } catch (e) {
      await HelperErrorLog.record(
        page: 'notes',
        action: 'loadNotes',
        stack: e.toString(),
      );
      await HelperToast.error('Failed to load notes');
    } finally {
      isLoading.value = false;
    }
  }

  void createNewNote() {
    _isApplyingNote = true;
    selectedNote.value = null;
    tfTitle.text = '';
    quillController.document = Document();
    isPreviewMode.value = false;
    _syncQuillReadOnly();
    hasDirtyChange.value = false;
    _isApplyingNote = false;
  }

  void openNote(SupaNotes note, {bool markClean = false}) {
    _isApplyingNote = true;
    selectedNote.value = note;
    tfTitle.text = note.title ?? '';
    quillController.document = _decodeDocument(note.content);
    isPreviewMode.value = true;
    _syncQuillReadOnly();
    hasDirtyChange.value = !markClean ? false : hasDirtyChange.value;
    hasDirtyChange.value = false;
    _isApplyingNote = false;
  }

  Future<void> saveNote() async {
    final content = quillController.document.toPlainText().trim();
    final title = _resolveTitle();

    if (title.isEmpty && content.isEmpty) {
      await HelperToast.warn('Note is empty');
      return;
    }

    try {
      isSaving.value = true;
      final current = selectedNote.value;
      final note = SupaNotes(
        id: current?.id ?? UuidV4().generate(),
        userId: current?.userId ?? db.auth.currentSession?.user.id ?? '',
        title: title,
        content: _encodeDocument(),
        createdAt: current?.createdAt ?? DateTime.now().toStringEx(),
        updatedAt: DateTime.now().toStringEx(),
      );

      if (current == null) {
        await repo.addNotes(note);
      } else {
        await repo.updateNotes(note);
      }

      selectedNote.value = note;
      hasDirtyChange.value = false;
      isPreviewMode.value = true;
      await loadNotes();
      _refreshHomeNotes();
      await HelperToast.success('Note saved');
    } catch (e) {
      await HelperErrorLog.record(
        page: 'notes',
        action: 'saveNote',
        stack: e.toString(),
      );
      await HelperToast.error('Failed to save note');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteSelectedNote() async {
    final note = selectedNote.value;
    if (note?.id == null) return;

    try {
      isSaving.value = true;
      await repo.deleteNotes(note!.id!);
      selectedNote.value = null;
      tfTitle.text = '';
      quillController.document = Document();
      hasDirtyChange.value = false;
      await loadNotes();
      _refreshHomeNotes();
      await HelperToast.success('Note deleted');
    } catch (e) {
      await HelperErrorLog.record(
        page: 'notes',
        action: 'deleteSelectedNote',
        stack: e.toString(),
      );
      await HelperToast.error('Failed to delete note');
    } finally {
      isSaving.value = false;
    }
  }

  void togglePreviewMode() {
    isPreviewMode.value = !isPreviewMode.value;
    _syncQuillReadOnly();
  }

  void enterEditMode() {
    isPreviewMode.value = false;
    _syncQuillReadOnly();
  }

  void markDirty() {
    _markDirty();
  }

  void _filterNotes() {
    final keyword = tfSearch.text.trim().toLowerCase();
    if (keyword.isEmpty) {
      filteredNotes.assignAll(notesList);
      return;
    }

    filteredNotes.assignAll(
      notesList.where((note) {
        final title = (note.title ?? '').toLowerCase();
        final content = notePlainText(note.content).toLowerCase();
        return title.contains(keyword) || content.contains(keyword);
      }),
    );
  }

  String notePlainText(String? content) {
    return _decodeDocument(content).toPlainText().trim();
  }

  String _resolveTitle() {
    final title = tfTitle.text.trim();
    if (title.isNotEmpty) return title;

    final firstLine = quillController.document
        .toPlainText()
        .split('\n')
        .map((line) => line.trim())
        .firstWhere((line) => line.isNotEmpty, orElse: () => '');
    return firstLine;
  }

  void _markDirty() {
    if (_isApplyingNote) return;
    hasDirtyChange.value = true;
  }

  String _encodeDocument() {
    return jsonEncode(quillController.document.toDelta().toJson());
  }

  Document _decodeDocument(String? content) {
    final data = content ?? '';
    if (data.trim().isEmpty) return Document();

    try {
      final decoded = jsonDecode(data);
      if (decoded is List) return Document.fromJson(decoded);
    } catch (_) {
      // Existing notes used markdown/plain text before the Quill migration.
    }

    return Document()..insert(0, data);
  }

  void _syncQuillReadOnly() {
    quillController.readOnly = isPreviewMode.value;
  }

  void _refreshHomeNotes() {
    if (!Get.isRegistered<HomeController>()) return;
    Get.find<HomeController>().loadNotesList();
  }
}
