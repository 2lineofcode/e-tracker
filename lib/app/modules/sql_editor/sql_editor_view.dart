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
    CodeFieldPrompt(word: 'expense:basic:groceries', type: 'Belanja Bulanan'),
    CodeFieldPrompt(word: 'expense:basic:food', type: 'Makan (Restoran, GoFood)'),
    CodeFieldPrompt(word: 'expense:basic:snacks-coffee', type: 'Jajan (Camilan, Kopi)'),
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
    CodeFieldPrompt(word: 'expense:entertainment:travel', type: 'Liburan & Jalan-jalan'),
    CodeFieldPrompt(word: 'expense:entertainment:hobbies', type: 'Hobi'),
    CodeFieldPrompt(word: 'expense:entertainment:social', type: 'Nongkrong, Sosial, Kencan'),
    CodeFieldPrompt(word: 'expense:entertainment:games', type: 'Game'),
    CodeFieldPrompt(word: 'expense:bill:subscription', type: 'Tagihan / Langganan'),
    CodeFieldPrompt(word: 'expense:bill:insurance', type: 'Asuransi'),
    CodeFieldPrompt(word: 'expense:bill:tax', type: 'Pajak'),
    CodeFieldPrompt(word: 'expense:misc:gifts-donations', type: 'Hadiah & Donasi'),
    CodeFieldPrompt(word: 'expense:misc:household', type: 'Alat Rumah Tangga'),
    CodeFieldPrompt(word: 'expense:misc:electronics', type: 'Elektronik & Gadget'),
    CodeFieldPrompt(word: 'expense:misc:medical', type: 'Kesehatan & Dokter'),
    CodeFieldPrompt(word: 'expense:misc:family', type: 'Keluarga'),
    CodeFieldPrompt(word: 'expense:unknown', type: 'Belum diketahui'),

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
        Expanded(
          child: _SqlTabBar(
            controller: controller,
            surface: _surface,
            border: _border,
            mutedText: _mutedText,
            accent: _accent,
            onRename: (index, currentName) => _promptRenameTab(Get.context!, index, currentName),
          ),
        ),
        const SizedBox(width: 8),
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

  Future<void> _promptRenameTab(BuildContext context, int index, String currentName) async {
    final nameController = TextEditingController(text: currentName);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _surface,
          title: const Text('Ganti nama tab', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: nameController,
            autofocus: true,
            maxLength: 40,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Nama tab',
              labelStyle: TextStyle(color: Colors.white70),
              counterText: '',
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
            ),
            onSubmitted: (value) {
              final trimmed = value.trim();
              if (trimmed.isEmpty) return;
              Navigator.of(dialogContext).pop(trimmed);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final trimmed = nameController.text.trim();
                if (trimmed.isEmpty) return;
                Navigator.of(dialogContext).pop(trimmed);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
    nameController.dispose();

    if (name == null || name.trim().isEmpty) return;
    await controller.renameTab(index, name);
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
          _tag('Ambil UUID', labelStyle: TextStyle(fontSize: 8, color: Vx.neutral500)).onInkTap(() {
            Clipboard.setData(ClipboardData(text: '${currentUserId ?? ''}'));
            HelperToast.info('"${currentUserId ?? ''}" disalin', duration: 500.milliseconds);
          }),
          const Spacer(),
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
          final sql = value.codeLines.asString(TextLineBreak.crlf);
          logD(sql);
          controller.updateActiveTabSql(sql);
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
        label: const Text('Jalankan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)).tooltip('⌘+⏎'),
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
          _resultsTab('Hasil', isActive: true),
          const Spacer(),
          Obx(
            () {
              final time = controller.lastRunAt.value;
              final duration = controller.lastDuration;
              var label = 'Query belum dijalankan';
              if (time != null) {
                label = 'Terakhir dijalankan ${DateFormat.Hms().format(time)}';
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
            'Jalankan query untuk melihat hasilnya.',
          );
        } else if (current.hasRows) {
          content = _buildDataTable(current);
        } else {
          final affected = controller.affectedRows;
          content = _buildResultsPlaceholder(
            affected == 0 ? 'Query berhasil dijalankan. Nggak ada baris hasil.' : 'Query berhasil dijalankan. $affected baris terpengaruh.',
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
    HelperToast.info('"$value" disalin', duration: 500.milliseconds);
  }

  Widget _buildResultsFooter() {
    return Obx(
      () {
        final rows = controller.totalRows;
        final columns = controller.columnCount;
        final duration = controller.lastDuration;
        final affected = controller.affectedRows;

        final chips = <String>[
          '$rows baris',
          if (columns > 0) '$columns kolom',
          if (duration != null) '${duration.inMilliseconds} ms',
          if (affected > 0) '$affected terpengaruh',
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 14, color: _mutedText),
              const SizedBox(width: 12),
              if (chips.isEmpty)
                Text(
                  'Menunggu query...',
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

class _SqlTabBar extends StatelessWidget {
  const _SqlTabBar({
    required this.controller,
    required this.surface,
    required this.border,
    required this.mutedText,
    required this.accent,
    required this.onRename,
  });

  final SqlEditorController controller;
  final Color surface;
  final Color border;
  final Color mutedText;
  final Color accent;
  final Future<void> Function(int index, String currentName) onRename;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SizedBox(
        height: 34,
        child: Row(
          children: [
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.tabs.length,
                separatorBuilder: (context, index) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final tab = controller.tabs[index];
                  return _SqlTabItem(
                    label: tab.name,
                    isActive: controller.activeTab.value == index,
                    canClose: controller.tabs.length > 1,
                    surface: surface,
                    border: border,
                    mutedText: mutedText,
                    accent: accent,
                    onTap: () => controller.selectTab(index),
                    onDoubleTap: () => onRename(index, tab.name),
                    onClose: () => controller.closeTab(index),
                  );
                },
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints.tightFor(width: 34, height: 34),
              padding: EdgeInsets.zero,
              tooltip: 'Tambah tab',
              icon: Icon(UIconsPro.solidRounded.plus, size: 16, color: mutedText),
              onPressed: controller.addTab,
            ),
          ],
        ),
      );
    });
  }
}

class _SqlTabItem extends StatelessWidget {
  const _SqlTabItem({
    required this.label,
    required this.isActive,
    required this.canClose,
    required this.surface,
    required this.border,
    required this.mutedText,
    required this.accent,
    required this.onTap,
    required this.onDoubleTap,
    required this.onClose,
  });

  final String label;
  final bool isActive;
  final bool canClose;
  final Color surface;
  final Color border;
  final Color mutedText;
  final Color accent;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final textColor = isActive ? Colors.white : mutedText;

    return GestureDetector(
      onDoubleTap: onDoubleTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: canClose ? 132 : 108,
          height: 34,
          padding: const EdgeInsets.only(left: 10, right: 6),
          decoration: BoxDecoration(
            color: isActive ? accent.withAlpha(35) : surface,
            border: Border.all(color: isActive ? accent.withAlpha(150) : border),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontFamily: 'RobotoMono',
                    height: 1,
                  ),
                ),
              ),
              if (canClose)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints.tightFor(width: 24, height: 24),
                  padding: EdgeInsets.zero,
                  tooltip: 'Tutup tab',
                  icon: Icon(UIconsPro.solidRounded.cross_small, size: 15, color: textColor.withAlpha(180)),
                  onPressed: onClose,
                ),
            ],
          ),
        ),
      ),
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
