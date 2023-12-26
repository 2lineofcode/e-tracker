import 'package:ex/ex.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../widgets/widgets.dart';
import 'detail_mutual_controller.dart';

class DetailMutualView extends GetView<DetailMutualController> {
  const DetailMutualView({super.key});
  @override
  Widget build(BuildContext context) {
    return MyLayout(
      appBarTitle: appBarTitle(),
      sideMenuContent: sideMenuContent(),
      bodyContent: bodyContent(),
      footerContent: footerContent(),
    );
  }

  Widget appBarTitle() {
    return Obx(() => '${controller.productDetail.value.name ?? '...'}'.text.size(13).bold.make());
  }

  Widget sideMenuContent() {
    return Container();
  }

  Widget bodyContent() {
    return Container();
  }

  Widget footerContent() {
    return Container();
  }
}
