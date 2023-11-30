import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/app_color.dart';
import '../widgets/widgets.dart';
import 'bibit_controller.dart';
import 'section_explore.dart';
import 'section_home.dart';
import 'section_portfolio.dart';

class BibitView extends GetView<BibitController> {
  const BibitView({super.key});
  @override
  Widget build(BuildContext context) {
    return MyLayout(
      appBarTitle: appBarTitle(),
      appBarAction: appBarAction().pOnly(right: 4),
      sideMenuContent: sideMenuContent(),
      bodyContent: Obx(() => bodyContent().p8()),
      footerContent: Container(),
    );
  }

  Widget appBarTitle() {
    return 'Investment'.text.size(11).bold.make();
  }

  IconButton appBarAction() {
    return IconButton(
      icon: Icon(CupertinoIcons.refresh_bold, size: 22),
      onPressed: () {},
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
              onTap: () => controller.onMenuChange(item['name']),
              child: Container(
                decoration: ExDecorator.box(
                  fillColor: item['name'] == controller.menuSelected.value ? AppColor.sideMenuSelected : Colors.transparent,
                  borderColor: Colors.transparent,
                ),
                child: HStack([
                  Icon(item['icon'], size: 18).pSymmetric(h: 8),
                  '${item['name']}'.text.size(11).make().pOnly(left: 4),
                ]).p8(),
              ).pSymmetric(h: 10).pOnly(bottom: 8),
            ),
          );
        },
      ).pOnly(top: 16).expand(),
    );
  }

  Widget bodyContent() {
    switch (controller.menuSelected.value) {
      case 'Home':
        return controller.obx((state) => SectionHome());
      case 'Portfolio':
        return controller.obx((state) => SectionPorfolio());
      case 'Explore':
        return controller.obx((state) => SectionExplore());
      default:
        return Container();
    }
  }
}
