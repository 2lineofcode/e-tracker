import 'package:ex/ex.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../core/app_color.dart';
import '../../helpers/helpers.dart';
import '../widgets/widgets.dart';
import 'section_appconfig.dart';
import 'section_autocomplete.dart';
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

  Widget appBarAction() {
    return HStack(
      [
        Obx(
          () => controller.menuSelected.value == SectionMenu.AUTO_COMPLETE
              ? TextField(
                  controller: controller.tfSearchAutoComplete,
                  style: TextStyle(fontSize: 13),
                  decoration: DecorationHelper.input(
                    hint: 'Search...',
                    contentPadding: EdgeInsets.only(left: 8, right: 8),
                    suffix: Icon(Icons.clear, size: 10).pOnly(top: 4, right: 8).onInkTap(() async {
                      controller.tfSearchAutoComplete.clear();
                      await controller.getAutoCompleteList();
                    }),
                  ),
                  onSubmitted: (s) async {
                    if (s.isNotEmpty) {
                      await controller.getAutoCompleteList(q: s);
                    } else {
                      await controller.getAutoCompleteList();
                    }
                  },
                ).wh(170, 28).pOnly(right: 12)
              : 0.heightBox,
        ),
      ],
    );
  }

  Widget sideMenuContent() {
    return Obx(
      () => ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: controller.menuList.length,
        itemBuilder: (context, index) {
          final item = controller.menuList[index];
          return Obx(
            () => InkWell(
              onTap: () => controller.onMenuChange(item),
              child: Container(
                decoration: ExDecorator.box(
                  fillColor: item == controller.menuSelected.value ? AppColor.sideMenuSelected : Colors.transparent,
                  borderColor: Colors.transparent,
                ),
                child: '$item'.text.size(11).make().p8(),
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
      case SectionMenu.AUTO_COMPLETE:
        return SectionAutoComplete();
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
              return 'Version: ${controller.appInfo['version']} (${controller.appInfo['buildNumber']})'.text.make();
            case SectionMenu.AUTO_COMPLETE:
              return '${controller.autoCompleteList.length} Record'.text.make();
            default:
              return Container();
          }
        },
      ),
    ]).p12();
  }
}
