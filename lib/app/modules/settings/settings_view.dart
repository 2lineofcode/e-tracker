import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../core/app_color.dart';
import '../../helpers/helpers.dart';
import '../widgets/widgets.dart';
import 'section_appconfig.dart';
import 'section_iemport.dart';
import 'section_repeat.dart';
import 'settings_controller.dart';
import 'settings_repository.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    return MyLayout(
      drawerKey: drawerKeySetting,
      appBarTitle: 'Settings'.text.size(11).bold.make(),
      appBarAction: appBarAction(),
      sideMenuContent: sideMenuContent(),
      bodyContent: Obx(() => bodyContent().p8()),
      footerContent: footerContent(),
    );
  }

  Widget appBarAction() => const SizedBox.shrink();

  Widget sideMenuContent() {
    return Obx(
      () => ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: controller.menuList.length,
        itemBuilder: (context, index) {
          final item = controller.menuList[index];
          return Obx(
            () => InkWell(
              onTap: () => controller.onMenuChange(item['label']),
              child: Container(
                decoration: ExDecorator.box(
                  fillColor: item['label'] == controller.menuSelected.value ? AppColor.sideMenuSelected : Colors.transparent,
                  borderColor: Colors.transparent,
                ),
                child: HStack(
                  [
                    Icon(item['icon'], color: AppColor.textReverse, size: 14).pOnly(right: 8),
                    '${item['label']}'.text.size(11).make(),
                  ],
                ).p8(),
              ).pSymmetric(h: 10).pOnly(bottom: 8),
            ),
          );
        },
      ).pOnly(top: 16).expand(),
    );
  }

  Widget bodyContent() {
    switch (controller.menuSelected.value) {
      case SectionMenu.APP_CONFIG:
        return SectionAppConfig();
      case SectionMenu.REPEAT_SETTING:
        return SectionRepeat();
      case SectionMenu.IMPORT_EXPORT:
        return SectionIEmport();
      default:
        return Container();
    }
  }

  Widget footerContent() {
    return HStack([
      if (Get.context!.isMobile) ...[
        IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back),
        ),
      ],
      Spacer(),
      Obx(
        () {
          switch (controller.menuSelected.value) {
            case SectionMenu.APP_CONFIG:
              return 'Version: ${controller.appInfo['version']} (${controller.appInfo['buildNumber']})'.text.size(12).make();
            default:
              return Container();
          }
        },
      ),
    ]).p12();
  }
}
