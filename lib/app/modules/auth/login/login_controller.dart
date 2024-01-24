import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../helpers/helpers.dart';
import '../../../routes/app_pages.dart';
import 'login_repository.dart';

class LoginController extends GetxController {
  final repo = Get.find<LoginRepository>();

  final tfEmail = TextEditingController();
  final tfPassword = TextEditingController();

  /// appInfo
  final appInfo = <String, dynamic>{}.obs;
  late PackageInfo? packageInfo;

  @override
  Future<void> onInit() async {
    packageInfo = await PackageInfo.fromPlatform();
    appInfo.value = packageInfo?.data ?? {};
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
      Get.offAllNamed(Routes.HOME);
    }).catchError((e) {
      logE('$e');
      OverlayHelper.notification('Invalid Credentials', color: Vx.red600, duration: 2.seconds);
      ExLoading.dismiss();
    });
  }
}
