import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';

import '../../helpers/helper_decoration.dart';
import '../../helpers/helper_money.dart';
import '../../models/autocomplete_entity.dart';
import 'settings_controller.dart';

class SectionAutoComplete extends GetView<SettingsController> {
  const SectionAutoComplete({super.key});

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        GroupedListView<AutoCompleteEntity, String>(
          elements: controller.autoCompleteList,
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
              /// title
              '${item.note}'.text.maxLines(1).ellipsis.make().pSymmetric(h: 8).constrainedBox(
                    BoxConstraints(maxWidth: 300),
                  ),

              /// amount
              if (item.amount.isNotEmptyAndNotNull) ...[
                Container(
                  color: Vx.neutral800,
                  child: '${item.amount?.toInt()?.moneyFormatCompact()}'.text.size(10).minFontSize(10).make().pSymmetric(h: 4, v: 2),
                ).cornerRadius(4).pOnly(top: 2),
              ],

              Spacer(),

              /// categoryName
              if (item.categoryName.isNotEmptyAndNotNull && !item.categoryName!.contains('Others')) ...[
                Container(
                  color: Vx.neutral800,
                  child: '${item.categoryName}'.text.size(10).minFontSize(10).make().pSymmetric(h: 4, v: 2),
                ).cornerRadius(4).pOnly(top: 2, right: 4),
              ],

              /// action
              IconButton(
                icon: Icon(Icons.delete, size: 16),
                onPressed: () => controller.onDeleteAutoComplete(item),
              ),
            ]);
          },
        ).expand(),
        TextField(
          controller: controller.tfAutoComplete,
          decoration: MyDecorationHelper.inputDecorator(hint: 'Create New', suffix: Icon(Icons.check, size: 14)),
          style: TextStyle(fontSize: 13),
          onSubmitted: (s) => controller.onAddAutoComplete(s),
        ).h(33),
      ],
    );
  }
}
