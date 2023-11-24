import 'dart:io';

import 'package:ex/ex.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// TOP LEVEL HELPER
bool get isDesktop =>
    !kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows);

extension TimeAgoToString on DateTime {
  /// Example:
  /// ```
  /// DateTime postTime = DateTime(2023, 1, 1);
  /// String timeAgo = postTime.getTimeAgoFromNow();
  /// ```
  /// Output: '2 months ago'
  String getTimeAgoFromNow() {
    Duration difference = DateTime.now().difference(this);
    int days = difference.inDays;
    final diff = DateTime.now().subtract(Duration(days: days));

    if (DateTime.now().isBefore(this)) {
      return '~'; // don't allow future
    } else {
      return diff.ago().replaceAll('Just now', 'Today');
    }
  }
}

extension ConvertHexToString on String {
  /// Example:
  /// ```
  /// String hexColorCode = '#FF5733';
  /// Color color = hexColorCode.fromHex;
  /// ```
  /// Output: Color(0xFFFF5733)
  Color get fromHex {
    bool isHexColor() {
      if (startsWith('#') && (length == 7 || length == 9)) {
        return substring(1).toLowerCase().split('').every((char) {
          return '0123456789abcdef'.contains(char);
        });
      }
      return false;
    }

    try {
      if (isHexColor()) {
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

extension StringToIconData on String {
  /// Example:
  /// ```
  /// String iconString = 'code=59462&family=MaterialIcons&pack=null';
  /// IconData? iconData = iconString.getIconData();
  /// ```
  /// Output: IconData(U+EB3E, fontFamily: 'MaterialIcons')
  /// String -> IconData
  IconData? getIconData() {
    final _iconCode = allBetween('code=', '&family=').toInt() ?? 59462;
    String? _iconFamily = allBetween('&family=', '&pack=');
    String? _iconPack = allAfter('&pack=');
    bool? isPackNull = _iconPack.contains('null');
    return IconData(_iconCode,
        fontFamily: _iconFamily, fontPackage: isPackNull ? null : _iconPack);
  }
}

extension IconDataToString on IconData {
  /// Example:
  /// ```
  /// IconData myIcon = IconData(59462, fontFamily: 'MaterialIcons', fontPackage: 'null');
  /// String? iconString = myIcon.setIconData();
  /// ```
  /// Output: 'code=59462&family=MaterialIcons&pack=null'
  /// IconData -> String
  String? setIconData() =>
      'code=$codePoint&family=$fontFamily&pack=$fontPackage';
}

// ------------------------------------------------------------------------
// Mobile Only
// ------------------------------------------------------------------------
void closeDrawer() {
  if (Get.context!.isMobile) Get.back();
}
