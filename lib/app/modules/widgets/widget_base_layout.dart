import 'package:ex/ex.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyLayout extends StatelessWidget {
  const MyLayout({
    super.key,
    required this.appBarTitle,
    this.appBarLeading,
    this.appBarAction,
    required this.sideMenuContent,
    this.sideMenuWidht,
    this.sideMenuColor,
    required this.bodyContent,
    required this.footerContent,
    this.footerColor,
    this.floatingActionButton,
  });

  // appBar
  final Widget appBarTitle;
  final Widget? appBarLeading;
  final Widget? appBarAction;

  // sideMenu
  final Widget sideMenuContent;
  final double? sideMenuWidht;
  final Color? sideMenuColor;

  // body
  final Widget bodyContent;

  // footer
  final Widget footerContent;
  final Color? footerColor;

  // fab
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// drawer -> Mobile
      drawer: context.isMobile ? Drawer(child: sideMenu()) : null,

      /// appbar -> Mobile
      appBar: context.isMobile
          ? AppBar(
              backgroundColor: Vx.neutral900,
              toolbarHeight: 44,
              title: appBarTitle,
              leadingWidth: 40,
              centerTitle: false,
              actions: [appBarAction ?? Container()],
            )
          : null,
      floatingActionButton: floatingActionButton?.pOnly(bottom: 16),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// row 1 -> Desktop
          if (!context.isMobile) sideMenu().wh(sideMenuWidht ?? 255, double.infinity),

          /// row 2
          VStack(
            [
              /// appbar -> Desktop
              if (!context.isMobile) myAppBar(),

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
        kIsWeb ? 8.heightBox : 32.heightBox,
        sideMenuContent,
      ]),
    );
  }

  Widget myAppBar() {
    return AppBar(
      backgroundColor: Vx.neutral900,
      toolbarHeight: 44,
      title: appBarTitle,
      centerTitle: false,
      leading: appBarLeading?.pOnly(right: 8) ??
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: Get.back,
          ).pOnly(right: 8),
      actions: [
        appBarAction ?? Container(),
      ],
    );
  }

  Widget body() => bodyContent.pOnly(top: 8);

  Widget footer() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: footerColor ?? Vx.neutral800),
      child: Padding(
        padding: Get.context!.isMobile ? EdgeInsets.only(bottom: 20, right: 8, left: 8) : EdgeInsets.all(0),
        child: footerContent,
      ),
    );
  }
}
