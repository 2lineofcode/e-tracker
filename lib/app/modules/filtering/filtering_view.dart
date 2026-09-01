import 'package:ex_kit/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';

import 'package:get/get.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:lottie/lottie.dart';

import '../../core/app_color.dart';
import '../../core/const.dart';
import '../../helpers/helper_misc.dart';
import '../../helpers/helper_money.dart';
import '../../models/supa_category_entity.dart';
import '../../models/supa_expense_entity.dart';
import '../home/section_dialog_expense.dart';
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
    return MyLayout(
      drawerKey: drawerKeyFiltering,
      appBarTitle: 'Filter lanjutan'.text.size(11).bold.make(),
      sideMenuContent: sideMenuContent(),
      bodyContent: bodyContent(),
      footerContent: footerContent(),
    );
  }

  Widget sideMenuContent() {
    return VStack(
      [
        if (Get.context!.isMobile) 24.heightBox,
        Obx(
          () => ' 📦 KATEGORI (${controller.categoryList.length})'.text.bold.make().pSymmetric(h: 8, v: 8),
        ),
        12.heightBox,
        Obx(
          () {
            final categories = controller.categoryList;
            if (categories.isEmpty) {
              return const SizedBox().expand();
            }

            ExpenseCategory? allCategory;
            final groupedCategories = <String, List<ExpenseCategory>>{};

            for (final item in categories) {
              if (item.code == 'All') {
                allCategory = item;
                continue;
              }
              groupedCategories.putIfAbsent(item.groupLabel, () => <ExpenseCategory>[]).add(item);
            }

            final children = <Widget>[];
            if (allCategory != null) {
              children.add(_buildCategoryTile(allCategory));
            }

            final groupedEntries = groupedCategories.entries.toList(growable: false);
            for (var i = 0; i < groupedEntries.length; i++) {
              final entry = groupedEntries[i];
              if (children.isNotEmpty) {
                children.add(12.heightBox);
              }

              children.add(
                entry.key.text.size(10).semiBold.color(AppColor.textReverse.withAlpha(150)).make().pSymmetric(h: 8),
              );
              children.add(6.heightBox);

              final items = entry.value;
              for (var j = 0; j < items.length; j++) {
                if (j > 0) {
                  children.add(4.heightBox);
                }
                children.add(_buildCategoryTile(items[j]));
              }
            }

            if (children.isEmpty) {
              return const SizedBox().expand();
            }

            return ListView(
              padding: EdgeInsets.zero,
              children: children,
            ).expand();
          },
        ),
      ],
    ).expand();
  }

  Widget _buildCategoryTile(ExpenseCategory item) {
    final isSelected = controller.categorySelected.value == item.code;
    return InkWell(
      onTap: () => controller.onCategoryChange(item.code),
      child: Container(
        decoration: ExDecorator.box(
          fillColor: isSelected ? AppColor.sideMenuSelected : Colors.transparent,
          borderColor: Colors.transparent,
        ),
        child: HStack(
          [
            Icon(
              item.icon ?? Icons.circle_outlined,
              color: item.color ?? AppColor.textReverse,
              size: 12,
            ).pOnly(right: 8),
            '${item.label}'.text.ellipsis.maxLines(1).size(11).make().expand(),
          ],
        ).p8(),
      ).pSymmetric(h: 8),
    );
  }

  Widget bodyContent() {
    return VStack(
      [
        GlassContainer(
          width: double.infinity,
          blur: 50,
          border: Border.all(
            color: Get.theme.textTheme.bodySmall!.color!.withAlpha(20),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Vx.pink500, AppColor.primary],
          ),
          child: VStack(
            [
              'Pengaturan filter'.text.bold.make().pOnly(bottom: 12),
              Obx(
                () => HStack([
                  'Filter: '.text.size(12).make(),
                  (() {
                    final code = controller.categorySelected.value;
                    if (code == 'All' || code == '*') return 'Semua'.text.size(12).make();
                    return resolveExpenseCategory(
                      code,
                    ).label.text.size(12).make();
                  })(),
                ]),
              ),
              8.heightBox,
              HStack([
                'Periode: '.text.size(12).make(),

                // start date
                MyMonthYearPicker(
                  child: Obx(
                    () => '${controller.startDate.value.reformatDate(from: yMd, to: 'dd MMM yyyy')}'.text.underline.size(12).make(),
                  ),
                  onGoDate: (dt) {
                    controller.startDate.value = '${dt.toStringEx(format: yM)}-01';
                    controller.findExpense(controller.categorySelected.value);
                  },
                ),

                ' sampai '.text.size(12).make(),

                // end date
                MyMonthYearPicker(
                  child: Obx(
                    () => '${controller.endDate.value.reformatDate(from: yMd, to: 'dd MMM yyyy')}'.text.underline.size(12).make(),
                  ),
                  onGoDate: (dt) async {
                    final ldate = dayInMonth(dt);
                    controller.endDate.value = '${dt.toStringEx(format: yM)}-$ldate';
                    await controller.findExpense(
                      controller.categorySelected.value,
                    );
                  },
                ),
              ]),
              8.heightBox,
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
                  color: controller.uiSelected.value == UiMode.list ? null : AppColor.textReverse.withAlpha(50),
                ),
              ),
              IconButton(
                onPressed: () => controller.uiSelected.value = UiMode.table,
                icon: Icon(
                  CupertinoIcons.table,
                  size: 16,
                  color: controller.uiSelected.value == UiMode.table ? null : AppColor.textReverse.withAlpha(50),
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
            illustration: Lottie.asset(
              'assets/lottie/empty.json',
              width: 150,
              reverse: true,
            ),
            title: 'Belum ada data',
          ).expand(),
          onError: (e) => ExUiErrorOrEmpty(
            illustration: Icon(CupertinoIcons.wifi_slash),
            title: 'Lagi offline?',
            message: 'Nggak ada koneksi internet',
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
      border: TableBorder.all(
        color: Get.theme.textTheme.bodySmall!.color!.withValues(alpha: 0.4),
      ),
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
                    ''.richText
                        .withTextSpanChildren([
                          '${e.note}'.textSpan.make(),
                          ' (${resolveExpenseCategory(e.categoryName).label} - ${e.amount?.moneyFormatCompact()})'.textSpan.neutral500.size(11).make(),
                        ])
                        .size(13)
                        .make()
                        .pSymmetric(h: 8),
                    if (e != controller.grouppedByDate![date]!.last) ...[
                      Divider(
                        color: AppColor.textReverse.withValues(alpha: 0.4),
                      ),
                    ],
                  ],
                ]).pSymmetric(v: 8),
              ),
              TableCell(
                child: VStack([
                  '${controller.sumByDate[date]?.moneyFormatCompact()}'.text.align(TextAlign.end).make(),
                ]).p8(),
              ),
            ],
          ),
        ],
      ],
    ).pSymmetric(h: 12).scrollVertical().expand();
  }

  Widget uiModeList() {
    return GroupedListView<SupaExpense, String>(
      elements: controller.expenseList,
      groupBy: (element) => element.date!,
      useStickyGroupSeparators: true,
      floatingHeader: true,
      order: GroupedListOrder.DESC,
      groupHeaderBuilder: (element) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColor.card,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          child: HStack(
            [
              Icon(
                    Icons.circle,
                    size: 8,
                    color: controller.sumByDate[element.date]?.getFlagColor(),
                  )
                  .tooltip(
                    '${controller.sumByDate[element.date]?.getFlagText()}',
                  )
                  .pOnly(right: 8),
              '${element.date!.reformatDate(from: yMd, to: '(E) dd MMM y')}'.text.color(AppColor.textReverse).size(11).make(),
              Spacer(),
              '${controller.sumByDate[element.date]!.moneyFormat()}'.text.size(12).color(AppColor.textReverse).make(),
            ],
          ).p8(),
        );
      },
      indexedItemBuilder: (context, item, index) {
        return Container(
          decoration: BoxDecoration(color: AppColor.card),
          child: HStack(
            [
              // row 0
              CustomPopup(
                content: VStack(
                  [
                    item.resolvedCategory.label.text.black.size(13).make(),
                    item.detail.isNotEmptyAndNotNull ? '${item.detail}'.text.black.size(12).make() : 0.heightBox,
                  ],
                ),
                child: Container(
                  decoration: ExDecorator.box(),
                  child: Icon(
                    item.resolvedCategory.icon ?? Icons.circle,
                    size: 16,
                    color: item.resolvedCategory.color,
                  ).p8(),
                ).pOnly(left: 8),
              ),

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
                    await DialogExpense.openManualInput(
                      expense: item,
                      customCallback: () async => await controller.findExpense(item.categoryName ?? ''),
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
      Obx(
        () => 'Total: ${controller.sumAll.value.moneyFormat()}'.text.bold.make(),
      ),
    ]).p12();
  }
}
