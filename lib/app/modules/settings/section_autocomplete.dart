import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:lottie/lottie.dart';

import '../../core/app_color.dart';
import '../../helpers/helper_decoration.dart';
import '../../helpers/helper_money.dart';
import '../../models/supa_autocomplete_entity.dart';
import 'settings_controller.dart';

class SectionAutoComplete extends GetView<SettingsController> {
  const SectionAutoComplete({super.key});

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        controller.obx(
          (state) => GroupedListView<SupaAutoComplete, String>(
            elements: controller.autoCompleteList,
            groupBy: (element) => element.note?.first()?.toUpperCase() ?? '?',
            floatingHeader: true,
            useStickyGroupSeparators: true,
            groupHeaderBuilder: (element) {
              return Container(
                width: double.infinity,
                color: AppColor.box,
                child: Text(element.note?.first()?.toUpperCase() ?? '?', style: TextStyle(fontWeight: FontWeight.bold)).p8(),
              );
            },
            indexedItemBuilder: (context, item, index) {
              return HStack([
                /// title
                '${item.note}'.text.maxLines(1).ellipsis.make().pSymmetric(h: 8).constrainedBox(BoxConstraints(maxWidth: 300)),

                /// amount
                if (item.amount.isNotEmptyAndNotNull) ...[
                  Container(
                    color: AppColor.primary.withAlpha(100),
                    child: '${item.amount?.toInt()?.moneyFormatCompact()}'.text.size(11).minFontSize(11).color(AppColor.textOnBackground).make().pSymmetric(h: 8, v: 2),
                  ).cornerRadius(90).pOnly(top: 2),
                ],

                Spacer(),

                /// categoryName
                if (item.categoryName.isNotEmptyAndNotNull && !item.categoryName!.contains('Others')) ...[
                  Container(
                    color: AppColor.primary.withAlpha(100),
                    child: '${item.categoryName}'.text.size(11).minFontSize(11).color(AppColor.textOnBackground).make().pSymmetric(h: 8, v: 2),
                  ).cornerRadius(90).pOnly(top: 2, right: 4),
                ],

                /// action
                IconButton(
                  icon: Icon(Icons.delete, size: 16),
                  onPressed: () => controller.onDeleteAutoComplete(item),
                ),
              ]);
            },
          ).expand(),
          onLoading: ExUiLoading().expand(),
          onEmpty: ExUiErrorOrEmpty(
            illustration: Get.context!.isMobile
                ? Image.asset('assets/icons/app_icon.png', width: 56, height: 56).pOnly(bottom: 16)
                : Lottie.asset('assets/lottie/empty.json', width: 150, reverse: true),
            title: 'No Data',
            message: 'You can add new Auto Complete by input in the field below',
          ).expand(),
        ),
        Divider(color: Colors.transparent),
        HStack(
          [
            TextField(
              controller: controller.tfAddAutoComplete,
              decoration: DecorationHelper.input(
                hint: 'Create New',
                fillColor: Get.isDarkMode ? AppColor.card : null,
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
