import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';

import '../../../core/app_color.dart';
import '../../widgets/widgets.dart';
import 'detail_stock_controller.dart';
import 'tab_1.dart';
import 'tab_2.dart';

class DetailStockView extends GetView<DetailStockController> {
  const DetailStockView({super.key});
  @override
  Widget build(BuildContext context) {
    return MyLayout(
      appBarTitle: appBarTitle(),
      appBarAction: appBarAction(),
      sideMenuContent: sideMenuContent(),
      bodyContent: Obx(() => bodyContent()),
      footerContent: footerContent(),
    );
  }

  Widget appBarTitle() {
    return Obx(
      () => VStack([
        '${controller.productDetail.value.symbol ?? '...'}'.text.size(13).minFontSize(13).bold.maxLines(1).ellipsis.make(),
        '${controller.productDetail.value.name ?? ''}'.text.size(11).minFontSize(11).maxLines(1).ellipsis.make(),
      ]),
    );
  }

  Widget appBarAction() {
    return HStack([
      IconButton(onPressed: () {}, icon: Icon(CupertinoIcons.purchased)),
      Obx(
        () => IconButton(
          onPressed: () {},
          icon: SvgPicture.asset(
            controller.isFavorite.isTrue ? 'assets/icons/ic_star_fill.svg' : 'assets/icons/ic_star_unfill.svg',
            height: 20,
          ),
        ),
      ),
    ]);
  }

  Widget sideMenuContent() {
    final menuList = ['Summaries', 'News'];
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
        return DetailStockTab1();
      case 'News':
        return DetailStockTab2();
      default:
        return Container();
    }
  }

  Widget footerContent() {
    return Container();
  }
}
