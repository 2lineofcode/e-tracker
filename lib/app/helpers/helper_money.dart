import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/app_color.dart';
import '../core/const.dart';

extension IntToMoneyExt on num {
  /// example: '1000' -> 'Rp. 1,000'
  String moneyFormat() {
    String formattedText = 'Rp. ${toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    return formattedText;
  }

  String moneyFormatCompact() {
    /// example: '1000' -> '1K'
    /// example: '1000000' -> '1M'
    if (this < 1000) {
      return toString();
    } else if (this < 1000000) {
      return '${(this / 1000).toStringAsFixed(0)}K';
    } else if (this < 1000000000) {
      return '${(this / 1000000).toStringAsFixed(0)}M';
    } else if (this < 1000000000000) {
      return '${(this / 1000000000).toStringAsFixed(0)}B';
    } else {
      return '${(this / 1000000000000).toStringAsFixed(0)}T';
    }
  }

  String percentageFormat({int decimalDigits = 1}) {
    var output = '';

    try {
      output = NumberFormat.decimalPercentPattern(decimalDigits: decimalDigits).format(this);
    } catch (_) {
      try {
        final x = double.parse(toString());
        output = '${x * 100}'.substring(0, 3).replaceAll('.', '');
      } catch (_) {
        output = '';
      }
    }

    if (output == '0.0') output = '0';

    return '$output';
  }
}

extension StringToMoneyExt on String {
  /// example: 'Rp. 1.000' -> '1000'
  int? moneyUnformat() => replaceAll(RegExp(r'[^0-9]'), '').toInt();
}

mixin MoneyHelper {
  static Color getExpenseFlagColor(num amount) {
    final eco = pref.read<num>(kFlagEco) ?? 50000;
    final average = pref.read<num>(kFlagAverage) ?? 100000;
    final spender = pref.read<num>(kFlagSpender) ?? 100000;

    if (amount == 0) return Vx.white;
    if (amount < eco) {
      return AppColor.green;
    } else if (amount < average) {
      return AppColor.orange;
    } else if (amount > spender) {
      return AppColor.red;
    } else {
      return Colors.white;
    }
  }

  static Color getExpenseFlagColorLight(num amount) {
    final eco = pref.read<num>(kFlagEco) ?? 50000;
    final average = pref.read<num>(kFlagAverage) ?? 100000;
    final spender = pref.read<num>(kFlagSpender) ?? 100000;

    if (amount == 0) return Vx.white;
    if (amount < eco) {
      return AppColor.greenLight;
    } else if (amount < average) {
      return AppColor.orangeLight;
    } else if (amount > spender) {
      return AppColor.redLight;
    } else {
      return Colors.white;
    }
  }

  static Color getExpenseFlagColorDark(num amount) {
    final eco = pref.read<num>(kFlagEco) ?? 50000;
    final average = pref.read<num>(kFlagAverage) ?? 100000;
    final spender = pref.read<num>(kFlagSpender) ?? 100000;

    if (amount == 0) return Vx.white;
    if (amount < eco) {
      return AppColor.greenDark;
    } else if (amount < average) {
      return AppColor.orangeDark;
    } else if (amount > spender) {
      return AppColor.redDark;
    } else {
      return Colors.white;
    }
  }

  static String getExpenseFlagText(num amount) {
    final eco = pref.read<num>(kFlagEco) ?? 50000;
    final average = pref.read<num>(kFlagAverage) ?? 100000;
    final spender = pref.read<num>(kFlagSpender) ?? 100000;

    if (amount == 0) return '';
    if (amount < eco) {
      return 'Eco';
    } else if (amount < average) {
      return 'Average';
    } else if (amount > spender) {
      return 'Spender';
    } else {
      return 'ERR';
    }
  }
}
