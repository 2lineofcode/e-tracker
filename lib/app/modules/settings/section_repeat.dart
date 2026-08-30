import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:uicons_pro/uicons_pro.dart';

import '../../core/app_color.dart';
import '../../helpers/helpers.dart';
import '../../models/supa_category_entity.dart';
import 'settings_controller.dart';

class SectionRepeat extends GetView<SettingsController> {
  const SectionRepeat({super.key});

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        HStack([
          'Transaksi rutin'.text.size(15).bold.make(),
          Spacer(),
          IconButton.outlined(
            tooltip: 'Tambah transaksi rutin',
            icon: Icon(Icons.add_rounded, size: 18),
            onPressed: () => controller.onShowAddCronDialog(),
          ),
        ]).pOnly(bottom: 18),
        Obx(
          () => controller.recurringList.isNotEmpty
              ? ListView.separated(
                  itemCount: controller.recurringList.length,
                  separatorBuilder: (context, index) => 10.heightBox,
                  itemBuilder: (context, index) {
                    final item = controller.recurringList[index];
                    final remainingDays = item.remainingDays();
                    final category = resolveExpenseCategory(item.categoryName);
                    final remainingLabel = remainingDays.isNegative
                        ? 'Bulan depan'
                        : remainingDays == 0
                            ? 'Hari ini'
                            : '$remainingDays hari lagi';

                    return Container(
                      decoration: ExDecorator.box(
                        borderRadius: 12,
                        fillColor: AppColor.box,
                        borderColor: AppColor.border,
                      ),
                      child: HStack(
                        [
                          VStack([
                            Container(
                              decoration: ExDecorator.box(
                                borderRadius: 20,
                                fillColor: AppColor.card,
                                borderColor: Colors.transparent,
                              ),
                              child: HStack([
                                Icon(
                                  UIconsPro.solidRounded.calendar_day,
                                  size: 10,
                                  color: AppColor.red,
                                ).pOnly(right: 7),
                                '${item.scheduleLabel} • ${item.dueDay}'.text
                                    .size(10)
                                    .make(),
                              ]).pSymmetric(h: 9, v: 5),
                            ).pOnly(bottom: 10),

                            HStack([
                              '${item.note}'.text.size(14).bold.make().expand(),
                              '${item.amount?.moneyFormat()}'.text
                                  .size(14)
                                  .bold
                                  .make(),
                            ]).pOnly(bottom: 10),

                            HStack(
                              [
                                Icon(
                                  category.icon,
                                  size: 12,
                                  color: category.color,
                                ).pOnly(right: 8),
                                '${category.label}'
                                    .text
                                    .size(11)
                                    .minFontSize(11)
                                    .color(category.color)
                                    .make()
                                    .expand(),
                                '$remainingLabel'.text
                                    .color(
                                      remainingDays.isNegative
                                          ? AppColor.green
                                          : AppColor.orange,
                                    )
                                    .size(11)
                                    .make(),
                              ],
                            ),
                          ]).expand(),
                        ],
                      ).p16(),
                    ).onInkTap(() {
                      controller.onShowRecurringInfo(item);
                    });
                  },
                ).expand()
              : ExUiErrorOrEmpty(
                  illustration: LottieBuilder.asset(
                    'assets/lottie/empty.json',
                    width: 150,
                    reverse: true,
                  ),
                  title: 'Belum ada transaksi rutin',
                  message: 'Tekan + untuk menambah',
                ).expand(),
        ),
      ],
    );
  }
}
