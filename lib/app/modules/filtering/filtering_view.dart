import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_month_picker/flutter_month_picker.dart';

import 'package:get/get.dart';

import '../../helpers/helper_color.dart';
import '../../helpers/helper_money.dart';
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
      ),
    );
  }

  Widget sideMenuContent() {
    return VStack(
      [
        Obx(() => ' 📦 CATEGORY (${controller.categoryList.length})'.text.bold.make().pSymmetric(h: 8, v: 8)),
        12.heightBox,
        Obx(
          () => ListView.separated(
            itemCount: controller.categoryList.length,
            separatorBuilder: (context, index) => 8.heightBox,
            itemBuilder: (context, index) {
              final item = controller.categoryList[index];
              return Container(
                decoration: ExDecorator.box(
                  fillColor: item.name == controller.categorySelected.value ? Colors.blue : Colors.transparent,
                  borderColor: Colors.transparent,
                ),
                child: HStack(
                  [
                    Icon(Icons.circle_outlined, color: HexColor.fromHex(item.color ?? '#FFFFFF'), size: 12).pOnly(right: 8),
                    '${item.name}'.text.size(11).make().expand(),
                  ],
                ).p8(),
              ).pSymmetric(h: 8).onInkTap(() => controller.onCategoryChange(item.name!));
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
              'Setting'.text.make().pOnly(bottom: 12),
              HStack([
                'Filter: '.text.size(11).minFontSize(11).neutral400.make(),
                '${controller.categorySelected.value}'.text.size(11).minFontSize(11).make(),
              ]),
              8.heightBox,
              HStack([
                'Period: '.text.size(11).minFontSize(11).neutral400.make(),

                // startDate
                Obx(
                  () => '${controller.startDate.value.reformatDate(from: 'yyyy-MM-dd', to: 'MMMM yyyy')}'.text.underline.size(11).minFontSize(11).bold.make().onInkTap(
                    () async {
                      final date = await showMonthPicker(context: Get.context!, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2050));
                      if (date != null) controller.startDate.value = '${date.toStringEx(format: 'yyyy-MM')}-01';
                      controller.onCategoryChange(controller.categorySelected.value);
                    },
                  ),
                ),

                ' to '.text.size(11).minFontSize(11).neutral400.make(),

                // endDate
                Obx(
                  () => '${controller.endDate.value.reformatDate(from: 'yyyy-MM-dd', to: 'MMMM yyyy')}'.text.underline.size(11).minFontSize(11).bold.make().onInkTap(
                    () async {
                      final date = await showMonthPicker(context: Get.context!, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2050));
                      if (date != null) controller.endDate.value = '${date.toStringEx(format: 'yyyy-MM')}-01';
                      controller.onCategoryChange(controller.categorySelected.value);
                    },
                  ),
                ),
              ]),
              8.heightBox,
              HStack([
                'Order By: '.text.size(11).minFontSize(11).neutral400.make(),
                Obx(
                  () => '${controller.orderBy.value.toTitleCase}'.text.underline.size(11).minFontSize(11).make().onTap(() {
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
                                await controller.onCategoryChange(controller.categorySelected.value);
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
        ExDivider(
          label: '  # Result (${controller.expenseList.length})',
          dividerMode: ExDividerMode.LINE,
          textMode: ExDividerTextMode.LEFT,
        ).pOnly(bottom: 12, top: 8),
        controller
            .obx(
              (state) => Obx(
                () => ListView.builder(
                  itemCount: controller.expenseList.length,
                  itemBuilder: (context, index) {
                    final item = controller.expenseList[index];
                    return Container(
                      decoration: BoxDecoration(color: Vx.neutral900, borderRadius: BorderRadius.all(Radius.circular(4))),
                      child: Row(
                        children: [
                          VStack([
                            '${item.date!.reformatDate(from: 'yyyy-MM-dd', to: 'EEE, dd MMM yyyy')}'.text.size(11).minFontSize(11).make().pOnly(bottom: 8),
                            '${item.note}'.text.bold.make().pOnly(bottom: 2),
                          ]),
                          Spacer(),
                          '${MoneyHelper.toRupiah(item.amount?.toDouble())}'.text.bold.size(16).make(),
                        ],
                      ).p12(),
                    ).onTap(() async {
                      await controller.home.onShowDialogExpense(
                        expense: item,
                        customCallback: () => controller.onCategoryChange(item.categoryName!),
                      );
                    }).pSymmetric(h: 8, v: 4);
                  },
                ),
              ),
              onEmpty: ExUiErrorOrEmpty(
                illustration: Icon(CupertinoIcons.list_bullet),
                title: 'No Data'.text.bold.makeCentered(),
                bgColor: Color(0xff242424),
              ),
              onError: (e) => ExUiErrorOrEmpty(
                illustration: Icon(CupertinoIcons.wifi_slash),
                title: 'Offline'.text.bold.makeCentered(),
                message: 'No Internet'.text.neutral500.makeCentered(),
                bgColor: Color(0xff242424),
              ),
            )
            .expand(),
      ],
    );
  }

  Widget footerContent() {
    return HStack([
      Spacer(),
      Obx(() => 'Total: ${MoneyHelper.toRupiah(controller.total.value)}'.text.make()),
    ]).p12();
  }
}
