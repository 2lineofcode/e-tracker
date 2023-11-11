import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';

import '../../core/app_color.dart';
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
        HStack(
          [
            TextField(
              controller: controller.tfSearchAutoComplete,
              decoration: MyDecoration.input(
                hint: 'Search...',
                suffix: Icon(Icons.clear, size: 10).pOnly(top: 4, right: 8).onInkTap(() async {
                  controller.tfSearchAutoComplete.clear();
                  await controller.getAutoCompleteList();
                }),
                contentPadding: EdgeInsets.only(left: 8, right: 8),
              ),
              style: TextStyle(fontSize: 13),
              onSubmitted: (s) async {
                if (s.isNotEmpty) {
                  await controller.getAutoCompleteList(q: s);
                } else {
                  await controller.getAutoCompleteList();
                }
              },
            ).h(38).expand(),
            Obx(() => '${controller.autoCompleteList.length} Record'.text.bold.make().pOnly(left: 8)),
          ],
        ),
        Divider().pSymmetric(v: 8),
        controller.obx(
          (state) => GroupedListView<AutoCompleteEntity, String>(
            elements: controller.autoCompleteList,
            groupBy: (element) => element.note?.first()?.toUpperCase() ?? '?',
            floatingHeader: true,
            useStickyGroupSeparators: true,
            groupHeaderBuilder: (element) {
              return Container(
                width: double.infinity,
                color: AppColor.cardHeaderPrimary,
                child: Text(element.note?.first()?.toUpperCase() ?? '?').p8(),
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
                    child: '${item.amount?.toInt()?.moneyFormatCompact()}'.text.size(11).minFontSize(11).color(AppColor.textOnBackground).make().pSymmetric(h: 4, v: 2),
                  ).cornerRadius(4).pOnly(top: 2),
                ],

                Spacer(),

                /// categoryName
                if (item.categoryName.isNotEmptyAndNotNull && !item.categoryName!.contains('Others')) ...[
                  Container(
                    color: Vx.neutral800,
                    child: '${item.categoryName}'.text.size(11).minFontSize(11).color(AppColor.textOnBackground).make().pSymmetric(h: 4, v: 2),
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
        ),
        Divider(),
        HStack(
          [
            TextField(
              controller: controller.tfAddAutoComplete,
              decoration: MyDecoration.input(
                hint: 'Create New',
                suffix: Icon(Icons.check, size: 14),
                // fillColor: Vx.neutral500,
              ),
              style: TextStyle(fontSize: 13),
              onSubmitted: (s) => controller.onAddAutoComplete(s),
            ).h(33).expand(),
          ],
        ),
      ],
    );
  }
}
