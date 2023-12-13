import 'package:flutter/material.dart';

import '../core/app_color.dart';

mixin DecorationHelper {
  static InputDecoration input({
    String? hint,
    Color? fillColor,
    Widget? suffix,
    Widget? suffixIcon,
    Widget? prefix,
    Widget? prefixIcon,
    Widget? icon,
    String? label,
    InputBorder? border,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: fillColor ?? AppColor.textFieldPrimary,
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13),
      border: border ?? OutlineInputBorder(borderSide: BorderSide.none),
      enabledBorder: border ?? OutlineInputBorder(borderSide: BorderSide.none),
      disabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
      focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide.none),
      contentPadding: contentPadding ?? EdgeInsets.only(top: 2, bottom: 2, left: 12, right: 12),
      icon: icon,
      labelText: label,
      labelStyle: TextStyle(fontSize: 12, color: AppColor.textReverse),
      // prefix
      prefix: prefix,
      prefixIcon: prefixIcon,
      // suffix
      suffix: suffix,
      suffixIcon: suffixIcon,
    );
  }
}
