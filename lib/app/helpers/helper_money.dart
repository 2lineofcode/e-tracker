import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_formatter/money_formatter.dart';

import '../core/app_color.dart';
import '../core/app_setting.dart';
import '../core/const.dart';

extension MoneyFormatExt on num {
  /// example: 1000 -> 'Rp. 1,000'
  String moneyFormat({String? symbol = 'Rp.'}) {
    String formattedText = '$symbol${toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    return formattedText;
  }

  /// example: 1000 -> '1K'
  /// example: 1000000 -> '1M'
  String moneyFormatCompact() {
    try {
      final fmf = MoneyFormatter(
        amount: toDouble(),
        settings: MoneyFormatterSettings(
          symbol: 'IDR',
          thousandSeparator: '.',
          decimalSeparator: ' ,',
          symbolAndNumberSeparator: ' ',
          fractionDigits: 2,
        ),
      );
      return fmf.output.compactNonSymbol;
    } on Exception catch (_) {
      return '-';
    }
  }

  /// example: 100 -> '100%'
  String percentageFormat({int decimalDigits = 2}) {
    var output = '';
    try {
      output = NumberFormat.decimalPercentPattern(decimalDigits: decimalDigits).format(this);
    } catch (_) {
      try {
        final x = this;
        output = '${x * 100}'.substring(0, 3).replaceAll('.', '');
      } catch (_) {
        output = '';
      }
    }
    return '${output.replaceAll('.00', '')}';
  }
}

extension MoneyUnformatExt on String {
  /// example: 'Rp. 1.000' -> 1000
  int? moneyUnformat() => replaceAll(RegExp(r'[^0-9]'), '').toInt();
}

extension ExpenseFlagColorExt on num {
  /// example: 0 -> Vx.white
  /// example: 50000 -> AppColor.green
  /// example: 100000 -> AppColor.orange
  /// example: 1000000 -> AppColor.red
  Color getFlagColor() {
    final eco = pref.read<num>(kFlagEco) ?? 50000;
    final average = pref.read<num>(kFlagAverage) ?? 100000;

    if (this == 0) return AppColor.textReverse;
    if (this <= eco) {
      return AppColor.green;
    } else if (this <= average) {
      return AppColor.orange;
    } else {
      return AppColor.red;
    }
  }

  /// example: 0 -> Vx.white
  /// example: 50000 -> AppColor.greenLight
  /// example: 100000 -> AppColor.orangeLight
  /// example: 1000000 -> AppColor.redLight
  Color getFlagColorLight() {
    final eco = pref.read<num>(kFlagEco) ?? 50000;
    final average = pref.read<num>(kFlagAverage) ?? 100000;

    if (this == 0) return AppColor.textReverse;
    if (this <= eco) {
      return AppColor.greenLight;
    } else if (this <= average) {
      return AppColor.orangeLight;
    } else {
      return AppColor.redLight;
    }
  }

  Color getFlagColorDark() {
    final eco = pref.read<num>(kFlagEco) ?? 50000;
    final average = pref.read<num>(kFlagAverage) ?? 100000;

    if (this == 0) return AppColor.neutral;
    if (this <= eco) {
      return AppColor.greenDark;
    } else if (this <= average) {
      return AppColor.orangeDark;
    } else {
      return AppColor.redDark;
    }
  }
}

extension ExpenseFlagTextExt on num {
  String getFlagText() {
    final eco = pref.read<num>(kFlagEco) ?? 50000;
    final average = pref.read<num>(kFlagAverage) ?? 100000;

    if (this == 0) return 'Note';
    if (this <= eco) {
      return 'Hemat';
    } else if (this <= average) {
      return 'Biasa';
    } else {
      return 'Boros';
    }
  }
}
