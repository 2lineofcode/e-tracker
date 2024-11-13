import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../core/app_api.dart';
import '../../core/app_color.dart';
import '../../helpers/helpers.dart';
import 'settings_controller.dart';

class SectionRepeat extends GetView<SettingsController> {
  const SectionRepeat({super.key});

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        HStack([
          'Repeat Transaction'.text.bold.make(),
          Spacer(),
          IconButton(onPressed: () {}, icon: Icon(Icons.add)),
        ]).pOnly(bottom: 16),
        Obx(
          () => controller.cronList.isNotEmpty
              ? ListView.separated(
                  itemCount: controller.cronList.length,
                  separatorBuilder: (context, index) => 8.heightBox,
                  itemBuilder: (context, index) {
                    final item = controller.cronList[index];

                    var jobName = item.command?.replaceAll('\n', '').allBetween('values', "', '");
                    jobName = jobName?.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '').trimAll;
                    final dueDate = item.schedule.allBetween('0 0 ', ' * *');
                    final amount = item.command.allBetween("', ", ', current_date').replaceAll(RegExp(r'[^0-9]'), '').toNum();
                    final categoryName = item.command
                        .allBetween("', ", ', current_date')
                        .replaceAll(RegExp('[0-9]'), '')
                        .replaceAll(RegExp(",|!|'"), '')
                        .replaceAll('#${db.auth.currentSession?.user.email}', '')
                        .trim();

                    final now = DateTime.now();
                    final dateA = DateTime(now.year, now.month, now.day);
                    final dateB = DateTime(now.year, now.month, int.parse(dueDate));
                    final remainingDays = dateB.difference(dateA).inDays;

                    return Container(
                      decoration: ExDecorator.box(
                        borderRadius: 4,
                        fillColor: AppColor.cardHeaderPrimary,
                        borderColor: AppColor.cardItemPrimary,
                      ),
                      child: HStack(
                        [
                          /// body
                          VStack([
                            '🗓️ Every day-of-month $dueDate'.text.size(12).make().pOnly(bottom: 8),
                            '$jobName ($categoryName)'.text.size(13).bold.make(),
                            if (remainingDays.isNegative) ...[
                              'Next month'.text.green300.size(11).minFontSize(11).make(),
                            ] else ...[
                              'Remaining $remainingDays more days'.text.orange300.size(11).minFontSize(11).make(),
                            ],
                          ]).expand(),

                          /// trailing
                          '${amount?.moneyFormat()}'.text.bold.make(),
                        ],
                      ).p12(),
                    ).onInkTap(() {
                      ExAlert.success(title: item.schedule, message: item.command);
                    });
                  },
                ).expand()
              : ExUiErrorOrEmpty(
                  illustration: LottieBuilder.asset('assets/lottie/empty.json', width: 150, reverse: true),
                  title: 'No Data',
                  message: 'You can add new Repeat Transaction by tap `+`',
                ).expand(),
        ),
      ],
    );
  }
}
