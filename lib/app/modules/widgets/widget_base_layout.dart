import 'dart:io';

import 'package:ex_kit/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import '../../core/app_color.dart';

class MyLayout extends StatelessWidget {
  const MyLayout({
    super.key,
    this.drawerKey,
    required this.appBarTitle,
    this.appBarLeading,
    this.appBarAction,
    required this.sideMenuContent,
    this.sideMenuWidth,
    this.sideMenuColor,
    required this.bodyContent,
    required this.footerContent,
    this.footerColor,
    this.floatingActionButton,
    this.isShowAppBarLeading = true,
  });

  final GlobalKey<ScaffoldState>? drawerKey;

  // appBar
  final Widget? appBarTitle;
  final Widget? appBarLeading;
  final bool isShowAppBarLeading;

  final Widget? appBarAction;

  // sideMenu
  final Widget? sideMenuContent;
  final double? sideMenuWidth;
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
      key: drawerKey,
      backgroundColor: AppColor.scaffoldPrimary,

      /// drawer -> Mobile
      drawer: context.isMobile ? Drawer(child: sideMenu(context)) : null,

      /// appbar -> Mobile
      appBar: context.isMobile ? myAppBarMobile() : null,
      floatingActionButton: floatingActionButton?.pOnly(bottom: 16),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// row 1 -> Desktop
            if (!context.isMobile)
              sideMenu(context).wh(sideMenuWidth ?? 255, double.infinity),

            /// row 2
            VStack(
              [
                /// appbar -> Desktop
                if (!context.isMobile) myAppBarDesktop(),

                /// body
                body().expand(),

                /// footer
                if (!context.isMobile || MediaQuery.viewInsetsOf(context).bottom == 0)
                  footer(),
              ],
            ).expand(),
          ],
        ),
      ),
    );
  }

  Widget sideMenu(BuildContext context) {
    return GlassContainer(
      color: AppColor.sideMenuPrimary,
      borderRadius: BorderRadius.all(Radius.circular(0)),
      border: Border.all(color: Colors.transparent),
      blur: kIsWeb && context.isMobile ? 0 : 50,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Get.theme.scaffoldBackgroundColor,
          AppColor.sideMenuPrimary,
          // AppColor.sideMenuSecondary,
        ],
      ),
      width: 250,
      height: double.infinity,
      child: VStack([
        kIsWeb ? 8.heightBox : 32.heightBox,
        sideMenuContent ?? Container(),
      ]),
    );
  }

  AppBar myAppBarMobile() {
    return AppBar(
      backgroundColor: AppColor.appbarPrimary,
      surfaceTintColor: AppColor.appbarPrimary,
      title: appBarTitle,
      leadingWidth: 40,
      centerTitle: false,
      actions: [appBarAction ?? Container()],
    );
  }

  Widget myAppBarDesktop() {
    return AppBar(
      backgroundColor: AppColor.appbarPrimary,
      surfaceTintColor: AppColor.appbarPrimary,
      title: appBarTitle,
      centerTitle: false,
      leading: isShowAppBarLeading == true
          ? appBarLeading?.pOnly(right: 8) ??
                IconButton(
                  icon: Icon(CupertinoIcons.arrow_left, size: 22),
                  onPressed: Get.back,
                ).pOnly(right: 8)
          : null,
      actions: [
        appBarAction ?? Container(),
      ],
    );
  }

  Widget body() => bodyContent.pOnly(top: 8);

  Widget footer() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: footerColor ?? AppColor.footerPrimary),
      child: Padding(
        padding: !kIsWeb && Platform.isIOS
            ? EdgeInsets.only(bottom: 20, right: 8, left: 8)
            : EdgeInsets.all(0),
        child: footerContent,
      ),
    );
  }
}
