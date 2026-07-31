import 'package:ex_kit/ex.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uicons_pro/uicons_pro.dart';

import '../../core/app_color.dart';
import '../../helpers/helpers.dart';
import '../../models/supa_notes_entity.dart';
import 'notes_controller.dart';
import 'notes_markdown_clipboard.dart';

class NotesView extends GetView<NotesController> {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop: !controller.hasDirtyChange.value && !controller.isSaving.value,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          controller.confirmDiscardChanges(() => Get.back(result: result));
        },
        child: Scaffold(
          backgroundColor: AppColor.scaffoldPrimary,
          body: SafeArea(
            child: VStack([
              _NotesHeader(controller: controller).pOnly(left: 12, top: 28, right: 12, bottom: 12),
              Obx(() {
                if (controller.isLoading.value && controller.notesList.isEmpty) {
                  return CupertinoActivityIndicator().centered();
                }

                if (context.isMobile) {
                  return VStack([
                    _NotesSidePanel(controller: controller).h(220),
                    Divider(height: 1, color: AppColor.border.withAlpha(80)),
                    _NoteEditorPanel(controller: controller).expand(),
                  ]);
                }

                return HStack([
                  _NotesSidePanel(controller: controller).w(290),
                  VerticalDivider(width: 1, color: AppColor.border.withAlpha(80)),
                  _NoteEditorPanel(controller: controller).expand(),
                ]);
              }).expand(),
            ]),
          ),
        ),
      ),
    );
  }
}

class _NotesHeader extends StatelessWidget {
  const _NotesHeader({required this.controller});

  final NotesController controller;

  @override
  Widget build(BuildContext context) {
    return HStack([
      IconButton(
        tooltip: 'Kembali',
        icon: Icon(CupertinoIcons.arrow_left, size: 20),
        onPressed: controller.isSaving.value
            ? null
            : () => controller.confirmDiscardChanges(() => Get.back()),
      ),
      Icon(UIconsPro.solidRounded.notebook, size: 15).pOnly(left: 4, right: 10),
      'Note'.text.size(12).bold.make(),
      Obx(() {
        if (controller.isSaving.value) {
          return 'Menyimpan...'.text.size(10).color(AppColor.neutral).make().pOnly(left: 10);
        }
        if (controller.hasDirtyChange.value) {
          return 'Belum disimpan'.text.size(10).color(AppColor.orangeLight).make().pOnly(left: 10);
        }
        return SizedBox.shrink();
      }),
      Spacer(),
      Obx(
        () => IconButton(
          tooltip: controller.isPreviewMode.value ? 'Ubah' : 'Lihat hasil',
          icon: Icon(
            controller.isPreviewMode.value ? UIconsPro.solidRounded.pen_nib : UIconsPro.solidRounded.eye,
            size: 16,
          ),
          onPressed: controller.isSaving.value ? null : controller.togglePreviewMode,
        ),
      ),
      Obx(() {
        final note = controller.selectedNote.value;
        if (note == null) return SizedBox.shrink();
        return IconButton(
          tooltip: note.isPinned ? 'Lepas pin' : 'Pin',
          icon: Icon(
            note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            size: 16,
            color: note.isPinned ? AppColor.primary : null,
          ),
          onPressed: controller.isPinning.value
              ? null
              : () => controller.togglePinned(note),
        );
      }),
      Obx(() {
        if (controller.selectedNote.value == null) return SizedBox.shrink();
        return IconButton(
          tooltip: 'Hapus',
          icon: Icon(UIconsPro.solidRounded.trash, size: 16, color: AppColor.red),
          onPressed: controller.isSaving.value
              ? null
              : () {
                  ExAlert.confirm(
                    title: 'Hapus note ini?',
                    message: 'Note yang dihapus nggak bisa dikembalikan.',
                    btnYesText: 'Hapus',
                    onYes: () async {
                      Get.back();
                      await controller.deleteSelectedNote();
                    },
                  );
                },
        );
      }),
      Obx(
        () => IconButton(
          tooltip: 'Simpan',
          icon: controller.isSaving.value
              ? CupertinoActivityIndicator(radius: 8)
              : Icon(UIconsPro.solidRounded.disk, size: 16),
          onPressed: controller.isSaving.value || !controller.hasDirtyChange.value
              ? null
              : controller.saveNote,
        ),
      ),
    ]);
  }
}

class _NotesSidePanel extends StatelessWidget {
  const _NotesSidePanel({required this.controller});

  final NotesController controller;

  @override
  Widget build(BuildContext context) {
    return VStack([
      HStack([
        TextField(
          controller: controller.tfSearch,
          style: TextStyle(fontSize: 12),
          decoration: HelperDecoration.input(
            fillColor: Get.isDarkMode ? AppColor.card : null,
            prefixIcon: Icon(UIconsPro.regularRounded.search, size: 13),
            hint: 'Cari note...',
            suffix: Tooltip(
              message: 'Hapus pencarian',
              child:
                  Icon(
                    UIconsPro.solidRounded.cross_small,
                    size: 12,
                    color: AppColor.textReverse,
                  ).p4().onInkTap(() => controller.tfSearch.clear()),
            ),
          ),
        ).h(34).expand(),
        8.widthBox,
        Tooltip(
          message: 'Note baru',
          child: Container(
            decoration: ExDecorator.box(
              borderRadius: 8,
              borderColor: AppColor.border,
              fillColor: Get.isDarkMode ? AppColor.card : AppColor.box,
            ),
            child: Icon(UIconsPro.solidRounded.plus, size: 15).centered(),
          ).wh(34, 34).onInkTap(
            () => controller.confirmDiscardChanges(controller.createNewNote),
          ),
        ),
      ]).p12(),
      Obx(() {
        if (controller.filteredNotes.isEmpty) {
          return VStack([
            Icon(Icons.note_alt_outlined, size: 54, color: Vx.neutral400).centered(),
            8.heightBox,
            'Note nggak ditemukan'.text.size(12).color(Vx.neutral400).makeCentered(),
          ]).centered().expand();
        }

        final pinnedNotes =
            controller.filteredNotes.where((note) => note.isPinned);
        final notes =
            controller.filteredNotes.where((note) => !note.isPinned);
        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 12),
          children: [
            if (pinnedNotes.isNotEmpty) ...[
              'DI-PIN'.text
                  .size(9)
                  .bold
                  .color(AppColor.neutral)
                  .make()
                  .pOnly(left: 2, top: 4, bottom: 8),
              ...pinnedNotes.map(_buildNoteTile),
            ],
            if (notes.isNotEmpty) ...[
              'NOTE'.text
                  .size(9)
                  .bold
                  .color(AppColor.neutral)
                  .make()
                  .pOnly(
                    left: 2,
                    top: pinnedNotes.isEmpty ? 4 : 8,
                    bottom: 8,
                  ),
              ...notes.map(_buildNoteTile),
            ],
          ],
        ).expand();
      }),
    ]);
  }

  Widget _buildNoteTile(SupaNotes note) {
    final isSelected = controller.selectedNote.value?.id == note.id;
    return _NoteTile(
      note: note,
      isSelected: isSelected,
      onPin: () => controller.togglePinned(note),
      onTap: () {
        if (isSelected) return;
        controller.confirmDiscardChanges(() => controller.openNote(note));
      },
    ).pOnly(bottom: 10);
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({
    required this.note,
    required this.isSelected,
    required this.onPin,
    required this.onTap,
  });

  final SupaNotes note;
  final bool isSelected;
  final VoidCallback onPin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = (note.title ?? '').trim().isEmpty ? 'Note tanpa judul' : note.title ?? '';

    return Container(
      decoration: ExDecorator.box(
        borderRadius: 8,
        borderColor: isSelected ? AppColor.primary : AppColor.border,
        fillColor: isSelected ? AppColor.sideMenuSelected : AppColor.box,
      ),
      child: VStack([
        HStack([
          title.text.size(12).bold.maxLines(1).ellipsis.make().expand(),
          IconButton(
            tooltip: note.isPinned ? 'Lepas pin' : 'Pin',
            icon: Icon(
              note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              size: 13,
              color: note.isPinned ? AppColor.primary : AppColor.neutral,
            ),
            style: IconButton.styleFrom(
              minimumSize: Size(24, 24),
              maximumSize: Size(24, 24),
              padding: EdgeInsets.zero,
            ),
            onPressed: onPin,
          ),
        ]),
        if (note.createdAt != null) ...[
          6.heightBox,
          '${note.createdAt?.reformatDate(to: 'dd MMM yyyy, HH:mm')}'.text.size(10).color(AppColor.neutral).make(),
        ],
      ]).pSymmetric(h: 10, v: 8),
    ).onInkTap(onTap);
  }
}

class _NoteEditorPanel extends StatelessWidget {
  const _NoteEditorPanel({required this.controller});

  final NotesController controller;

  @override
  Widget build(BuildContext context) {
    return VStack([
      Obx(
        () => TextField(
          controller: controller.tfTitle,
          readOnly: controller.isPreviewMode.value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Note tanpa judul',
            hintStyle: TextStyle(color: AppColor.neutral),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
      Obx(() {
        final editorRevision = controller.editorRevision.value;
        return VStack([
          if (!controller.isPreviewMode.value) _FleatherEditorToolbar(controller: controller).pSymmetric(h: 16).pOnly(bottom: 12),
          _FleatherNoteEditor(
            key: ValueKey(editorRevision),
            controller: controller,
          ).expand(),
          _NoteFooter(controller: controller),
        ]).expand();
      }),
    ]);
  }
}

class _NoteFooter extends StatelessWidget {
  const _NoteFooter({required this.controller});

  final NotesController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.fleatherController,
      builder: (context, child) => HStack([
        Spacer(),
        'karakter:${controller.characterCount}'.text
            .size(10)
            .color(AppColor.neutral)
            .make(),
        12.widthBox,
        'kata:${controller.wordCount}'.text
            .size(10)
            .color(AppColor.neutral)
            .make(),
      ]).pOnly(left: 16, right: 16, bottom: 12),
    );
  }
}

class _FleatherNoteEditor extends StatelessWidget {
  const _FleatherNoteEditor({
    super.key,
    required this.controller,
  });

  final NotesController controller;

  @override
  Widget build(BuildContext context) {
    final editorBackground = Get.isDarkMode ? AppColor.card : AppColor.box;
    final fleatherController = controller.fleatherController;
    final baseTheme = FleatherThemeData.fallback(context);
    final textStyle = TextStyle(
      color: AppColor.textReverse,
      fontSize: 13,
      height: 1.5,
    );
    final blockSpacing = VerticalSpacing(top: 4, bottom: 4);

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: editorBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.border.withAlpha(80)),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onDoubleTap: controller.enterEditMode,
        child: CheckboxTheme(
          data: CheckboxThemeData(
            fillColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? AppColor.primary
                  : Colors.transparent,
            ),
            checkColor: WidgetStatePropertyAll(AppColor.textOnBackground),
            side: BorderSide(color: AppColor.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: FleatherTheme(
            data: baseTheme.copyWith(
              link: TextStyle(
                color: AppColor.primary,
                decoration: TextDecoration.underline,
                decorationColor: AppColor.primary,
              ),
              paragraph: TextBlockTheme(
                style: textStyle,
                spacing: blockSpacing,
              ),
              heading1: _textBlock(
                textStyle.copyWith(
                  fontSize: 24,
                  height: 1.25,
                  fontWeight: FontWeight.bold,
                ),
                top: 12,
              ),
              heading2: _textBlock(
                textStyle.copyWith(
                  fontSize: 19,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                ),
                top: 10,
              ),
              heading3: _textBlock(
                textStyle.copyWith(
                  fontSize: 16,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
                top: 8,
              ),
              lists: TextBlockTheme(
                style: textStyle,
                spacing: blockSpacing,
                lineSpacing: VerticalSpacing(bottom: 2),
              ),
              quote: TextBlockTheme(
                style: textStyle.copyWith(
                  color: AppColor.neutral,
                  fontStyle: FontStyle.italic,
                ),
                spacing: VerticalSpacing(top: 6, bottom: 6),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: AppColor.primary, width: 3),
                  ),
                ),
              ),
              code: TextBlockTheme(
                style: textStyle.copyWith(
                  fontSize: 12,
                  fontFamily: 'Menlo',
                ),
                spacing: VerticalSpacing(top: 6, bottom: 6),
                decoration: BoxDecoration(
                  color: AppColor.scaffoldPrimary,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            child: AnimatedBuilder(
              animation: fleatherController,
              child: FleatherEditor(
                controller: fleatherController,
                editorKey: controller.editorKey,
                focusNode: controller.editorFocusNode,
                readOnly: controller.isPreviewMode.value,
                showCursor: !controller.isPreviewMode.value,
                expands: true,
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                clipboardManager: NotesMarkdownClipboardManager(
                  fleatherController,
                ),
                embedBuilder: (context, node) => _buildEmbed(context, node),
              ),
              builder: (context, editor) {
                final isEmpty = fleatherController.document.toPlainText().trim().isEmpty;
                return Stack(children: [
                  Positioned.fill(child: editor!),
                  if (isEmpty)
                    Positioned(
                      left: 14,
                      top: 16,
                      child: IgnorePointer(
                        child: 'Tulis note kamu...'.text
                            .size(13)
                            .color(AppColor.neutral)
                            .make(),
                      ),
                    ),
                ]);
              },
            ),
          ),
        ),
      ),
    );
  }

  TextBlockTheme _textBlock(TextStyle style, {required double top}) {
    return TextBlockTheme(
      style: style,
      spacing: VerticalSpacing(top: top, bottom: 4),
    );
  }

  Widget _buildEmbed(BuildContext context, EmbedNode node) {
    if (node.value.type == 'table') {
      final tableData = Map<String, dynamic>.from(node.value.data);
      final tableId = tableData['id'] as String?;
      final editedRows = controller.tableRows(tableId);
      if (editedRows != null) tableData['rows'] = editedRows;
      return _NoteTableWidget(
        key: ValueKey(tableId ?? node.documentOffset),
        tableData: tableData,
        readOnly: controller.isPreviewMode.value,
        autofocus: controller.consumeTableFocus(tableId),
        onChanged: tableId == null
            ? (_) {}
            : (rows) => controller.updateTable(tableId, rows),
        onDelete: () {
          ExAlert.confirm(
            title: 'Hapus tabel?',
            message: 'Tabel yang dihapus nggak bisa dikembalikan.',
            btnYesText: 'Hapus',
            onYes: () {
              Get.back();
              controller.deleteTable(node.documentOffset, tableId);
            },
          );
        },
      );
    }

    if (node.value.type == 'hr') {
      return defaultFleatherEmbedBuilder(context, node);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColor.scaffoldPrimary,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColor.border.withAlpha(80)),
      ),
      child: HStack([
        Icon(Icons.attachment, size: 13, color: AppColor.neutral),
        8.widthBox,
        'Lampiran ${node.value.type}'.text
            .size(11)
            .color(AppColor.neutral)
            .make(),
      ]).pSymmetric(h: 10, v: 8),
    );
  }
}

class _FleatherEditorToolbar extends StatelessWidget {
  const _FleatherEditorToolbar({required this.controller});

  final NotesController controller;

  @override
  Widget build(BuildContext context) {
    final editor = controller.fleatherController;
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: Get.isDarkMode ? AppColor.card : AppColor.box,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.border.withAlpha(80)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: HStack([
          _HeadingButton(
            editor: editor,
            focusNode: controller.editorFocusNode,
          ),
          _ToolbarDivider(),
          _FormatButton(
            tooltip: 'Tebal',
            icon: Icons.format_bold,
            attribute: ParchmentAttribute.bold,
            editor: editor,
            focusNode: controller.editorFocusNode,
          ),
          _FormatButton(
            tooltip: 'Miring',
            icon: Icons.format_italic,
            attribute: ParchmentAttribute.italic,
            editor: editor,
            focusNode: controller.editorFocusNode,
          ),
          _FormatButton(
            tooltip: 'Garis bawah',
            icon: Icons.format_underline,
            attribute: ParchmentAttribute.underline,
            editor: editor,
            focusNode: controller.editorFocusNode,
          ),
          _FormatButton(
            tooltip: 'Coret',
            icon: Icons.format_strikethrough,
            attribute: ParchmentAttribute.strikethrough,
            editor: editor,
            focusNode: controller.editorFocusNode,
          ),
          _ToolbarDivider(),
          _FormatButton(
            tooltip: 'Daftar poin',
            icon: Icons.format_list_bulleted,
            attribute: ParchmentAttribute.block.bulletList,
            editor: editor,
            focusNode: controller.editorFocusNode,
          ),
          _FormatButton(
            tooltip: 'Daftar nomor',
            icon: Icons.format_list_numbered,
            attribute: ParchmentAttribute.block.numberList,
            editor: editor,
            focusNode: controller.editorFocusNode,
          ),
          _FormatButton(
            tooltip: 'Daftar centang',
            icon: Icons.checklist,
            attribute: ParchmentAttribute.block.checkList,
            editor: editor,
            focusNode: controller.editorFocusNode,
          ),
          _FormatButton(
            tooltip: 'Kutipan',
            icon: Icons.format_quote,
            attribute: ParchmentAttribute.block.quote,
            editor: editor,
            focusNode: controller.editorFocusNode,
          ),
          _FormatButton(
            tooltip: 'Blok kode',
            icon: Icons.code,
            attribute: ParchmentAttribute.block.code,
            editor: editor,
            focusNode: controller.editorFocusNode,
          ),
          _ToolbarDivider(),
          AnimatedBuilder(
            animation: editor,
            builder: (context, child) => _ToolbarButton(
              tooltip: 'Tambah link',
              icon: Icons.link,
              onPressed: editor.selection.isCollapsed
                  ? null
                  : () => _addLink(context, editor),
            ),
          ),
          _TableInsertButton(
            onSelected: controller.insertTable,
          ),
          _ToolbarDivider(),
          AnimatedBuilder(
            animation: editor,
            builder: (context, child) => _ToolbarButton(
              tooltip: 'Urungkan',
              icon: Icons.undo,
              onPressed: editor.canUndo ? editor.undo : null,
            ),
          ),
          AnimatedBuilder(
            animation: editor,
            builder: (context, child) => _ToolbarButton(
              tooltip: 'Ulangi',
              icon: Icons.redo,
              onPressed: editor.canRedo ? editor.redo : null,
            ),
          ),
        ]).pSymmetric(h: 4),
      ),
    );
  }

  Future<void> _addLink(
    BuildContext context,
    FleatherController editor,
  ) async {
    final input = TextEditingController();
    final link = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambah link'),
        content: TextField(
          controller: input,
          autofocus: true,
          decoration: InputDecoration(hintText: 'https://'),
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, input.text.trim()),
            child: Text('Tambah'),
          ),
        ],
      ),
    );
    input.dispose();
    if (link == null || link.isEmpty) return;
    editor.formatSelection(ParchmentAttribute.link.fromString(link));
    controller.editorFocusNode.requestFocus();
  }
}

class _HeadingButton extends StatelessWidget {
  const _HeadingButton({
    required this.editor,
    required this.focusNode,
  });

  final FleatherController editor;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: PopupMenuButton<int>(
        tooltip: 'Gaya teks',
        padding: EdgeInsets.zero,
        icon: Icon(Icons.title, size: 15),
        itemBuilder: (context) => [
          PopupMenuItem(value: 0, child: Text('Normal')),
          PopupMenuItem(value: 1, child: Text('Judul 1')),
          PopupMenuItem(value: 2, child: Text('Judul 2')),
          PopupMenuItem(value: 3, child: Text('Judul 3')),
        ],
        onSelected: (value) {
          final attribute = switch (value) {
            1 => ParchmentAttribute.heading.level1,
            2 => ParchmentAttribute.heading.level2,
            3 => ParchmentAttribute.heading.level3,
            _ => ParchmentAttribute.heading.unset,
          };
          editor.formatSelection(attribute);
          focusNode.requestFocus();
        },
      ),
    );
  }
}

class _FormatButton extends StatelessWidget {
  const _FormatButton({
    required this.tooltip,
    required this.icon,
    required this.attribute,
    required this.editor,
    required this.focusNode,
  });

  final String tooltip;
  final IconData icon;
  final ParchmentAttribute attribute;
  final FleatherController editor;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: editor,
      builder: (context, child) {
        final isSelected = editor.getSelectionStyle().containsSame(attribute);
        return _ToolbarButton(
          tooltip: tooltip,
          icon: icon,
          isSelected: isSelected,
          onPressed: () {
            editor.formatSelection(
              isSelected ? attribute.unset : attribute,
            );
            focusNode.requestFocus();
          },
        );
      },
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.isSelected = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 14),
        color: isSelected ? AppColor.primary : AppColor.textReverse,
        disabledColor: AppColor.neutral.withAlpha(80),
        style: IconButton.styleFrom(
          backgroundColor: isSelected
              ? AppColor.primary.withAlpha(28)
              : Colors.transparent,
          minimumSize: Size(28, 28),
          maximumSize: Size(28, 28),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class _ToolbarDivider extends StatelessWidget {
  const _ToolbarDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 18,
      color: AppColor.border.withAlpha(100),
    ).pSymmetric(h: 4);
  }
}

class _TableInsertButton extends StatelessWidget {
  const _TableInsertButton({required this.onSelected});

  final void Function(int rows, int columns) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: PopupMenuButton<(int, int)>(
        tooltip: 'Sisipkan tabel',
        padding: EdgeInsets.zero,
        icon: Icon(Icons.table_chart_outlined, size: 14),
        itemBuilder: (context) => [
          PopupMenuItem(value: (2, 2), child: Text('2 × 2')),
          PopupMenuItem(value: (3, 3), child: Text('3 × 3')),
          PopupMenuItem(value: (4, 4), child: Text('4 × 4')),
        ],
        onSelected: (size) => onSelected(size.$1, size.$2),
      ),
    );
  }
}

class _NoteTableWidget extends StatefulWidget {
  const _NoteTableWidget({
    super.key,
    required this.tableData,
    required this.readOnly,
    required this.autofocus,
    required this.onChanged,
    required this.onDelete,
  });

  final Map<String, dynamic> tableData;
  final bool readOnly;
  final bool autofocus;
  final ValueChanged<List<List<String>>> onChanged;
  final VoidCallback onDelete;

  @override
  State<_NoteTableWidget> createState() => _NoteTableWidgetState();
}

class _NoteTableWidgetState extends State<_NoteTableWidget> {
  late List<List<TextEditingController>> _cellControllers;
  late List<List<String>> _rows;

  @override
  void initState() {
    super.initState();
    _setRows(_readRows(), disposeOld: false);
  }

  @override
  void didUpdateWidget(covariant _NoteTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextRows = _readRows();
    if (!_sameRows(_rows, nextRows)) {
      _setRows(nextRows);
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.border.withAlpha(120)),
        borderRadius: BorderRadius.circular(6),
      ),
      clipBehavior: Clip.antiAlias,
      child: VStack([
        if (!widget.readOnly)
          HStack([
            '${_rows.length} × ${_rows.first.length}'.text
                .size(10)
                .color(AppColor.neutral)
                .make(),
            Spacer(),
            _TableActionButton(
              tooltip: 'Hapus baris',
              label: 'Baris −',
              onPressed: _rows.length == 1 ? null : () => _changeRows(-1),
            ),
            _TableActionButton(
              tooltip: 'Tambah baris',
              label: 'Baris +',
              onPressed: _rows.length == 20 ? null : () => _changeRows(1),
            ),
            _TableActionButton(
              tooltip: 'Hapus kolom',
              label: 'Kolom −',
              onPressed: _rows.first.length == 1
                  ? null
                  : () => _changeColumns(-1),
            ),
            _TableActionButton(
              tooltip: 'Tambah kolom',
              label: 'Kolom +',
              onPressed: _rows.first.length == 20
                  ? null
                  : () => _changeColumns(1),
            ),
            IconButton(
              tooltip: 'Hapus tabel',
              icon: Icon(Icons.delete_outline, size: 14, color: AppColor.red),
              style: IconButton.styleFrom(
                minimumSize: Size(28, 28),
                maximumSize: Size(28, 28),
                padding: EdgeInsets.zero,
              ),
              onPressed: widget.onDelete,
            ),
          ]).pSymmetric(h: 8, v: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultColumnWidth: FixedColumnWidth(140),
            border: TableBorder(
              top: widget.readOnly
                  ? BorderSide.none
                  : BorderSide(color: AppColor.border.withAlpha(120)),
              horizontalInside: BorderSide(color: AppColor.border.withAlpha(120)),
              verticalInside: BorderSide(color: AppColor.border.withAlpha(120)),
            ),
            children: List.generate(_rows.length, (rowIndex) {
              return TableRow(
                children: List.generate(_rows[rowIndex].length, (columnIndex) {
                  return _buildCell(rowIndex, columnIndex);
                }),
              );
            }),
          ),
        ),
      ]),
    );
  }

  Widget _buildCell(int rowIndex, int columnIndex) {
    if (widget.readOnly) {
      return Text(
        _rows[rowIndex][columnIndex],
        style: TextStyle(color: AppColor.textReverse, fontSize: 12),
      ).pSymmetric(h: 8, v: 7);
    }

    return TextField(
      controller: _cellControllers[rowIndex][columnIndex],
      autofocus: widget.autofocus && rowIndex == 0 && columnIndex == 0,
      minLines: 1,
      maxLines: 4,
      style: TextStyle(color: AppColor.textReverse, fontSize: 12),
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      ),
      onChanged: (value) {
        _rows[rowIndex][columnIndex] = value;
        widget.onChanged(
          _rows.map((row) => List<String>.from(row)).toList(),
        );
      },
    );
  }

  List<List<String>> _readRows() {
    final data = widget.tableData['rows'];
    if (data is! List || data.isEmpty) {
      return List.generate(3, (_) => List.generate(3, (_) => ''));
    }
    return data.map((row) {
      if (row is! List || row.isEmpty) return <String>[''];
      return row.map((cell) => '$cell').toList();
    }).toList();
  }

  bool _sameRows(List<List<String>> first, List<List<String>> second) {
    if (first.length != second.length) return false;
    for (var row = 0; row < first.length; row++) {
      if (first[row].length != second[row].length) return false;
      for (var column = 0; column < first[row].length; column++) {
        if (first[row][column] != second[row][column]) return false;
      }
    }
    return true;
  }

  void _setRows(
    List<List<String>> rows, {
    bool disposeOld = true,
  }) {
    if (disposeOld) _disposeControllers();
    _rows = rows;
    _cellControllers = _rows
        .map(
          (row) => row
              .map((cell) => TextEditingController(text: cell))
              .toList(),
        )
        .toList();
  }

  void _changeRows(int delta) {
    final rows = _rows.map((row) => List<String>.from(row)).toList();
    if (delta > 0) {
      rows.add(List.generate(rows.first.length, (_) => ''));
    } else {
      rows.removeLast();
    }
    setState(() => _setRows(rows));
    widget.onChanged(rows);
  }

  void _changeColumns(int delta) {
    final rows = _rows.map((row) {
      final cells = List<String>.from(row);
      if (delta > 0) {
        cells.add('');
      } else {
        cells.removeLast();
      }
      return cells;
    }).toList();
    setState(() => _setRows(rows));
    widget.onChanged(rows);
  }

  void _disposeControllers() {
    for (final row in _cellControllers) {
      for (final controller in row) {
        controller.dispose();
      }
    }
  }
}

class _TableActionButton extends StatelessWidget {
  const _TableActionButton({
    required this.tooltip,
    required this.label,
    required this.onPressed,
  });

  final String tooltip;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: TextButton(
        style: TextButton.styleFrom(
          minimumSize: Size(0, 28),
          padding: EdgeInsets.symmetric(horizontal: 6),
          textStyle: TextStyle(fontSize: 10),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
