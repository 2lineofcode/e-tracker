import 'dart:io';

import 'package:expense_tracker/app/core/app_setting.dart';
import 'package:expense_tracker/app/core/const.dart';
import 'package:expense_tracker/app/models/supa_user_profile_entity.dart';
import 'package:expense_tracker/app/modules/settings/settings_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('settings rejects empty and reversed expense thresholds', () {
    expect(() => SettingsController.parseExpenseThresholds('', '100000', '100000'), throwsFormatException);
    expect(() => SettingsController.parseExpenseThresholds('50000', '', '100000'), throwsFormatException);
    expect(() => SettingsController.parseExpenseThresholds('50000', '100000', ''), throwsFormatException);
    expect(() => SettingsController.parseExpenseThresholds('100000', '50000', '100000'), throwsFormatException);
    expect(SettingsController.parseExpenseThresholds('Rp.50.000', 'Rp.100.000', 'Rp.200.000'),
        (eco: 50000, average: 100000, spender: 200000));
  });

  test('saved profile replaces cached thresholds without resetting theme', () async {
    final directory = await Directory.systemTemp.createTemp('settings_safety_');
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => directory.path);
    await pref.initStorage;
    addTearDown(() async {
      await pref.queue.add(() async {});
      await pumpEventQueue();
      await directory.delete(recursive: true);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
    });
    await pref.write(kFlagEco, 1);
    await pref.write(kFlagAverage, 2);
    await pref.write(kFlagSpender, 3);
    await pref.write(kThemeColor, 123);
    await AppSettingService().applyProfilePreferences(SupaUserProfile(
      ecoDay: 50000, averageDay: 100000, spenderDay: 200000,
    ));
    expect(pref.read<num>(kFlagEco), 50000);
    expect(pref.read<num>(kFlagAverage), 100000);
    expect(pref.read<num>(kFlagSpender), 200000);
    expect(pref.read<int>(kThemeColor), 123);
  });
}
