import 'dart:async';
import 'dart:io';

import 'package:ex_kit/ex.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// TOP LEVEL HELPER
bool get isDesktop => !kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows);
bool get isMobileWeb => kIsWeb && Get.context!.isMobile;

extension TimeAgoToString on DateTime {
  /// Example:
  /// ```
  /// DateTime postTime = DateTime(2023, 1, 1);
  /// String timeAgo = postTime.getTimeAgoFromNow();
  /// ```
  /// Output: '2 months ago'
  ///
  String getTimeAgoFromNow() {
    final selDate = toStringEx(format: 'yyyy-MM-dd').toDateEx(format: 'yyyy-MM-dd');
    final now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    Duration difference = now.difference(selDate);
    int days = difference.inDays;
    final diff = now.subtract(Duration(days: days));
    if (now.isBefore(selDate)) {
      return '~';
    } else {
      var output = diff.ago();
      if (days <= 0) output = 'Today';
      return output;
    }
  }

  /// Example:
  /// ```
  /// DateTime postTime = DateTime(2023, 1, 1);
  /// String timeDiff = postTime.timeDiff();
  /// ```
  String timeDiff() {
    Duration difference = this.difference(DateTime.now());

    int years = difference.inDays ~/ 365;
    int months = (difference.inDays % 365) ~/ 30;
    int days = difference.inDays % 30;

    String result = '';

    if (years > 0) result += '$years tahun, ';
    if (months > 0) result += '$months bulan, ';
    if (days > 0) result += '$days hari ';

    return result.isEmpty ? 'Sekarang!' : '${result}lagi';
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
    return IconData(_iconCode, fontFamily: _iconFamily, fontPackage: isPackNull ? null : _iconPack);
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
  String? setIconData() => 'code=$codePoint&family=$fontFamily&pack=$fontPackage';
}

String formatFileSize(int bytes) {
  const int kilobyte = 1024;
  const int megabyte = kilobyte * 1024;
  const int gigabyte = megabyte * 1024;

  if (bytes >= gigabyte) {
    return '${(bytes / gigabyte).toStringAsFixed(2)} GB';
  } else if (bytes >= megabyte) {
    return '${(bytes / megabyte).toStringAsFixed(2)} MB';
  } else if (bytes >= kilobyte) {
    return '${(bytes / kilobyte).toStringAsFixed(2)} KB';
  } else {
    return '$bytes bytes';
  }
}

// ------------------------------------------------------------------------
// Mobile Only: closeDrawer -> only close when drawer is open
// ------------------------------------------------------------------------
final drawerKeyLogin = GlobalKey<ScaffoldState>();
final drawerKeyHome = GlobalKey<ScaffoldState>();
final drawerKeySummary = GlobalKey<ScaffoldState>();
final drawerKeySetting = GlobalKey<ScaffoldState>();
final drawerKeyFiltering = GlobalKey<ScaffoldState>();
final drawerKeyBibit = GlobalKey<ScaffoldState>();
final _gsk = <GlobalKey<ScaffoldState>>[
  drawerKeyLogin,
  drawerKeyHome,
  drawerKeySummary,
  drawerKeySetting,
  drawerKeyFiltering,
  drawerKeyBibit,
];

/// #### Mobile Only: closeDrawer -> only close when drawer is open
void closeDrawer() {
  if (Get.context!.isMobile) {
    for (var k in _gsk) {
      if (k.currentState != null) {
        if (k.currentState!.isDrawerOpen == true) {
          k.currentState!.openEndDrawer();
        }
      }
    }
  }
}

int hashDate(DateTime key) => key.day * 1000000 + key.month * 10000 + key.year;

int dayInMonth(DateTime dt) => DateTime(dt.year, dt.month + 1, 0).day;

/// ------------------------------------------------------------------------
/// ! DEBOUNCE
/// ------------------------------------------------------------------------
class DebounceSearch {
  final Duration duration;
  Timer? _timer;

  DebounceSearch({required this.duration});

  Future<List<String>> run(FutureOr<List<String>> Function() action) async {
    if (null != _timer) _timer?.cancel();

    Completer<List<String>> completer = Completer();
    _timer = Timer(duration, () async {
      var result = await action();
      completer.complete(result);
    });
    return completer.future;
  }
}
