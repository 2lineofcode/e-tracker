import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uicons_pro/uicons_pro.dart';

import '../../core/app_color.dart';
import '../../helpers/helpers.dart';
import 'calcp_controller.dart';

class CalcpView extends GetView<CalcpController> {
  const CalcpView({super.key});

  // static const _background = Color(0xFF1E1F26);
  static const _horizontalPadding = 28.0;
  static const _verticalPadding = 28.0;
  static const _resultGap = 12.0;
  static const _resultWidth = 140.0;
  static const _commentColor = Color(0xFFFFB454);
  static const _labelColor = Color(0xFF6CB4FF);
  static const _placeholderColor = Color(0xFF6B6F7B);
  static const _resultColor = Color(0xFFA5F26A);
  static final _codeTextStyle = GoogleFonts.firaCode(fontSize: 16, height: 1.6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            // ** head
            Row(
              children: [
                Expanded(
                  child: _CalcpTabBar(
                    controller: controller,
                    onRename: (index, currentName) => _promptRenameTab(context, index, currentName),
                  ),
                ),
                IconButton(
                  icon: Icon(UIconsPro.solidRounded.cross_small, color: Get.isDarkMode ? Colors.white70: Colors.black54, size: 24),
                  color: Get.isDarkMode ? Colors.white70: Colors.black54,
                  onPressed: () => Get.back(),
                ),
              ],
            ).pOnly(left: 12, top: 28, right: 12, bottom: 12),

            // ** body
            _EditorSurface(controller: controller).p(0).expand(),

            // ** footer
            Obx(() {
              final total = controller.lines.where((line) => line.hasResult).fold<double>(0, (sum, line) => sum + (line.value ?? 0));
              final formatted = total == 0 ? '—' : controller.formatValue(total);
              return Text(
                'Total: $formatted',
                style: CalcpView._codeTextStyle.copyWith(color: Colors.white70, fontSize: 14),
              ).onInkTap(() {
                Clipboard.setData(ClipboardData(text: formatted));
                HelperToast.success('Total: $formatted', duration: 1200.milliseconds);
              });
            }).pOnly(bottom: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _promptRenameTab(BuildContext context, int index, String currentName) async {
    final nameController = TextEditingController(text: currentName);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Ganti nama tab'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            maxLength: 40,
            decoration: const InputDecoration(
              labelText: 'Nama tab',
              counterText: '',
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
}

class _CalcpTabBar extends StatelessWidget {
  const _CalcpTabBar({
    required this.controller,
    required this.onRename,
  });

  final CalcpController controller;
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
                  final isActive = controller.activeTab.value == index;
                  return _CalcpTabItem(
                    label: tab.name,
                    isActive: isActive,
                    canClose: controller.tabs.length > 1,
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
              icon: Icon(UIconsPro.solidRounded.plus, size: 15, color: Get.isDarkMode ? Colors.white70 : Colors.black54),
              onPressed: controller.addTab,
            ),
          ],
        ),
      );
    });
  }
}

class _CalcpTabItem extends StatelessWidget {
  const _CalcpTabItem({
    required this.label,
    required this.isActive,
    required this.canClose,
    required this.onTap,
    required this.onDoubleTap,
    required this.onClose,
  });

  final String label;
  final bool isActive;
  final bool canClose;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final textColor = isActive
        ? AppColor.textReverse
        : Get.isDarkMode
            ? Colors.white60
            : Colors.black54;

    return GestureDetector(
      onDoubleTap: onDoubleTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: canClose ? 108 : 86,
          height: 34,
          padding: const EdgeInsets.only(left: 10, right: 6),
          decoration: BoxDecoration(
            color: isActive ? AppColor.primary.withAlpha(110) : AppColor.box,
            border: Border.all(color: isActive ? AppColor.primary.withAlpha(180) : AppColor.border),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CalcpView._codeTextStyle.copyWith(color: textColor, fontSize: 12, height: 1),
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

class _EditorSurface extends StatelessWidget {
  const _EditorSurface({required this.controller});

  final CalcpController controller;

  @override
  Widget build(BuildContext context) {
    const overlayPadding = EdgeInsets.symmetric(
      horizontal: CalcpView._horizontalPadding,
      vertical: CalcpView._verticalPadding,
    );
    const textPadding = EdgeInsets.fromLTRB(
      CalcpView._horizontalPadding,
      CalcpView._verticalPadding,
      CalcpView._horizontalPadding + CalcpView._resultGap + CalcpView._resultWidth,
      CalcpView._verticalPadding,
    );

    return Stack(
      children: [
        TextField(
          controller: controller.textController,
          focusNode: controller.focusNode,
          autofocus: true,
          scrollController: controller.textScrollController,
          keyboardType: TextInputType.multiline,
          expands: true,
          maxLines: null,
          cursorColor: Colors.white70,
          cursorHeight: 20,
          cursorWidth: 1,
          style: CalcpView._codeTextStyle.copyWith(color: Colors.transparent, wordSpacing: 0.2, letterSpacing: -0.05),
          decoration: const InputDecoration(border: InputBorder.none, contentPadding: textPadding),
        ),
        IgnorePointer(
          child: Obx(() {
            final lines = controller.lines;
            if (lines.isEmpty) {
              return const SizedBox.shrink();
            }
            return ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: false
              ),
              child: ListView.builder(
                controller: controller.overlayScrollController,
                physics: const NeverScrollableScrollPhysics(),
                padding: overlayPadding,
                itemCount: lines.length,
                itemBuilder: (context, index) => _LineRow(line: lines[index]),
              ),
            );
          }),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Obx(() {
              final hasContent = controller.lines.any((l) => !l.isBlank);
              if (hasContent) return const SizedBox.shrink();
              return Padding(
                padding: overlayPadding,
                child: Text(
                  'A = 20M\nB = 13,1M\nC = A + B',
                  style: CalcpView._codeTextStyle.copyWith(color: CalcpView._placeholderColor),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({required this.line});

  final CalcLine line;

  @override
  Widget build(BuildContext context) {
    final baseText = CalcpView._codeTextStyle;

    if (line.isComment) {
      return Text(line.raw, style: baseText.copyWith(color: CalcpView._commentColor, letterSpacing: -0.05));
    }

    if (line.isBlank) {
      return Text(' ', style: baseText.copyWith(color: Colors.transparent));
    }

    Widget expression;
    if ((line.label ?? '').isEmpty) {
      expression = Text(line.raw, style: baseText.copyWith(color: Colors.white));
    } else {
      final raw = line.raw;
      final eqIndex = raw.indexOf('=');
      if (eqIndex == -1) {
        expression = Text(raw, style: baseText.copyWith(color: Colors.white));
      } else {
        final labelSegment = raw.substring(0, eqIndex);
        final expressionSegment = raw.substring(eqIndex + 1);
        expression = RichText(
          text: TextSpan(
            style: baseText.copyWith(height: 1.2),
            children: [
              TextSpan(
                text: labelSegment,
                style: TextStyle(color: CalcpView._labelColor),
              ),
              TextSpan(
                text: '=',
                style: TextStyle(color: Get.isDarkMode ? Colors.white70 : Colors.black54),
              ),
              TextSpan(
                text: expressionSegment,
                style: TextStyle(color: Colors.red[300]),
              ),
            ],
          ),
        );
      }
    }

    // final result = line.result ?? line.error ?? '';
    final result = line.result ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: expression),
        const SizedBox(width: CalcpView._resultGap),
        SizedBox(
          width: CalcpView._resultWidth,
          child: Text(
            '$result',
            textAlign: TextAlign.right,
            style: baseText.copyWith(color: line.hasResult ? CalcpView._resultColor : Colors.redAccent),
          ),
        ),
      ],
    );
  }
}
