import 'package:ex/ex.dart';
import 'package:flutter/material.dart';

mixin MyDecorationHelper {
  static InputDecoration inputDecorator({
    String? hint,
    Color? fillColor = Vx.neutral700,
    Widget? suffix,
    Widget? prefix,
    Widget? prefixIcon,
    Widget? icon,
    String? label,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: fillColor,
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13),
      border: OutlineInputBorder(borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
      disabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
      focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide.none),
      contentPadding: contentPadding ?? EdgeInsets.only(top: 2, bottom: 2, left: 12, right: 12),
      suffix: suffix,
      prefix: prefix,
      prefixStyle: TextStyle(color: Colors.white),
      prefixIcon: prefixIcon,
      prefixIconColor: Colors.white,
      icon: icon,
      labelText: label,
      labelStyle: TextStyle(fontSize: 11),
    );
  }
}
