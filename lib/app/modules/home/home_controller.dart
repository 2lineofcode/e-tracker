import 'dart:collection';

import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/v4.dart';

import '../../core/const.dart';
import '../../helpers/helper_misc.dart';
import '../../models/category_entity.dart';
import '../../models/expense_entity.dart';
import 'home_repository.dart';

class HomeController extends GetxController with StateMixin {
  /// repo
  final repo = Get.find<HomeRepository>();

  /// calendar
  late PageController calenderPageController;
  final focusedDay = DateTime.now().obs;
  final selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
  );
  final events = <DateTime, List<String>>{}.obs;

  /// category
  final tfCategory = TextEditingController();
  final categoryList = <CategoryEntity>[].obs;
  final categorySelected = ''.obs;

  /// list
  final expenseList = <ExpenseEntity>[].obs;
  final tfSearchExpense = TextEditingController();

  /// count
  final countOfDay = 0.obs;
  final countOfMonth = 0.obs;

  /// flag
  final isSearchMode = false.obs;
  final isFirstLoad = true.obs;

  /// init ~~
  @override
  Future<void> onInit() async {
    selectedDays.add(DateTime.now());
    await getCategory();
    await getExpense();
    await getCount1Month(DateTime.now());
    await onCalenderRefreshEvent();
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
    await getCount1Month(DateTime.now());
    closeDrawer();
  }

  Future<void> onCalenderGoDate(ExpenseEntity element) async {
    final selectedDate = element.date!.toDateEx(format: yMd);
    selectedDays.clear();
    focusedDay.value = selectedDate;
    selectedDays.add(selectedDate);
    await getExpense();
    await getCount1Month(selectedDate);
  }

  Future<void> onCalenderGoPrevMonth() async {
    await calenderPageController.previousPage(duration: 300.milliseconds, curve: Curves.easeIn);
    await getCount1Month(focusedDay.value);
  }

  Future<void> onCalenderGoNextMonth() async {
    await calenderPageController.nextPage(duration: 300.milliseconds, curve: Curves.easeIn);
    await getCount1Month(focusedDay.value);
  }

  List<String> onCalenderLoadEvent(DateTime day) {
    final kEvents = LinkedHashMap<DateTime, List<String>>(
      equals: isSameDay,
      hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
    );

    kEvents.addAll(events);
    return kEvents[day] ?? [];
  }

  Future<void> onCalenderRefreshEvent() async {
    events.clear();
    await repo.getExpenseAll().then((res) {
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

    await Get.forceAppUpdate();
  }

  /// count total per month
  Future<void> getCount1Month(DateTime dateTime) async {
    final month = dateTime.toStringEx(format: yM);
    countOfMonth.value = await repo.getCount1Month(month);
  }

  /// category
  Future<void> getCategory() async {
    categoryList.value = await repo.getCategory();
  }

  Future<void> onAddCategory(String categoryName) async {
    if (categoryName.isEmptyOrNull) return;

    final categoryEntity = CategoryEntity(
      id: UuidV4().generate(),
      createdAt: DateTime.now().toStringEx(),
      name: categoryName,
      color: Vx.randomColor.toHex(), // todo Fix me
    );
    await repo.addCategory(categoryEntity);
    await getCategory();
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
      tfSearchExpense.clear();
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
}
