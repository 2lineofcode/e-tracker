import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helpers/helper_decoration.dart';
import 'settings_controller.dart';

class SectionAutoComplete extends GetView<SettingsController> {
  const SectionAutoComplete({super.key});

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        ListView.separated(
          itemCount: controller.autocompleteNote.length,
          separatorBuilder: (context, index) => Divider(),
          itemBuilder: (context, index) {
            final item = controller.autocompleteNote[index];

            return HStack(
              [
                VStack([
                  '${item.createdAt!.reformatDate(to: 'dd/MM/y')}'.text.neutral400.size(8).minFontSize(8).make().pOnly(bottom: 2).pSymmetric(h: 9),
                  '${item.note}'.text.make().pSymmetric(h: 8),
                ]),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.delete, size: 18),
                  onPressed: () => controller.onDeleteAutocompleteNote(item),
                ),
              ],
            );
          },
        ).expand(),
        TextField(
          controller: controller.tfAutocompleteNote,
          decoration: MyDecorationHelper.inputDecorator(hint: 'Create New', suffix: Icon(Icons.check, size: 14)),
          style: TextStyle(fontSize: 13),
          onSubmitted: (s) => controller.onAddAutocompleteNote(s),
        ).h(33),
      ],
    );
  }
}
