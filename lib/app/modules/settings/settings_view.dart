import 'package:ex/ex.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../core/app_color.dart';
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
    return Scaffold(
      body: MyLayout(
        appBarTitle: 'Settings'.text.size(11).bold.make(),
        sideMenuContent: sideMenuContent(),
        bodyContent: Obx(() => bodyContent().p8()),
        footerContent: footerContent(),
      ),
    );
  }

  Widget sideMenuContent() {
    return VStack([
      16.heightBox,
      Obx(
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
        ).expand(),
      ),
    ]).expand();
  }

  Widget bodyContent() {
    switch (controller.menuSelected.value) {
      case APP_CONFIG:
        return controller.obx((state) => SectionAppConfig());
      case AUTO_COMPLETE:
        return controller.obx((state) => SectionAutoComplete());
      case REPEAT_SETTING:
        return controller.obx((state) => SectionRepeat());
      case IMPORT_EXPORT:
        return controller.obx((state) => SectionIEmport());
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
    ]).p12();
  }
}
