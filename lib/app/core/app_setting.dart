import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/category_entity.dart';
import 'const.dart';
import 'generator.dart';

class AppSettingService extends GetxService {
  @override
  Future<void> onInit() async {
    await checkAndApplyDefaultAppConfig();
    await checkAndSeedCategoryIfEmpty();
    super.onInit();
  }

  // ------------------------------------------------------------------------
  // if new user: setup default app config
  // ------------------------------------------------------------------------
  Future<void> checkAndApplyDefaultAppConfig() async {
    if (!pref.hasData(kFlagEco) || //
        !pref.hasData(kFlagAverage) ||
        !pref.hasData(kFlagSpender) ||
        !pref.hasData(kIsDarkMode)) {
      await pref.write(kFlagEco, 50000);
      await pref.write(kFlagAverage, 100000);
      await pref.write(kFlagSpender, 100000);
      await pref.write(kIsDarkMode, true);
      logI('-- CONFIG CREATED --');
    }
  }

  // ------------------------------------------------------------------------
  // if new user: seed default category data
  // ------------------------------------------------------------------------
  Future<void> checkAndSeedCategoryIfEmpty() async {
    final response = await db.from('category').select().order('max_budget').withConverter<List<CategoryEntity>>((data) {
      return (data as List).map((e) => CategoryEntity.fromJson(e)).toList();
    });
    if (response.isEmpty) {
      await db.from('category').insert([
        DBGenerator.category('Food', Icons.fastfood).toJson(),
        DBGenerator.category('Smoking', Icons.smoking_rooms_rounded).toJson(),
        DBGenerator.category('Shopping', Icons.shopping_basket_rounded).toJson(),
        DBGenerator.category('Others', Icons.diamond).toJson(),
      ]);
      await 1.seconds.delay();
      logI('-- DEFAULT CATEGORY CREATED --');
    }
  }

  // ------------------------------------------------------------------------
  // theme management
  // ------------------------------------------------------------------------
  ThemeMode get theme => _getCurrentTheme() ? ThemeMode.dark : ThemeMode.light;
  bool _getCurrentTheme() => pref.read(kIsDarkMode) ?? true;
  Future<void> _changeCurrentTheme(bool isDarkMode) async => await pref.write(kIsDarkMode, isDarkMode);
  Future<void> switchTheme() async {
    Get.changeThemeMode(_getCurrentTheme() ? ThemeMode.light : ThemeMode.dark);
    await _changeCurrentTheme(!_getCurrentTheme());
  }
}
