import 'dart:collection';

import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/v4.dart';

import '../../core/app_base.dart';
import '../../core/const.dart';
import '../../helpers/helpers.dart';
import '../../models/category_entity.dart';
import '../../models/expense_entity.dart';
import '../../models/rpc_sum_by_category_entity.dart';
import '../../routes/app_pages.dart';
import 'home_repository.dart';

class HomeController extends GetxController with StateMixin {
  /// repo
  final repo = Get.find<HomeRepository>();

  /// calendar
  late PageController calenderPageController;
  final focusedDay = DateTime.now().obs;
  final selectedDays = LinkedHashSet<DateTime>(equals: isSameDay, hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year);
  final events = <DateTime, List<String>>{}.obs;

  /// category
  final tfCategory = TextEditingController();
  final categoryList = <Category>[].obs;
  final categorySelected = ''.obs;

  /// expense
  final expenseList = <Expense>[].obs;
  final tfSearchExpense = TextEditingController().obs;

  /// count
  final countOfDay = 0.obs;
  final countOfMonth = 0.obs;
  final rpcSpenderDay = [].obs;
  final countMaxBudget = 0.obs;
  final countRemainingBudget = 0.obs;
  final rpcSumByCategory = <RpcSumByCategory>[].obs;

  /// flag
  final isSearchMode = false.obs;
  final isFirstLoad = true.obs;

  /// init ~~
  @override
  Future<void> onInit() async {
    /// new user => seed dummy data
    await SeedHelper.generate();

    selectedDays.add(DateTime.now());
    await getCategory();
    await getExpense();
    await getCount1Month(DateTime.now());
    await onCalenderRefreshEvent(period: focusedDay.value.toStringEx(format: yM));
    rpcSpenderDay.value = await repo.rpcGetSpenderDay(focusedDay.value);
    rpcSumByCategory.value = await repo.rpcSumByCategory(focusedDay.value);
    super.onInit();
  }

  /// calendar
  Future<void> onCalenderDayChange(DateTime sDay, DateTime fDay) async {
    closeDrawer();
    focusedDay.value = fDay;
    selectedDays.clear();
    selectedDays.add(fDay);
    await getExpense();
  }

  Future<void> onCalenderGoToday() async {
    selectedDays.clear();
    focusedDay.value = DateTime.now();
    selectedDays.add(DateTime.now());
    await getExpense();
    closeDrawer();
  }

  Future<void> onCalenderGoDate(DateTime dateTime) async {
    selectedDays.clear();
    focusedDay.value = dateTime;
    selectedDays.add(dateTime);
    await getExpense();
  }

  Future<void> onCalenderGoPrevMonth() async {
    await calenderPageController.previousPage(duration: 300.milliseconds, curve: Curves.easeIn);
  }

  Future<void> onCalenderGoNextMonth() async {
    await calenderPageController.nextPage(duration: 300.milliseconds, curve: Curves.easeIn);
  }

  Future<void> onCalenderPageChanged(DateTime fd) async {
    focusedDay.value = fd;
    await onCalenderRefreshEvent(period: fd.toStringEx(format: yM));
    await getCount1Month(fd);
    rpcSpenderDay.value = await repo.rpcGetSpenderDay(fd);
    rpcSumByCategory.value = await repo.rpcSumByCategory(focusedDay.value);
  }

  List<String> onCalenderLoadEvent(DateTime day) {
    final kEvents = LinkedHashMap<DateTime, List<String>>(
      equals: isSameDay,
      hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
    );

    kEvents.addAll(events);
    return kEvents[day] ?? [];
  }

  Future<void> onCalenderRefreshEvent({String period = ''}) async {
    events.clear();
    await repo.getExpenseAll(period: period).then((res) {
      // Membuat Map untuk mengelompokkan data berdasarkan tanggal
      Map<DateTime, List<String>> groupedData = {};

      // Iterasi melalui data dan mengelompokkannya
      for (var item in res) {
        var date = item.date!.toDateEx(format: yMd);
        if (groupedData.containsKey(date)) {
          groupedData[date]!.add('${item.amount}');
        } else {
          groupedData[date] = ['${item.amount}'];
        }
      }
      events.addAll(groupedData);
    });

    update();
  }

  /// count total per month
  Future<void> getCount1Month(DateTime dateTime) async {
    try {
      final month = dateTime.toStringEx(format: yM);
      countOfMonth.value = await repo.getCount1Month(month) ?? 0;

      // count percentage of remain budget
      var sum = 0;
      for (var e in categoryList) sum += e.maxBudget?.toInt() ?? 0;
      countMaxBudget.value = sum;
      countRemainingBudget.value = (countOfMonth.value / sum * 100).toInt();
    } catch (e) {
      countMaxBudget.value = 0;
      countRemainingBudget.value = 0;
    }
  }

  /// category
  Future<void> getCategory() async {
    categoryList.value = await repo.getCategory();
  }

  Future<void> onAddCategory(String categoryName) async {
    if (categoryName.isEmptyOrNull) return;

    final categoryEntity = Category(
      id: UuidV4().generate(),
      userId: db.auth.currentSession?.user.id ?? '',
      createdAt: DateTime.now().toStringEx(),
      name: categoryName,
      color: Vx.randomPrimaryColor.toHex(),
    );
    await repo.addCategory(categoryEntity);
    await getCategory();
    OverlayHelper.notification('Category $categoryName Added', color: Vx.green600);
    tfCategory.clear();
  }

  /// expense
  Future<void> getExpense({String? find}) async {
    change(0, status: RxStatus.loading());
    final date = focusedDay.value.toStringEx(format: yMd);
    try {
      if (find == null) {
        expenseList.value = await repo.getExpense(date);
        isSearchMode.value = false;
      } else {
        expenseList.value = await repo.findExpense(find);
        isSearchMode.value = true;
      }
    } catch (e) {
      change(0, status: RxStatus.error('$e'));
    }

    /// search
    if (find == null) {
      tfSearchExpense.value.clear();
      isSearchMode.value = false;
    }

    /// count a day
    countOfDay.value = 0;
    for (var element in expenseList) {
      countOfDay.value += element.amount ?? 0;
    }

    /// ui state
    if (expenseList.isEmpty) {
      change(0, status: RxStatus.empty());
    } else {
      change(0, status: RxStatus.success());
    }
  }

  void goSummary() {
    Get.toNamed(Routes.SUMMARY, parameters: {'period': focusedDay.value.toStringEx(format: yM)});
  }

  void goSetting() {
    Get.toNamed(Routes.SETTINGS);
  }

  void goBibit() {
    Get.toNamed(Routes.BIBIT);
  }
}
