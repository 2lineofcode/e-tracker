import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';
import 'package:re_editor/re_editor.dart';
import 'package:uuid/uuid.dart';

import '../../core/app_api.dart';
import '../../core/app_setting.dart';
import 'sql_editor_repository.dart';

enum SqlTemplate { select, update, delete }

class SavedSqlTemplate {
  const SavedSqlTemplate({
    required this.id,
    required this.name,
    required this.sql,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String sql;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sql': sql,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SavedSqlTemplate.fromJson(Map<String, dynamic> json) {
    return SavedSqlTemplate(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Untitled',
      sql: json['sql'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class SqlEditorController extends GetxController {
  SqlEditorController({SqlEditorRepository? repository}) : _repository = repository ?? SqlEditorRepository();

  final SqlEditorRepository _repository;
  final _uuid = const Uuid();

  late final CodeLineEditingController queryController;
  final isRunning = false.obs;
  final lastRunAt = Rxn<DateTime>();
  final result = Rxn<SqlExecutionResult>();
  final errorMessage = Rxn<String>();
  final ScrollController resultsVerticalScroll = ScrollController();
  final ScrollController resultsHorizontalScroll = ScrollController();

  final availableTableList = ['assets', 'budgets', 'error_log', 'expense', 'goals', 'notes', 'profiles'];

  static const _defaultLimit = 50;
  static final _selectRegex = RegExp(r'^\s*select\b', caseSensitive: false);
  static final _limitRegex = RegExp(r'\blimit\b', caseSensitive: false);

  final savedTemplates = <SavedSqlTemplate>[].obs;

  static const _seedQueryKey = '_seedQuery';
  static const _templatesStorageKey = '_sqlSavedTemplates';

  final _seedQuery = pref.read<String>(_seedQueryKey) ?? '';

  @override
  void onInit() {
    super.onInit();
    queryController = CodeLineEditingController.fromText(_seedQuery.trim());
    _loadSavedTemplates();
  }

  Future<void> runQuery() async {
    if (isRunning.value) return;
    final sql = _resolveExecutableSql();
    if (sql == null || sql.isEmpty) {
      errorMessage.value = 'Please enter a SQL statement.';
      return;
    }

    isRunning.value = true;
    errorMessage.value = null;
    try {
      final execution = await _repository.run(sql);
      result.value = execution;
      lastRunAt.value = DateTime.now();
    } on PgException catch (e, stack) {
      errorMessage.value = e.message;
      if (kDebugMode) {
        // ignore: avoid_print
        print(stack);
      }
    } on ArgumentError catch (e) {
      errorMessage.value = e.message?.toString() ?? e.toString();
    } on StateError catch (e) {
      errorMessage.value = e.message;
    } catch (e, stack) {
      errorMessage.value = '$e';
      if (kDebugMode) {
        // ignore: avoid_print
        print(stack);
      }
    } finally {
      isRunning.value = false;
    }
  }

  int get totalRows => result.value?.rowCount ?? 0;

  int get columnCount => result.value?.columns.length ?? 0;

  int get affectedRows => result.value?.affectedRows ?? 0;

  Duration? get lastDuration => result.value?.elapsed;

  String? _resolveExecutableSql() {
    final selection = _selectedSql();
    final raw = (selection?.isNotEmpty ?? false) ? selection! : queryController.text;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    return _applyDefaultLimit(trimmed);
  }

  String? _selectedSql() {
    final text = queryController.selectedText.trim();
    return text.isEmpty ? null : text;
  }

  String _applyDefaultLimit(String sql) {
    final trimmed = sql.trimRight();
    final base = _stripTrailingSemicolon(trimmed);
    final hasMultipleStatements = base.contains(';');
    if (hasMultipleStatements || !_selectRegex.hasMatch(base) || _limitRegex.hasMatch(base)) {
      return trimmed;
    }
    return '$base\nlimit $_defaultLimit';
  }

  String _stripTrailingSemicolon(String sql) {
    var result = sql;
    while (result.endsWith(';')) {
      result = result.substring(0, result.length - 1).trimRight();
    }
    return result;
  }

  void applyTemplate(SqlTemplate template) {
    final snippet = switch (template) {
      SqlTemplate.select => ''' select date, note, category_name, amount from expense limit 100; ''',
      SqlTemplate.update => ''' update from expense set category_name = '' where note ilike '%%' ''',
      SqlTemplate.delete => ''' delete from expense where id = '<expense_id>' and user_id = '${currentUserId ?? ''}'; ''',
    };

    queryController.text += '\n--- $template \n ${snippet.trimRight()}';
  }

  Future<void> saveTemplate({required String name, required String sql}) async {
    final trimmedName = name.trim();
    final trimmedSql = sql.trim();
    if (trimmedName.isEmpty || trimmedSql.isEmpty) {
      return;
    }
    final template = SavedSqlTemplate(
      id: _uuid.v4(),
      name: trimmedName,
      sql: trimmedSql,
      createdAt: DateTime.now(),
    );
    savedTemplates.removeWhere((element) => element.sql.trim() == trimmedSql && element.name == trimmedName);
    savedTemplates.insert(0, template);
    await _persistTemplates();
  }

  void applySavedTemplate(SavedSqlTemplate template) {
    queryController.text = template.sql;
  }

  Future<void> deleteTemplate(String id) async {
    savedTemplates.removeWhere((element) => element.id == id);
    await _persistTemplates();
  }

  void _loadSavedTemplates() {
    final stored = pref.read<List<dynamic>>(_templatesStorageKey);
    if (stored is! List || stored.isEmpty) {
      return;
    }
    final templates = <SavedSqlTemplate>[];
    for (final entry in stored) {
      if (entry is Map) {
        templates.add(SavedSqlTemplate.fromJson(Map<String, dynamic>.from(entry)));
      }
    }
    if (templates.isNotEmpty) {
      templates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      savedTemplates.assignAll(templates);
    }
  }

  Future<void> _persistTemplates() {
    return pref.write(
      _templatesStorageKey,
      savedTemplates.map((e) => e.toJson()).toList(),
    );
  }

  @override
  void onClose() {
    resultsVerticalScroll.dispose();
    resultsHorizontalScroll.dispose();
    queryController.dispose();
    super.onClose();
  }
}
