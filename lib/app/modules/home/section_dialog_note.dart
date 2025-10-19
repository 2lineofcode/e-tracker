import 'package:ex_kit/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lorem/flutter_lorem.dart';
import 'package:get/get.dart';
import 'package:markdown_toolbar/markdown_toolbar.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:overlayment/overlayment.dart';
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
      ExLoading.show(paddingSymmetric: Get.context!.isMobile ? 90 : 250, child: CupertinoActivityIndicator());
      await _controller.loadNotesList();
      ExLoading.dismiss();
    }

    await Overlayment.show(
      context: Get.context!,
      OverPanel(
        alignment: Alignment.centerRight,
        width: 300,
        backgroundSettings: BackgroundSettings(color: Color.fromARGB(255, 204, 211, 186).withAlpha(20), blur: 1),
        animation: OverSlideAnimation(begin: Offset(1, 0), end: Offset(0, 0), durationMilliseconds: 100, reverseDurationMilliseconds: 100),

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
                Icon(Icons.indeterminate_check_box, size: 64, color: Vx.neutral400).centered(),
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
                  decoration: ExDecorator.box(borderRadius: 12, borderColor: AppColor.border, fillColor: AppColor.box),
                  child: HStack([
                    Icon(UIconsPro.solidRounded.circle, size: 12).pOnly(right: 8),
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

    final _tfTitle = TextEditingController(text: notes != null ? notes.title : '');
    final _tfContent = TextEditingController(text: notes != null ? notes.content : '');
    final _fnContent = FocusNode();
    final isViewMode = (notes != null).obs;

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
            await Overlayment.dismissLast();
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
                    icon: Icon(isViewMode.isFalse ? UIconsPro.solidRounded.eye : UIconsPro.solidRounded.eye_crossed, size: 15),
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
                      content: _tfContent.text,
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
                Obx(
                  () => MarkdownToolbar(
                    useIncludedTextField: false,
                    controller: _tfContent,
                    focusNode: _fnContent,
                    iconSize: 14,
                    width: 20,
                    height: 20,
                  ).hide(isVisible: isViewMode.isFalse),
                ),
              ],
            ).pOnly(bottom: 16),

            Obx(() {
              if (isViewMode.isFalse) {
                return CupertinoTextField(
                  controller: _tfContent,
                  placeholder: '${lorem(paragraphs: 1, words: 10)}',
                  placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
                  decoration: BoxDecoration(color: Get.isDarkMode ? Vx.black : Vx.white, borderRadius: BorderRadius.circular(4)),
                  style: TextStyle(fontSize: 13, color: AppColor.textReverse),
                  minLines: 28,
                  maxLines: 28,
                  onChanged: (value) {
                    // first line as title
                    final firstLine = _tfContent.text.split('\n').first;
                    _tfTitle.text = firstLine;
                  },
                ).expand();
              } else {
                return MarkdownWidget(
                  data: '${_tfContent.text}',
                  shrinkWrap: true,
                  selectable: true,
                  config: MarkdownConfig(
                    configs: [
                      PConfig(textStyle: TextStyle(color: Vx.neutral100, fontSize: 12, height: 1.5)),
                      H1Config(style: TextStyle(color: Vx.neutral100, fontSize: 20, fontWeight: FontWeight.bold)),
                      H2Config(style: TextStyle(color: Vx.neutral100, fontSize: 18, fontWeight: FontWeight.bold)),
                      H3Config(style: TextStyle(color: Vx.neutral100, fontSize: 16, fontWeight: FontWeight.bold)),
                      CodeConfig(style: TextStyle(color: Vx.green700, fontSize: 12, fontFamily: 'monospace')),
                      BlockquoteConfig(sideColor: AppColor.blue, textColor: AppColor.orangeLight),
                      LinkConfig(style: TextStyle(color: AppColor.blue, decoration: TextDecoration.underline)),
                      PreConfig(
                        decoration: BoxDecoration(color: Vx.neutral900, borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.all(12),
                        textStyle: TextStyle(color: Vx.green700, fontSize: 12, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ).expand();
              }
            }),
          ],
        ).p12(),
      ),
    );
  }
}
