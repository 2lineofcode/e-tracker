import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';

import '../../helpers/helper_decoration.dart';
import '../../models/autocomplete_note_entity.dart';
import 'settings_controller.dart';

class SectionAutoComplete extends GetView<SettingsController> {
  const SectionAutoComplete({super.key});

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        GroupedListView<AutocompleteNoteEntity, String>(
          elements: controller.autocompleteNote,
          groupBy: (element) => element.note!.toTitleCase!.substring(0, 1),
          floatingHeader: true,
          groupHeaderBuilder: (element) {
            return Container(
              color: Vx.neutral900,
              child: Text(element.note!.toTitleCase!.substring(0, 1)).p8(),
            );
          },
          indexedItemBuilder: (context, item, index) {
            return HStack([
              '${item.note}'.text.make().pSymmetric(h: 8).expand(),
              IconButton(
                icon: Icon(Icons.delete, size: 16),
                onPressed: () => controller.onDeleteAutocompleteNote(item),
              ),
            ]);
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
