import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:keymap/keymap.dart';

import 'app/modules/settings/settings_repository.dart';
import 'app/routes/app_pages.dart';

List<KeyAction> get keyBindings {
  return [
    /// ⌘ + .
    KeyAction.fromString(
      '.',
      'Open Settings',
      () async {
        await Get.toNamed(Routes.SETTINGS, parameters: {'page': AUTO_COMPLETE});
      },
      isMetaPressed: true,
    ),

    /// arrow left <-
    KeyAction(
      LogicalKeyboardKey.arrowLeft,
      'Home <- Go Prev Day',
      () => {},
    ),

    /// arrow right ->
    KeyAction(
      LogicalKeyboardKey.arrowRight,
      'Home -> Go Next Day',
      () => {},
    ),
  ];
}
