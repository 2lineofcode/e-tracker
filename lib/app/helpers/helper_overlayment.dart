import 'dart:async';

import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';
import 'package:get/get.dart';
import 'package:overlayment/overlayment.dart';

mixin OverlayHelper {
  static void notification(
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
          color: color ?? Vx.green600,
          duration: duration ?? 1.seconds,
        ),
      ),
    );
  }

  static void openCalculator(double initialValue) {
    Overlayment.dismissAll();
    unawaited(
      Overlayment.show(
        OverPanel(
          name: 'calc',
          alignment: Alignment.bottomRight,
          width: 300,
          child: SimpleCalculator(
            autofocus: true,
            hideSurroundingBorder: true,
            value: initialValue,
            onTappedDisplay: (p0, p1) => Overlayment.dismissName('calc'),
          ),
        ),
        context: Get.context!,
      ),
    );
  }
}
