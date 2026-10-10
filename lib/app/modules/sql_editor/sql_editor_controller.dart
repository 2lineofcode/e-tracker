import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';
import 'package:re_editor/re_editor.dart';

import '../../core/app_setting.dart';
import 'sql_editor_repository.dart';

class SqlEditorTab {
  const SqlEditorTab({
    required this.name,
    required this.sql,
  });

  final String name;
  final String sql;

  SqlEditorTab copyWith({
    String? name,
    String? sql,
  }) {
    return SqlEditorTab(
      name: name ?? this.name,
      sql: sql ?? this.sql,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'sql': sql,
      };

  factory SqlEditorTab.fromJson(Map<String, dynamic> json) {
    return SqlEditorTab(
      name: json['name'] as String? ?? 'Query',
      sql: json['sql'] as String? ?? '',
    );
  }
}

class SqlEditorController extends GetxController {
  SqlEditorController({SqlEditorRepository? repository}) : _repository = repository ?? SqlEditorRepository();

  final SqlEditorRepository _repository;

  late final CodeLineEditingController queryController;
  final tabs = <SqlEditorTab>[].obs;
  final activeTab = 0.obs;
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

  static const _seedQueryKey = '_seedQuery';
  static const _tabsStorageKey = '_sqlEditorTabs';
  static const _activeTabStorageKey = '_sqlEditorActiveTab';

  bool _isApplyingTab = false;

  @override
  void onInit() {
    super.onInit();
    _loadTabs();
    queryController = CodeLineEditingController.fromText(tabs[activeTab.value].sql.trim());
  }

  void addTab() {
    _saveActiveTabSql(queryController.text);
    tabs.add(SqlEditorTab(name: 'Query ${tabs.length + 1}', sql: ''));
    activeTab.value = tabs.length - 1;
    _persistTabs();
    _applyActiveTabSql();
  }

  void selectTab(int index) {
    if (index == activeTab.value || index < 0 || index >= tabs.length) {
      return;
    }

    _saveActiveTabSql(queryController.text);
    activeTab.value = index;
    _persistTabs();
    _applyActiveTabSql();
  }

  void closeTab(int index) {
    if (tabs.length <= 1 || index < 0 || index >= tabs.length) {
      return;
    }

    _saveActiveTabSql(queryController.text);
    tabs.removeAt(index);

    if (activeTab.value >= tabs.length) {
      activeTab.value = tabs.length - 1;
    } else if (index < activeTab.value) {
      activeTab.value--;
    }

    _persistTabs();
    _applyActiveTabSql();
  }

  Future<void> renameTab(int index, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || index < 0 || index >= tabs.length) {
      return;
    }

    tabs[index] = tabs[index].copyWith(name: trimmed);
    await _persistTabs();
  }

  void updateActiveTabSql(String sql) {
    if (_isApplyingTab) return;
    _saveActiveTabSql(sql);
    _persistTabs();
  }

  Future<void> runQuery() async {
    if (isRunning.value) return;
    final sql = _resolveExecutableSql();
    if (sql == null || sql.isEmpty) {
      errorMessage.value = 'Tulis query SQL dulu.';
      return;
    }

    if (kIsWeb) {
      errorMessage.value = 'SQL Editor tersedia di aplikasi desktop.';
      return;
    }
    isRunning.value = true;
    errorMessage.value = null;
    try {
      if (!_repository.isConfigured) {
        final connectionString = await _requestConnectionString();
        if (connectionString == null || connectionString.trim().isEmpty) return;
        _repository.configure(connectionString);
      }
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

  Future<String?> _requestConnectionString() async {
    final input = TextEditingController();
    try {
      return await showDialog<String>(
        context: Get.context!,
        builder: (context) => AlertDialog(
          title: const Text('Koneksi database'),
          content: TextField(
            controller: input,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(labelText: 'Connection string'),
            onSubmitted: (value) => Navigator.pop(context, value),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            FilledButton(onPressed: () => Navigator.pop(context, input.text), child: const Text('Hubungkan')),
          ],
        ),
      );
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) => input.dispose());
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

  void _loadTabs() {
    final stored = pref.read<List<dynamic>>(_tabsStorageKey);
    final loadedTabs = <SqlEditorTab>[];
    if (stored is List) {
      for (final entry in stored) {
        if (entry is Map) {
          loadedTabs.add(SqlEditorTab.fromJson(Map<String, dynamic>.from(entry)));
        }
      }
    }

    final legacyQuery = pref.read<String>(_seedQueryKey) ?? '';
    tabs.assignAll(loadedTabs.isNotEmpty ? loadedTabs : [SqlEditorTab(name: 'Query 1', sql: legacyQuery)]);

    final savedIndex = pref.read<int>(_activeTabStorageKey) ?? 0;
    activeTab.value = savedIndex.clamp(0, tabs.length - 1);
  }

  void _saveActiveTabSql(String sql) {
    if (tabs.isEmpty) {
      tabs.add(const SqlEditorTab(name: 'Query 1', sql: ''));
    }
    tabs[activeTab.value] = tabs[activeTab.value].copyWith(sql: sql);
  }

  Future<void> _persistTabs() async {
    await pref.write(_tabsStorageKey, tabs.map((tab) => tab.toJson()).toList());
    await pref.write(_activeTabStorageKey, activeTab.value);
    await pref.write(_seedQueryKey, tabs[activeTab.value].sql);
  }

  void _applyActiveTabSql() {
    _isApplyingTab = true;
    queryController.text = tabs[activeTab.value].sql;
    _isApplyingTab = false;
  }

  @override
  void onClose() {
    resultsVerticalScroll.dispose();
    resultsHorizontalScroll.dispose();
    queryController.dispose();
    super.onClose();
  }
}
