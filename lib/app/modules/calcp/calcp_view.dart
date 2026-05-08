import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uicons_pro/uicons_pro.dart';

import '../../core/app_setting.dart';
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
            HStack(
              [
                Spacer(),
                IconButton(
                  icon: Icon(UIconsPro.solidRounded.cross_small, color: Get.isDarkMode ? Colors.white70: Colors.black54, size: 24),
                  color: Get.isDarkMode ? Colors.white70: Colors.black54,
                  onPressed: () => Get.back(),
                ),
              ],
            ).p12(),

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
          onChanged: (v) {
            pref.write('calcp', v);
          },
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
