import 'dart:convert';

import 'package:ex_kit/ex.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/v4.dart';

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
  final editorFocusNode = FocusNode();
  final editorKey = GlobalKey<EditorState>();
  final editorRevision = 0.obs;
  FleatherController fleatherController = FleatherController();

  final isLoading = false.obs;
  final isSaving = false.obs;
  final isPinning = false.obs;
  final isPreviewMode = true.obs;
  final hasDirtyChange = false.obs;
  bool _isApplyingNote = false;
  String _savedTitle = '';
  String _savedContent = '';
  String? _tableToFocus;
  // ponytail: Table edits bypass Fleather undo; use native table nodes if undo is required.
  final _tableEdits = <String, List<List<String>>>{};

  @override
  Future<void> onInit() async {
    super.onInit();
    _savedContent = _encodeDocument();
    tfSearch.addListener(_filterNotes);
    tfTitle.addListener(_markDirty);
    fleatherController.addListener(_markDirty);
    await loadNotes();
  }

  @override
  void onClose() {
    tfSearch.removeListener(_filterNotes);
    tfTitle.removeListener(_markDirty);
    fleatherController.removeListener(_markDirty);
    tfSearch.dispose();
    tfTitle.dispose();
    editorFocusNode.dispose();
    fleatherController.dispose();
    super.onClose();
  }

  Future<void> loadNotes() async {
    try {
      isLoading.value = true;
      final notes = await repo.getNotes();
      notesList.assignAll(notes);
      _sortNotes();
      _filterNotes();

      if (selectedNote.value == null) {
        if (notes.isEmpty) {
          createNewNote();
        } else {
          openNote(notesList.first);
        }
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
    _replaceDocument(ParchmentDocument());
    isPreviewMode.value = false;
    _rememberCurrentState();
    _isApplyingNote = false;
  }

  void openNote(SupaNotes note) {
    _isApplyingNote = true;
    selectedNote.value = note;
    tfTitle.text = note.title ?? '';
    _replaceDocument(_decodeDocument(note.content));
    isPreviewMode.value = true;
    _rememberCurrentState();
    _isApplyingNote = false;
  }

  Future<void> saveNote() async {
    if (isSaving.value) return;

    final content = _plainText(fleatherController.document);
    final title = _resolveTitle();

    if (title.isEmpty && content.isEmpty && !_hasEmbed()) {
      await HelperToast.warn('Note is empty');
      return;
    }

    try {
      isSaving.value = true;
      final current = selectedNote.value;
      final note = SupaNotes(
        id: current?.id ?? UuidV4().generate(),
        title: title,
        content: _encodeDocument(),
        createdAt: current?.createdAt ?? DateTime.now().toStringEx(),
        updatedAt: DateTime.now().toStringEx(),
        isPinned: current?.isPinned ?? false,
      );

      if (current == null) {
        await repo.addNotes(note);
      } else {
        await repo.updateNotes(note);
      }

      _isApplyingNote = true;
      selectedNote.value = note;
      tfTitle.text = title;
      isPreviewMode.value = true;
      _rememberCurrentState();
      _isApplyingNote = false;
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
    if (isSaving.value) return;

    final note = selectedNote.value;
    if (note?.id == null) return;

    try {
      isSaving.value = true;
      await repo.deleteNotes(note!.id!);
      selectedNote.value = null;
      tfTitle.text = '';
      _replaceDocument(ParchmentDocument());
      _rememberCurrentState();
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

  Future<void> togglePinned(SupaNotes note) async {
    if (isPinning.value || note.id == null) return;

    final isPinned = !note.isPinned;
    try {
      isPinning.value = true;
      await repo.updatePinned(note.id!, isPinned);
      note.isPinned = isPinned;
      for (final item in notesList) {
        if (item.id == note.id) item.isPinned = isPinned;
      }
      if (selectedNote.value?.id == note.id) {
        selectedNote.value?.isPinned = isPinned;
        selectedNote.refresh();
      }
      _sortNotes();
      _filterNotes();
    } catch (e) {
      await HelperErrorLog.record(
        page: 'notes',
        action: 'togglePinned',
        stack: e.toString(),
      );
      await HelperToast.error('Failed to update pin');
    } finally {
      isPinning.value = false;
    }
  }

  void togglePreviewMode() {
    isPreviewMode.value = !isPreviewMode.value;
  }

  void enterEditMode() {
    isPreviewMode.value = false;
    editorFocusNode.requestFocus();
  }

  void insertTable(int rows, int columns) {
    if (rows < 1 || columns < 1 || rows > 20 || columns > 20) return;

    final selection = fleatherController.selection;
    final start = selection.start < 0 ? 0 : selection.start;
    final length = selection.end - selection.start;
    final tableId = UuidV4().generate();
    _tableToFocus = tableId;
    fleatherController.replaceText(
      start,
      length < 0 ? 0 : length,
      BlockEmbed('table', data: {
        'id': tableId,
        'rows': List.generate(rows, (_) => List.generate(columns, (_) => '')),
      }),
      selection: TextSelection.collapsed(offset: start + 2),
    );
  }

  void updateTable(String tableId, List<List<String>> rows) {
    if (isPreviewMode.value) return;
    _tableEdits[tableId] =
        rows.map((row) => List<String>.from(row)).toList();
    _markDirty();
  }

  void deleteTable(int offset, String? tableId) {
    if (tableId != null) _tableEdits.remove(tableId);
    fleatherController.replaceText(
      offset,
      1,
      '',
      selection: TextSelection.collapsed(offset: offset),
    );
    editorFocusNode.requestFocus();
  }

  bool consumeTableFocus(String? tableId) {
    if (tableId == null || tableId != _tableToFocus) return false;
    _tableToFocus = null;
    return true;
  }

  List<List<String>>? tableRows(String? tableId) {
    final rows = tableId == null ? null : _tableEdits[tableId];
    if (rows == null) return null;
    return rows.map((row) => List<String>.from(row)).toList();
  }

  String get bodyText => _plainText(fleatherController.document);

  int get characterCount => bodyText.length;

  int get wordCount {
    final text = bodyText;
    return text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
  }

  void confirmDiscardChanges(VoidCallback action) {
    if (isSaving.value) return;

    if (!hasDirtyChange.value) {
      action();
      return;
    }

    ExAlert.confirm(
      title: 'Discard changes?',
      message: 'Your unsaved changes will be lost.',
      btnYesText: 'Discard',
      onYes: () {
        Get.back();
        hasDirtyChange.value = false;
        WidgetsBinding.instance.addPostFrameCallback((_) => action());
      },
    );
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

  void _sortNotes() {
    notesList.sort((first, second) {
      if (first.isPinned != second.isPinned) {
        return first.isPinned ? -1 : 1;
      }
      return (second.updatedAt ?? '').compareTo(first.updatedAt ?? '');
    });
  }

  String notePlainText(String? content) {
    final document = _decodeDocument(content);
    final result = _plainText(document);
    document.close();
    return result;
  }

  String _resolveTitle() {
    final title = tfTitle.text.trim();
    if (title.isNotEmpty) return title;

    final firstLine = _plainText(fleatherController.document)
        .split('\n')
        .map((line) => line.trim())
        .firstWhere((line) => line.isNotEmpty, orElse: () => '');
    return firstLine;
  }

  void _markDirty() {
    if (_isApplyingNote) return;
    hasDirtyChange.value =
        tfTitle.text.trim() != _savedTitle ||
        _encodeDocument() != _savedContent;
  }

  void _rememberCurrentState() {
    _savedTitle = tfTitle.text.trim();
    _savedContent = _encodeDocument();
    hasDirtyChange.value = false;
  }

  String _encodeDocument() {
    final document = fleatherController.document
        .toDelta()
        .toList()
        .map((operation) => operation.toJson())
        .toList();
    for (final operation in document) {
      final insert = operation['insert'];
      if (insert is! Map || insert['_type'] != 'table') continue;
      final rows = _tableEdits[insert['id']];
      if (rows == null) continue;
      operation['insert'] = {
        ...insert,
        'rows': rows,
      };
    }
    return jsonEncode(document);
  }

  ParchmentDocument _decodeDocument(String? content) {
    final data = content ?? '';
    if (data.trim().isEmpty) return ParchmentDocument();

    try {
      final decoded = jsonDecode(data);
      if (decoded is List) {
        return ParchmentDocument.fromJson(_normalizeDelta(decoded));
      }
    } catch (_) {
      // Existing notes used markdown/plain text before rich text storage.
    }

    return _plainDocument(data);
  }

  void _replaceDocument(ParchmentDocument document) {
    _tableEdits.clear();
    _tableToFocus = null;
    final previous = fleatherController;
    previous.removeListener(_markDirty);
    fleatherController = FleatherController(document: document);
    fleatherController.addListener(_markDirty);
    editorRevision.value++;
    WidgetsBinding.instance.addPostFrameCallback((_) => previous.dispose());
  }

  List<Map<String, dynamic>> _normalizeDelta(List<dynamic> delta) {
    final normalized = <Map<String, dynamic>>[];

    for (final item in delta) {
      if (item is! Map || !item.containsKey('insert')) continue;
      final operation = <String, dynamic>{
        'insert': _normalizeInsert(item['insert']),
      };
      final attributes = _normalizeAttributes(item['attributes']);
      if (attributes.isNotEmpty) operation['attributes'] = attributes;
      normalized.add(operation);
    }

    if (normalized.isEmpty) return [{'insert': '\n'}];
    final lastInsert = normalized.last['insert'];
    if (lastInsert is! String || !lastInsert.endsWith('\n')) {
      normalized.add({'insert': '\n'});
    }
    return normalized;
  }

  dynamic _normalizeInsert(dynamic insert) {
    if (insert is! Map) return insert is String ? insert : '$insert';
    if (insert['_type'] is String && insert['_inline'] is bool) {
      final normalized = Map<String, dynamic>.from(insert);
      if (normalized['_type'] == 'table') {
        normalized.putIfAbsent('id', () => UuidV4().generate());
      }
      return normalized;
    }

    if (insert.length == 1) {
      final type = '${insert.keys.first}';
      final value = insert.values.first;
      if (type == 'table' && value is Map) {
        final normalized = <String, dynamic>{
          '_type': 'table',
          '_inline': false,
          ...Map<String, dynamic>.from(value),
        };
        normalized.putIfAbsent('id', () => UuidV4().generate());
        return normalized;
      }
      if (type == 'image') {
        return {
          '_type': 'image',
          '_inline': false,
          'source': '$value',
          'source_type': '$value'.startsWith('data:') ? 'data' : 'url',
        };
      }
      return {
        '_type': type,
        '_inline': false,
        'value': value,
      };
    }

    return {
      '_type': 'unsupported',
      '_inline': false,
      'value': Map<String, dynamic>.from(insert),
    };
  }

  Map<String, dynamic> _normalizeAttributes(dynamic data) {
    if (data is! Map) return {};
    final result = <String, dynamic>{};

    for (final entry in data.entries) {
      final key = '${entry.key}';
      final value = entry.value;
      switch (key) {
        case 'b':
        case 'i':
        case 'u':
        case 's':
        case 'c':
        case 'a':
        case 'heading':
        case 'fg':
        case 'bg':
        case 'checked':
        case 'block':
        case 'direction':
        case 'alignment':
        case 'indent':
          result[key] = value;
        case 'bold':
          result['b'] = value;
        case 'italic':
          result['i'] = value;
        case 'underline':
          result['u'] = value;
        case 'strike':
          result['s'] = value;
        case 'code':
          result['c'] = value;
        case 'link':
          result['a'] = value;
        case 'header':
          result['heading'] = value;
        case 'align':
          result['alignment'] = value;
        case 'list':
          if (value == 'bullet') result['block'] = 'ul';
          if (value == 'ordered') result['block'] = 'ol';
          if (value == 'checked' || value == 'unchecked') {
            result['block'] = 'cl';
            if (value == 'checked') result['checked'] = true;
          }
        case 'code-block':
          if (value == true) result['block'] = 'code';
        case 'blockquote':
          if (value == true) result['block'] = 'quote';
        case 'color':
          final color = _parseColor(value);
          if (color != null) result['fg'] = color;
        case 'background':
          final color = _parseColor(value);
          if (color != null) result['bg'] = color;
      }
    }
    return result;
  }

  int? _parseColor(dynamic value) {
    if (value is int) return value;
    if (value is! String || !value.startsWith('#')) return null;
    final hex = value.substring(1);
    if (hex.length == 6) return int.tryParse('ff$hex', radix: 16);
    if (hex.length == 8) return int.tryParse(hex, radix: 16);
    return null;
  }

  ParchmentDocument _plainDocument(String text) {
    final value = text.endsWith('\n') ? text : '$text\n';
    return ParchmentDocument.fromJson([{'insert': value}]);
  }

  String _plainText(ParchmentDocument document) {
    return document
        .toPlainText()
        .replaceAll(EmbedNode.kObjectReplacementCharacter, '')
        .trim();
  }

  bool _hasEmbed() {
    return fleatherController.document
        .toDelta()
        .toList()
        .any((operation) => operation.data is! String);
  }

  void _refreshHomeNotes() {
    if (!Get.isRegistered<HomeController>()) return;
    Get.find<HomeController>().loadNotesList();
  }
}
