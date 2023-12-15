import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helpers/helpers.dart';
import 'settings_controller.dart';

class SectionIEmport extends GetView<SettingsController> {
  const SectionIEmport({super.key});

  @override
  Widget build(BuildContext context) {
    return VStack([
      'Import From CSV'.text.make().pOnly(bottom: 8),
      ExButtonElevated(
        label: 'Import File',
        labelSize: 12,
        radius: 8,
        onPressed: () async => await SeedHelper.importFromCSV(),
      ),
      Divider().pSymmetric(v: 16),
      'Export From CSV'.text.make().pOnly(bottom: 8),
      ExButtonElevated(
        label: 'Export File',
        labelSize: 12,
        radius: 8,
        onPressed: () async => await SeedHelper.exportToCSV(),
      ),
    ]).pSymmetric(h: 8);
  }
}
