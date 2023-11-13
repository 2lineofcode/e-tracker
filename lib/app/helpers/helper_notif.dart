import 'dart:async';

import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlayment/overlayment.dart';

mixin AppNotif {
  static void show(
    String msg, {
    Color? color,
    TextStyle? style,
    Alignment? alignment,
    Duration? duration,
  }) {
    unawaited(
      Overlayment.show(
        context: Get.context!,
        OverNotification(
          name: 'notif',
          child: Text(msg, style: style ?? TextStyle(color: Colors.white)).p12(),
          alignment: alignment ?? Alignment.topRight,
          color: color,
          duration: duration ?? 1.seconds,
        ),
      ),
    );
  }
}
