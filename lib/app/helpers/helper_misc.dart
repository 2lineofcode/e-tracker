import 'dart:io';

import 'package:ex/ex.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// TOP LEVEL HELPER

bool get isDesktop => !kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows);

extension TimeAgo on DateTime {
  String getTimeAgoFromNow() {
    Duration difference = DateTime.now().difference(this);
    int days = difference.inDays;

    final diff = DateTime.now().subtract(Duration(days: days));
    if (days.isNegative) {
      return '~';
    } else {
      return diff.ago().replaceAll('Just now', 'Today');
    }
  }
}

extension HexToColor on String {
  Color get fromHex {
    try {
      if (isHexColor) {
        final buffer = StringBuffer();
        if (length == 6 || length == 7) buffer.write('FF');
        buffer.write(replaceFirst('#', ''));
        return Color(int.parse(buffer.toString(), radix: 16));
      }
    } catch (_) {
      return Colors.white;
    }
    return Colors.white;
  }
}

// ------------------------------------------------------------------------
// Mobile Only
// ------------------------------------------------------------------------
void closeDrawer() {
  if (Get.context!.isMobile) Get.back();
}
