import 'dart:io';
import 'dart:ui';

import 'package:ex/ex.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

// ------------------------------------------------------------------------
// Platform
// ------------------------------------------------------------------------
mixin PlatformUtil {
  static bool isDesktop() {
    return !kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows);
  }
}

void closeDrawer() {
  if (Get.context!.isMobile) Get.back();
}

// ------------------------------------------------------------------------
// Colors
// ------------------------------------------------------------------------
extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Color(0xffffffff);
    }
  }
}
