import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/category_entity.dart';
import '../../models/expense_entity.dart';
import '../home/home_controller.dart';
import 'filtering_repository.dart';

class FilteringController extends GetxController with StateMixin {
  /// repo
  final repo = Get.find<FilteringRepository>();

  /// home
  final home = Get.find<HomeController>();

  /// category
  final tfCategory = TextEditingController();
  final categoryList = <CategoryEntity>[].obs;

  /// argument
  final categorySelected = ''.obs;
  final startDate = ''.obs;
  final endDate = ''.obs;

  final orderBy = 'date'.obs;

  final total = 0.obs;

  /// list
  final expenseList = <ExpenseEntity>[].obs;
  final orderByList = <String>[].obs;

  /// init ~~
  @override
  Future<void> onInit() async {
    categorySelected.value = Get.arguments[0];
    startDate.value = Get.arguments[1];
    endDate.value = Get.arguments[2];

    orderByList.value = await repo.getOrderList();
    categoryList.value = await repo.getCategory();
    await findExpense(categorySelected.value);
    super.onInit();
  }

  Future<void> onCategoryChange(String categoryName) async {
    categorySelected.value = categoryName;
    await findExpense(categorySelected.value);
    Get.forceAppUpdate();
  }

  /// expense
  Future<void> findExpense(String categoryName) async {
    try {
      expenseList.value = await repo.findExpense(categoryName, startDate.value, endDate.value, orderBy: orderBy.value);

      // count total
      total.value = 0;
      for (var e in expenseList) total.value += e.amount ?? 0;
    } catch (e) {
      change(0, status: RxStatus.error('$e'));
    }
    if (expenseList.isNotEmpty) {
      change(0, status: RxStatus.success());
    } else {
      change(0, status: RxStatus.empty());
    }
  }
}
