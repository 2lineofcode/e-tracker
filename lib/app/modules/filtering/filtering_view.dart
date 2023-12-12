import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_month_picker/flutter_month_picker.dart';

import 'package:get/get.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:lottie/lottie.dart';

import '../../core/app_color.dart';
import '../../core/const.dart';
import '../../helpers/helper_misc.dart';
import '../../helpers/helper_money.dart';
import '../../models/expense_entity.dart';
import '../home/section_dialog_input.dart';
import '../widgets/widgets.dart';
import 'filtering_controller.dart';

mixin UiMode {
  static const list = 'list';
  static const table = 'table';
}

class FilteringView extends GetView<FilteringController> {
  const FilteringView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyLayout(
        appBarTitle: 'Advance Filter'.text.size(11).bold.make(),
        sideMenuContent: sideMenuContent(),
        bodyContent: bodyContent(),
        footerContent: footerContent(),
      ),
    );
  }

  Widget sideMenuContent() {
    return VStack(
      [
        if (Get.context!.isMobile) 24.heightBox,
        Obx(() => ' 📦 CATEGORY (${controller.categoryList.length})'.text.bold.make().pSymmetric(h: 8, v: 8)),
        12.heightBox,
        Obx(
          () => ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: controller.categoryList.length,
            separatorBuilder: (context, index) => 8.heightBox,
            itemBuilder: (context, index) {
              final item = controller.categoryList[index];
              return Obx(
                () => InkWell(
                  onTap: () => controller.onCategoryChange(item.name!),
                  child: Container(
                    decoration: ExDecorator.box(
                      fillColor: item.name == controller.categorySelected.value ? AppColor.sideMenuSelected : Colors.transparent,
                      borderColor: Colors.transparent,
                    ),
                    child: HStack([
                      Icon(item.icon?.getIconData() ?? Icons.circle_outlined, color: item.color?.fromHex, size: 12).pOnly(right: 8),
                      '${item.name}'.text.size(11).make().expand(),
                    ]).p8(),
                  ).pSymmetric(h: 8),
                ),
              );
            },
          ).expand(),
        ),
      ],
    ).expand();
  }

  Widget bodyContent() {
    return VStack(
      [
        GlassContainer(
          color: AppColor.cardHeaderPrimary,
          width: double.infinity,
          blur: 50,
          border: Border.all(color: Get.theme.textTheme.bodySmall!.color!.withAlpha(20)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColor.cardHeaderPrimary, Get.theme.scaffoldBackgroundColor],
          ),
          child: VStack(
            [
              'Filter Settings'.text.bold.make().pOnly(bottom: 12),
              Obx(
                () => HStack([
                  'Filter: '.text.size(12).make(),
                  '${controller.categorySelected.value}'.text.size(12).make(),
                ]),
              ),
              8.heightBox,
              HStack([
                'Period: '.text.size(12).make(),

                // startDate
                Obx(
                  () => '${controller.startDate.value.reformatDate(from: yMd, to: 'dd MMM yyyy')}'.text.underline.size(12).make().onInkTap(
                    () async {
                      final date = await showMonthPicker(context: Get.context!, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2050));
                      if (date != null) controller.startDate.value = '${date.toStringEx(format: yM)}-01';
                      await controller.findExpense(controller.categorySelected.value);
                    },
                  ),
                ),

                ' to '.text.size(12).make(),

                // endDate
                Obx(
                  () => '${controller.endDate.value.reformatDate(from: yMd, to: 'dd MMM yyyy')}'.text.underline.size(12).make().onInkTap(
                    () async {
                      final date = await showMonthPicker(context: Get.context!, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2050));
                      if (date != null) controller.endDate.value = '${date.toStringEx(format: yM)}-31';
                      await controller.findExpense(controller.categorySelected.value);
                    },
                  ),
                ),
              ]),
              8.heightBox,
              HStack([
                'Order By: '.text.size(12).make(),
                Obx(
                  () => '${controller.orderBy.value.toTitleCase}'.text.underline.size(12).make().onTap(() {
                    ExAlert.adaptive(
                      content: VStack(
                        [
                          Text(
                            'Order By',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ).pOnly(bottom: 24),
                          for (var i = 0; i < controller.orderByList.length; i++) ...[
                            ListTile(
                              title: HStack(
                                [
                                  Text('${controller.orderByList[i].toTitleCase}', style: TextStyle(fontSize: 11)),
                                ],
                              ),
                              onTap: () async {
                                controller.orderBy.value = controller.orderByList[i];
                                await controller.findExpense(controller.categorySelected.value);
                                Get.back();
                              },
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                ),
              ]),
            ],
          ).p12(),
        ).p8(),
        16.heightBox,
        Obx(
          () => HStack(
            [
              Spacer(),
              IconButton(
                onPressed: () => controller.uiSelected.value = UiMode.list,
                icon: Icon(
                  CupertinoIcons.list_bullet,
                  size: 16,
                  color: controller.uiSelected.value == UiMode.list ? AppColor.blue : AppColor.textReverse.withOpacity(0.2),
                ),
              ),
              IconButton(
                onPressed: () => controller.uiSelected.value = UiMode.table,
                icon: Icon(
                  CupertinoIcons.table,
                  size: 16,
                  color: controller.uiSelected.value == UiMode.table ? AppColor.blue : AppColor.textReverse.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ),
        controller.obx(
          (state) => Obx(
            () => controller.uiSelected.value == UiMode.table ? uiModeTable() : uiModeList(),
          ),
          onEmpty: ExUiErrorOrEmpty(
            illustration: Lottie.asset('assets/lottie/empty-1.json', width: 150, reverse: true),
            title: 'No Data',
          ).expand(),
          onError: (e) => ExUiErrorOrEmpty(
            illustration: Icon(CupertinoIcons.wifi_slash),
            title: 'Offline?',
            message: 'No Internet',
          ).expand(),
        ),
      ],
    );
  }

  Widget uiModeTable() {
    return Table(
      columnWidths: {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder.all(color: Get.theme.textTheme.bodySmall!.color!.withOpacity(0.4)),
      children: [
        for (var date in controller.grouppedByDate!.keys) ...[
          TableRow(
            children: [
              TableCell(
                child: '${date?.reformatDate(from: yMd, to: 'dd MMM yyyy')}'.text.size(11).bold.make().pOnly(left: 8),
              ),
              TableCell(
                child: VStack([
                  for (var e in controller.grouppedByDate![date]!) ...[
                    ''
                        .richText
                        .withTextSpanChildren([
                          '${e.note}'.textSpan.make(),
                          ' (${e.categoryName} - ${e.amount?.moneyFormatCompact()})'.textSpan.neutral500.size(11).make(),
                        ])
                        .size(13)
                        .make()
                        .pSymmetric(h: 8),
                    if (e != controller.grouppedByDate![date]!.last) ...[
                      Divider(color: AppColor.textReverse.withOpacity(0.4)),
                    ]
                  ]
                ]).pSymmetric(v: 8),
              ),
              TableCell(
                child: VStack([
                  '${controller.sumByDate[date]?.moneyFormatCompact()}'.text.align(TextAlign.end).make(),
                ]).p8(),
              ),
            ],
          ),
        ]
      ],
    ).scrollVertical().expand();
  }

  Widget uiModeList() {
    return GroupedListView<ExpenseEntity, String>(
      elements: controller.expenseList,
      groupBy: (element) => element.date!,
      useStickyGroupSeparators: true,
      floatingHeader: true,
      order: GroupedListOrder.DESC,
      groupHeaderBuilder: (element) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColor.cardHeaderPrimary,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
          ),
          child: HStack(
            [
              Icon(
                Icons.circle,
                size: 8,
                color: controller.sumByDate[element.date]?.getFlagColor(),
              ).tooltip('${controller.sumByDate[element.date]?.getFlagText()}').pOnly(right: 8),
              '${element.date!.reformatDate(from: yMd, to: '(E) dd MMM y')}'.text.size(11).make(),
              Spacer(),
              '${controller.sumByDate[element.date]!.moneyFormat()}'.text.size(12).make(),
            ],
          ).p8(),
        );
      },
      indexedItemBuilder: (context, item, index) {
        return Container(
          decoration: BoxDecoration(color: AppColor.cardItemPrimary),
          child: HStack(
            [
              // row 1
              VStack([
                '${item.note}'.text.size(13).make().pOnly(bottom: 4),
                '${item.amount?.moneyFormat()}'.text.size(12).make(),
              ]).p12(),

              Spacer(),

              // row 2
              VStack([
                IconButton(
                  icon: Icon(Icons.edit, size: 16),
                  onPressed: () async {
                    await DialogInputHelper.showDialogExpense(
                      expense: item,
                      customCallback: () async => await controller.findExpense(item.categoryName!),
                    );
                  },
                ),
              ]).p12(),
            ],
          ),
        );
      },
    ).pSymmetric(h: 8).expand();
  }

  Widget footerContent() {
    return HStack([
      if (Get.context!.isMobile) ...[
        IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back),
        ),
      ],
      Spacer(),
      Obx(() => 'Total: ${controller.sumAll.value.moneyFormat()}'.text.bold.make()),
    ]).p12();
  }
}
