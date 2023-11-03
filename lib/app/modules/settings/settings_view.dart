import 'package:ex/ex.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../widgets/widgets.dart';
import 'section_appconfig.dart';
import 'section_autocomplete.dart';
import 'section_iemport.dart';
import 'section_repeat.dart';
import 'settings_controller.dart';
import 'settings_repository.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyLayout(
        appBarTitle: 'Settings'.text.size(11).bold.make(),
        sideMenuContent: sideMenuContent(),
        bodyContent: bodyContent().p8(),
        footerContent: Container(),
      ),
    );
  }

  Widget sideMenuContent() {
    return VStack([
      8.heightBox,
      Obx(
        () => ListView.builder(
          itemCount: controller.menuList.length,
          itemBuilder: (context, index) {
            final item = controller.menuList[index];
            return Container(
              decoration: ExDecorator.box(
                fillColor: item == controller.menuSelected.value ? Colors.blue : Colors.transparent,
                borderColor: Colors.transparent,
              ),
              child: '$item'.text.size(11).make().p8(),
            ).onTap(() => controller.onMenuChange(item)).pSymmetric(h: 10).pOnly(bottom: 8);
          },
        ).expand(),
      ),
    ]).expand();
  }

  Widget bodyContent() {
    switch (controller.menuSelected.value) {
      case AUTO_COMPLETE:
        return controller.obx((state) => SectionAutoComplete());
      case APP_CONFIG:
        return controller.obx((state) => SectionAppConfig());
      case REPEAT_SETTING:
        return controller.obx((state) => SectionRepeat());
      case IMPORT_EXPORT:
        return controller.obx((state) => SectionIEmport());
      default:
        return Container();
    }
  }
}
