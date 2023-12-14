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
      'Section Import/Export'.text.make().onTap(() async {
        await SeedHelper.exportToCSV();
      }),
    ]);
  }
}
