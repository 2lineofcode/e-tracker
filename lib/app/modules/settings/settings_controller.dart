import 'dart:async';
import 'dart:io';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:ex_kit/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:overlayment/overlayment.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../core/app_api.dart';
import '../../core/app_color.dart';
import '../../core/app_setting.dart';
import '../../core/app_theme.dart';
import '../../core/const.dart';
import '../../helpers/helpers.dart';
import '../../models/supa_category_entity.dart';
import '../../models/supa_cron_entity.dart';
import '../../models/supa_user_profile_entity.dart';
import '../../routes/app_pages.dart';
import '../home/home_controller.dart';
import '../widgets/widgets.dart';
import 'settings_repository.dart';

String repeatScheduleLabel(SupaCronSchedule? schedule) {
  if (schedule == null) return 'Jadwal khusus';
  return switch (schedule.repeatMonths) {
    1 => 'Setiap bulan',
    12 => 'Setiap tahun',
    _ => 'Setiap ${schedule.repeatMonths} bulan',
  };
}

class SettingsController extends GetxController with StateMixin {
  // repo
  final repo = Get.find<SettingsRepository>();

  // menu
  final menuList = <Map<String, dynamic>>[].obs;
  final menuSelected = SectionMenu.APP_CONFIG.obs;

  /// Page: App Config
  final tfEco = TextEditingController();
  final tfAverage = TextEditingController();
  final tfSpender = TextEditingController();
  final tfCurrencySymbol = TextEditingController();
  final tfCalendarStartDay = TextEditingController();
  final userProfile = SupaUserProfile().obs;
  final selectedThemeColor = AppColor.themeColorValue.obs;

  late PackageInfo? packageInfo;
  final appInfo = <String, dynamic>{}.obs;

  /// counting & sum
  final countExpense = 0.obs;
  final countCategory = 0.obs;
  final sumAllExpense = Rx<num>(0);

  /// backupList
  final backupList = <FileObject>[].obs;

  /// cronList
  final cronList = <SupaCron>[].obs;

  @override
  Future<void> onInit() async {
    menuList.value = await repo.getMenuList();
    userProfile.value = await repo.getUserProfile().then((value) => value[0]);

    /// Page: App Config

    tfEco.text = userProfile.value.ecoDay?.moneyFormat() ?? '';
    tfAverage.text = userProfile.value.averageDay?.moneyFormat() ?? '';
    tfSpender.text = userProfile.value.spenderDay?.moneyFormat() ?? '';
    tfCurrencySymbol.text = pref.read<String>(kCurrencySymbol) ?? '';
    tfCalendarStartDay.text = '${pref.read<int>(kCalendarStartDay) ?? 1}';
    selectedThemeColor.value = AppColor.themeColorValue;

    packageInfo = await PackageInfo.fromPlatform();
    appInfo.value = packageInfo?.data ?? {};
    change(200, status: RxStatus.success());

    countExpense.value = await repo.countExpense();
    countCategory.value = await repo.countCategory();
    sumAllExpense.value = await repo.sumAllExpense();

    backupList.value = await repo.getBackupList();
    cronList.value = await repo.getCron();

    super.onInit();
  }

  Future<void> onMenuChange(String menu) async {
    menuSelected.value = menu;
    closeDrawer();
  }

  void onEditProfile() {
    final tfFullName = TextEditingController(text: userProfile.value.fullName);
    final tfUsername = TextEditingController(text: userProfile.value.username);
    final tfEmail = TextEditingController(
      text: db.auth.currentSession?.user.email,
    );
    final tfBirthYear = TextEditingController(
      text: userProfile.value.birthYearInput,
    );
    final tfPaymentDay = TextEditingController(
      text: '${userProfile.value.paymentDay ?? 28}',
    );
    final tfIncome = TextEditingController(text: userProfile.value.income);
    final tfBalance = TextEditingController(text: userProfile.value.balance);
    final tfAvatar = userProfile.value.avatarUrl.obs;

    final isReplacePhoto = false.obs;
    final imgReplace = Uint8List(0).obs;
    final errorMsg = ''.obs;
    Widget fieldLabel(String label) => Container(
      width: 112,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 12),
      child: label.text.size(12).semiBold.make(),
    );

    Overlayment.show(
      context: Get.context!,
      OverPanel(
        alignment: Alignment.centerRight,
        width: 340,
        child: VStack([
          'Edit profil'.text.size(16).bold.make().pOnly(bottom: 24),
          Obx(() {
            if (isReplacePhoto.isTrue) {
              return Container(
                decoration: ExDecorator.box(borderRadius: 90),
                child: Image.memory(
                  imgReplace.value,
                  fit: BoxFit.cover,
                ).wh(64, 64).cornerRadius(90),
              ).centered().pOnly(bottom: 16);
            } else {
              return ExImageNoCacheView(
                url: db.storage
                    .from('avatars')
                    .getPublicUrl('${db.auth.currentSession?.user.id}.png'),
                size: 64,
                radius: 90,
                errorBuilder: (p0, p1, p2) =>
                    ExAvatarView(source: '', name: tfFullName.text, size: 64),
              ).centered().pOnly(bottom: 16);
            }
          }).onInkTap(() {
            logW('clicked');
            launchUrlString(
              db.storage
                  .from('avatars')
                  .getPublicUrl('${db.auth.currentSession?.user.id}.png'),
            );
          }),
          Obx(
            () => errorMsg.value.isNotEmpty
                ? '$errorMsg'.text
                      .size(11)
                      .minFontSize(11)
                      .align(TextAlign.center)
                      .makeCentered()
                      .pSymmetric(v: 4)
                : 0.heightBox,
          ),
          ExButtonElevated(
            onPressed: () async {
              // filepicker select file and upload to supabase storage
              try {
                await FilePicker.pickFile(
                  type: FileType.image,
                ).then((img) async {
                  if (img != null) {
                    final bytes = await img.readAsBytes();

                    isReplacePhoto.value = true;

                    final fileName = '${db.auth.currentSession?.user.id}.png';
                    imgReplace.value = bytes;

                    await db.storage
                        .from('avatars')
                        .uploadBinary(
                          fileName,
                          bytes,
                          fileOptions: FileOptions(
                            upsert: true,
                            cacheControl: '1',
                            contentType: 'image/png',
                          ),
                        )
                        .then((response) async {
                          tfAvatar.value = db.storage
                              .from('avatars')
                              .getPublicUrl(fileName);
                          log('tfAvatar: $tfAvatar');
                          errorMsg.value = '';
                        });
                  }
                });
              } catch (e) {
                if (e is StorageException) {
                  errorMsg.value = '${e.message}\nMaks. 5 MB';
                } else {
                  await HelperErrorLog.record(
                    page: 'settings',
                    action: 'onEditProfile',
                    stack: e.toString(),
                  );
                  errorMsg.value = '$e';
                }
              }
            },
            height: 33,
            child: 'Ganti foto'.text.size(11).minFontSize(11).make(),
          ).centered().pOnly(bottom: 16),
          TextField(
            controller: tfFullName,
            decoration: HelperDecoration.input(
              hint: 'Budi Santoso',
              prefixIcon: fieldLabel('Nama lengkap'),
            ),
            style: TextStyle(fontSize: 13),
          ).h(36).pOnly(bottom: 10),
          TextField(
            controller: tfBirthYear,
            decoration: HelperDecoration.input(
              hint: '1995',
              prefixIcon: fieldLabel('Tahun lahir'),
            ),
            style: TextStyle(fontSize: 13),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
          ).h(36).pOnly(bottom: 10),
          TextField(
            controller: tfUsername,
            decoration: HelperDecoration.input(
              hint: 'aditya',
              prefixIcon: fieldLabel('Username'),
            ),
            style: TextStyle(fontSize: 13),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_.]')),
              LengthLimitingTextInputFormatter(30),
            ],
          ).h(36).pOnly(bottom: 10),
          TextField(
            enabled: false,
            controller: tfEmail,
            decoration: HelperDecoration.input(
              prefixIcon: fieldLabel('Email'),
            ),
            style: TextStyle(fontSize: 13),
          ).h(36).pOnly(bottom: 10),
          TextField(
            controller: tfPaymentDay,
            decoration: HelperDecoration.input(
              hint: '28',
              prefixIcon: fieldLabel('Tanggal gajian'),
            ),
            style: TextStyle(fontSize: 13),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
          ).h(36).pOnly(bottom: 10),
          TextField(
            controller: tfIncome,
            decoration: HelperDecoration.input(
              hint: 'Rp.1.234.567',
              prefixIcon: fieldLabel('Penghasilan'),
            ),
            style: TextStyle(fontSize: 13),
            inputFormatters: [
              CurrencyTextInputFormatter(
                NumberFormat.simpleCurrency(
                  locale: 'id_ID',
                  name: 'Rp.',
                  decimalDigits: 0,
                ),
              ),
              LengthLimitingTextInputFormatter(16),
            ],
            keyboardType: TextInputType.number,
          ).h(36).pOnly(bottom: 10),
          TextField(
            controller: tfBalance,
            decoration: HelperDecoration.input(
              hint: 'Rp.1.234.567',
              prefixIcon: fieldLabel('Saldo'),
            ),
            style: TextStyle(fontSize: 13),
            inputFormatters: [
              CurrencyTextInputFormatter(
                NumberFormat.simpleCurrency(
                  locale: 'id_ID',
                  name: 'Rp.',
                  decimalDigits: 0,
                ),
              ),
              LengthLimitingTextInputFormatter(16),
            ],
            keyboardType: TextInputType.number,
          ).h(36).pOnly(bottom: 10),
          'Diperbarui ${userProfile.value.updatedAt?.reformatDate(to: 'dd MMM y, HH:mm') ?? '-'}'
              .text
              .size(10)
              .color(AppColor.neutral)
              .make()
              .objectCenterRight(),
          Divider().pSymmetric(v: 16),
          ExButtonElevated(
            width: double.infinity,
            label: 'Simpan',
            onPressed: () async {
              final birthYear = int.tryParse(tfBirthYear.text);
              if (birthYear == null ||
                  birthYear < 1900 ||
                  birthYear > DateTime.now().year) {
                await HelperToast.error('Tahun lahirnya belum valid');
                return;
              }

              final username = tfUsername.text.trim();
              if (username.isNotEmpty && username.length < 3) {
                await HelperToast.error('Username minimal 3 karakter');
                return;
              }

              final paymentDay = int.tryParse(tfPaymentDay.text);
              if (paymentDay == null || paymentDay < 1 || paymentDay > 31) {
                await HelperToast.error('Tanggal gajian harus 1-31');
                return;
              }

              final editProfile = SupaUserProfile(
                id: userProfile.value.id,
                username: username.isEmpty ? null : username,
                fullName: tfFullName.text,
                age: tfBirthYear.text,
                avatarUrl: tfAvatar.value,
                income: tfIncome.text,
                balance: tfBalance.text,
                ecoDay: userProfile.value.ecoDay,
                averageDay: userProfile.value.averageDay,
                spenderDay: userProfile.value.spenderDay,
                paymentDay: paymentDay,
                updatedAt: DateTime.now().toStringEx(),
              );
              await Overlayment.dismissAll();
              ExLoading.show(
                paddingSymmetric: Get.context!.isMobile ? 90 : 250,
                child: CupertinoActivityIndicator(),
              );
              await repo.editProfile(editProfile);
              if (Get.isRegistered<HomeController>()) {
                final home = Get.find<HomeController>();
                home.userProfile.value = editProfile;
                await home.loadPayCycleExpense();
              }
              await onInit();
              ExLoading.dismiss();
            },
          ).centered(),
        ]).p16(),
      ),
    );
  }

  /// flow:
  /// 1. collect data expense from database
  /// 2. save to temp directory
  /// 3. upload to supabase storage -> file temp directory
  /// 4. delete temp directory
  /// 5. refresh data backup list
  /// 6. show notification
  /// 7. handle error
  Future<void> onUploadBackup() async {
    try {
      final filePath = await getTemporaryDirectory();
      final fileName =
          '${db.auth.currentSession?.user.email}_etracker_${DateTime.now().toStringEx(format: 'ddMMMy')}.csv';

      await HelperImportExport.exportToCSV(
        customPath: filePath.path,
        customCallback: (file) async {
          await db.storage
              .from('backup')
              .upload(
                fileName,
                file,
                fileOptions: FileOptions(upsert: true, cacheControl: '1'),
              )
              .then((response) async {
                file.deleteSync();
                await onInit();
                await HelperToast.success('Backup selesai');
              })
              .catchError((e) {
                HelperErrorLog.record(
                  page: 'settings',
                  action: 'onUploadBackup',
                  stack: e.toString(),
                );
                ExAlert.error(message: '${(e as StorageException).message}');
              });
        },
      );
    } catch (e) {
      log('e: $e');
      await HelperErrorLog.record(
        page: 'settings',
        action: 'onUploadBackup',
        stack: e.toString(),
      );
      ExAlert.error(message: '$e');
    }
  }

  /// flow:
  /// 1. download file from supabase storage
  /// 2. save file to temp directory
  /// 3. delete all current data [expense]
  /// 4. apply new data [expense] from supabase storage selected
  /// 5. delete file temp directory
  /// 6. show notification
  /// 7. handle error
  Future<void> onDownloadBackup(FileObject fileObj) async {
    final filename =
        '${fileObj.name.replaceAll('${db.auth.currentSession?.user.email}_', '')}';
    ExAlert.confirm(
      title: 'Pulihkan backup',
      message: 'Data pengeluaran saat ini akan diganti dengan\n"$filename". Lanjut?',
      onYes: () async {
        Get.back();
        await db.storage
            .from('backup')
            .download(fileObj.name)
            .then((res) async {
              final filePath = await getTemporaryDirectory();
              final fileName = '${fileObj.name}';
              final file = File('${filePath.path}/$fileName');

              await file.writeAsBytes(res);
              await db.from('expense').delete().match({
                'user_id': db.auth.currentSession?.user.id ?? '',
              });
              await HelperImportExport.importFromCSV(
                customPath: '${filePath.path}/$fileName',
                customCallback: () async {
                  file.deleteSync();
                  await onInit();
                  await HelperToast.success(
                    'Backup "${fileName.replaceAll('${db.auth.currentSession?.user.email}_', '')}" berhasil dipulihkan',
                  );
                },
              );
            })
            .catchError((e) {
              log('e: $e');
              HelperErrorLog.record(
                page: 'settings',
                action: 'onDownloadBackup',
                stack: e.toString(),
              );
              ExAlert.error(message: '$e');
            });
      },
    );
  }

  Future<void> onDeleteOldCloudData() async {
    final listToDelete = <String>[];
    await repo.getBackupList()
      ..removeAt(0)
      ..forEach((element) {
        listToDelete.add(element.name);
      });

    ExAlert.confirm(
      title: 'Hapus backup lama',
      message:
          '''
        ${listToDelete.length} backup akan dihapus
        ${listToDelete.map((word) => '- $word').join('\n').replaceAll('${db.auth.currentSession?.user.email}_etracker_', '')}
      '''
              .trim(),
      onYes: () async {
        Get.back();
        ExLoading.show(
          paddingSymmetric: Get.context!.isMobile ? 90 : 250,
          child: CupertinoActivityIndicator(),
        );
        await db.storage.from('backup').remove(listToDelete);
        backupList.value = await repo.getBackupList();
        ExLoading.dismiss();
      },
    );
  }

  Future<void> onSaveConfig() async {
    if (tfAverage.text.moneyUnformat()! < tfEco.text.moneyUnformat()!) {
      ExSnackbar.danger('Batas hari biasa harus lebih besar dari hari hemat');
      return;
    }

    final calendarStartDay = int.tryParse(tfCalendarStartDay.text);
    if (calendarStartDay == null ||
        calendarStartDay < 1 ||
        calendarStartDay > 31) {
      ExSnackbar.danger('Tanggal awal periode harus 1-31');
      return;
    }

    ExLoading.show(
      paddingSymmetric: Get.context!.isMobile ? 90 : 250,
      child: CupertinoActivityIndicator(),
    );
    final entity = userProfile.value;
    entity.username = userProfile.value.fullName
        ?.replaceAll(' ', '_')
        .toLowerCase();
    entity.ecoDay = tfEco.text.moneyUnformat();
    entity.averageDay = tfAverage.text.moneyUnformat();
    entity.spenderDay = tfSpender.text.moneyUnformat();
    await repo.editProfile(entity);
    await pref.write(kCalendarStartDay, calendarStartDay);
    await Get.find<AppSettingService>().setupAppPref();
    await Get.forceAppUpdate();
    ExLoading.dismiss();
    await HelperToast.success('Pengaturan disimpan');
  }

  Future<void> onThemeColorChange(int colorValue) async {
    await pref.write(kThemeColor, colorValue);
    await 50.milliseconds.delay();
    selectedThemeColor.value = colorValue;
    await AppTheme.refreshTheme();
  }

  Future<void> onGoAppPath() async {
    final appPath = await getApplicationDocumentsDirectory();
    if (await canLaunchUrl(appPath.uri)) {
      await launchUrl(appPath.uri);
    }
  }

  Future<void> onLogout() async {
    ExLoading.show(
      paddingSymmetric: Get.context!.isMobile ? 90 : 250,
      child: CupertinoActivityIndicator(),
    );
    final userId = currentUserId;
    if (userId != null) {
      final chatPrefix = '$kAgentChatMessages:$userId';
      final legacyChatPrefix = '$kLegacyAgentChatMessages:$userId';
      final chatKeys = pref
          .getKeys<Iterable<String>>()
          .where(
            (key) =>
                key == chatPrefix ||
                key.startsWith('$chatPrefix:') ||
                key == legacyChatPrefix ||
                key.startsWith('$legacyChatPrefix:'),
          )
          .toList();
      for (final key in chatKeys) {
        await pref.remove(key);
      }
    }
    await pref.remove(kAgentChatMessages);
    await pref.remove(kLegacyAgentChatMessages);
    await db.auth.signOut();
    await Get.delete<HomeController>();
    await Get.offAllNamed(Routes.LOGIN);
    ExLoading.dismiss();
  }

  Future<void> addCron(
    String date, {
    required String note,
    required String category,
    required num amount,
    int repeatMonths = 1,
  }) async {
    try {
      final jobName = cronJobName(note);

      // Call database function
      final params = <String, dynamic>{
        'job_name': jobName,
        'day_of_month': date,
        'note_text': note,
        'category_text': category,
        'amount_value': amount,
        'user_email': db.auth.currentSession?.user.email ?? '',
        'user_id_value': db.auth.currentSession?.user.id ?? '',
      };
      if (repeatMonths != 1) {
        params['repeat_months'] = repeatMonths;
        params['start_month'] = DateTime.now().month;
      }

      await db.rpc(
        'create_expense_cron',
        params: params,
      );

      cronList.value = await repo.getCron();
    } catch (e) {
      await HelperErrorLog.record(
        page: 'settings',
        action: 'addCron',
        stack: e.toString(),
      );
      logE(e);
    }
  }

  @visibleForTesting
  static String cronJobName(String note, {int? timestamp}) {
    final normalizedNote = note
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');
    final shortenedNote = normalizedNote.length > 30
        ? normalizedNote.substring(0, 30)
        : normalizedNote;
    final cleanNote = shortenedNote.replaceFirst(RegExp(r'_+$'), '');
    return '${cleanNote.isEmpty ? 'expense' : cleanNote}_${timestamp ?? DateTime.now().millisecondsSinceEpoch}';
  }

  /// Delete cron job by job name
  Future<void> deleteCron(String jobName) async {
    try {
      await db.rpc('delete_expense_cron', params: {'job_name': jobName});
      cronList.value = await repo.getCron();
    } catch (e) {
      await HelperErrorLog.record(
        page: 'settings',
        action: 'deleteCron',
        stack: e.toString(),
      );
      ExAlert.error(message: 'Gagal: $e');
      logE(e);
    }
  }

  /// Show dialog to add new cron job
  void onShowAddCronDialog() {
    final homeController = Get.find<HomeController>();

    final tfNote = TextEditingController();
    final tfCategory = TextEditingController();
    final tfCategoryCode = homeController.categoryList[0].code.obs;
    final tfAmount = TextEditingController();
    final tfDate = TextEditingController();
    final repeatMonths = 1.obs;
    final tfRepeat = TextEditingController(text: 'Setiap bulan');
    final repeatOptions = {
      1: 'Setiap bulan',
      3: 'Setiap 3 bulan',
      6: 'Setiap 6 bulan',
      12: 'Setiap tahun',
    };

    Overlayment.show(
      context: Get.context!,
      OverPanel(
        alignment: Alignment.center,
        width: 300,
        backgroundSettings: BackgroundSettings(color: AppColor.card.withAlpha(150), blur: 1),
        animation: OverScaleAnimation(
          durationMilliseconds: 100,
          reverseDurationMilliseconds: 100,
        ),

        child: VStack([
          HStack([
            'Tambah transaksi rutin'.text.bold.make(),
            Spacer(),
            IconButton(
              icon: Icon(UIconsPro.solidRounded.cross, size: 14),
              onPressed: () => Overlayment.dismissLast(),
            ),
          ]).pOnly(bottom: 24),

          /// field date
          CupertinoTextField(
            controller: tfDate,
            autofocus: true,
            placeholder: 'Tanggal (1-31)',
            placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
            decoration: BoxDecoration(
              color: Get.isDarkMode ? Vx.black : Vx.white,
              borderRadius: BorderRadius.circular(4),
            ),
            style: TextStyle(fontSize: 13, color: AppColor.textReverse),
            prefix: Icon(
              UIconsPro.solidRounded.calendar_day,
              size: 13,
              color: AppColor.blue,
            ).pOnly(left: 12, right: 4),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 2,
          ).h(33).pOnly(bottom: 4),

          'Tanggal transaksi tiap bulan (1-31)'.text
              .size(9)
              .minFontSize(9)
              .neutral500
              .make()
              .pOnly(bottom: 16, left: 4),

          /// field repeat interval
          CupertinoTextField(
            controller: tfRepeat,
            readOnly: true,
            placeholder: 'Jadwal pengulangan',
            placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
            style: TextStyle(fontSize: 12, color: AppColor.textReverse),
            decoration: BoxDecoration(
              color: Get.isDarkMode ? Vx.black : Vx.white,
              borderRadius: BorderRadius.circular(4),
            ),
            prefix: Icon(
              Icons.repeat_rounded,
              size: 13,
              color: AppColor.blue,
            ).pOnly(left: 12, right: 4),
            suffix: Icon(
              UIconsPro.solidRounded.caret_down,
              size: 13,
              color: AppColor.textReverse,
            ).pOnly(right: 12),
            onTap: () => _openRepeatIntervalPicker(
              selectedValue: repeatMonths.value,
              options: repeatOptions,
              callback: (value) {
                repeatMonths.value = value;
                tfRepeat.text = repeatOptions[value] ?? 'Setiap bulan';
              },
            ),
          ).h(33).pOnly(bottom: 12),

          /// field note
          CupertinoTextField(
            controller: tfNote,
            autofocus: true,
            placeholder: 'Contoh: Langganan Netflix',
            placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
            decoration: BoxDecoration(
              color: Get.isDarkMode ? Vx.black : Vx.white,
              borderRadius: BorderRadius.circular(4),
            ),
            style: TextStyle(fontSize: 13, color: AppColor.textReverse),
            prefix: Icon(
              UIconsPro.solidRounded.hastag,
              size: 13,
              color: AppColor.textReverse,
            ).pOnly(left: 12, right: 4),
          ).h(32).pOnly(bottom: 12),

          /// field category
          Obx(
            () => CupertinoTextField(
              controller: tfCategory,
              readOnly: true,
              placeholder: 'Pilih kategori',
              decoration: BoxDecoration(
                color: Get.isDarkMode ? Vx.black : Vx.white,
                borderRadius: BorderRadius.circular(4),
              ),
              placeholderStyle: TextStyle(
                fontSize: 13,
                color: AppColor.neutral,
              ),
              prefix: Icon(
                resolveExpenseCategory(tfCategoryCode.value).icon,
                size: 13,
                color: resolveExpenseCategory(tfCategoryCode.value).color,
              ).pOnly(left: 12, right: 4),
              style: TextStyle(fontSize: 13, color: AppColor.textReverse),
              onTap: () => HelperOverlay.openCategoryPicker(
                callback: (c) {
                  tfCategory.text = resolveExpenseCategory(c).label;
                  tfCategoryCode.value = c;
                },
              ),
            ).pOnly(bottom: 12),
          ),

          /// field amount
          CupertinoTextField(
            controller: tfAmount,
            placeholder: 'Rp. 10.000',
            placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
            decoration: BoxDecoration(
              color: Get.isDarkMode ? Vx.black : Vx.white,
              borderRadius: BorderRadius.circular(4),
            ),
            style: TextStyle(fontSize: 13, color: AppColor.textReverse),
            prefix: Icon(
              UIconsPro.solidRounded.coins,
              size: 13,
              color: AppColor.textReverse,
            ).pOnly(left: 12, right: 4),
            inputFormatters: [
              CurrencyTextInputFormatter(
                NumberFormat.simpleCurrency(
                  locale: 'id_ID',
                  name: 'Rp.',
                  decimalDigits: 0,
                ),
              ),
              LengthLimitingTextInputFormatter(16),
            ],
            keyboardType: TextInputType.number,
          ).h(32),

          Divider().pSymmetric(v: 6),

          // Buttons
          HStack([
            ExButtonText(
              label: 'Simpan',
              onPressed: () async {
                // Validation
                if (tfNote.text.isEmpty) {
                  ExSnackbar.danger('Note wajib diisi');
                  return;
                }
                if (tfAmount.text.isEmpty) {
                  ExSnackbar.danger('Nominal wajib diisi');
                  return;
                }
                if (tfDate.text.isEmpty) {
                  ExSnackbar.danger('Tanggal wajib diisi');
                  return;
                }

                final day = int.tryParse(tfDate.text);
                if (day == null || day < 1 || day > 31) {
                  ExSnackbar.danger('Tanggal harus 1-31');
                  return;
                }

                await Overlayment.dismissAll();

                // Add cron job
                await addCron(
                  tfDate.text,
                  note: tfNote.text,
                  category: tfCategoryCode.value,
                  amount: tfAmount.text.moneyUnformat() ?? 0,
                  repeatMonths: repeatMonths.value,
                );
              },
            ).expand(),
          ]),
        ]).p16(),
      ),
    );
  }

  void _openRepeatIntervalPicker({
    required int selectedValue,
    required Map<int, String> options,
    required Function(int value) callback,
  }) {
    Overlayment.show(
      context: Get.context!,
      OverPanel(
        alignment: Alignment.center,
        width: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColor.appbarPrimary,
        ),
        backgroundSettings: BackgroundSettings(color: Colors.black54, blur: 1),
        animation: OverScaleAnimation(
          durationMilliseconds: 100,
          reverseDurationMilliseconds: 100,
        ),
        child: VStack([
          HStack([
            'Jadwal pengulangan'.text.bold.make().expand(),
            IconButton(
              icon: Icon(UIconsPro.solidRounded.cross, size: 14),
              onPressed: () => Overlayment.dismissLast(),
            ),
          ]).pOnly(bottom: 8),
          ...options.entries.map((entry) {
            final isSelected = entry.key == selectedValue;
            return Container(
                  decoration: ExDecorator.box(
                    borderRadius: 6,
                    fillColor: isSelected
                        ? AppColor.menuSelected
                        : Colors.transparent,
                    borderColor: Colors.transparent,
                  ),
                  child: HStack([
                    Icon(
                      Icons.repeat_rounded,
                      size: 13,
                      color: isSelected
                          ? AppColor.primary
                          : AppColor.textReverse,
                    ).pOnly(right: 8),
                    entry.value.text.size(12).make().expand(),
                    if (isSelected) ...[
                      Icon(Icons.check, size: 14, color: AppColor.primary),
                    ],
                  ]).p8(),
                )
                .onInkTap(() async {
                  callback(entry.key);
                  await Overlayment.dismissLast();
                })
                .pOnly(bottom: 4);
          }),
        ]).p12(),
      ),
    );
  }

  /// Show info dialog when tap cron item
  void onShowCronInfo(SupaCron item) {
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
    final scheduleLabel = repeatScheduleLabel(schedule);

    Overlayment.show(
      context: Get.context!,
      OverPanel(
        alignment: Alignment.center,
        width: 300,
        backgroundSettings: BackgroundSettings(color: AppColor.card.withAlpha(150), blur: 1),
        animation: OverScaleAnimation(
          durationMilliseconds: 100,
          reverseDurationMilliseconds: 100,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColor.appbarPrimary,
        ),
        child: VStack([
          HStack([
            'Detail transaksi rutin'.text.bold.size(16).make(),
            Spacer(),
            IconButton(
              icon: Icon(UIconsPro.solidRounded.cross, size: 16),
              onPressed: () => Overlayment.dismissAll(),
            ),
          ]).pOnly(bottom: 12),

          // Note
          VStack([
            'Note'.text.size(11).neutral500.make(),
            4.heightBox,
            '📝 $note'.text.size(13).make(),
          ], crossAlignment: CrossAxisAlignment.start).pOnly(bottom: 16),

          // Category
          VStack([
            'Kategori'.text.size(11).neutral500.make(),
            4.heightBox,
            '🏷️ ${resolveExpenseCategory(categoryName).label}'.text
                .size(13)
                .make(),
          ], crossAlignment: CrossAxisAlignment.start).pOnly(bottom: 16),

          // Amount
          VStack([
            'Nominal'.text.size(11).neutral500.make(),
            4.heightBox,
            '💰 ${amount.moneyFormat()}'.text.size(13).bold.make(),
          ], crossAlignment: CrossAxisAlignment.start).pOnly(bottom: 16),

          // Schedule
          VStack([
            'Jadwal'.text.size(11).neutral500.make(),
            4.heightBox,
            '🗓️ $scheduleLabel, tanggal $dueDate pukul 00.00'.text.size(13).make(),
          ], crossAlignment: CrossAxisAlignment.start).pOnly(bottom: 16),

          // Next Run
          VStack([
            'Jadwal berikutnya'.text.size(11).neutral500.make(),
            4.heightBox,
            if (remainingDays.isNegative) ...[
              '⏰ Bulan depan (lewat ${remainingDays.abs()} hari)'.text.green300
                  .size(13)
                  .make(),
            ] else if (remainingDays == 0) ...[
              '⏰ Hari ini!'.text.orange300.size(13).bold.make(),
            ] else ...[
              '⏰ $remainingDays hari lagi'.text.orange300.size(13).make(),
            ],
          ], crossAlignment: CrossAxisAlignment.start).pOnly(bottom: 16),

          Divider(thickness: 0.5),

          // Buttons
          HStack([
            ExButtonText(
              child: 'Hapus'.text.color(AppColor.red).size(12).make(),
              onPressed: () async {
                await deleteCron(item.jobname ?? '');
                await Overlayment.dismissAll();
              },
            ).expand(),
          ]),
        ]).p16(),
      ),
    );
  }
}
