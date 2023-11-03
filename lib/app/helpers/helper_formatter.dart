import 'package:flutter/services.dart';

class DigitsAndSpacesInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Use a regular expression to keep only digits (0-9) and spaces
    String newString = newValue.text.replaceAll(RegExp(r'[^0-9\s]'), '');
    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}
