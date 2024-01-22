import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/app_api.dart';
import '../../core/app_color.dart';
import '../../helpers/helpers.dart';
import 'settings_controller.dart';

class SectionIEmport extends GetView<SettingsController> {
  const SectionIEmport({super.key});

  @override
  Widget build(BuildContext context) {
    return VStack([
      Obx(
        () => Container(
          width: double.infinity,
          decoration: ExDecorator.box(borderRadius: 4, borderColor: AppColor.cardItemPrimary, fillColor: AppColor.cardHeaderPrimary),
          child: VStack([
            '📈 Analytics'.text.bold.make().pOnly(bottom: 8),
            'Total Data Expense: ${controller.countExpense.value}'.text.size(11).make(),
            'Total Data Category: ${controller.countCategory.value}'.text.size(11).make(),
            'Total Data AutoComplete: ${controller.autoCompleteList.length}'.text.size(11).make(),
          ]).p12(),
        ),
      ),
      Divider().pSymmetric(v: 12),
      Container(
        width: double.infinity,
        decoration: ExDecorator.box(borderRadius: 4, borderColor: AppColor.cardItemPrimary, fillColor: AppColor.cardHeaderPrimary),
        child: VStack(
          [
            // 1
            HStack(
              [
                'Import From CSV'.text.make().expand(),
                ExButtonElevated(
                  height: 33,
                  width: 75,
                  label: 'Select File',
                  labelSize: 12,
                  radius: 8,
                  onPressed: () async => await ImportExportHelper.importFromCSV(),
                ),
              ],
            ),

            Divider().pSymmetric(v: 4),

            // 2
            HStack([
              'Export As CSV'.text.make().expand(),
              IconButton(
                onPressed: () async => await ImportExportHelper.exportToCSV(),
                icon: Icon(Icons.arrow_forward_ios_rounded),
              ),
            ]),

            Divider().pSymmetric(v: 4),

            // 3
            buttonDelete(
              title: 'Delete All Data',
              subtitle: 'to confirm delete all data',
              btnLabel: 'Delete Data',
              action: () async => await ImportExportHelper.deleteAllData(),
            ),

            Divider().pSymmetric(v: 4),

            // 4
            buttonDelete(
              title: 'Delete Account',
              subtitle: 'to confirm delete account',
              btnLabel: 'Delete Account',
              btnColor: Vx.red900,
              action: () async => await ImportExportHelper.deleteAccount(),
            ),
          ],
        ).p12(),
      ),
      Obx(
        () => controller.backupList.isNotEmpty

            /// has data
            ? VStack([
                Divider().pSymmetric(v: 16),
                HStack([
                  'Cloud Sync'.text.make().expand(),
                  ExButtonLoading(
                    height: 33,
                    width: 80,
                    type: ExButtonType.elevated,
                    child: 'Sync Now'.text.size(11).minFontSize(11).make(),
                    onTap: (startLoading, stopLoading, btnState) async {
                      startLoading();
                      await controller.onUploadBackup();
                      stopLoading();
                    },
                  ),
                ]).pOnly(bottom: 12),
                ListView.separated(
                  itemCount: controller.backupList.length,
                  separatorBuilder: (c, i) => Divider(),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = controller.backupList[index];
                    final fileName = '${item.name.replaceAll('${db.auth.currentSession?.user.email}_', '')}';

                    return ListTile(
                      title: '$fileName'.text.size(11).make(),
                      subtitle: '${item.updatedAt?.reformatDate(to: 'd MMM y HH:mm', addHours: 7)} • ${formatFileSize(item.metadata!['size'])}'.text.size(10).minFontSize(10).make(),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: AppColor.cardItemPrimary, width: 1)),
                      trailing: IconButton(
                        icon: Icon(CupertinoIcons.arrow_turn_up_left),
                        onPressed: () => controller.onDownloadBackup(item),
                      ),
                    );
                  },
                ),
              ])

            /// empty
            : VStack([
                Divider().pSymmetric(v: 16),
                'Cloud Sync'.text.make().pOnly(bottom: 12),
                ExUiErrorOrEmpty(
                  child: VStack(
                    [
                      'No Data Backup'.text.size(13).bold.makeCentered(),
                      ''.text.size(11).minFontSize(11).makeCentered(),
                      ExButtonElevated(
                        label: 'Backup Now',
                        labelSize: 11,
                        height: 33,
                        onPressed: () => controller.onUploadBackup(),
                      ).centered().pOnly(top: 8)
                    ],
                  ),
                ).h(150)
              ]),
      ),
    ]).pSymmetric(h: 8).scrollVertical();
  }

  Widget buttonDelete({
    required String title,
    required String subtitle,
    required String btnLabel,
    Color? btnColor,
    required Function() action,
  }) {
    return HStack(
      [
        title.text.make().expand(),
        ExButtonElevated(
          height: 33,
          width: 75,
          label: btnLabel,
          labelSize: 12,
          labelColor: Vx.red50,
          backgroundColor: btnColor ?? Vx.red700,
          radius: 8,
          onPressed: () async {
            final tf = TextEditingController();
            final isValid = false.obs;

            ExAlert.custom(
              title: title,
              content: VStack(
                [
                  Text(subtitle).centered(),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: 'Please Type ', style: TextStyle(color: AppColor.textReverse)),
                        TextSpan(text: '"${db.auth.currentSession?.user.email}"', style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.red)),
                      ],
                      style: TextStyle(fontSize: 13),
                    ),
                  ).centered(),
                  TextField(
                    controller: tf,
                    decoration: DecorationHelper.input(hint: db.auth.currentSession?.user.email),
                    style: TextStyle(fontSize: 13),
                    textAlign: TextAlign.center,
                    onChanged: (s) => isValid.value = s == db.auth.currentSession?.user.email,
                    onSubmitted: (value) async {
                      if (isValid.isTrue) {
                        Get.back();
                        action.call();
                      }
                    },
                  ).h(33).pSymmetric(v: 12),
                  Obx(
                    () => ExButtonElevated(
                      width: double.infinity,
                      label: 'Delete',
                      labelSize: 12,
                      backgroundColor: Vx.red600,
                      labelColor: Vx.red50,
                      radius: 8,
                      onPressed: isValid.isFalse ? null : () async => {Get.back(), action.call()},
                    ).centered(),
                  ),
                ],
              ).p12(),
            );
          },
        ),
      ],
    );
  }
}
