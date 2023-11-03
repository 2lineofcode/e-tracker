import 'dart:ui';

import 'package:ex/ex.dart';
import 'package:intl/intl.dart';
import 'package:money_formatter/money_formatter.dart';

mixin MoneyHelper {
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

  static String toRupiahNonSymbol(dynamic number, {int? decimalDigit}) {
    try {
      final currencyFormatter = NumberFormat.currency(
        locale: 'id',
        symbol: '',
        decimalDigits: decimalDigit ?? 0,
      );

      return '${currencyFormatter.format(number)}';
    } catch (_) {
      return '';
    }
  }

  static String toCompactNonSymbol(dynamic number) {
    try {
      if (number != null) {
        final fmf = MoneyFormatter(
          amount: number,
          settings: MoneyFormatterSettings(
            symbol: 'IDR',
            thousandSeparator: '.',
            decimalSeparator: ' ,',
            symbolAndNumberSeparator: ' ',
            fractionDigits: 2,
          ),
        );
        return fmf.output.compactNonSymbol;
      } else {
        return '-';
      }
    } on Exception catch (_) {
      return '-';
    }
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

  static Color getExpenseColor(num amount) {
    if (amount == 0) return Vx.white;
    if (amount < 50000) {
      return Vx.green300;
    } else if (amount < 100000) {
      return Vx.orange300;
    } else {
      return Vx.red500;
    }
  }

  static String getTargetPercentage(a, b, {decimalDigits = 2}) {
    try {
      final o = a / b;
      final output = NumberFormat.decimalPercentPattern(decimalDigits: decimalDigits).format(o);
      return '$output';
    } catch (_) {
      return '-';
    }
  }
}
