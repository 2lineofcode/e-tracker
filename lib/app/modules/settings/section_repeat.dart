import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:uicons_pro/uicons_pro.dart';

import '../../core/app_color.dart';
import '../../helpers/helpers.dart';
import '../../models/supa_category_entity.dart';
import '../../models/supa_cron_entity.dart';
import 'settings_controller.dart';

class SectionRepeat extends GetView<SettingsController> {
  const SectionRepeat({super.key});

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        HStack([
          'Recurring Transactions'.text.bold.make(),
          Spacer(),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => controller.onShowAddCronDialog(),
          ),
        ]).pOnly(bottom: 16),
        Obx(
          () => controller.cronList.isNotEmpty
              ? ListView.separated(
                  itemCount: controller.cronList.length,
                  separatorBuilder: (context, index) => 8.heightBox,
                  itemBuilder: (context, index) {
                    final item = controller.cronList[index];

                    // Parse data from cron job command
                    final command = item.command ?? '';

                    // Use regex to extract all values at once
                    final valuesRegex = RegExp(
                      r"values\s*\('([^']*)',\s*'([^']*)',\s*([0-9.]+)",
                      caseSensitive: false,
                    );
                    final match = valuesRegex.firstMatch(command);

                    final note = match?.group(1) ?? '';
                    final categoryFull = match?.group(2) ?? '';
                    final categoryName = categoryFull.split('#').first.trim();
                    final amount = num.tryParse(match?.group(3) ?? '0') ?? 0;
                    final schedule = SupaCronSchedule.parse(item.schedule);
                    final dueDate = schedule?.dueDay.toString() ?? '-';
                    final remainingDays = schedule?.remainingDays() ?? 0;
                    final scheduleLabel = schedule?.label ?? 'Custom schedule';

                    return Container(
                      decoration: ExDecorator.box(
                        borderRadius: 12,
                        fillColor: AppColor.box,
                        borderColor: AppColor.border,
                      ),
                      child: HStack(
                        [
                          /// body
                          VStack([
                            HStack([
                              Icon(
                                UIconsPro.solidRounded.calendar_day,
                                size: 11,
                                color: AppColor.red,
                              ).pOnly(right: 8),
                              '$scheduleLabel, date $dueDate '.text
                                  .size(11)
                                  .minFontSize(11)
                                  .make(),
                            ]).pOnly(bottom: 8),

                            HStack([
                              '$note'.text.size(13).bold.make().expand(),
                              '${amount.moneyFormat()}'.text.bold.make(),
                            ]).pOnly(bottom: 8),

                            HStack(
                              [
                                Icon(
                                  resolveExpenseCategory(categoryName).icon,
                                  size: 12,
                                  color: resolveExpenseCategory(
                                    categoryName,
                                  ).color,
                                ).pOnly(right: 8),
                                '${resolveExpenseCategory(categoryName).label}'
                                    .text
                                    .size(11)
                                    .minFontSize(11)
                                    .color(
                                      resolveExpenseCategory(
                                        categoryName,
                                      ).color,
                                    )
                                    .make()
                                    .expand(),
                                if (remainingDays.isNegative) ...[
                                  'Next month'.text.green300
                                      .size(11)
                                      .minFontSize(11)
                                      .make(),
                                ] else ...[
                                  'Remaining $remainingDays more days'
                                      .text
                                      .orange300
                                      .size(11)
                                      .minFontSize(11)
                                      .make(),
                                ],
                              ],
                            ),
                          ]).expand(),
                        ],
                      ).p12(),
                    ).onInkTap(() {
                      controller.onShowCronInfo(item);
                    });
                  },
                ).expand()
              : ExUiErrorOrEmpty(
                  illustration: LottieBuilder.asset(
                    'assets/lottie/empty.json',
                    width: 150,
                    reverse: true,
                  ),
                  title: 'No Data',
                  message: 'You can add a recurring transaction by tapping `+`',
                ).expand(),
        ),
      ],
    );
  }
}
