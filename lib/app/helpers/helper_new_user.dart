import 'dart:io';
import 'dart:typed_data';

import 'package:ex/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlayment/overlayment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/v4.dart';

import '../core/app_api.dart';
import '../models/supa_expense_entity.dart';
import '../models/supa_user_profile_entity.dart';
import '../modules/home/home_controller.dart';
import '../modules/widgets/widget_image_no_cache_view.dart';
import 'helper_decoration.dart';

mixin NewUserHelper {
  static Future<void> gettingStart() async {
    final _home = Get.find<HomeController>();
    if (_home.categoryList.isEmptyOrNull && _home.expenseList.isEmptyOrNull) {
      await _createRequireCategory();
      await sayWelcome();
      await _home.onInit();
    }
  }

  /// create category
  static Future<void> _createRequireCategory() async {
    final _home = Get.find<HomeController>();
    await _home.onAddCategory('Others');
    await _home.onAddCategory('Notes', icon: 'code=63033&family=CupertinoIcons&pack=cupertino_icons', iconColor: '#fffdf0b0');
  }

  /// create welcome
  static Future<void> sayWelcome() async {
    final opt1 = true.obs;

    final userProfile = await db.from('profiles').select().eq('id', db.auth.currentSession?.user.id ?? '').withConverter<List<SupaUserProfile>>((data) {
      return (data).map((e) => SupaUserProfile.fromJson(e)).toList();
    });

    final tfFullName = TextEditingController(text: userProfile[0].fullName);
    final name = '${userProfile[0].fullName ?? ''}'.obs;
    final tfAge = TextEditingController(text: userProfile[0].age);
    final tfAvatar = userProfile[0].avatarUrl.obs;

    final isReplacePhoto = false.obs;
    final imgReplace = Uint8List(0).obs;

    await Overlayment.show(
      context: Get.context!,
      OverPanel(
        width: 300,
        alignment: Alignment.centerRight,
        child: VStack([
          Obx(() => 'Hi ${name.value}👋'.text.size(16).bold.make().pOnly(bottom: 12)),

          Obx(() {
            if (isReplacePhoto.isTrue) {
              return Container(
                decoration: ExDecorator.box(borderRadius: 90),
                child: Image.memory(imgReplace.value).wh(64, 64).cornerRadius(90),
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
          ExButtonElevated(
            onPressed: () async {
              // filepicker select file and upload to supabase storage
              await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false).then((img) async {
                if (img != null) {
                  isReplacePhoto.value = true;

                  final file = File(img.paths.first ?? '');
                  final fileName = '${db.auth.currentSession?.user.id}.png';
                  imgReplace.value = file.readAsBytesSync();

                  await db.storage.from('avatars').upload(fileName, file, fileOptions: FileOptions(upsert: true, cacheControl: '1')).then((response) async {
                    tfAvatar.value = db.storage.from('avatars').getPublicUrl(fileName);
                    log('tfAvatar: $tfAvatar');
                  });
                }
              });
            },
            height: 33,
            child: 'Change Photo'.text.size(11).minFontSize(11).make(),
          ).centered().pOnly(bottom: 16),
          TextField(
            controller: tfFullName,
            decoration: DecorationHelper.input(hint: 'Full Name'),
            style: TextStyle(fontSize: 13),
            onChanged: (value) => name.value = value,
          ).h(33).pOnly(bottom: 12),
          TextField(
            controller: tfAge,
            decoration: DecorationHelper.input(hint: 'Age'),
            style: TextStyle(fontSize: 13),
          ).h(33),
          Divider().pSymmetric(v: 16),

          ///
          '"${DateTime.now().toStringEx(format: 'dd MMM y')}" This is the day that we hope you commit to start tracking your fucking expenses! 🔥'.text.make(),

          /// opt1
          Obx(
            () => Visibility(
              visible: opt1.isTrue,
              child: Container(
                decoration: ExDecorator.box(),
                child: VStack([
                  'do you wants to record this as reminder?'.text.size(12).makeCentered().pOnly(bottom: 8),
                  HStack([
                    ExButtonElevated(
                      label: 'Yes',
                      height: 33,
                      onPressed: () async {
                        opt1.value = false;
                        final expsenses = SupaExpense(
                          id: UuidV4().generate(),
                          createdAt: DateTime.now().toStringEx(),
                          userId: db.auth.currentSession?.user.id ?? '',
                          date: DateTime.now().toStringEx(format: 'yyyy-MM-dd'),
                          categoryName: 'Notes',
                          amount: 0,
                          note: 'Hi!',
                          detail: 'This is the day you commit to starting record your fucking expenses! 🔥',
                        );
                        await db.from('expense').insert(expsenses.toJson());
                        await Get.find<HomeController>().getExpense();
                      },
                    ).expand(),
                    12.widthBox,
                    ExButtonElevated(
                      label: 'No',
                      height: 33,
                      onPressed: () => opt1.value = false,
                    ).expand(),
                  ]),
                ]).p8(),
              ),
            ),
          ).pSymmetric(v: 12),

          Spacer(),
          ExButtonElevated(
            width: double.infinity,
            label: 'Save',
            onPressed: () async {
              await Overlayment.dismissAll();
              final editProfile = SupaUserProfile(
                id: userProfile[0].id ?? '',
                fullName: tfFullName.text,
                age: tfAge.text,
                avatarUrl: tfAvatar.value,
                updatedAt: DateTime.now().toStringEx(),
              );
              await Overlayment.dismissAll();
              await db //
                  .from('profiles')
                  .update(editProfile.toJson())
                  .eq('id', db.auth.currentSession?.user.id ?? '')
                  .then((value) {
                //
              });
            },
          )
        ]).p16(),
      ),
    );
  }
}
