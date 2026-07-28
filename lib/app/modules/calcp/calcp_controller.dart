import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/app_setting.dart';

class CalcLine {
  CalcLine({
    required this.raw,
    this.label,
    this.expression,
    this.value,
    this.result,
    this.error,
    this.isComment = false,
    this.isBlank = false,
  });

  final String raw;
  final String? label;
  final String? expression;
  final double? value;
  final String? result;
  final String? error;
  final bool isComment;
  final bool isBlank;

  bool get hasResult => value != null && error == null;
}

class CalcpTab {
  const CalcpTab({
    required this.name,
    required this.content,
  });

  final String name;
  final String content;

  CalcpTab copyWith({
    String? name,
    String? content,
  }) {
    return CalcpTab(
      name: name ?? this.name,
      content: content ?? this.content,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'content': content,
      };

  factory CalcpTab.fromJson(Map<String, dynamic> json, int index) {
    return CalcpTab(
      name: json['name'] as String? ?? 'Calc ${index + 1}',
      content: json['content'] as String? ?? '',
    );
  }
}

class CalcpController extends GetxController {
  static const _legacyStorageKey = 'calcp';
  static const _tabsStorageKey = 'calcp_tabs';
  static const _activeTabStorageKey = 'calcp_active_tab';

  final textController = TextEditingController();
  final focusNode = FocusNode();
  final textScrollController = ScrollController();
  final overlayScrollController = ScrollController();
  final lines = <CalcLine>[].obs;
  final tabs = <CalcpTab>[].obs;
  final activeTab = 0.obs;
  final NumberFormat _numberFormat = NumberFormat.decimalPattern('id_ID');

  bool _isApplyingTab = false;

  @override
  void onInit() {
    super.onInit();
    _loadTabs();
    textController.addListener(_handleInput);
    textScrollController.addListener(_syncScroll);
    focusNode.requestFocus();

    _applyActiveTabText();
    _handleInput();
  }

  @override
  void onClose() {
    textScrollController.removeListener(_syncScroll);
    textController.removeListener(_handleInput);
    textController.dispose();
    textScrollController.dispose();
    overlayScrollController.dispose();
    super.onClose();
  }

  void addTab() {
    _saveActiveTabText();
    tabs.add(CalcpTab(name: 'Calc ${tabs.length + 1}', content: ''));
    activeTab.value = tabs.length - 1;
    _persistTabs();
    _applyActiveTabText();
    focusNode.requestFocus();
  }

  void selectTab(int index) {
    if (index == activeTab.value || index < 0 || index >= tabs.length) {
      return;
    }

    _saveActiveTabText();
    activeTab.value = index;
    _persistTabs();
    _applyActiveTabText();
    focusNode.requestFocus();
  }

  void closeTab(int index) {
    if (tabs.length <= 1 || index < 0 || index >= tabs.length) {
      return;
    }

    _saveActiveTabText();
    tabs.removeAt(index);

    if (activeTab.value >= tabs.length) {
      activeTab.value = tabs.length - 1;
    } else if (index < activeTab.value) {
      activeTab.value--;
    }

    _persistTabs();
    _applyActiveTabText();
    focusNode.requestFocus();
  }

  Future<void> renameTab(int index, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || index < 0 || index >= tabs.length) {
      return;
    }

    tabs[index] = tabs[index].copyWith(name: trimmed);
    await _persistTabs();
  }

  void _handleInput() {
    final content = textController.text.replaceAll('\r\n', '\n');
    final currentLines = content.split('\n');
    final parsed = <CalcLine>[];
    final memory = <String, double>{};

    for (final raw in currentLines) {
      final line = _parseLine(raw, memory);
      parsed.add(line);
      if (line.label != null && line.hasResult) {
        memory[_normalizeIdentifier(line.label!)] = line.value!;
      }
    }

    lines.assignAll(parsed);
    if (!_isApplyingTab) {
      _saveActiveTabText();
      _persistTabs();
    }
    _syncScroll();
  }

  void _loadTabs() {
    final stored = pref.read<List<dynamic>>(_tabsStorageKey);
    final savedTabs = <CalcpTab>[];
    if (stored is List) {
      for (var i = 0; i < stored.length; i++) {
        final item = stored[i];
        if (item is Map) {
          savedTabs.add(CalcpTab.fromJson(Map<String, dynamic>.from(item), i));
        } else {
          savedTabs.add(CalcpTab(name: 'Calc ${i + 1}', content: item?.toString() ?? ''));
        }
      }
    }
    final legacyContent = pref.read<String>(_legacyStorageKey);

    tabs.assignAll(savedTabs.isNotEmpty ? savedTabs : [CalcpTab(name: 'Calc 1', content: legacyContent ?? '')]);

    final savedIndex = pref.read<int>(_activeTabStorageKey) ?? 0;
    activeTab.value = savedIndex.clamp(0, tabs.length - 1);
  }

  void _saveActiveTabText() {
    if (tabs.isEmpty) {
      tabs.add(const CalcpTab(name: 'Calc 1', content: ''));
    }
    tabs[activeTab.value] = tabs[activeTab.value].copyWith(content: textController.text);
  }

  Future<void> _persistTabs() async {
    await pref.write(_tabsStorageKey, tabs.map((tab) => tab.toJson()).toList());
    await pref.write(_activeTabStorageKey, activeTab.value);
  }

  void _applyActiveTabText() {
    _isApplyingTab = true;
    textController.text = tabs[activeTab.value].content;
    textController.selection = TextSelection.collapsed(offset: textController.text.length);
    _isApplyingTab = false;
  }

  void _syncScroll() {
    if (!textScrollController.hasClients || !overlayScrollController.hasClients) {
      return;
    }
    final offset = textScrollController.offset;
    final position = overlayScrollController.position;
    final target = offset.clamp(position.minScrollExtent, position.maxScrollExtent);
    if ((overlayScrollController.offset - target).abs() > 0.5) {
      overlayScrollController.jumpTo(target);
    }
  }

  String formatValue(double value) => _formatValue(value);

  CalcLine _parseLine(String raw, Map<String, double> memory) {
    final trimmed = raw.trim();

    if (trimmed.isEmpty) {
      return CalcLine(raw: raw, isBlank: true);
    }

    if (trimmed.startsWith('#') || trimmed.startsWith('//') || trimmed.startsWith('---')) {
      return CalcLine(raw: raw, isComment: true);
    }

    String? label;
    String expression = trimmed;
    final eqIndex = trimmed.indexOf('=');

    if (eqIndex != -1) {
      label = trimmed.substring(0, eqIndex).trim();
      expression = trimmed.substring(eqIndex + 1).trim();
    }

    if (expression.isEmpty) {
      return CalcLine(
        raw: raw,
        label: label,
        expression: expression,
        error: 'Missing expression',
      );
    }

    try {
      final value = _evaluateExpression(expression, memory);
      final formatted = _formatValue(value);
      return CalcLine(
        raw: raw,
        label: label,
        expression: expression,
        value: value,
        result: formatted,
      );
    } on FormatException catch (err) {
      return CalcLine(
        raw: raw,
        label: label,
        expression: expression,
        error: err.message,
      );
    } catch (_) {
      return CalcLine(
        raw: raw,
        label: label,
        expression: expression,
        error: 'Unable to evaluate',
      );
    }
  }

  String _formatValue(double value) {
    final isInt = (value % 1).abs() < 1e-9;
    return _numberFormat.format(isInt ? value.toInt() : value);
  }

  double _evaluateExpression(String expression, Map<String, double> memory) {
    final normalized = _normalizeExpression(expression);
    final tokens = _tokenize(normalized);
    if (tokens.isEmpty) {
      throw const FormatException('Empty expression');
    }
    final rpn = _toReversePolish(tokens);
    return _evaluateRpn(rpn, memory);
  }

  String _normalizeExpression(String expression) {
    final suffixPattern = RegExp(r'(\d+(?:[.,]\d+)?)([kmbt])', caseSensitive: false);

    String result = expression
        .replaceAll(',', '.')
        .replaceAll('×', '*')
        .replaceAll('x', '*')
        .replaceAll('·', '*')
        .replaceAll('÷', '/')
        .replaceAll(RegExp(r'\s+'), ' ');

    result = result.replaceAllMapped(
      RegExp(r'(\d+(?:\.\d+)?)%\s*of\s*', caseSensitive: false),
      (match) {
        final percent = double.parse(match[1]!);
        return '(${(percent / 100).toString()})*';
      },
    );

    result = result.replaceAll(RegExp(r'\bof\b', caseSensitive: false), '*');

    result = result.replaceAllMapped(
      suffixPattern,
      (match) {
        final base = double.parse(match[1]!);
        final suffix = match[2]!.toLowerCase();
        final multiplier = switch (suffix) {
          'k' => 1e3,
          'm' => 1e6,
          'b' => 1e9,
          't' => 1e12,
          _ => 1.0,
        };
        return (base * multiplier).toString();
      },
    );

    result = result.replaceAllMapped(
      RegExp(r'(\d+(?:\.\d+)?)%', caseSensitive: false),
      (match) {
        final percent = double.parse(match[1]!);
        return '(${(percent / 100).toString()})';
      },
    );

    return result.toLowerCase().trim();
  }

  List<String> _tokenize(String expression) {
    final tokens = <String>[];
    final current = StringBuffer();

    bool isUnaryMinus(int index) {
      if (expression[index] != '-') return false;
      if (current.isNotEmpty) return false;
      int prevIndex = index - 1;
      while (prevIndex >= 0 && expression[prevIndex] == ' ') {
        prevIndex--;
      }
      if (prevIndex < 0) return true;
      const operators = '+-*/(';
      return operators.contains(expression[prevIndex]);
    }

    void flush() {
      if (current.isNotEmpty) {
        tokens.add(current.toString());
        current.clear();
      }
    }

    for (int i = 0; i < expression.length; i++) {
      final char = expression[i];

      if (char == ' ') {
        flush();
        continue;
      }

      if (char == '-' && isUnaryMinus(i)) {
        current.write(char);
        continue;
      }

      if (_isNumericChar(char)) {
        current.write(char);
        continue;
      }

      if (_isIdentifierStart(char)) {
        flush();
        final buffer = StringBuffer()..write(char);
        while (i + 1 < expression.length && _isIdentifierPart(expression[i + 1])) {
          buffer.write(expression[++i]);
        }
        tokens.add(buffer.toString());
        continue;
      }

      flush();

      if ('+-*/()'.contains(char)) {
        tokens.add(char);
      } else {
        throw FormatException('Unsupported character "$char"');
      }
    }

    flush();
    return tokens;
  }

  bool _isNumericChar(String char) {
    final code = char.codeUnitAt(0);
    return (code >= 48 && code <= 57) || char == '.';
  }

  bool _isIdentifierStart(String char) {
    final code = char.codeUnitAt(0);
    final isLetter = (code >= 97 && code <= 122);
    return isLetter || char == '_';
  }

  bool _isIdentifierPart(String char) => _isIdentifierStart(char) || _isNumericChar(char);

  List<String> _toReversePolish(List<String> tokens) {
    const precedence = {'+': 1, '-': 1, '*': 2, '/': 2};
    final output = <String>[];
    final operators = <String>[];

    for (final token in tokens) {
      if (_isOperator(token)) {
        while (
            operators.isNotEmpty &&
            _isOperator(operators.last) &&
            precedence[operators.last]! >= precedence[token]!) {
          output.add(operators.removeLast());
        }
        operators.add(token);
      } else if (token == '(') {
        operators.add(token);
      } else if (token == ')') {
        while (operators.isNotEmpty && operators.last != '(') {
          output.add(operators.removeLast());
        }
        if (operators.isEmpty) {
          throw const FormatException('Mismatched parentheses');
        }
        operators.removeLast();
      } else {
        output.add(token);
      }
    }

    while (operators.isNotEmpty) {
      final op = operators.removeLast();
      if (op == '(' || op == ')') {
        throw const FormatException('Mismatched parentheses');
      }
      output.add(op);
    }

    return output;
  }

  bool _isOperator(String value) => value == '+' || value == '-' || value == '*' || value == '/';

  double _evaluateRpn(List<String> tokens, Map<String, double> memory) {
    final stack = <double>[];

    for (final token in tokens) {
      if (_isOperator(token)) {
        if (stack.length < 2) {
          throw const FormatException('Invalid expression');
        }
        final b = stack.removeLast();
        final a = stack.removeLast();
        final result = switch (token) {
          '+' => a + b,
          '-' => a - b,
          '*' => a * b,
          '/' => _safeDivide(a, b),
          _ => throw FormatException('Unknown operator $token'),
        };
        stack.add(result);
      } else {
        stack.add(_parseValueToken(token, memory));
      }
    }

    if (stack.length != 1) {
      throw const FormatException('Invalid expression');
    }

    return stack.single;
  }

  double _safeDivide(double a, double b) {
    if (b == 0) {
      throw const FormatException('Division by zero');
    }
    return a / b;
  }

  double _parseValueToken(String token, Map<String, double> memory) {
    final number = double.tryParse(token);
    if (number != null) return number;
    final normalized = _normalizeIdentifier(token);
    final value = memory[normalized];
    if (value == null) {
      throw FormatException('Unknown value "$token"');
    }
    return value;
  }

  String _normalizeIdentifier(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'\s+'), '');
}
