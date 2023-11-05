import 'dart:ui';

import 'package:ex/ex.dart';
import 'package:intl/intl.dart';

extension StringToMoneyExt on String {
  /// example: 'Rp. 1.000' -> '1000'
  int? moneyUnformat() => replaceAll(RegExp(r'[^0-9]'), '').toInt();
}

extension IntToMoneyExt on int {
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
}

mixin MoneyHelper {
  /// example: '1000' -> 'Rp. 1.000'
  static String toRupiah(dynamic number, {int? decimalDigit, bool? allowMinus = true}) {
    var o = 'ERR';
    try {
      final currencyFormatter = NumberFormat.currency(
        locale: 'id',
        symbol: '',
        decimalDigits: decimalDigit ?? 0,
      );

      o = 'Rp. ${currencyFormatter.format(number)}';
    } catch (_) {
      o = '';
    }
    return o;
  }

  static String toPercentage(dynamic number, {int decimalDigits = 1}) {
    var output = '';

    try {
      output = NumberFormat.decimalPercentPattern(decimalDigits: decimalDigits).format(number);
    } catch (_) {
      try {
        final x = double.parse(number);
        output = '${x * 100}'.substring(0, 3).replaceAll('.', '');
      } catch (_) {
        output = '';
      }
    }

    return '$output';
  }

  static Color getExpenseFlagColor(num amount) {
    if (amount == 0) return Vx.white;
    if (amount < 50000) {
      return Vx.green300;
    } else if (amount < 100000) {
      return Vx.orange300;
    } else {
      return Vx.red500;
    }
  }

  static String getExpenseFlagText(num amount) {
    if (amount == 0) return '';
    if (amount < 50000) {
      return 'Hemat';
    } else if (amount < 100000) {
      return 'Stardart';
    } else {
      return 'Boros';
    }
  }
}
