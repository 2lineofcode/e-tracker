import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:worksheet/worksheet.dart' as ws;

import 'worksheet_controller.dart';

class WorksheetView extends GetView<WorksheetController> {
  const WorksheetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Obx(
                () => Text(
                  controller.selectedCellInfo.value,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            Expanded(
              child: ws.WorksheetTheme(
                data: const ws.WorksheetThemeData(
                  showHeaders: true,
                  showGridlines: true,
                  defaultRowHeight: 28,
                  defaultColumnWidth: 120,
                  rowHeaderWidth: 44,
                  columnHeaderHeight: 24,
                  fontSize: 12,
                ),
                child: ws.Worksheet(
                  data: controller.displayData,
                  rawData: controller.rawData,
                  controller: controller.worksheetController,
                  editController: controller.editController,
                  rowCount: WorksheetController.rowCount,
                  columnCount: WorksheetController.columnCount,
                  onCellTap: controller.onCellTap,
                  shortcuts: const {
                    SingleActivator(LogicalKeyboardKey.enter): ws.EditCellIntent(),
                    SingleActivator(LogicalKeyboardKey.numpadEnter): ws.EditCellIntent(),
                    SingleActivator(LogicalKeyboardKey.keyB, meta: true): ToggleWorksheetBoldIntent(),
                    SingleActivator(LogicalKeyboardKey.keyG, meta: true): ToggleWorksheetBackgroundIntent(),
                    SingleActivator(LogicalKeyboardKey.keyB, control: true): ToggleWorksheetBoldIntent(),
                    SingleActivator(LogicalKeyboardKey.keyG, control: true): ToggleWorksheetBackgroundIntent(),
                  },
                  actions: {
                    ToggleWorksheetBoldIntent: ToggleWorksheetBoldAction(controller),
                    ToggleWorksheetBackgroundIntent: ToggleWorksheetBackgroundAction(controller),
                  },
                  formulaAutocompleteConfig: const ws.FormulaAutocompleteConfig(
                    functions: [
                      ws.FormulaFunction(
                        name: 'SUM',
                        signature: 'SUM(number1, [number2], ...)',
                        description: 'Adds numbers from a range.',
                      ),
                      ws.FormulaFunction(
                        name: 'AVERAGE',
                        signature: 'AVERAGE(number1, [number2], ...)',
                        description: 'Returns the average value.',
                      ),
                      ws.FormulaFunction(
                        name: 'MIN',
                        signature: 'MIN(number1, [number2], ...)',
                      ),
                      ws.FormulaFunction(
                        name: 'MAX',
                        signature: 'MAX(number1, [number2], ...)',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(10),
          color: Theme.of(context).colorScheme.surface,
          child: const Text(
            'Enter edit. Meta+B bold, Meta+G background. Saat edit: Enter save, Tab pindah kanan, Esc batal.',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final textColor = Get.isDarkMode ? Colors.white70 : Colors.black87;
    final iconColor = Get.isDarkMode ? Colors.white70 : Colors.black54;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Worksheet Tester',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: controller.resetSample,
            splashRadius: 18,
            tooltip: 'Clear sheet',
            icon: Icon(
              Icons.refresh,
              color: iconColor,
              size: 20,
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            splashRadius: 18,
            tooltip: 'Close',
            icon: Icon(
              Icons.close,
              color: iconColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class ToggleWorksheetBoldIntent extends Intent {
  const ToggleWorksheetBoldIntent();
}

class ToggleWorksheetBackgroundIntent extends Intent {
  const ToggleWorksheetBackgroundIntent();
}

class ToggleWorksheetBoldAction extends Action<Intent> {
  ToggleWorksheetBoldAction(this.controller);

  final WorksheetController controller;

  @override
  Object? invoke(Intent intent) {
    controller.toggleSelectedBold();
    return null;
  }
}

class ToggleWorksheetBackgroundAction extends Action<Intent> {
  ToggleWorksheetBackgroundAction(this.controller);

  final WorksheetController controller;

  @override
  Object? invoke(Intent intent) {
    controller.toggleSelectedBackground();
    return null;
  }
}
