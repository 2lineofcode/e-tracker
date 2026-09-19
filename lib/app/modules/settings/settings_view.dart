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
      appBarTitle: 'Pengaturan'.text.size(15).bold.make(),
      appBarAction: appBarAction(),
      sideMenuContent: sideMenuContent(),
      sideMenuWidth: 220,
      bodyContent: LayoutBuilder(
        builder: (context, constraints) => Obx(
          () => Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 820),
              child: bodyContent(),
            ),
          ).pSymmetric(
            h: constraints.maxWidth < 600 ? 12 : 24,
            v: 16,
          ),
        ),
      ),
      footerContent: footerContent(),
    );
  }

  Widget appBarAction() => const SizedBox.shrink();

  Widget sideMenuContent() {
    return Obx(
      () => VStack([
        'MENU'.text
            .size(10)
            .color(AppColor.neutral)
            .letterSpacing(1.2)
            .make()
            .pSymmetric(h: 16)
            .pOnly(bottom: 10),
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: controller.menuList.length,
          itemBuilder: (context, index) {
            final item = controller.menuList[index];

            return Obx(() {
              final isSelected =
                  item['label'] == controller.menuSelected.value;

              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => controller.onMenuChange(item['label']),
                child: Container(
                  decoration: ExDecorator.box(
                    borderRadius: 8,
                    fillColor: isSelected
                        ? AppColor.sideMenuSelected
                        : Colors.transparent,
                    borderColor: Colors.transparent,
                  ),
                  child: HStack(
                    [
                      Icon(
                        item['icon'],
                        color: isSelected
                            ? AppColor.textReverse
                            : AppColor.neutral,
                        size: 16,
                      ).pOnly(right: 12),
                      '${item['label']}'.text
                          .size(12)
                          .color(
                            isSelected
                                ? AppColor.textReverse
                                : AppColor.neutral,
                          )
                          .make(),
                    ],
                  ).pSymmetric(h: 12, v: 11),
                ),
              ).pSymmetric(h: 10).pOnly(bottom: 4);
            });
          },
        ),
      ]).pOnly(top: 20).expand(),
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
    const buildDate = String.fromEnvironment('BUILD_DATE');
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
              return 'v${controller.appInfo['version']} (${controller.appInfo['buildNumber']})${buildDate.isNotEmpty ? ' · $buildDate' : ''}'
                  .text
                  .size(11)
                  .color(AppColor.neutral)
                  .make();
            default:
              return Container();
          }
        },
      ),
    ]).p12();
  }
}
