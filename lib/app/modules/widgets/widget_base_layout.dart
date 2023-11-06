import 'dart:io';

import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyLayout extends StatelessWidget {
  const MyLayout({
    super.key,
    //
    required this.appBarTitle,
    this.appBarLeading,
    this.appBarAction,
    //
    required this.sideMenuContent,
    this.sideMenuWidht,
    this.sideMenuColor,
    //
    required this.bodyContent,
    //
    required this.footerContent,
    this.footerColor,
  });

  final Widget appBarTitle;
  final Widget? appBarLeading;
  final Widget? appBarAction;

  // sidemenu
  final Widget sideMenuContent;
  final double? sideMenuWidht;
  final Color? sideMenuColor;

  // body
  final Widget bodyContent;

  // footer
  final Widget footerContent;
  final Color? footerColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// row 1
          sideMenu().wh(sideMenuWidht ?? 255, double.infinity),

          /// row 2
          VStack(
            [
              /// appbar
              myAppBar(),

              /// body
              body().expand(),

              /// footer
              footer(),
            ],
          ).expand(),
        ],
      ),
    );
  }

  Widget sideMenu() {
    return Container(
      color: Vx.neutral800,
      width: 250,
      height: double.infinity,
      child: VStack([
        Platform.isMacOS ? 32.heightBox : 8.heightBox,
        sideMenuContent,
      ]),
    );
  }

  Widget myAppBar() {
    return Container(
      width: double.infinity,
      height: 44,
      color: Vx.neutral900,
      child: HStack(
        [
          appBarLeading?.pOnly(right: 8) ??
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: Get.back,
              ).pOnly(right: 8),
          appBarTitle,
          Spacer(),
          appBarAction ?? Container(),
        ],
      ),
    );
  }

  Widget body() => bodyContent;

  Widget footer() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: footerColor ?? Vx.neutral800),
      child: footerContent,
    );
  }
}
