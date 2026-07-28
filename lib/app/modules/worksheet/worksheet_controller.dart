import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:worksheet/worksheet.dart' as ws;
import 'package:worksheet_formula/worksheet_formula.dart' as formula;

import '../../core/app_setting.dart';

class WorksheetController extends GetxController {
  static const _storageKey = 'worksheet_tester_cells';
  static const _highlightColor = Color(0xFFFFF3CD);

  late final ws.SparseWorksheetData rawData;
  late final ws.WorksheetData displayData;
  late final ws.WorksheetController worksheetController;
  late final ws.EditController editController;
  late final formula.FormulaEngine formulaEngine;
  StreamSubscription? _dataSubscription;
  Timer? _saveTimer;

  final selectedCellInfo = 'Tap a cell'.obs;

  static const rowCount = 100;
  static const columnCount = 12;

  @override
  void onInit() {
    super.onInit();

    formulaEngine = formula.FormulaEngine();
    rawData = ws.SparseWorksheetData(
      rowCount: rowCount,
      columnCount: columnCount,
    );
    worksheetController = ws.WorksheetController();
    editController = ws.EditController();

    _loadSavedData();
    displayData = FormulaWorksheetData(rawData, formulaEngine);
    _dataSubscription = rawData.changes.listen((_) => _scheduleSave());
  }

  void onCellTap(ws.CellCoordinate cell) {
    final rawValue = rawData.getCell(cell);
    final displayValue = displayData.getCell(cell);

    final rawText = rawValue?.displayValue ?? '';
    final resultText = displayValue?.displayValue ?? '';

    if (rawText.startsWith('=')) {
      selectedCellInfo.value = '${cell.toNotation()}  $rawText  =>  $resultText';
      return;
    }

    selectedCellInfo.value = '${cell.toNotation()}  $resultText';
  }

  void resetSample() {
    rawData.clearRange(const ws.CellRange(0, 0, rowCount - 1, columnCount - 1));
    selectedCellInfo.value = 'Tap a cell';
  }

  void toggleSelectedBold() {
    final range = worksheetController.selectedRange;
    if (range == null) return;

    final shouldBold = !_isRangeBold(range);

    rawData.batchUpdate((batch) {
      for (var row = range.startRow; row <= range.endRow; row++) {
        for (var column = range.startColumn; column <= range.endColumn; column++) {
          final cell = ws.CellCoordinate(row, column);
          batch.setRichText(
            cell,
            shouldBold
                ? const [
                    TextSpan(
                      text: '',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ]
                : null,
          );
        }
      }
    });
  }

  void toggleSelectedBackground() {
    final range = worksheetController.selectedRange;
    if (range == null) return;

    final shouldPaint = !_isRangeHighlighted(range);

    rawData.batchUpdate((batch) {
      for (var row = range.startRow; row <= range.endRow; row++) {
        for (var column = range.startColumn; column <= range.endColumn; column++) {
          final cell = ws.CellCoordinate(row, column);
          final current = rawData.getStyle(cell);

          batch.setStyle(
            cell,
            shouldPaint
                ? (current ?? const ws.CellStyle()).merge(
                    const ws.CellStyle(backgroundColor: _highlightColor),
                  )
                : _styleWithoutBackground(current),
          );
        }
      }
    });
  }

  bool _isRangeBold(ws.CellRange range) {
    for (var row = range.startRow; row <= range.endRow; row++) {
      for (var column = range.startColumn; column <= range.endColumn; column++) {
        if (!_isCellBold(ws.CellCoordinate(row, column))) return false;
      }
    }

    return true;
  }

  bool _isCellBold(ws.CellCoordinate cell) {
    final richText = rawData.getRichText(cell);
    if (richText == null || richText.isEmpty) return false;

    return richText.every((span) {
      final weight = span.style?.fontWeight;
      return weight == FontWeight.bold || weight == FontWeight.w700;
    });
  }

  bool _isRangeHighlighted(ws.CellRange range) {
    for (var row = range.startRow; row <= range.endRow; row++) {
      for (var column = range.startColumn; column <= range.endColumn; column++) {
        final style = rawData.getStyle(ws.CellCoordinate(row, column));
        if (style?.backgroundColor != _highlightColor) return false;
      }
    }

    return true;
  }

  ws.CellStyle? _styleWithoutBackground(ws.CellStyle? style) {
    if (style == null) return null;

    final hasOtherStyle =
        style.textAlignment != null ||
        style.verticalAlignment != null ||
        style.borders != null ||
        style.wrapText != null;

    if (!hasOtherStyle) return null;

    return ws.CellStyle(
      textAlignment: style.textAlignment,
      verticalAlignment: style.verticalAlignment,
      borders: style.borders,
      wrapText: style.wrapText,
    );
  }

  void _loadSavedData() {
    final stored = pref.read(_storageKey);

    if (stored is! List) return;

    rawData.batchUpdate((batch) {
      for (final item in stored) {
        if (item is! Map) continue;

        final row = item['row'];
        final column = item['column'];
        final value = _cellValueFromJson(item);
        final backgroundColor = _colorFromJson(item['backgroundColor']);
        final bold = item['bold'] == true;

        if (row is! int || column is! int) continue;
        if (row < 0 || row >= rowCount || column < 0 || column >= columnCount) {
          continue;
        }

        final cell = ws.CellCoordinate(row, column);

        if (value != null) {
          batch.setCell(cell, value);
        }

        if (backgroundColor != null) {
          batch.setStyle(
            cell,
            ws.CellStyle(backgroundColor: backgroundColor),
          );
        }

        if (bold) {
          batch.setRichText(
            cell,
            const [
              TextSpan(
                text: '',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          );
        }
      }
    });
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 400), saveWorksheet);
  }

  Future<void> saveWorksheet() async {
    const range = ws.CellRange(0, 0, rowCount - 1, columnCount - 1);
    final cellMap = <String, Map<String, dynamic>>{};

    Map<String, dynamic> ensureCell(ws.CellCoordinate coordinate) {
      final key = '${coordinate.row}:${coordinate.column}';
      return cellMap.putIfAbsent(key, () {
        return {
          'row': coordinate.row,
          'column': coordinate.column,
        };
      });
    }

    for (final entry in rawData.getCellsInRange(range)) {
      ensureCell(entry.key).addAll(_cellValueToJson(entry.value));
    }

    for (final entry in rawData.getStylesInRange(range)) {
      final backgroundColor = entry.value.backgroundColor;
      if (backgroundColor == null) continue;

      ensureCell(entry.key)['backgroundColor'] = backgroundColor.toARGB32();
    }

    for (final entry in rawData.getRichTextInRange(range)) {
      if (_isRichTextBold(entry.value)) {
        ensureCell(entry.key)['bold'] = true;
      }
    }

    final cells = cellMap.values.toList();

    await pref.write(_storageKey, cells);
  }

  @override
  void onClose() {
    _saveTimer?.cancel();
    saveWorksheet();
    _dataSubscription?.cancel();
    editController.dispose();
    worksheetController.dispose();
    rawData.dispose();
    super.onClose();
  }

  Map<String, dynamic> _cellValueToJson(ws.CellValue value) {
    return {
      'type': value.type.name,
      'value': _rawValueToJson(value),
    };
  }

  Object _rawValueToJson(ws.CellValue value) {
    switch (value.type) {
      case ws.CellValueType.date:
        return (value.rawValue as DateTime).toIso8601String();
      case ws.CellValueType.duration:
        return (value.rawValue as Duration).inMicroseconds;
      case ws.CellValueType.number:
      case ws.CellValueType.text:
      case ws.CellValueType.boolean:
      case ws.CellValueType.formula:
      case ws.CellValueType.error:
        return value.rawValue;
    }
  }

  ws.CellValue? _cellValueFromJson(Map item) {
    final type = item['type'];
    final value = item['value'];

    if (type is! String) return null;

    switch (type) {
      case 'number':
        if (value is! num) return null;
        return ws.CellValue.number(value);
      case 'text':
        if (value is! String) return null;
        return ws.CellValue.text(value);
      case 'boolean':
        if (value is! bool) return null;
        return ws.CellValue.boolean(value);
      case 'formula':
        if (value is! String) return null;
        return ws.CellValue.formula(value);
      case 'error':
        if (value is! String) return null;
        return ws.CellValue.error(value);
      case 'date':
        if (value is! String) return null;
        final date = DateTime.tryParse(value);
        return date == null ? null : ws.CellValue.date(date);
      case 'duration':
        if (value is! int) return null;
        return ws.CellValue.duration(Duration(microseconds: value));
      default:
        return null;
    }
  }

  Color? _colorFromJson(dynamic value) {
    if (value is! int) return null;

    return Color(value);
  }

  bool _isRichTextBold(List<TextSpan> richText) {
    if (richText.isEmpty) return false;

    return richText.every((span) {
      final weight = span.style?.fontWeight;
      return weight == FontWeight.bold || weight == FontWeight.w700;
    });
  }
}

class FormulaWorksheetData extends ws.DelegatingWorksheetData {
  FormulaWorksheetData(super.inner, this.engine);

  final formula.FormulaEngine engine;
  final Set<ws.CellCoordinate> _evaluating = {};

  @override
  ws.CellValue? getCell(ws.CellCoordinate coord) {
    final value = inner.getCell(coord);

    if (value == null || value.type != ws.CellValueType.formula) {
      return value;
    }

    return _evaluateFormulaCell(coord, value.rawValue as String);
  }

  ws.CellValue _evaluateFormulaCell(ws.CellCoordinate coord, String expression) {
    if (_evaluating.contains(coord)) {
      return const ws.CellValue.error('#CIRCULAR!');
    }

    _evaluating.add(coord);
    try {
      final context = WorksheetFormulaContext(this, engine, coord);
      final value = engine.evaluateString(expression, context);

      return _toCellValue(value);
    } catch (_) {
      return const ws.CellValue.error('#ERROR!');
    } finally {
      _evaluating.remove(coord);
    }
  }

  ws.CellValue _toCellValue(formula.FormulaValue value) {
    if (value is formula.NumberValue) {
      return ws.CellValue.number(value.value);
    }

    if (value is formula.TextValue) {
      return ws.CellValue.text(value.value);
    }

    if (value is formula.BooleanValue) {
      return ws.CellValue.boolean(value.value);
    }

    if (value is formula.ErrorValue) {
      return ws.CellValue.error(value.error.code);
    }

    if (value is formula.EmptyValue) {
      return const ws.CellValue.text('');
    }

    return ws.CellValue.text(value.toText());
  }
}

class WorksheetFormulaContext implements formula.EvaluationContext {
  WorksheetFormulaContext(this.data, this.engine, ws.CellCoordinate currentCell)
    : currentCell = ws.A1.fromVector(currentCell.column, currentCell.row);

  final FormulaWorksheetData data;
  final formula.FormulaEngine engine;

  @override
  final ws.A1 currentCell;

  @override
  String? get currentSheet => null;

  @override
  bool get isCancelled => false;

  @override
  formula.FormulaFunction? getFunction(String name) => engine.functions.get(name);

  @override
  formula.FormulaValue? getVariable(String name) => null;

  @override
  formula.FormulaValue getCellValue(ws.A1 cell) {
    final value = data.getCell(ws.CellCoordinate(cell.row, cell.column));

    return _toFormulaValue(value);
  }

  @override
  formula.FormulaValue getRangeValues(ws.A1Range range) {
    final values = <List<formula.FormulaValue>>[];

    for (var row = range.top; row <= range.bottom; row++) {
      final rowValues = <formula.FormulaValue>[];

      for (var column = range.left; column <= range.right; column++) {
        final cell = ws.CellCoordinate(row, column);
        rowValues.add(_toFormulaValue(data.getCell(cell)));
      }

      values.add(rowValues);
    }

    return formula.FormulaValue.range(values);
  }

  formula.FormulaValue _toFormulaValue(ws.CellValue? value) {
    if (value == null) {
      return const formula.FormulaValue.empty();
    }

    switch (value.type) {
      case ws.CellValueType.number:
        return formula.FormulaValue.number(value.rawValue as double);
      case ws.CellValueType.text:
        return formula.FormulaValue.text(value.rawValue as String);
      case ws.CellValueType.boolean:
        return formula.FormulaValue.boolean(value.rawValue as bool);
      case ws.CellValueType.error:
        return const formula.FormulaValue.error(formula.FormulaError.value);
      case ws.CellValueType.formula:
        return const formula.FormulaValue.error(formula.FormulaError.circular);
      case ws.CellValueType.date:
      case ws.CellValueType.duration:
        return formula.FormulaValue.text(value.displayValue);
    }
  }
}
