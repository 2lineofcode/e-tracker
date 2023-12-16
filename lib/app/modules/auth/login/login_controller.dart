import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../core/app_base.dart';
import '../../../core/const.dart';
import '../../../helpers/helpers.dart';
import '../../../routes/app_pages.dart';
import 'login_repository.dart';

class LoginController extends GetxController {
  final repo = Get.find<LoginRepository>();

  final tfEmail = TextEditingController();
  final tfPassword = TextEditingController();

  @override
  void onInit() {
    if (kDebugMode) {
      tfEmail.text = 'adit@gmail.com';
      tfPassword.text = 'asdasdasd';
    }
    super.onInit();
  }

  Future<void> onLogin() async {
    ExLoading.show(
      paddingSymmetric: Get.context!.isMobile ? 90 : 250,
      child: CupertinoActivityIndicator(),
    );
    await repo.login(tfEmail.text, tfPassword.text).then((response) {
      ExLoading.dismiss();
      pref.write(kIsLogin, true);
      Get.offAllNamed(Routes.HOME);
    }).catchError((e) {
      logE('$e');
      OverlayHelper.notification(
        'Invalid Credentials',
        color: Vx.red600,
        duration: 2.seconds,
      );
      ExLoading.dismiss();
    });
  }
}
