import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helpers/helper_misc.dart';
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
  final categoryList = <Category>[].obs;

  /// argument
  final categorySelected = ''.obs;
  final startDate = ''.obs;
  final endDate = ''.obs;
  final orderBy = 'amount'.obs;

  final sumAll = 0.0.obs;
  final sumByDate = <String, num>{}.obs;

  /// list
  final expenseList = <Expense>[].obs;
  final orderByList = <String>[].obs;

  /// uiSelected
  final uiSelected = 'list'.obs;
  late Map<String?, List<Expense>>? grouppedByDate; // <- for tabel view [group date manually]

  /// init ~~
  @override
  Future<void> onInit() async {
    categorySelected.value = Get.arguments[0];
    startDate.value = Get.arguments[1];
    endDate.value = Get.arguments[2];

    orderByList.value = await repo.getOrderList();
    categoryList.value = await repo.getCategory();
    categoryList.insert(0, Category(name: 'All'));

    await findExpense(categorySelected.value);
    super.onInit();
  }

  Future<void> onCategoryChange(String categoryName) async {
    closeDrawer();
    categorySelected.value = categoryName;
    await findExpense(categorySelected.value);
  }

  /// expense
  Future<void> findExpense(String categoryName) async {
    try {
      expenseList.value = await repo.findExpense(categoryName, startDate.value, endDate.value, orderBy: orderBy.value);

      /// calc sumAll
      sumAll.value = 0.0;
      for (var e in expenseList) {
        sumAll.value += e.amount ?? 0;
      }

      /// calc sumByDate
      sumByDate.clear();
      for (var data in expenseList) {
        var date = data.date!;
        var amount = data.amount!;
        if (sumByDate.containsKey(date)) {
          sumByDate[date] = (sumByDate[date] ?? 0) + amount;
        } else {
          sumByDate[date] = amount;
        }
      }
    } catch (e) {
      change(0, status: RxStatus.error('$e'));
    }

    if (expenseList.isNotEmpty) {
      change(0, status: RxStatus.success());
    } else {
      change(0, status: RxStatus.empty());
    }

    /// for tabel view [group date manually]
    final _grouping = expenseList.groupBy((element) => element.date);
    final _sorting = _grouping.entries.toList()..sort((e1, e2) => e2.key!.compareTo(e1.key!));
    grouppedByDate = <String?, List<Expense>>{};
    for (var element in _sorting) {
      grouppedByDate![element.key] = List<Expense>.from(element.value);
    }
  }
}
