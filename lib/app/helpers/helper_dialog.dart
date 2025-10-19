import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

mixin HelperDialog {
  static void ios({
    bool? isDismissible,
    Widget? icon,
    Widget? title,
    Widget? content,
    List<Widget>? actions,
    double? radius,
    double? padding,
  }) {
    showAdaptiveDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: title,
          content: content,
          actions: actions ?? [],
        );
      },
      barrierDismissible: isDismissible ?? true,
      useSafeArea: true,
      
    );
  }
}
