import 'dart:ui';

import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/app_color.dart';

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
    if (amount == 0) return Vx.white;
    if (amount < 50000) {
      return AppColor.green;
    } else if (amount < 100000) {
      return AppColor.orange;
    } else {
      return AppColor.red;
    }
  }

  static Color getExpenseFlagColorLight(num amount) {
    if (amount == 0) return Vx.white;
    if (amount < 50000) {
      return AppColor.greenLight;
    } else if (amount < 100000) {
      return AppColor.orangeLight;
    } else {
      return AppColor.redLight;
    }
  }

  static Color getExpenseFlagColorDark(num amount) {
    if (amount == 0) return Vx.white;
    if (amount < 50000) {
      return AppColor.greenDark;
    } else if (amount < 100000) {
      return AppColor.orangeDark;
    } else {
      return AppColor.redDark;
    }
  }

  static String getExpenseFlagText(num amount) {
    if (amount == 0) return '';
    if (amount < 50000) {
      return 'Eco';
    } else if (amount < 100000) {
      return 'Average';
    } else {
      return 'Spender';
    }
  }
}
