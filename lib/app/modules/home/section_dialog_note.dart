import 'package:ex_kit/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lorem/flutter_lorem.dart';
import 'package:get/get.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:overlayment/overlayment.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/markdown.dart';
import 'package:re_highlight/styles/atom-one-dark.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:uuid/v4.dart';

import '../../core/app_api.dart';
import '../../core/app_color.dart';
import '../../models/supa_notes_entity.dart';
import 'home_controller.dart';

mixin DialogNote {
  /// ------------------------------------------------------------------------
  /// Dialog Note
  /// ------------------------------------------------------------------------
  static Future<void> openList() async {
    final _controller = Get.find<HomeController>();

    if (_controller.notesList.isEmpty) {
      ExLoading.show(
        paddingSymmetric: Get.context!.isMobile ? 90 : 250,
        child: CupertinoActivityIndicator(),
      );
      await _controller.loadNotesList();
      ExLoading.dismiss();
    }

    await Overlayment.show(
      context: Get.context!,
      OverPanel(
        alignment: Alignment.centerRight,
        width: 300,
        backgroundSettings: BackgroundSettings(
          color: Color.fromARGB(255, 204, 211, 186).withAlpha(20),
          blur: 1,
        ),
        animation: OverSlideAnimation(
          begin: Offset(1, 0),
          end: Offset(0, 0),
          durationMilliseconds: 100,
          reverseDurationMilliseconds: 100,
        ),

        child: VStack([
          // title
          HStack([
            Icon(UIconsPro.solidRounded.notebook, size: 16).pOnly(right: 12),
            'Notes'.text.bold.make().pSymmetric(h: 8, v: 2).color(AppColor.border).cornerRadius(4),
            Spacer(),
            IconButton(
              icon: Icon(UIconsPro.solidRounded.plus, size: 16),
              onPressed: () => openAddEdit(),
            ),
          ]).pOnly(bottom: 8),

          // body
          Obx(() {
            final notes = _controller.notesList;
            if (notes.isEmpty) {
              return VStack([
                Icon(
                  Icons.indeterminate_check_box,
                  size: 64,
                  color: Vx.neutral400,
                ).centered(),
                12.heightBox,
                'No notes yet'.text.size(12).color(Vx.neutral400).makeCentered().pSymmetric(v: 12),
              ]).centered();
            }
            return ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: notes.length,
              separatorBuilder: (context, index) => 12.heightBox,
              itemBuilder: (context, index) {
                final item = notes[index];

                return Container(
                  decoration: ExDecorator.box(
                    borderRadius: 12,
                    borderColor: AppColor.border,
                    fillColor: AppColor.box,
                  ),
                  child: HStack([
                    Icon(
                      UIconsPro.solidRounded.circle,
                      size: 12,
                    ).pOnly(right: 8),
                    VStack([
                      '${item.title}'.text.size(12).bold.make(),
                      '${item.updatedAt?.reformatDate(to: 'dd MMM yyyy')}'.text.size(10).minFontSize(10).color(AppColor.neutral).make(),
                    ]).expand(),
                  ]).pSymmetric(h: 8, v: 8),
                ).onInkTap(() => openAddEdit(notes: item));
              },
            );
          }).expand(),
        ]).p12(),
      ),
    );
  }

  static Future<void> openAddEdit({SupaNotes? notes}) async {
    final _controller = Get.find<HomeController>();

    final _tfTitle = TextEditingController(
      text: notes != null ? notes.title : '',
    );
    final _mdController = CodeLineEditingController.fromText(
      notes?.content ?? '',
    );
    final isViewMode = false.obs; //(notes != null).obs;
    var _editorDisposed = false;

    void _updateTitleFromContent() {
      if (_editorDisposed) return;
      final content = _mdController.text;
      final firstLine = (content.isEmpty ? '' : content.split('\n').first);
      _tfTitle.text = firstLine;
    }

    _mdController.addListener(_updateTitleFromContent);

    void _disposeEditor() {
      if (_editorDisposed) return;
      _mdController.removeListener(_updateTitleFromContent);
      _mdController.dispose();
      _editorDisposed = true;
    }

    await Overlayment.dismissLast();
    await Overlayment.show(
      context: Get.context,
      OverPanel(
        alignment: Alignment.center,
        width: Get.width * 0.80,
        height: Get.height * 0.80,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColor.appbarPrimary),
        backgroundSettings: BackgroundSettings(color: AppColor.card, blur: 1),
        animation: OverScaleAnimation(durationMilliseconds: 100, reverseDurationMilliseconds: 100),
        actions: OverlayActions(
          onClose: (_) async {
            _disposeEditor();
            await Overlayment.dismissLast();
            await 100.milliseconds.delay();
            await openList();
          },
        ),
        child: VStack(
          [
            //
            HStack(
              [
                '${notes != null ? 'Edit Note' : 'New Note'}'.text.bold.make(),
                Spacer(),
                Obx(
                  () => IconButton(
                    icon: Icon(
                      isViewMode.isFalse ? UIconsPro.solidRounded.eye : UIconsPro.solidRounded.eye_crossed,
                      size: 15,
                    ),
                    onPressed: () => isViewMode.value = !isViewMode.value,
                  ),
                ),
                if (notes != null) ...[
                  ExButtonText(
                    child: 'Delete'.text.size(13).bold.color(AppColor.red).make(),
                    onPressed: () async {
                      await _controller.repo.deleteNotes(notes.id ?? '');
                      await _controller.loadNotesList();
                      await Overlayment.dismissLast();
                    },
                  ),
                ],
                ExButtonText(
                  child: 'Save'.text.size(13).bold.make(),
                  onPressed: () async {
                    final newNote = SupaNotes(
                      id: notes?.id ?? UuidV4().generate(),
                      userId: db.auth.currentSession?.user.id ?? '',
                      title: _tfTitle.text,
                      content: _mdController.text,
                      createdAt: notes?.createdAt ?? DateTime.now().toStringEx(),
                      updatedAt: DateTime.now().toStringEx(),
                    );
                    if (notes != null) {
                      await _controller.repo.updateNotes(newNote).then((s) {});
                    } else {
                      await _controller.repo.addNotes(newNote).then((s) {});
                    }
                    await _controller.loadNotesList();
                    await Overlayment.dismissLast();
                  },
                ),
              ],
            ),

            HStack(
              [
                _MarkdownEditorToolbar(controller: _mdController).hide(isVisible: !Get.context!.isMobile),
              ],
            ).pOnly(bottom: 16),

            Obx(() {
              if (isViewMode.isFalse) {
                final editorBackground = Get.isDarkMode ? Color(0xFF16141A) : Vx.neutral100;
                return Container(
                  decoration: BoxDecoration(
                    color: editorBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColor.border.withAlpha(80)),
                  ),
                  child: CodeEditor(
                    controller: _mdController,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    wordWrap: true,
                    style: CodeEditorStyle(
                      fontSize: 13,
                      fontHeight: 1.4,
                      textColor: AppColor.textReverse,
                      backgroundColor: Colors.transparent,
                      selectionColor: AppColor.blue.withAlpha(80),
                      cursorColor: AppColor.blue,
                      cursorWidth: 1.4,
                      codeTheme: CodeHighlightTheme(
                        languages: {
                          'markdown': CodeHighlightThemeMode(mode: langMarkdown),
                        },
                        theme: atomOneDarkTheme,
                      ),
                    ),
                    hint: '${lorem(paragraphs: 1, words: 8)}',
                  ),
                ).expand();
              } else {
                return ValueListenableBuilder<CodeLineEditingValue>(
                  valueListenable: _mdController,
                  builder: (_, _, _) {
                    return MarkdownWidget(
                      data: _mdController.text,
                      shrinkWrap: true,
                      selectable: true,
                      config: MarkdownConfig(
                        configs: [
                          PConfig(textStyle: TextStyle(color: Vx.neutral100, fontSize: 12, height: 1.5)),
                          H1Config(
                            style: TextStyle(color: Vx.neutral100, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          H2Config(
                            style: TextStyle(color: Vx.neutral100, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          H3Config(
                            style: TextStyle(color: Vx.neutral100, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          CodeConfig(
                            style: TextStyle(color: Vx.green700, fontSize: 12, fontFamily: 'monospace'),
                          ),
                          BlockquoteConfig(sideColor: AppColor.blue, textColor: AppColor.orangeLight),
                          LinkConfig(
                            style: TextStyle(color: AppColor.blue, decoration: TextDecoration.underline),
                          ),
                          PreConfig(
                            decoration: BoxDecoration(color: Vx.neutral900, borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.all(12),
                            textStyle: TextStyle(color: Vx.green700, fontSize: 12, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ).expand();
                  },
                );
              }
            }),
          ],
        ).p12(),
      ),
    );
  }
}

class _MarkdownEditorToolbar extends StatelessWidget {
  const _MarkdownEditorToolbar({required this.controller});

  final CodeLineEditingController controller;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    final Color buttonColor = isDark ? Vx.neutral800 : Vx.neutral200;
    final Color iconColor = AppColor.textReverse;

    final actions = <_MarkdownToolbarAction>[
      _MarkdownToolbarAction(
        icon: Icons.format_bold,
        tooltip: 'Bold',
        onTap: () => _wrapSelection('**', '**'),
      ),
      _MarkdownToolbarAction(
        icon: Icons.format_italic,
        tooltip: 'Italic',
        onTap: () => _wrapSelection('_', '_'),
      ),
      _MarkdownToolbarAction(
        icon: Icons.format_strikethrough,
        tooltip: 'Strike',
        onTap: () => _wrapSelection('~~', '~~'),
      ),
      _MarkdownToolbarAction(
        icon: Icons.code,
        tooltip: 'Inline code',
        onTap: () => _wrapSelection('`', '`'),
      ),
      _MarkdownToolbarAction(
        icon: Icons.code_off,
        tooltip: 'Code block',
        onTap: () => _insertCodeBlock(),
      ),
      _MarkdownToolbarAction(
        icon: Icons.format_quote,
        tooltip: 'Quote',
        onTap: () => _applyLinePrefix('> '),
      ),
      _MarkdownToolbarAction(
        icon: Icons.format_list_bulleted,
        tooltip: 'Bulleted list',
        onTap: () => _applyLinePrefix('- '),
      ),
      _MarkdownToolbarAction(
        icon: Icons.format_list_numbered,
        tooltip: 'Numbered list',
        onTap: () => _applyLinePrefix('1. '),
      ),
      // _MarkdownToolbarAction(
      //   icon: Icons.check_box_outlined,
      //   tooltip: 'Task',
      //   onTap: () => _applyLinePrefix('- [ ] '),
      // ),
      _MarkdownToolbarAction(
        icon: Icons.title,
        tooltip: 'Heading',
        onTap: () => _applyLinePrefix('# '),
      ),

      _MarkdownToolbarAction(
        icon: Icons.grid_on,
        tooltip: 'Table',
        onTap: () => _applyLinePrefix('|  |  |\n|---|---|\n|  |  |'),
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: actions
            .map(
              (action) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Tooltip(
                  message: action.tooltip,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: action.onTap,
                    child: Container(
                      decoration: BoxDecoration(
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColor.border.withAlpha(60),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Icon(action.icon, size: 16, color: iconColor),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  void _wrapSelection(String left, String right) {
    final selection = controller.selection;
    final selectedText = controller.selectedText;
    if (selectedText.isEmpty) {
      controller.replaceSelection('$left$right');
      controller.selection = CodeLineSelection.collapsed(
        index: selection.baseIndex,
        offset: selection.baseOffset + left.length,
      );
      return;
    }
    controller.replaceSelection('$left$selectedText$right');
  }

  void _applyLinePrefix(String prefix) {
    final selectedText = controller.selectedText;
    if (selectedText.isEmpty) {
      controller.replaceSelection(prefix);
      return;
    }
    final updated = selectedText
        .split('\n')
        .map((line) {
          if (line.trim().isEmpty) return line;
          return '$prefix$line';
        })
        .join('\n');
    controller.replaceSelection(updated);
  }

  void _insertCodeBlock() {
    final selectedText = controller.selectedText;
    final buffer = StringBuffer();
    buffer.writeln('```');
    if (selectedText.isNotEmpty) {
      buffer.writeln(selectedText);
    }
    buffer.writeln('```');
    controller.replaceSelection(buffer.toString());
  }
}

class _MarkdownToolbarAction {
  const _MarkdownToolbarAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
}
