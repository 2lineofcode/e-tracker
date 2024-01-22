import 'package:ex/ex.dart';
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
            'Total Data AutoComplete: ${controller.countAutoComplete.value}'.text.size(11).make(),
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
      Divider().pSymmetric(v: 16),
    ]).pSymmetric(h: 8);
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
