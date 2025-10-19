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
import '../../core/const.dart';
import '../../helpers/helpers.dart';
import '../../models/supa_category_entity.dart';
import '../../models/supa_cron_entity.dart';
import '../../models/supa_user_profile_entity.dart';
import '../../routes/app_pages.dart';
import '../home/home_controller.dart';
import '../widgets/widgets.dart';
import 'settings_repository.dart';

class SettingsController extends GetxController with StateMixin {
  // repo
  final repo = Get.find<SettingsRepository>();

  // menu
  final menuList = <String>[].obs;
  final menuSelected = SectionMenu.APP_CONFIG.obs;

  /// Page: App Config
  final tfEco = TextEditingController();
  final tfAverage = TextEditingController();
  final tfSpender = TextEditingController();
  final tfCurrencySymbol = TextEditingController();
  final userProfile = SupaUserProfile().obs;

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
    final tfAge = TextEditingController(text: userProfile.value.age);
    final tfIncome = TextEditingController(text: userProfile.value.income);
    final tfBalance = TextEditingController(text: userProfile.value.balance);
    final tfAvatar = userProfile.value.avatarUrl.obs;

    final isReplacePhoto = false.obs;
    final imgReplace = Uint8List(0).obs;
    final errorMsg = ''.obs;

    Overlayment.show(
      context: Get.context!,
      OverPanel(
        alignment: Alignment.centerRight,
        width: 300,
        child: VStack([
          'Edit Profile'.text.bold.makeCentered().pOnly(bottom: 24),
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
                url: db.storage.from('avatars').getPublicUrl('${db.auth.currentSession?.user.id}.png'),
                size: 64,
                radius: 90,
                errorBuilder: (p0, p1, p2) => ExAvatarView(source: '', name: tfFullName.text, size: 64),
              ).centered().pOnly(bottom: 16);
            }
          }).onInkTap(() {
            logW('clicked');
            launchUrlString(
              db.storage.from('avatars').getPublicUrl('${db.auth.currentSession?.user.id}.png'),
            );
          }),
          Obx(
            () => errorMsg.value.isNotEmpty ? '$errorMsg'.text.size(11).minFontSize(11).align(TextAlign.center).makeCentered().pSymmetric(v: 4) : 0.heightBox,
          ),
          ExButtonElevated(
            onPressed: () async {
              // filepicker select file and upload to supabase storage
              try {
                await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false).then((img) async {
                  if (img != null) {
                    isReplacePhoto.value = true;

                    final file = File(img.paths.first ?? '');
                    final fileName = '${db.auth.currentSession?.user.id}.png';
                    imgReplace.value = file.readAsBytesSync();

                    await db.storage
                        .from('avatars')
                        .upload(
                          fileName,
                          file,
                          fileOptions: FileOptions(
                            upsert: true,
                            cacheControl: '1',
                          ),
                        )
                        .then((response) async {
                          tfAvatar.value = db.storage.from('avatars').getPublicUrl(fileName);
                          log('tfAvatar: $tfAvatar');
                          errorMsg.value = '';
                        });
                  }
                });
              } catch (e) {
                if (e is StorageException) {
                  errorMsg.value = '${e.message}\nMax 5MB';
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
            child: 'Change Photo'.text.size(11).minFontSize(11).make(),
          ).centered().pOnly(bottom: 16),
          TextField(
            controller: tfFullName,
            decoration: HelperDecoration.input(
              hint: 'Jhon Doe',
              prefixIcon: 'Full Name'.text.size(13).bold.make().pOnly(top: 8, left: 8, right: 16),
            ),
            style: TextStyle(fontSize: 13),
          ).h(33).pOnly(bottom: 12),
          TextField(
            controller: tfAge,
            decoration: HelperDecoration.input(
              hint: '29',
              prefixIcon: 'Age'.text.size(13).bold.make().pOnly(top: 8, left: 8, right: 16),
            ),
            style: TextStyle(fontSize: 13),
          ).h(33).pOnly(bottom: 12),
          TextField(
            controller: tfIncome,
            decoration: HelperDecoration.input(
              hint: 'Rp.1.234.567',
              prefixIcon: 'Income'.text.size(13).bold.make().pOnly(top: 8, left: 8, right: 16),
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
          ).h(33).pOnly(bottom: 12),
          TextField(
            controller: tfBalance,
            decoration: HelperDecoration.input(
              hint: 'Rp.1.234.567',
              prefixIcon: 'Balance'.text.size(13).bold.make().pOnly(top: 8, left: 8, right: 16),
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
          ).h(33).pOnly(bottom: 12),
          HStack([
            Spacer(),
            'Last Updated: ${userProfile.value.updatedAt?.reformatDate(to: 'dd MMM y HH:mm')}'.text.size(12).neutral500.make(),
          ]),
          Divider().pSymmetric(v: 16),
          ExButtonElevated(
            width: double.infinity,
            label: 'Save',
            onPressed: () async {
              final editProfile = SupaUserProfile(
                id: userProfile.value.id,
                fullName: tfFullName.text,
                age: tfAge.text,
                avatarUrl: tfAvatar.value,
                income: tfIncome.text,
                balance: tfBalance.text,
                ecoDay: userProfile.value.ecoDay,
                averageDay: userProfile.value.averageDay,
                spenderDay: userProfile.value.spenderDay,
                updatedAt: DateTime.now().toStringEx(),
              );
              await Overlayment.dismissAll();
              ExLoading.show(
                paddingSymmetric: Get.context!.isMobile ? 90 : 250,
                child: CupertinoActivityIndicator(),
              );
              await repo.editProfile(editProfile);
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
      final fileName = '${db.auth.currentSession?.user.email}_etracker_${DateTime.now().toStringEx(format: 'ddMMMy')}.csv';

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
                await HelperToast.success('Syncronization Done');
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
    final filename = '${fileObj.name.replaceAll('${db.auth.currentSession?.user.email}_', '')}';
    ExAlert.confirm(
      title: 'Confirm Apply Migration',
      message: 'Are you sure want to apply migration from\n"$filename"?',
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
                  await HelperToast.success('Success Apply Migration "${fileName.replaceAll('${db.auth.currentSession?.user.email}_', '')}"');
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
      title: 'Delete Old Data',
      message:
          '''
        ${listToDelete.length} data will be deleted
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
      ExSnackbar.danger('"average" must > "eco"');
      return;
    }

    ExLoading.show(
      paddingSymmetric: Get.context!.isMobile ? 90 : 250,
      child: CupertinoActivityIndicator(),
    );
    final entity = userProfile.value;
    entity.username = userProfile.value.fullName?.replaceAll(' ', '_').toLowerCase();
    entity.ecoDay = tfEco.text.moneyUnformat();
    entity.averageDay = tfAverage.text.moneyUnformat();
    entity.spenderDay = tfSpender.text.moneyUnformat();
    await repo.editProfile(entity);
    await Get.find<AppSettingService>().checkAndApplyDefaultAppConfig();
    await Get.forceAppUpdate();
    ExLoading.dismiss();
    await HelperToast.success('Config Saved');
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
  }) async {
    try {
      final cleanNote = note
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9\s]'), '') // Remove special chars
          .trim()
          .replaceAll(RegExp(r'\s+'), '_') // Spaces to underscore
          .substring(0, note.length > 30 ? 30 : note.length); // Max 30 chars

      // Add timestamp suffix for uniqueness
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(7); // Last 6 digits
      final jobName = '${cleanNote}_$timestamp';

      // Call database function
      await db.rpc(
        'create_expense_cron',
        params: {
          'job_name': jobName,
          'day_of_month': date,
          'note_text': note,
          'category_text': category,
          'amount_value': amount,
          'user_email': db.auth.currentSession?.user.email ?? '',
          'user_id_value': db.auth.currentSession?.user.id ?? '',
        },
      );

      cronList.value = await repo.getCron();
    } catch (e) {
      await HelperErrorLog.record(page: 'settings', action: 'addCron', stack: e.toString());
      logE(e);
    }
  }

  /// Delete cron job by job name
  Future<void> deleteCron(String jobName) async {
    try {
      await db.rpc('delete_expense_cron', params: {'job_name': jobName});
      cronList.value = await repo.getCron();
    } catch (e) {
      await HelperErrorLog.record(page: 'settings', action: 'deleteCron', stack: e.toString());
      ExAlert.error(message: 'Error: $e');
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

    Overlayment.show(
      context: Get.context!,
      OverPanel(
        alignment: Alignment.center,
        width: 300,
        backgroundSettings: BackgroundSettings(color: AppColor.card, blur: 1),
        animation: OverScaleAnimation(durationMilliseconds: 100, reverseDurationMilliseconds: 100),

        child: VStack([
          HStack([
            'Add Cron'.text.bold.make(),
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
            placeholder: 'Date of month (1-31)',
            placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
            decoration: BoxDecoration(color: Get.isDarkMode ? Vx.black : Vx.white, borderRadius: BorderRadius.circular(4)),
            style: TextStyle(fontSize: 13, color: AppColor.textReverse),
            prefix: Icon(UIconsPro.solidRounded.calendar_day, size: 13, color: AppColor.blue).pOnly(left: 12, right: 4),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 2,
          ).h(33).pOnly(bottom: 4),

          'Day of month (1-31)'.text.size(9).minFontSize(9).neutral500.make().pOnly(bottom: 16, left: 4),

          /// field note
          CupertinoTextField(
            controller: tfNote,
            autofocus: true,
            placeholder: 'e.g. Netflix Subscription',
            placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
            decoration: BoxDecoration(color: Get.isDarkMode ? Vx.black : Vx.white, borderRadius: BorderRadius.circular(4)),
            style: TextStyle(fontSize: 13, color: AppColor.textReverse),
            prefix: Icon(UIconsPro.solidRounded.hastag, size: 13, color: AppColor.textReverse).pOnly(left: 12, right: 4),
          ).h(32).pOnly(bottom: 12),

          /// field category
          Obx(
            () => CupertinoTextField(
              controller: tfCategory,
              readOnly: true,
              placeholder: 'Select Category',
              decoration: BoxDecoration(color: Get.isDarkMode ? Vx.black : Vx.white, borderRadius: BorderRadius.circular(4)),
              placeholderStyle: TextStyle(fontSize: 13, color: AppColor.neutral),
              prefix: Icon(resolveExpenseCategory(tfCategoryCode.value).icon, size: 13, color: resolveExpenseCategory(tfCategoryCode.value).color).pOnly(left: 12, right: 4),
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
            decoration: BoxDecoration(color: Get.isDarkMode ? Vx.black : Vx.white, borderRadius: BorderRadius.circular(4)),
            style: TextStyle(fontSize: 13, color: AppColor.textReverse),
            prefix: Icon(UIconsPro.solidRounded.coins, size: 13, color: AppColor.textReverse).pOnly(left: 12, right: 4),
            inputFormatters: [
              CurrencyTextInputFormatter(NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp.', decimalDigits: 0)),
              LengthLimitingTextInputFormatter(16),
            ],
            keyboardType: TextInputType.number,
          ).h(32),

          Divider().pSymmetric(v: 6),

          // Buttons
          HStack([
            ExButtonText(
              label: 'Save',
              onPressed: () async {
                // Validation
                if (tfNote.text.isEmpty) {
                  ExSnackbar.danger('Note is required');
                  return;
                }
                if (tfAmount.text.isEmpty) {
                  ExSnackbar.danger('Amount is required');
                  return;
                }
                if (tfDate.text.isEmpty) {
                  ExSnackbar.danger('Day is required');
                  return;
                }

                final day = int.tryParse(tfDate.text);
                if (day == null || day < 1 || day > 31) {
                  ExSnackbar.danger('Day must be between 1-31');
                  return;
                }

                await Overlayment.dismissAll();

                // Add cron job
                await addCron(
                  tfDate.text,
                  note: tfNote.text,
                  category: tfCategoryCode.value,
                  amount: tfAmount.text.moneyUnformat() ?? 0,
                );
              },
            ).expand(),
          ]),
        ]).p16(),
      ),
    );
  }

  /// Show info dialog when tap cron item
  void onShowCronInfo(SupaCron item) {
    final command = item.command ?? '';

    // Use regex to extract all values at once
    final valuesRegex = RegExp(r"VALUES\s*\('([^']*)',\s*'([^']*)',\s*(\d+)");
    final match = valuesRegex.firstMatch(command);

    final note = match?.group(1) ?? '';
    final categoryFull = match?.group(2) ?? '';
    final categoryName = categoryFull.split('#').first.trim();
    final amount = num.tryParse(match?.group(3) ?? '0') ?? 0;
    final dueDate = item.schedule.allBetween('0 0 ', ' * *');

    final now = DateTime.now();
    final dateA = DateTime(now.year, now.month, now.day);
    final dateB = DateTime(now.year, now.month, int.parse(dueDate));
    final remainingDays = dateB.difference(dateA).inDays;

    Overlayment.show(
      context: Get.context!,
      OverPanel(
        alignment: Alignment.center,
        width: 300,
        backgroundSettings: BackgroundSettings(color: AppColor.card, blur: 1),
        animation: OverScaleAnimation(durationMilliseconds: 100, reverseDurationMilliseconds: 100),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColor.appbarPrimary),
        child: VStack([
          HStack([
            'Info'.text.bold.size(16).make(),
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
            'Category'.text.size(11).neutral500.make(),
            4.heightBox,
            '🏷️ ${resolveExpenseCategory(categoryName).label}'.text.size(13).make(),
          ], crossAlignment: CrossAxisAlignment.start).pOnly(bottom: 16),

          // Amount
          VStack([
            'Amount'.text.size(11).neutral500.make(),
            4.heightBox,
            '💰 ${amount.moneyFormat()}'.text.size(13).bold.make(),
          ], crossAlignment: CrossAxisAlignment.start).pOnly(bottom: 16),

          // Schedule
          VStack([
            'Schedule'.text.size(11).neutral500.make(),
            4.heightBox,
            '🗓️ Every month, date $dueDate at 00:00'.text.size(13).make(),
          ], crossAlignment: CrossAxisAlignment.start).pOnly(bottom: 16),

          // Next Run
          VStack([
            'Next Run'.text.size(11).neutral500.make(),
            4.heightBox,
            if (remainingDays.isNegative) ...[
              '⏰ Next month (${remainingDays.abs()} days ago)'.text.green300.size(13).make(),
            ] else if (remainingDays == 0) ...[
              '⏰ Today!'.text.orange300.size(13).bold.make(),
            ] else ...[
              '⏰ In $remainingDays days'.text.orange300.size(13).make(),
            ],
          ], crossAlignment: CrossAxisAlignment.start).pOnly(bottom: 16),

          Divider(thickness: 0.5),

          // Buttons
          HStack([
            ExButtonText(
              child: 'Delete'.text.color(AppColor.red).size(12).make(),
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
