import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:get/get.dart';

import '../../core/app_color.dart';
import '../../helpers/helpers.dart';
import '../widgets/widgets.dart';
import '_explore/section_bibit_explore_view.dart';
import '_home/section_bibit_home_view.dart';
import '_performance/section_bibit_performance_view.dart';
import '_portfolio/section_bibit_portfolio_view.dart';
import '_transaction/section_bibit_transaction_view.dart';
import 'bibit_controller.dart';

class BibitView extends GetView<BibitController> {
  const BibitView({super.key});
  @override
  Widget build(BuildContext context) {
    return MyLayout(
      drawerKey: drawerKeyBibit,
      appBarTitle: appBarTitle(),
      appBarAction: appBarAction().pOnly(right: 4),
      sideMenuContent: sideMenuContent(),
      bodyContent: Obx(() => bodyContent().p8()),
      footerContent: footerContent(),
    );
  }

  Widget appBarTitle() {
    return 'Investment'.text.size(11).bold.make();
  }

  Widget appBarAction() {
    return Obx(
      () {
        return controller.menuSelected.value == 'Home'
            ? CustomPopup(
                content: VStack(
                  [
                    if (controller.isMarketOpen.isFalse) ...[
                      'Market Sedang Tutup'.text.bold.black.make().pOnly(bottom: 8),
                      'Market akan buka kembali dalam:'.text.black.size(12).make(),
                      '${controller.getCompaniesInfo.value.marketHours?.formattedTimeLeft}'.text.size(12).black.make(),
                    ] else ...[
                      'Market Buka'.text.bold.black.make().pOnly(bottom: 8),
                      'Market sedang buka'.text.black.size(12).make(),
                    ],
                  ],
                ),
                child: HStack([
                  Icon(
                    CupertinoIcons.circle_fill,
                    size: 6,
                    color: controller.isMarketOpen.isFalse ? AppColor.red : AppColor.green,
                  ).pOnly(right: 8),
                  Icon(
                    controller.isMarketOpen.isFalse ? CupertinoIcons.moon_circle_fill : CupertinoIcons.timer_fill,
                    size: 22,
                  ),
                ]),
              ).p12()
            : Container();
      },
    );
  }

  Widget sideMenuContent() {
    final menuList = <Map<String, dynamic>>[
      {'icon': CupertinoIcons.home, 'name': 'Home'},
      {'icon': CupertinoIcons.app_badge_fill, 'name': 'Portfolio'},
      {'icon': CupertinoIcons.chart_bar_alt_fill, 'name': 'Performance'},
      {'icon': CupertinoIcons.flame_fill, 'name': 'Explore'},
      {'icon': CupertinoIcons.arrow_right_arrow_left, 'name': 'Transaction'},
    ];
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemCount: menuList.length,
      itemBuilder: (context, index) {
        final item = menuList[index];
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
    ).pOnly(top: 16).expand();
  }

  Widget bodyContent() {
    switch (controller.menuSelected.value) {
      case 'Home':
        return controller.obx((state) => SectionBibitHomeView());
      case 'Portfolio':
        return controller.obx((state) => SectionBibitPorfolioView());
      case 'Performance':
        return controller.obx((state) => SectionBibitPerformanceView());
      case 'Explore':
        return controller.obx((state) => SectionBibitExploreView());
      case 'Transaction':
        return controller.obx((state) => SectionBibitTransactionView());
      default:
        return Container();
    }
  }

  Widget footerContent() {
    if (Get.context!.isMobile) {
      return HStack([
        if (Get.context!.isMobile) ...[
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back),
          ),
        ],
        Spacer(),
      ]).p12();
    } else {
      return Container();
    }
  }
}
