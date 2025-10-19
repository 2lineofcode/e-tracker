import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:uicons_pro/uicons_pro.dart';

import 'xlsio_controller.dart';

class XlsioView extends GetView<XlsioController> {
  const XlsioView({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ZStack(
          [
            Positioned.fill(
              child: VStack([
                'asdasd'.text.make(),
              ]),
            ),

            IconButton(
              onPressed: () => Get.back(),
              icon: Icon(UIconsPro.solidRounded.cross, size: 14),
            ).positioned(right: 0, top: 0),
          ],
        ).pOnly(top: 42, left: 12, right: 12, bottom: 12),
      ),
    );
  }
}
