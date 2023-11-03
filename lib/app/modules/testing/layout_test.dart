import 'package:ex/ex.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../widgets/widgets.dart';

class LayoutTest extends GetView {
  const LayoutTest({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyLayout(
        appBarTitle: appBarTitle(),
        appBarLeading: appBarLeading(),
        appBarAction: appBarAction(),
        sideMenuContent: sideMenuContent(),
        bodyContent: bodyContent(),
        footerContent: footerContent(),
      ),
    );
  }

  Widget appBarTitle() {
    return 'LAYOUT RAW TEST'.text.maxLines(1).make();
  }

  Widget appBarLeading() {
    return IconButton(
      onPressed: () => Get.back(),
      icon: Icon(Icons.abc),
    );
  }

  Widget appBarAction() {
    return HStack(
      [
        '[action1] '.text.make(),
        '[action2] '.text.make(),
      ],
    );
  }

  Widget sideMenuContent() {
    return VStack(
      [
        'SIDE MENU TOP'.text.bold.make(),
        ListView.builder(
          itemCount: 100,
          itemBuilder: (context, index) {
            return ListTile(
              title: '${faker.animal.name()}'.text.size(11).ellipsis.maxLines(1).make(),
            );
          },
        ).expand(),
        'SIDE MENU BOTTOM'.text.bold.make(),
      ],
    ).expand();
  }

  Widget bodyContent() {
    return VStack([
      'BODY TOP'.text.bold.make(),
      ListView.builder(
        itemCount: 100,
        itemBuilder: (context, index) {
          return ListTile(
            title: '${ExRandom.alphaNumeric(12)}'.text.size(11).ellipsis.maxLines(1).make(),
          );
        },
      ).expand(),
      'BODY BOTTOM'.text.bold.make(),
    ]);
  }

  Widget footerContent() {
    return HStack(
      [
        'Footer Start'.text.make(),
        Spacer(),
        'Footer End'.text.make(),
      ],
    );
  }
}
