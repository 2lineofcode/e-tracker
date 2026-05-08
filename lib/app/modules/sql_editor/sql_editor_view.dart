import 'dart:math' as math;

import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/sql.dart';
import 'package:re_highlight/styles/atom-one-dark.dart';
import 'package:uicons_pro/uicons_pro.dart';

import '../../core/app_api.dart';
import '../../core/app_setting.dart';
import '../../helpers/helpers.dart';
import 'sql_editor_controller.dart';
import 'sql_editor_repository.dart';

class SqlEditorView extends GetView<SqlEditorController> {
  const SqlEditorView({super.key});

  Color get _background => const Color(0xFF0D1117);
  Color get _surface => const Color(0xFF131722);
  Color get _border => const Color(0xFF1E2230);
  Color get _mutedText => const Color(0xFF7C8698);
  Color get _accent => const Color(0xFF2ECB70);
  static const double _tableHeaderHeight = 44;
  static const double _tableRowHeight = 44;
  static const double _tableColumnSpacing = 32;
  static const double _tableColumnMinWidth = 140;
  static final List<CodePrompt> _sqlPrompts = [
    // table
    CodeKeywordPrompt(word: 'assets'),
    CodeKeywordPrompt(word: 'budgets'),
    CodeKeywordPrompt(word: 'error_log'),
    CodeKeywordPrompt(word: 'expense'),
    CodeKeywordPrompt(word: 'goals'),
    CodeKeywordPrompt(word: 'notes'),
    CodeKeywordPrompt(word: 'profiles'),

    // category_name
    CodeFieldPrompt(word: 'expense:basic:groceries', type: 'Belanja Bulanan (Groceries)'),
    CodeFieldPrompt(word: 'expense:basic:food', type: 'Makan (Restaurants, Gofood)'),
    CodeFieldPrompt(word: 'expense:basic:snacks-coffee', type: 'Jajan (Snacks, Coffee)'),
    CodeFieldPrompt(word: 'expense:basic:smoke', type: 'Rokok / Vape'),
    CodeFieldPrompt(word: 'expense:basic:housing-rent', type: 'Sewa / Cicilan Rumah'),
    CodeFieldPrompt(word: 'expense:basic:housing-needs', type: 'Kebutuhan Rumah Tangga (Listrik, Air, Laundry, dll)'),
    CodeFieldPrompt(word: 'expense:transport:fuel', type: 'Bensin / Bahan Bakar'),
    CodeFieldPrompt(word: 'expense:transport:ride-hailing', type: 'Transportasi, Taksi / Ojek Online'),
    CodeFieldPrompt(word: 'expense:transport:parking-toll', type: 'Parkir & Tol'),
    CodeFieldPrompt(word: 'expense:transport:maintenance', type: 'Servis & Perawatan Kendaraan'),
    CodeFieldPrompt(word: 'expense:personal:apparel', type: 'Pakaian & Aksesoris'),
    CodeFieldPrompt(word: 'expense:personal:care', type: 'Perawatan Diri (Skincare, Potong Rambut, dll)'),
    CodeFieldPrompt(word: 'expense:personal:health-supplements', type: 'Obat & Suplemen'),
    CodeFieldPrompt(word: 'expense:personal:education', type: 'Pendidikan / Kursus'),
    CodeFieldPrompt(word: 'expense:personal:books', type: 'Buku & Majalah'),
    CodeFieldPrompt(word: 'expense:entertainment:movies-streaming', type: 'Nonton Bioskop / Streaming'),
    CodeFieldPrompt(word: 'expense:entertainment:travel', type: 'Liburan & Traveling'),
    CodeFieldPrompt(word: 'expense:entertainment:hobbies', type: 'Hobi'),
    CodeFieldPrompt(word: 'expense:entertainment:social', type: 'Hangout, Sosial, Dating'),
    CodeFieldPrompt(word: 'expense:entertainment:games', type: 'Game'),
    CodeFieldPrompt(word: 'expense:bill:subscription', type: 'Bill / Subscription'),
    CodeFieldPrompt(word: 'expense:bill:insurance', type: 'Asuransi'),
    CodeFieldPrompt(word: 'expense:bill:tax', type: 'Pajak'),
    CodeFieldPrompt(word: 'expense:misc:gifts-donations', type: 'Hadiah & Donasi'),
    CodeFieldPrompt(word: 'expense:misc:household', type: 'Alat Rumah Tangga'),
    CodeFieldPrompt(word: 'expense:misc:electronics', type: 'Elektronik & Gadget'),
    CodeFieldPrompt(word: 'expense:misc:medical', type: 'Kesehatan & Dokter'),
    CodeFieldPrompt(word: 'expense:misc:family', type: 'Keluarga'),
    CodeFieldPrompt(word: 'expense:unknown', type: 'Unknown'),

    // basic
    CodeKeywordPrompt(word: 'select'),
    CodeKeywordPrompt(word: 'distinct'),
    CodeKeywordPrompt(word: 'from'),
    CodeKeywordPrompt(word: 'where'),
    CodeKeywordPrompt(word: 'group'),
    CodeKeywordPrompt(word: 'having'),
    CodeKeywordPrompt(word: 'order'),
    CodeKeywordPrompt(word: 'limit'),
    CodeKeywordPrompt(word: 'insert'),
    CodeKeywordPrompt(word: 'update'),
    CodeKeywordPrompt(word: 'delete'),
    CodeKeywordPrompt(word: 'join'),
    CodeKeywordPrompt(word: 'inner'),
    CodeKeywordPrompt(word: 'left'),
    CodeKeywordPrompt(word: 'right'),
    CodeKeywordPrompt(word: 'on'),
    CodeKeywordPrompt(word: 'and'),
    CodeKeywordPrompt(word: 'or'),
    CodeFieldPrompt(word: 'count', type: 'int'),
    CodeFieldPrompt(word: 'sum', type: 'numeric'),
    CodeFieldPrompt(word: 'avg', type: 'numeric'),
    CodeFieldPrompt(word: 'min', type: 'numeric'),
    CodeFieldPrompt(word: 'max', type: 'numeric'),
    CodeFieldPrompt(word: 'user_id', type: 'uuid'),
    CodeFieldPrompt(word: 'category_name', type: 'text'),
    CodeFieldPrompt(word: 'note', type: 'text'),
    CodeFieldPrompt(word: 'amount', type: 'numeric'),

    CodeFunctionPrompt(
      word: 'date_trunc',
      type: 'timestamp',
      parameters: const {'precision': 'text', 'source': 'timestamp'},
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: _background,
        body: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.enter, meta: true): () => controller.runQuery(),
            const SingleActivator(LogicalKeyboardKey.numpadEnter, meta: true): () => controller.runQuery(),
            const SingleActivator(LogicalKeyboardKey.enter, control: true): () => controller.runQuery(),
            const SingleActivator(LogicalKeyboardKey.numpadEnter, control: true): () => controller.runQuery(),
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 16),
                _buildEditorCard(context),
                const SizedBox(height: 16),
                Expanded(child: _buildResultsCard()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        const Text(
          'SQL Editor',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        const Spacer(),
        IconButton(
          onPressed: () => Get.back(),
          splashRadius: 18,
          icon: Icon(
            UIconsPro.solidRounded.cross,
            color: _mutedText,
            size: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildEditorCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 24,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildEditorToolbar(),
          const Divider(color: Color(0xFF1C202C), height: 1),
          SizedBox(
            height: 260,
            child: _buildCodeEditor(),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorToolbar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // _templateMenu(),
          // const SizedBox(width: 8),
          _savedTemplatesMenu(Get.context!),
          const SizedBox(width: 8),

          _tag('Get uuid', labelStyle: TextStyle(fontSize: 8, color: Vx.neutral500)).onInkTap(() {
            Clipboard.setData(ClipboardData(text: '${currentUserId ?? ''}'));
            HelperToast.info('copied "${currentUserId ?? ''}"', duration: 500.milliseconds);
          }),
          const Spacer(),
          _saveTemplateButton(Get.context!),
          const SizedBox(width: 8),
          _runButton(),
        ],
      ),
    );
  }

  Widget _buildCodeEditor() {
    final codeTheme = CodeHighlightTheme(
      languages: {
        'sql': CodeHighlightThemeMode(mode: langSql),
      },
      theme: atomOneDarkTheme,
    );

    return CodeAutocomplete(
      viewBuilder: (context, notifier, onSelected) => _SqlAutocompleteList(
        notifier: notifier,
        onSelected: onSelected,
        accentColor: _accent,
        textColor: Colors.white,
        mutedColor: _mutedText,
      ),
      promptsBuilder: DefaultCodeAutocompletePromptsBuilder(
        language: langSql,
        directPrompts: _sqlPrompts,
      ),
      child: CodeEditor(
        controller: controller.queryController,
        wordWrap: false,
        shortcutsActivatorsBuilder: const _SqlShortcutsBuilder(),
        style: CodeEditorStyle(
          backgroundColor: Colors.transparent,
          cursorColor: _accent,
          fontSize: 14,
          fontFamily: 'RobotoMono',
          fontHeight: 1.6,
          textColor: Colors.white,
          codeTheme: codeTheme,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        onChanged: (value) async {
          // get value text
          logD(value.codeLines.asString(TextLineBreak.crlf));
          await pref.write('_seedQuery', value.codeLines.asString(TextLineBreak.crlf));
        },
        indicatorBuilder: (context, editingController, chunkController, notifier) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF10131D),
              border: Border(
                right: BorderSide(color: _border),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DefaultCodeLineNumber(
                  controller: editingController,
                  notifier: notifier,
                  textStyle: TextStyle(
                    color: _mutedText,
                    fontSize: 12,
                  ),
                  focusedTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                DefaultCodeChunkIndicator(
                  width: 18,
                  controller: chunkController,
                  notifier: notifier,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _tag(
    String label, {
    Color? color = const Color(0xFF1C1F2B),
    TextStyle? labelStyle = const TextStyle(color: Colors.white, fontSize: 12),
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: labelStyle),
    );
  }

  Future<void> _promptSaveTemplate(BuildContext context) async {
    final sql = controller.queryController.text.trim();
    if (sql.isEmpty) {
      await HelperToast.error('Write a query first', duration: 1500.milliseconds);
      return;
    }

    final defaultName = 'Template ${DateFormat.Hm().format(DateTime.now())}';
    final nameController = TextEditingController(text: defaultName);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _surface,
          title: const Text('Save template', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: nameController,
            autofocus: true,
            maxLength: 60,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Template name',
              labelStyle: TextStyle(color: Colors.white70),
              counterText: '',
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final trimmed = nameController.text.trim();
                if (trimmed.isEmpty) return;
                Navigator.of(dialogContext).pop(trimmed);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    nameController.dispose();

    if (name == null || name.trim().isEmpty) return;
    await controller.saveTemplate(name: name.trim(), sql: sql);
    await HelperToast.success('Template "$name" saved', duration: 1200.milliseconds);
  }

  Future<void> _openTemplatesManager(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final bottomInset = MediaQuery.viewInsetsOf(sheetContext).bottom;
        final maxHeight = math.min(MediaQuery.sizeOf(sheetContext).height * 0.75, 520.0);
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 16),
          child: Material(
            color: _surface,
            borderRadius: BorderRadius.circular(20),
            child: Obx(
              () {
                final templates = controller.savedTemplates;
                return SizedBox(
                  height: templates.isEmpty ? 260 : maxHeight,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Row(
                          children: [
                            const Text(
                              'Saved templates',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            IconButton(
                              tooltip: 'Close',
                              onPressed: () => Navigator.of(sheetContext).pop(),
                              icon: Icon(UIconsPro.solidRounded.cross, color: _mutedText, size: 18),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: _border),
                              backgroundColor: const Color(0xFF151823),
                            ),
                            onPressed: () {
                              Navigator.of(sheetContext).pop();
                              _promptSaveTemplate(context);
                            },
                            icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                            label: const Text('Save current query'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: templates.isEmpty
                            ? _buildEmptyTemplatesState()
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                itemCount: templates.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final template = templates[index];
                                  return _buildTemplateTile(sheetContext, context, template);
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyTemplatesState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bookmark_border, color: _mutedText, size: 36),
          const SizedBox(height: 8),
          Text(
            'No templates saved yet.',
            style: TextStyle(color: _mutedText),
          ),
          const SizedBox(height: 4),
          Text(
            'Save a query to reuse it later.',
            style: TextStyle(color: _mutedText, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateTile(BuildContext sheetContext, BuildContext parentContext, SavedSqlTemplate template) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: ListTile(
        title: Text(
          template.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            DateFormat('MMM d · HH:mm').format(template.createdAt),
            style: TextStyle(color: _mutedText, fontSize: 12),
          ),
        ),
        onTap: () {
          controller.applySavedTemplate(template);
          Navigator.of(sheetContext).pop();
          HelperToast.success('Loaded "${template.name}"', duration: 1200.milliseconds);
        },
        trailing: IconButton(
          tooltip: 'Delete template',
          icon: const Icon(Icons.delete_outline, color: Color(0xFFDD4A68)),
          onPressed: () => _confirmDeleteTemplate(parentContext, template),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteTemplate(BuildContext context, SavedSqlTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _surface,
          title: const Text('Delete template?', style: TextStyle(color: Colors.white)),
          content: Text(
            'Remove "${template.name}"?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDD4A68)),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    await controller.deleteTemplate(template.id);
    await HelperToast.info('Template deleted', duration: 1200.milliseconds);
  }

  Widget _savedTemplatesMenu(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        foregroundColor: Colors.white,
        side: BorderSide(color: _border),
        backgroundColor: const Color(0xFF151823),
      ),
      onPressed: () => _openTemplatesManager(context),
      icon: const Icon(Icons.list_alt_outlined, size: 14),
      label: const Text('My Queries', style: TextStyle(fontSize: 12)),
    );
  }

  Widget _saveTemplateButton(BuildContext context) {
    return Tooltip(
      message: 'Save current query as template',
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          foregroundColor: Colors.white,
          side: BorderSide(color: _border),
          backgroundColor: const Color(0xFF151823),
        ),
        onPressed: () => _promptSaveTemplate(context),
        icon: const Icon(Icons.bookmark_add_outlined, size: 14),
        label: const Text('Save', style: TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _runButton() {
    return Obx(
      () => FilledButton.icon(
        onPressed: controller.isRunning.value ? null : controller.runQuery,
        style: FilledButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
        icon: controller.isRunning.value
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
              )
            : const Icon(Icons.play_arrow_rounded, size: 14),
        label: const Text('Run', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)).tooltip('⌘+⏎'),
      ),
    );
  }

  Widget _buildResultsCard() {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResultsToolbar(),
          const Divider(color: Color(0xFF1C202C), height: 1),
          Expanded(child: _buildResultsBody()),
          const Divider(color: Color(0xFF1C202C), height: 1),
          _buildResultsFooter(),
        ],
      ),
    );
  }

  Widget _buildResultsToolbar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _resultsTab('Results', isActive: true),
          const Spacer(),
          Obx(
            () {
              final time = controller.lastRunAt.value;
              final duration = controller.lastDuration;
              var label = 'Query not run yet';
              if (time != null) {
                label = 'Last run ${DateFormat.Hms().format(time)}';
                if (duration != null) {
                  label += ' · ${duration.inMilliseconds} ms';
                }
              }
              return Text(
                label,
                style: TextStyle(color: _mutedText, fontSize: 12),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _resultsTab(String label, {bool isActive = false}) {
    final color = isActive ? Colors.white : _mutedText;
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }

  Widget _buildResultsBody() {
    return Obx(
      () {
        final error = controller.errorMessage.value;
        final current = controller.result.value;
        final isRunning = controller.isRunning.value;

        Widget content;
        if (error != null) {
          content = _buildErrorBanner(error);
        } else if (current == null) {
          content = _buildResultsPlaceholder(
            'Run a query to see results here.',
          );
        } else if (current.hasRows) {
          content = _buildDataTable(current);
        } else {
          final affected = controller.affectedRows;
          content = _buildResultsPlaceholder(
            affected == 0 ? 'Query executed successfully. No rows returned.' : 'Query executed successfully. $affected rows affected.',
          );
        }

        return Stack(
          children: [
            Positioned.fill(child: content),
            if (isRunning)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: Colors.transparent,
                  color: _accent,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildResultsPlaceholder(String label) {
    return Center(
      child: Text(
        label,
        style: TextStyle(color: _mutedText),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2B1222),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDD4A68)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFDD4A68)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(SqlExecutionResult result) {
    final columns = result.columns.isNotEmpty
        ? result.columns
        : List.generate(
            result.rows.isNotEmpty ? result.rows.first.length : 0,
            (index) => 'column_${index + 1}',
          );
    final vertical = controller.resultsVerticalScroll;
    final horizontal = controller.resultsHorizontalScroll;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final hasBoundedHeight = constraints.hasBoundedHeight && constraints.maxHeight.isFinite;
          final availableHeight = hasBoundedHeight ? constraints.maxHeight : math.max(_tableHeaderHeight + 1, MediaQuery.sizeOf(context).height * 0.5);
          final tableWidth = _resolveTableWidth(columns.length, constraints.maxWidth);

          final table = SizedBox(
            width: tableWidth,
            height: availableHeight,
            child: Column(
              children: [
                _buildTableHeaderRow(columns),
                const SizedBox(
                  height: 1,
                  child: ColoredBox(color: Color(0xFF1C202C)),
                ),
                Expanded(
                  child: Scrollbar(
                    controller: vertical,
                    thumbVisibility: result.rows.length > 50,
                    child: ListView.builder(
                      controller: vertical,
                      physics: const ClampingScrollPhysics(),
                      itemExtent: _tableRowHeight,
                      itemCount: result.rows.length,
                      itemBuilder: (context, index) {
                        return _buildTableDataRow(columns, result.rows[index]);
                      },
                    ),
                  ),
                ),
              ],
            ),
          );

          return Scrollbar(
            controller: horizontal,
            notificationPredicate: (notification) => notification.metrics.axis == Axis.horizontal,
            child: SingleChildScrollView(
              controller: horizontal,
              scrollDirection: Axis.horizontal,
              child: Material(color: Colors.transparent, child: table),
            ),
          );
        },
      ),
    );
  }

  String _formatCellValue(Object? value) {
    if (value == null) return 'NULL';
    if (value is DateTime) {
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(value.toLocal());
    }
    return '$value';
  }

  double _resolveTableWidth(int columnCount, double maxWidth) {
    if (columnCount <= 0) {
      if (maxWidth.isFinite && maxWidth > 0) return maxWidth;
      return _tableColumnMinWidth;
    }
    final spacingWidth = math.max(0, columnCount - 1) * _tableColumnSpacing;
    final minWidth = columnCount * _tableColumnMinWidth + spacingWidth;
    if (maxWidth.isFinite && maxWidth > 0) {
      return math.max(minWidth, maxWidth);
    }
    return minWidth;
  }

  Widget _buildTableHeaderRow(List<String> columns) {
    final children = <Widget>[];
    for (var i = 0; i < columns.length; i++) {
      children.add(
        _buildTableCell(
          Text(
            columns[i],
            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          onTap: () => _copyToClipboard(columns[i]),
        ),
      );
      if (i != columns.length - 1) {
        children.add(const SizedBox(width: _tableColumnSpacing));
      }
    }

    return Container(
      height: _tableHeaderHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF1C202C),
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }

  Widget _buildTableDataRow(List<String> columns, List<dynamic> values) {
    final children = <Widget>[];
    for (var i = 0; i < columns.length; i++) {
      final displayValue = _formatCellValue(i < values.length ? values[i] : null);
      children.add(
        _buildTableCell(
          Text(
            displayValue,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          onTap: () => _copyToClipboard(displayValue),
        ),
      );
      if (i != columns.length - 1) {
        children.add(const SizedBox(width: _tableColumnSpacing));
      }
    }

    return Container(
      height: _tableRowHeight,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }

  Widget _buildTableCell(
    Widget child, {
    VoidCallback? onTap,
  }) {
    Widget content = SizedBox(
      width: _tableColumnMinWidth,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Align(alignment: Alignment.centerLeft, child: child),
      ),
    );
    if (onTap != null) {
      content = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }

  void _copyToClipboard(String value) {
    Clipboard.setData(ClipboardData(text: value));
    HelperToast.info('copied "$value"', duration: 500.milliseconds);
  }

  Widget _buildResultsFooter() {
    return Obx(
      () {
        final rows = controller.totalRows;
        final columns = controller.columnCount;
        final duration = controller.lastDuration;
        final affected = controller.affectedRows;

        final chips = <String>[
          '$rows rows',
          if (columns > 0) '$columns columns',
          if (duration != null) '${duration.inMilliseconds} ms',
          if (affected > 0) '$affected affected',
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 14, color: _mutedText),
              const SizedBox(width: 12),
              if (chips.isEmpty)
                Text(
                  'Awaiting query...',
                  style: TextStyle(color: _mutedText, fontSize: 12),
                ),
              if (chips.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: chips
                      .map(
                        (text) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C202C),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(text, style: TextStyle(color: _mutedText, fontSize: 11)),
                        ),
                      )
                      .toList(),
                ),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}

class _SqlAutocompleteList extends StatefulWidget implements PreferredSizeWidget {
  const _SqlAutocompleteList({
    required this.notifier,
    required this.onSelected,
    required this.accentColor,
    required this.textColor,
    required this.mutedColor,
  });

  final ValueNotifier<CodeAutocompleteEditingValue> notifier;
  final ValueChanged<CodeAutocompleteResult> onSelected;
  final Color accentColor;
  final Color textColor;
  final Color mutedColor;

  static const double _itemHeight = 28;
  static const double _maxHeight = 200;

  @override
  Size get preferredSize => Size(280, math.min(_itemHeight * notifier.value.prompts.length, _maxHeight) + 2);

  @override
  State<_SqlAutocompleteList> createState() => _SqlAutocompleteListState();
}

class _SqlAutocompleteListState extends State<_SqlAutocompleteList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();

    widget.notifier.addListener(_handleValueChanged);
    super.initState();
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_handleValueChanged);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prompts = widget.notifier.value.prompts;
    return Container(
      width: widget.preferredSize.width,
      height: widget.preferredSize.height,
      decoration: BoxDecoration(
        color: const Color(0xFF121827),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: widget.accentColor.withValues(alpha: 0.25)),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 18, offset: Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Material(
          color: Colors.transparent,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: prompts.length,
            itemExtent: _SqlAutocompleteList._itemHeight,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final prompt = prompts[index];
              final selected = index == widget.notifier.value.index;
              return InkWell(
                onTap: () {
                  widget.onSelected(widget.notifier.value.copyWith(index: index).autocomplete);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: selected ? widget.accentColor.withValues(alpha: 0.18) : Colors.transparent,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white12,
                        width: index == prompts.length - 1 ? 0 : 1,
                      ),
                    ),
                  ),
                  child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: _buildPromptSpan(prompt, widget.notifier.value.input),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleValueChanged() {
    if (!mounted) return;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureVisible());
  }

  void _ensureVisible() {
    if (!_scrollController.hasClients) return;
    final index = widget.notifier.value.index;
    final itemTop = index * _SqlAutocompleteList._itemHeight;
    final viewport = (widget.preferredSize.height - 2).clamp(1.0, double.infinity);
    final currentOffset = _scrollController.offset;
    if (itemTop < currentOffset) {
      _scrollController.jumpTo(itemTop);
    } else if (itemTop + _SqlAutocompleteList._itemHeight > currentOffset + viewport) {
      final target = itemTop + _SqlAutocompleteList._itemHeight - viewport;
      _scrollController.jumpTo(target.clamp(0.0, _scrollController.position.maxScrollExtent));
    }
  }

  InlineSpan _buildPromptSpan(CodePrompt prompt, String input) {
    final baseStyle = TextStyle(
      color: widget.textColor,
      fontSize: 13,
      fontFamily: 'RobotoMono',
    );
    final List<InlineSpan> children = [
      TextSpan(children: _highlight(prompt.word, input, baseStyle)),
    ];
    if (prompt is CodeFieldPrompt) {
      children.add(
        TextSpan(
          text: '  ${prompt.type}',
          style: baseStyle.copyWith(color: widget.mutedColor),
        ),
      );
    } else if (prompt is CodeFunctionPrompt) {
      final params = prompt.parameters.keys.join(', ');
      children.add(
        TextSpan(
          text: '($params) → ${prompt.type}',
          style: baseStyle.copyWith(color: widget.mutedColor),
        ),
      );
    }
    return TextSpan(children: children);
  }

  List<TextSpan> _highlight(String word, String input, TextStyle base) {
    if (input.isEmpty) {
      return [TextSpan(text: word, style: base)];
    }
    final lowerWord = word.toLowerCase();
    final lowerInput = input.toLowerCase();
    final start = lowerWord.indexOf(lowerInput);
    if (start == -1) {
      return [TextSpan(text: word, style: base)];
    }
    final end = start + input.length;
    return [
      if (start > 0) TextSpan(text: word.substring(0, start), style: base),
      TextSpan(
        text: word.substring(start, end),
        style: base.copyWith(color: widget.accentColor, fontWeight: FontWeight.w600),
      ),
      if (end < word.length) TextSpan(text: word.substring(end), style: base),
    ];
  }
}

class _SqlShortcutsBuilder extends CodeShortcutsActivatorsBuilder {
  const _SqlShortcutsBuilder();

  static const _defaultBuilder = DefaultCodeShortcutsActivatorsBuilder();

  @override
  List<ShortcutActivator>? build(CodeShortcutType type) {
    final defaults = _defaultBuilder.build(type);
    if (defaults == null) return null;
    final activators = List<ShortcutActivator>.from(defaults);
    if (type == CodeShortcutType.newLine) {
      activators.removeWhere(
        (activator) => activator is SingleActivator && (activator.meta || activator.control),
      );
      const tabActivator = SingleActivator(LogicalKeyboardKey.tab);
      if (!activators.contains(tabActivator)) {
        activators.add(tabActivator);
      }
    } else if (type == CodeShortcutType.indent) {
      activators.removeWhere(
        (activator) {
          return activator is SingleActivator && activator.trigger == LogicalKeyboardKey.tab && !activator.meta && !activator.control && !activator.shift && !activator.alt;
        },
      );
    }
    return activators;
  }
}
