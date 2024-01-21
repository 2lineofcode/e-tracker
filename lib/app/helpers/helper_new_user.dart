import 'package:ex/ex.dart';
import 'package:get/get.dart';
import 'package:uuid/v4.dart';

import '../core/app_api.dart';
import '../models/supa_expense_entity.dart';
import '../modules/home/home_controller.dart';

mixin NewUserHelper {
  static Future<void> gettingStart() async {
    final _home = Get.find<HomeController>();
    if (_home.categoryList.isEmptyOrNull && _home.expenseList.isEmptyOrNull) {
      await _createCategory();
      await _createWelcome();
      await _home.onInit();
    }
  }

  /// create category
  static Future<void> _createCategory() async {
    final _home = Get.find<HomeController>();
    await _home.onAddCategory('Others');
    await _home.onAddCategory('Notes', icon: 'code=63033&family=CupertinoIcons&pack=cupertino_icons', iconColor: '#fffdf0b0');
  }

  /// create welcome
  static Future<void> _createWelcome() async {
    final expsenses = SupaExpense(
      id: UuidV4().generate(),
      createdAt: DateTime.now().toStringEx(),
      userId: db.auth.currentSession?.user.id ?? '',
      date: DateTime.now().toStringEx(format: 'yyyy-MM-dd'),
      categoryName: 'Notes',
      amount: 0,
      note: 'Hi ${db.auth.currentSession?.user.email?.allBefore('@')}',
      detail: 'This is the day you commit to starting record your fucking expenses! 🔥',
    );
    await db.from('expense').insert(expsenses.toJson());
  }
}
