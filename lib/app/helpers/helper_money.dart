import 'package:ex/ex.dart';
import 'package:flutter/material.dart';

import '../core/app_color.dart';
import '../core/const.dart';

extension MoneyFormatExt on num {
  /// example: 1000 -> 'Rp. 1,000'
  String moneyFormat() {
    String formattedText = 'Rp. ${toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    return formattedText;
  }

  /// example: 1000 -> '1K'
  /// example: 1000000 -> '1M'
  String moneyFormatCompact() {
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

extension MoneyUnformatExt on String {
  /// example: 'Rp. 1.000' -> 1000
  int? moneyUnformat() => replaceAll(RegExp(r'[^0-9]'), '').toInt();
}

extension ExpenseFlagColorExt on num {
  Color getFlagColor() {
    final eco = pref.read<num>(kFlagEco) ?? 50000;
    final average = pref.read<num>(kFlagAverage) ?? 100000;

    if (this == 0) return Vx.white;
    if (this <= eco) {
      return AppColor.green;
    } else if (this <= average) {
      return AppColor.orange;
    } else {
      return AppColor.red;
    }
  }

  Color getFlagColorLight() {
    final eco = pref.read<num>(kFlagEco) ?? 50000;
    final average = pref.read<num>(kFlagAverage) ?? 100000;

    if (this == 0) return Vx.white;
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

    if (this == 0) return Vx.white;
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

    if (this == 0) return '';
    if (this <= eco) {
      return 'Eco';
    } else if (this <= average) {
      return 'Average';
    } else {
      return 'Spender';
    }
  }
}
