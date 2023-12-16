import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../helpers/helpers.dart';
import '../../widgets/widgets.dart';
import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    return MyLayout(
      drawerKey: drawerKeyLogin,
      appBarTitle: appBarTitle(),
      appBarLeading: appBarLeading(),
      sideMenuContent: sideMenuContent(),
      bodyContent: bodyContent(),
      footerContent: footerContent(),
    );
  }

  Widget appBarTitle() {
    return 'AI Expense Tracker+'.text.size(12).bold.make();
  }

  Widget appBarLeading() {
    return Icon(CupertinoIcons.app_badge);
  }

  Widget sideMenuContent() {
    return Container();
  }

  Widget bodyContent() {
    final passwordVisible = false.obs;

    return VStack(
      [
        'Email/Username'.text.make().pOnly(bottom: 8),
        TextField(
          controller: controller.tfEmail,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(fontSize: 13),
          decoration: DecorationHelper.input(
            hint: 'Enter your email/username',
          ),
          onSubmitted: (_) => controller.onLogin(),
        ).h(36).pOnly(bottom: 24),
        'Password'.text.make().pOnly(bottom: 8),
        Obx(
          () => TextField(
            controller: controller.tfPassword,
            keyboardType: TextInputType.visiblePassword,
            style: TextStyle(fontSize: 13),
            obscureText: !passwordVisible.value,
            enableSuggestions: false,
            autocorrect: false,
            decoration: DecorationHelper.input(
              hint: 'Enter your password',
              suffixIcon: IconButton(
                icon: Icon(passwordVisible.isTrue ? Icons.visibility : Icons.visibility_off, size: 16),
                onPressed: () => passwordVisible.value = !passwordVisible.value,
              ),
            ),
            onSubmitted: (_) => controller.onLogin(),
          ).h(36),
        ),
        24.heightBox,
        HStack(
          [
            'Just Personal Project'.text.neutral500.make(),
            Spacer(),
            ExButtonElevated(
              label: 'Login',
              onPressed: () => controller.onLogin(),
            ),
          ],
        ),
      ],
    ).p24().centered();
  }

  Widget footerContent() {
    return Container();
  }
}
