import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:ex/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlayment/overlayment.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/v4.dart';

import '../../core/app_api.dart';
import '../../core/app_setting.dart';
import '../../core/const.dart';
import '../../helpers/helpers.dart';
import '../../models/supa_autocomplete_entity.dart';
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

  /// Page: AutoComplete
  final tfSearchAutoComplete = TextEditingController();
  final tfAddAutoComplete = TextEditingController();
  final autoCompleteList = <SupaAutoComplete>[].obs;

  /// Page: App Config
  final tfEco = TextEditingController();
  final tfAverage = TextEditingController();
  final tfSpender = TextEditingController();
  final tfCurrencySymbol = TextEditingController();
  final userProfile = SupaUserProfile().obs;

  late PackageInfo? packageInfo;
  final appInfo = <String, dynamic>{}.obs;

  /// counting
  final countExpense = 0.obs;
  final countCategory = 0.obs;
  final countAutoComplete = 0.obs;

  /// backupList
  final backupList = <FileObject>[].obs;

  /// cronList
  final cronList = <SupaCron>[].obs;

  @override
  Future<void> onInit() async {
    /// Page: AutoComplete
    menuList.value = await repo.getMenuList();
    unawaited(getAutoCompleteList());
    unawaited(getUserProfile());

    /// Page: App Config
    tfEco.text = pref.read<num>(kFlagEco)?.moneyFormat() ?? '';
    tfAverage.text = pref.read<num>(kFlagAverage)?.moneyFormat() ?? '';
    tfSpender.text = pref.read<num>(kFlagSpender)?.moneyFormat() ?? '';
    tfCurrencySymbol.text = pref.read<String>(kCurrencySymbol) ?? '';

    packageInfo = await PackageInfo.fromPlatform();
    appInfo.value = packageInfo?.data ?? {};

    countExpense.value = await repo.countExpense();
    countCategory.value = await repo.countCategory();
    countAutoComplete.value = await repo.countAutoComplete();

    backupList.value = await repo.getBackupList();
    cronList.value = await repo.getCron();
    super.onInit();
  }

  Future<void> onMenuChange(String menu) async {
    menuSelected.value = menu;
    closeDrawer();
  }

  Future<void> getUserProfile() async {
    userProfile.value = await repo.getUserProfile().then((value) => value[0]);
  }

  Future<void> getAutoCompleteList({String? q}) async {
    try {
      change(0, status: RxStatus.loading());
      if (q != null) {
        autoCompleteList.value = await repo.findAutoComplete(q);
      } else {
        autoCompleteList.value = await repo.getAutoComplete();
      }

      if (autoCompleteList.isEmpty) {
        change(0, status: RxStatus.empty());
      } else {
        change(200, status: RxStatus.success());
      }
    } catch (e) {
      await ErrorLogHelper.record(page: 'settings', action: 'getAutoComplete', stack: e.toString());
      change(400, status: RxStatus.error('$e'));
    }
  }

  Future<void> onAddAutoComplete(String note) async {
    if (note.isEmptyOrNull) return;

    final newAutoComplete = SupaAutoComplete(
      id: UuidV4().generate(),
      userId: db.auth.currentSession?.user.id ?? '',
      createdAt: DateTime.now().toStringEx(),
      note: note,
      amount: '0',
      categoryName: 'Others',
    );

    await repo.addAutoComplete(newAutoComplete);
    tfAddAutoComplete.clear();
    autoCompleteList.value = await repo.getAutoComplete();
    change(0, status: RxStatus.success());
  }

  Future<void> onDeleteAutoComplete(SupaAutoComplete entity) async {
    await repo.deleteAutoComplete(entity.note ?? '');
    autoCompleteList.value = await repo.getAutoComplete();
    change(0, status: RxStatus.success());
  }

  void onEditProfile() {
    final tfFullName = TextEditingController(text: userProfile.value.fullName);
    final tfAge = TextEditingController(text: userProfile.value.age);
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
          }),
          Obx(() => errorMsg.value.isNotEmpty ? '$errorMsg'.text.size(11).minFontSize(11).align(TextAlign.center).makeCentered().pSymmetric(v: 4) : 0.heightBox),
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

                    await db.storage.from('avatars').upload(fileName, file, fileOptions: FileOptions(upsert: true, cacheControl: '1')).then((response) async {
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
                  await ErrorLogHelper.record(page: 'settings', action: 'onEditProfile', stack: e.toString());
                  errorMsg.value = '$e';
                }
              }
            },
            height: 33,
            child: 'Change Photo'.text.size(11).minFontSize(11).make(),
          ).centered().pOnly(bottom: 16),
          TextField(
            controller: tfFullName,
            decoration: DecorationHelper.input(hint: 'Full Name'),
            style: TextStyle(fontSize: 13),
          ).h(33).pOnly(bottom: 12),
          TextField(
            controller: tfAge,
            decoration: DecorationHelper.input(hint: 'Age'),
            style: TextStyle(fontSize: 13),
          ).h(33),
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
                updatedAt: DateTime.now().toStringEx(),
              );
              await Overlayment.dismissAll();
              ExLoading.show(paddingSymmetric: Get.context!.isMobile ? 90 : 250, child: CupertinoActivityIndicator());
              await repo.editProfile(editProfile);
              await onInit();
              ExLoading.dismiss();
            },
          ).centered()
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

      await ImportExportHelper.exportToCSV(
        customPath: filePath.path,
        customCallback: (file) async {
          await db.storage.from('backup').upload(fileName, file, fileOptions: FileOptions(upsert: true, cacheControl: '1')).then((response) async {
            file.deleteSync();
            await onInit();
            OverlayHelper.notification('Syncronization Done');
          }).catchError((e) {
            ErrorLogHelper.record(page: 'settings', action: 'onUploadBackup', stack: e.toString());
            ExAlert.error(message: '${(e as StorageException).message}');
          });
        },
      );
    } catch (e) {
      log('e: $e');
      await ErrorLogHelper.record(page: 'settings', action: 'onUploadBackup', stack: e.toString());
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
        await db.storage.from('backup').download(fileObj.name).then((res) async {
          final filePath = await getTemporaryDirectory();
          final fileName = '${fileObj.name}';
          final file = File('${filePath.path}/$fileName');

          await file.writeAsBytes(res);
          await db.from('expense').delete().match({'user_id': db.auth.currentSession?.user.id ?? ''});
          await ImportExportHelper.importFromCSV(
            customPath: '${filePath.path}/$fileName',
            customCallback: () async {
              file.deleteSync();
              await onInit();
              OverlayHelper.notification(
                'Success Apply Migration "${fileName.replaceAll('${db.auth.currentSession?.user.email}_', '')}"',
                duration: 4.seconds,
              );
            },
          );
        }).catchError((e) {
          log('e: $e');
          ErrorLogHelper.record(page: 'settings', action: 'onDownloadBackup', stack: e.toString());
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
        message: '''
${listToDelete.length} data will be deleted
${listToDelete.map((word) => '- $word').join('\n').replaceAll('${db.auth.currentSession?.user.email}_etracker_', '')}
          '''
            .trim(),
        onYes: () async {
          Get.back();
          ExLoading.show(paddingSymmetric: Get.context!.isMobile ? 90 : 250, child: CupertinoActivityIndicator());
          await db.storage.from('backup').remove(listToDelete);
          backupList.value = await repo.getBackupList();
          ExLoading.dismiss();
        });
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
}
