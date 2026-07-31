import 'package:ex_kit/ex.dart';
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
      analytics(),
      16.heightBox,
      importExport(),
      16.heightBox,
      dangerZone(),
      16.heightBox,
      cloudBackup(),
    ]).scrollVertical();
  }

  Widget analytics() {
    return Obx(
      () => Container(
        width: double.infinity,
        decoration: ExDecorator.box(
          borderRadius: 12,
          borderColor: AppColor.border,
          fillColor: AppColor.box,
        ),
        child: VStack([
          HStack([
            Icon(
              Icons.analytics_outlined,
              size: 18,
              color: AppColor.primary,
            ).pOnly(right: 8),
            'Ringkasan'.text.size(14).bold.make(),
          ]).pOnly(bottom: 14),
          '${controller.sumAllExpense.value.moneyFormat()}'.text
              .size(18)
              .bold
              .make(),
          '${controller.countExpense.value} pengeluaran • ${controller.countCategory.value} kategori'
              .text
              .size(11)
              .color(AppColor.neutral)
              .make(),
        ]).p16(),
      ),
    );
  }

  Widget importExport() {
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(
        borderRadius: 12,
        borderColor: AppColor.border,
        fillColor: AppColor.box,
      ),
      child: VStack(
        [
          'Data'.text.size(14).bold.make().pOnly(bottom: 8),
          actionRow(
            icon: Icons.upload_file_outlined,
            title: 'Impor CSV',
            onTap: () async => await HelperImportExport.importFromCSV(),
          ),
          Divider(height: 1),
          actionRow(
            icon: Icons.download_outlined,
            title: 'Ekspor CSV',
            onTap: () async => await HelperImportExport.exportToCSV(),
          ),
          Divider(height: 1),
          actionRow(
            icon: Icons.archive_outlined,
            title: 'Backup lengkap',
            onTap: () async =>
                await HelperImportExport.exportFullBackupBundle(),
          ),
        ],
      ).p16(),
    );
  }

  Widget actionRow({
    required IconData icon,
    required String title,
    required Future<void> Function() onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: HStack([
        Icon(icon, size: 18, color: AppColor.neutral).pOnly(right: 12),
        title.text.size(12).make().expand(),
        Icon(Icons.chevron_right_rounded, size: 18, color: AppColor.neutral),
      ]).pSymmetric(v: 13),
    );
  }

  Widget dangerZone() {
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(
        borderRadius: 12,
        borderColor: AppColor.red.withAlpha(100),
        fillColor: AppColor.box,
      ),
      child: VStack([
        'Aksi berisiko'.text.size(14).bold.color(AppColor.red).make(),
        12.heightBox,
        buttonDelete(
          title: 'Hapus semua data',
          action: () async => await HelperImportExport.deleteAllData(),
        ).pOnly(bottom: 10),
        buttonDelete(
          title: 'Hapus akun',
          action: () async => await HelperImportExport.deleteAccount(),
        ),
      ]).p16(),
    );
  }

  Widget buttonDelete({
    required String title,
    required Function() action,
  }) {
    return HStack(
      [
        title.text.make().expand(),
        ExButtonOutline(
          label: 'Hapus',
          labelSize: 12,
          height: 38,
          borderColor: Vx.red400,
          labelColor: Vx.red400,
          onPressed: () async {
            final tf = TextEditingController();
            final isValid = false.obs;

            ExAlert.custom(
              title: title,
              content: VStack(
                [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Ketik ',
                          style: TextStyle(color: AppColor.textReverse),
                        ),
                        TextSpan(
                          text: '"${db.auth.currentSession?.user.email}"',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.red),
                        ),
                      ],
                      style: TextStyle(fontSize: 13),
                    ),
                  ).centered(),
                  TextField(
                    controller: tf,
                    decoration: HelperDecoration.input(hint: db.auth.currentSession?.user.email),
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
                      label: 'Hapus',
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

  Widget cloudBackup() {
    return Obx(
      () => controller.backupList.isNotEmpty
          ? Container(
              decoration: ExDecorator.box(
                borderRadius: 12,
                borderColor: AppColor.border,
                fillColor: AppColor.box,
              ),
              child: VStack(
                [
                  HStack([
                    'Backup cloud'.text.size(14).bold.make().expand(),
                    ExButtonLoading(
                      height: 33,
                      width: 80,
                      type: ExButtonType.outlined,
                      child: 'Backup'.text.size(11).minFontSize(11).make(),
                      onTap: (startLoading, stopLoading, btnState) async {
                        startLoading();
                        await controller.onUploadBackup();
                        stopLoading();
                      },
                    ),
                  ]).pOnly(bottom: 12),
                  ListView.separated(
                    itemCount: controller.backupList.length,
                    separatorBuilder: (c, i) => 8.heightBox,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = controller.backupList[index];
                      final fileName = '${item.name.replaceAll('${db.auth.currentSession?.user.email}_', '')}';

                      return ListTile(
                        title: '$fileName'.text.size(11).make(),
                        subtitle: '${item.updatedAt?.reformatDate(to: 'd MMM y HH:mm', addHours: 7)} • ${formatFileSize(item.metadata!['size'])}'.text.size(10).minFontSize(10).make(),
                        tileColor: AppColor.card,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        trailing: IconButton(
                          tooltip: 'Pulihkan',
                          icon: Icon(
                            CupertinoIcons.arrow_turn_up_left,
                            size: 18,
                          ),
                          onPressed: () => controller.onDownloadBackup(item),
                        ),
                      );
                    },
                  ),

                  if (controller.backupList.length > 1) ...[
                    ExButtonOutline(
                      label: 'Hapus backup lama',
                      labelSize: 12,
                      borderColor: AppColor.red,
                      labelColor: AppColor.red,
                      onPressed: () => controller.onDeleteOldCloudData(),
                    ).pOnly(top: 12).centered(),
                  ],
                ],
              ).p16(),
            )
          : Container(
              width: double.infinity,
              decoration: ExDecorator.box(
                borderRadius: 12,
                borderColor: AppColor.border,
                fillColor: AppColor.box,
              ),
              child: VStack([
                'Backup cloud'.text.size(14).bold.make(),
                ExUiErrorOrEmpty(
                  child: VStack(
                    [
                      'Belum ada backup'.text.size(13).bold.makeCentered(),
                      ExButtonElevated(
                        label: 'Backup sekarang',
                        labelSize: 11,
                        height: 33,
                        onPressed: () => controller.onUploadBackup(),
                      ).centered().pOnly(top: 8),
                    ],
                  ),
                ).h(130),
              ]).p16(),
            ),
    );
  }
}
