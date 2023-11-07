import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_month_picker/flutter_month_picker.dart';

import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';

import '../../helpers/helper_misc.dart';
import '../../helpers/helper_money.dart';
import '../../models/expense_entity.dart';
import '../widgets/widgets.dart';
import 'filtering_controller.dart';

class FilteringView extends GetView<FilteringController> {
  const FilteringView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyLayout(
        appBarTitle: 'Advance Filter'.text.size(11).bold.make(),
        sideMenuContent: sideMenuContent(),
        bodyContent: bodyContent(),
        footerContent: footerContent(),
        footerColor: Vx.neutral900,
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
                      fillColor: item.name == controller.categorySelected.value ? Colors.blue : Colors.transparent,
                      borderColor: Colors.transparent,
                    ),
                    child: HStack([
                      Icon(Icons.circle_outlined, color: HexColor.fromHex(item.color ?? '#FFFFFF'), size: 12).pOnly(right: 8),
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
        Container(
          width: double.infinity,
          decoration: ExDecorator.box(fillColor: Vx.neutral800, borderColor: Vx.neutral800, borderRadius: 2),
          child: VStack(
            [
              'Setting'.text.bold.make().pOnly(bottom: 12),
              Obx(
                () => HStack([
                  'Filter: '.text.size(12).neutral400.make(),
                  '${controller.categorySelected.value}'.text.size(12).make(),
                ]),
              ),
              8.heightBox,
              HStack([
                'Period: '.text.size(12).neutral400.make(),

                // startDate
                Obx(
                  () => '${controller.startDate.value.reformatDate(from: 'yyyy-MM-dd', to: 'dd MMM yyyy')}'.text.underline.size(12).make().onInkTap(
                    () async {
                      final date = await showMonthPicker(context: Get.context!, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2050));
                      if (date != null) controller.startDate.value = '${date.toStringEx(format: 'yyyy-MM')}-01';
                      await controller.findExpense(controller.categorySelected.value);
                    },
                  ),
                ),

                ' to '.text.size(12).neutral400.make(),

                // endDate
                Obx(
                  () => '${controller.endDate.value.reformatDate(from: 'yyyy-MM-dd', to: 'dd MMM yyyy')}'.text.underline.size(12).make().onInkTap(
                    () async {
                      final date = await showMonthPicker(context: Get.context!, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2050));
                      if (date != null) controller.endDate.value = '${date.toStringEx(format: 'yyyy-MM')}-31';
                      await controller.findExpense(controller.categorySelected.value);
                    },
                  ),
                ),
              ]),
              8.heightBox,
              HStack([
                'Order By: '.text.size(12).neutral400.make(),
                Obx(
                  () => '${controller.orderBy.value.toTitleCase}'.text.underline.size(12).make().onTap(() {
                    ExDialog.custom(
                      title: 'Order By',
                      titleTextStyle: TextStyle(),
                      content: VStack(
                        [
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
        controller.obx(
          (state) => GroupedListView<ExpenseEntity, String>(
            elements: controller.expenseList,
            groupBy: (element) => element.date!,
            useStickyGroupSeparators: true,
            floatingHeader: true,
            groupHeaderBuilder: (element) {
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Vx.neutral900,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                ),
                child: HStack(
                  [
                    Icon(
                      Icons.circle,
                      size: 7,
                      color: MoneyHelper.getExpenseFlagColor(controller.sumByDate[element.date]!),
                    ).tooltip('${MoneyHelper.getExpenseFlagText(controller.sumByDate[element.date]!)}').pOnly(right: 8),
                    '${element.date!.reformatDate(from: 'yyyy-MM-dd', to: 'dd/MM/y (E)')}'.text.size(11).make(),
                    Spacer(),
                    '${MoneyHelper.toRupiah(controller.sumByDate[element.date]!)}'.text.size(12).make(),
                  ],
                ).p8(),
              );
            },
            indexedItemBuilder: (context, item, index) {
              return Container(
                decoration: BoxDecoration(color: Vx.neutral800),
                child: HStack(
                  [
                    // row 1
                    VStack([
                      '${item.note}'.text.neutral400.size(13).make().pOnly(bottom: 4),
                      '${MoneyHelper.toRupiah(item.amount?.toDouble())}'.text.white.size(12).make(),
                    ]).p12(),

                    Spacer(),

                    // row 2
                    VStack([
                      IconButton(
                        icon: Icon(Icons.edit, size: 16),
                        onPressed: () async {
                          await controller.home.onShowDialogExpense(
                            expense: item,
                            customCallback: () => controller.findExpense(item.categoryName!),
                          );
                        },
                      ),
                    ]).p12(),
                  ],
                ),
              );
            },
          ).pSymmetric(h: 8).expand(),

          // ~
          onEmpty: ExUiErrorOrEmpty(
            illustration: Icon(CupertinoIcons.list_bullet),
            title: 'No Data'.text.bold.makeCentered(),
            bgColor: Color(0xff242424),
          ).expand(),
          onError: (e) => ExUiErrorOrEmpty(
            illustration: Icon(CupertinoIcons.wifi_slash),
            title: 'Offline'.text.bold.makeCentered(),
            message: 'No Internet'.text.neutral500.makeCentered(),
            bgColor: Color(0xff242424),
          ).expand(),
        ),
      ],
    );
  }

  Widget footerContent() {
    return HStack([
      Spacer(),
      Obx(() => 'Total: ${MoneyHelper.toRupiah(controller.sumAll.value)}'.text.make()),
    ]).p12();
  }
}
