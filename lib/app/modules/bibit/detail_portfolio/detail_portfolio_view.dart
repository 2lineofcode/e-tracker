import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/app_color.dart';
import '../../widgets/widgets.dart';
import 'detail_portfolio_controller.dart';
import 'tab_1.dart';
import 'tab_2.dart';

class DetailPortfolioView extends GetView<DetailPortfolioController> {
  const DetailPortfolioView({super.key});
  @override
  Widget build(BuildContext context) {
    return MyLayout(
      appBarTitle: appBarTitle(),
      sideMenuContent: sideMenuContent(),
      bodyContent: Obx(() => bodyContent()),
      footerContent: footerContent(),
    );
  }

  Widget appBarTitle() {
    return Obx(() => '${controller.porto.value.categoryname ?? '...'}'.text.size(13).make());
  }

  Widget sideMenuContent() {
    final menuList = ['Summaries', 'Chart'];
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemCount: menuList.length,
      itemBuilder: (context, index) {
        final item = menuList[index];
        return Obx(
          () => InkWell(
            onTap: () => controller.onMenuChange(item),
            child: Container(
              decoration: ExDecorator.box(
                fillColor: item == controller.menuSelected.value ? AppColor.sideMenuSelected : Colors.transparent,
                borderColor: Colors.transparent,
              ),
              child: HStack([
                '$item'.text.size(11).make().pOnly(left: 4),
              ]).p8(),
            ).pSymmetric(h: 10).pOnly(bottom: 8),
          ),
        );
      },
    ).pOnly(top: 16).expand();
  }

  Widget bodyContent() {
    switch (controller.menuSelected.value) {
      case 'Summaries':
        return DetailPortpolioTab1();
      case 'Chart':
        return DetailPortpolioTab2();
      default:
        return Container();
    }
  }

  Widget footerContent() {
    return Container();
  }
}
