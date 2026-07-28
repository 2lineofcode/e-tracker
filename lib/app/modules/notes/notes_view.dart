import 'package:ex_kit/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:get/get.dart';
import 'package:uicons_pro/uicons_pro.dart';

import '../../core/app_color.dart';
import '../../helpers/helpers.dart';
import '../../models/supa_notes_entity.dart';
import 'notes_controller.dart';

class NotesView extends GetView<NotesController> {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        icon: Icon(CupertinoIcons.arrow_left, size: 20),
        onPressed: Get.back,
      ),
      Icon(UIconsPro.solidRounded.notebook, size: 15).pOnly(left: 4, right: 10),
      'Notes'.text.size(12).bold.make(),
      Obx(() {
        if (!controller.hasDirtyChange.value) return SizedBox.shrink();
        return 'Unsaved'.text.size(10).color(AppColor.orangeLight).make().pOnly(left: 10);
      }),
      Spacer(),
      Obx(
        () => IconButton(
          tooltip: controller.isPreviewMode.value ? 'Edit' : 'Preview',
          icon: Icon(
            controller.isPreviewMode.value ? UIconsPro.solidRounded.pen_nib : UIconsPro.solidRounded.eye,
            size: 16,
          ),
          onPressed: controller.togglePreviewMode,
        ),
      ),
      Obx(() {
        if (controller.selectedNote.value == null) return SizedBox.shrink();
        return IconButton(
          tooltip: 'Delete',
          icon: Icon(UIconsPro.solidRounded.trash, size: 16, color: AppColor.red),
          onPressed: () {
            ExAlert.confirm(
              title: 'Delete Note',
              message: 'Are you sure want to delete this note?',
              btnYesText: 'Delete',
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
          tooltip: 'Save',
          icon: controller.isSaving.value
              ? CupertinoActivityIndicator(radius: 8)
              : Icon(UIconsPro.solidRounded.disk, size: 16),
          onPressed: controller.isSaving.value ? null : controller.saveNote,
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
            hint: 'Search notes...',
            suffix:
                Icon(
                  UIconsPro.solidRounded.cross_small,
                  size: 12,
                  color: AppColor.textReverse,
                ).onInkTap(() => controller.tfSearch.clear()),
          ),
        ).h(34).expand(),
        8.widthBox,
        Tooltip(
          message: 'New note',
          child: Container(
            decoration: ExDecorator.box(
              borderRadius: 8,
              borderColor: AppColor.border,
              fillColor: Get.isDarkMode ? AppColor.card : AppColor.box,
            ),
            child: Icon(UIconsPro.solidRounded.plus, size: 15).centered(),
          ).wh(34, 34).onInkTap(controller.createNewNote),
        ),
      ]).p12(),
      Obx(() {
        if (controller.filteredNotes.isEmpty) {
          return VStack([
            Icon(Icons.note_alt_outlined, size: 54, color: Vx.neutral400).centered(),
            8.heightBox,
            'No notes found'.text.size(12).color(Vx.neutral400).makeCentered(),
          ]).centered().expand();
        }

        return ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 12),
          itemCount: controller.filteredNotes.length,
          separatorBuilder: (context, index) => 10.heightBox,
          itemBuilder: (context, index) {
            final note = controller.filteredNotes[index];
            return Obx(() {
              final isSelected = controller.selectedNote.value?.id == note.id;
              return _NoteTile(
                note: note,
                isSelected: isSelected,
                contentPreview: controller.notePlainText(note.content),
                onTap: () => controller.openNote(note),
              );
            });
          },
        ).expand();
      }),
    ]);
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({
    required this.note,
    required this.isSelected,
    required this.contentPreview,
    required this.onTap,
  });

  final SupaNotes note;
  final bool isSelected;
  final String contentPreview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = (note.title ?? '').trim().isEmpty ? 'Untitled note' : note.title ?? '';
    final content = contentPreview.trim();

    return Container(
      decoration: ExDecorator.box(
        borderRadius: 8,
        borderColor: isSelected ? AppColor.primary : AppColor.border,
        fillColor: isSelected ? AppColor.sideMenuSelected : AppColor.box,
      ),
      child: VStack([
        HStack([
          Icon(UIconsPro.solidRounded.circle, size: 9, color: isSelected ? AppColor.primary : AppColor.neutral).pOnly(right: 8),
          title.text.size(12).bold.maxLines(1).ellipsis.make().expand(),
        ]),
        if (content.isNotEmpty) ...[
          6.heightBox,
          content.text.size(10).maxLines(2).ellipsis.color(AppColor.neutral).make(),
        ],
        if (note.updatedAt != null) ...[
          8.heightBox,
          '${note.updatedAt?.reformatDate(to: 'dd MMM yyyy, HH:mm')}'.text.size(9).color(AppColor.neutral).make(),
        ],
      ]).pSymmetric(h: 10, v: 10),
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
            hintText: 'Untitled note',
            hintStyle: TextStyle(color: AppColor.neutral),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
      Obx(() {
        return VStack([
          if (!controller.isPreviewMode.value) _QuillEditorToolbar(controller: controller).pSymmetric(h: 16).pOnly(bottom: 12),
          _QuillEditor(controller: controller).expand(),
        ]).expand();
      }),
    ]);
  }
}

class _QuillEditor extends StatelessWidget {
  const _QuillEditor({required this.controller});

  final NotesController controller;

  @override
  Widget build(BuildContext context) {
    final editorBackground = Get.isDarkMode ? AppColor.card : AppColor.box;
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
        child: QuillEditor.basic(
          controller: controller.quillController,
          configurations: QuillEditorConfigurations(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            placeholder: 'Write your note...',
            showCursor: !controller.isPreviewMode.value,
            readOnlyMouseCursor: SystemMouseCursors.basic,
            embedBuilders: [
              _NoteTableEmbedBuilder(notesController: controller),
            ],
            customStyles: DefaultStyles(
              paragraph: DefaultTextBlockStyle(
                TextStyle(color: AppColor.textReverse, fontSize: 13, height: 1.5),
                HorizontalSpacing.zero,
                VerticalSpacing(4, 4),
                VerticalSpacing.zero,
                null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuillEditorToolbar extends StatelessWidget {
  const _QuillEditorToolbar({required this.controller});

  final NotesController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Get.isDarkMode ? AppColor.card : AppColor.box,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.border.withAlpha(80)),
      ),
      child: QuillToolbar.simple(
        controller: controller.quillController,
        configurations: QuillSimpleToolbarConfigurations(
          multiRowsDisplay: false,
          toolbarSize: 28,
          showFontFamily: false,
          showFontSize: false,
          showSmallButton: false,
          showSubscript: false,
          showSuperscript: false,
          showSearchButton: false,
          showClipboardCut: false,
          showClipboardCopy: false,
          showClipboardPaste: false,
          showDirection: false,
          showColorButton: false,
          showBackgroundColorButton: false,
          customButtons: [
            QuillToolbarCustomButtonOptions(
              tooltip: 'Insert table',
              icon: Icon(Icons.table_chart, size: 13),
              onPressed: () => _insertTable(controller.quillController),
            ),
          ],
          buttonOptions: QuillSimpleToolbarButtonOptions(
            base: QuillToolbarBaseButtonOptions(
              iconSize: 13,
              iconTheme: QuillIconTheme(
                iconButtonSelectedData: IconButtonData(
                  color: AppColor.primary,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColor.primary.withAlpha(28),
                    minimumSize: Size(26, 26),
                    padding: EdgeInsets.zero,
                  ),
                ),
                iconButtonUnselectedData: IconButtonData(
                  color: AppColor.textReverse,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    minimumSize: Size(26, 26),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _insertTable(QuillController controller) {
    final selection = controller.selection;
    final start = selection.start < 0 ? 0 : selection.start;
    final length = selection.end - selection.start;
    final delta = Delta()
      ..insert({
        'table': _createTableData(3, 3),
      });

    controller.replaceText(
      start,
      length < 0 ? 0 : length,
      delta,
      TextSelection.collapsed(offset: start + 1),
    );
  }

  Map<String, dynamic> _createTableData(int rows, int columns) {
    return {
      'rows': List.generate(
        rows,
        (_) => List.generate(columns, (_) => ''),
      ),
    };
  }
}

class _NoteTableEmbedBuilder extends EmbedBuilder {
  const _NoteTableEmbedBuilder({required this.notesController});

  final NotesController notesController;

  @override
  String get key => 'table';

  @override
  Widget build(
    BuildContext context,
    QuillController controller,
    Embed node,
    bool readOnly,
    bool inline,
    TextStyle textStyle,
  ) {
    final tableData = _normalizeTableData(node.value.data);
    return _NoteTableWidget(
      notesController: notesController,
      tableData: tableData,
      readOnly: readOnly,
    );
  }

  Map<String, dynamic> _normalizeTableData(dynamic data) {
    if (data is Map && data['rows'] is List) {
      if (data is Map<String, dynamic>) return data;
      return data.cast<String, dynamic>();
    }

    return {
      'rows': [
        ['', '', ''],
        ['', '', ''],
        ['', '', ''],
      ],
    };
  }
}

class _NoteTableWidget extends StatefulWidget {
  const _NoteTableWidget({
    required this.notesController,
    required this.tableData,
    required this.readOnly,
  });

  final NotesController notesController;
  final Map<String, dynamic> tableData;
  final bool readOnly;

  @override
  State<_NoteTableWidget> createState() => _NoteTableWidgetState();
}

class _NoteTableWidgetState extends State<_NoteTableWidget> {
  late List<List<TextEditingController>> _cellControllers;
  late List<List<dynamic>> _rows;

  @override
  void initState() {
    super.initState();
    _rows = (widget.tableData['rows'] as List)
        .map((row) => row is List ? row : [''])
        .map((row) => row.toList())
        .toList();
    widget.tableData['rows'] = _rows;
    _cellControllers = _rows
        .map(
          (row) => row.map((cell) => TextEditingController(text: cell)).toList(),
        )
        .toList();
  }

  @override
  void dispose() {
    for (final row in _cellControllers) {
      for (final controller in row) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: FixedColumnWidth(140),
        border: TableBorder.all(color: AppColor.border.withAlpha(120)),
        children: List.generate(_rows.length, (rowIndex) {
          return TableRow(
            children: List.generate(_rows[rowIndex].length, (columnIndex) {
              return _buildCell(rowIndex, columnIndex);
            }),
          );
        }),
      ).pOnly(bottom: 10),
    );
  }

  Widget _buildCell(int rowIndex, int columnIndex) {
    if (widget.readOnly) {
      return Text(
        '${_rows[rowIndex][columnIndex]}',
        style: TextStyle(color: AppColor.textReverse, fontSize: 12),
      ).pSymmetric(h: 8, v: 7);
    }

    return TextField(
      controller: _cellControllers[rowIndex][columnIndex],
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
        widget.notesController.markDirty();
      },
    );
  }
}
