import 'dart:async';
import 'dart:collection';

import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/const.dart';
import '../../helpers/helpers.dart';
import '../../models/supa_assets_entity.dart';
import '../../models/supa_budgets_entity.dart';
import '../../models/supa_category_entity.dart';
import '../../models/supa_expense_entity.dart';
import '../../models/supa_goals_entity.dart';
import '../../models/supa_notes_entity.dart';
import '../../models/supa_user_profile_entity.dart';
import '../../routes/app_pages.dart';
import 'home_repository.dart';
import 'home_rt.dart';

class HomeController extends GetxController with StateMixin {
  /// repo
  final repo = Get.find<HomeRepository>();

  /// calendar
  late PageController calenderPageController;
  final focusedDay = DateTime.now().obs;
  final selectedDays = LinkedHashSet<DateTime>(equals: isSameDay, hashCode: hashDate);

  final events = <DateTime, List<String>>{}.obs;

  /// category
  final categoryList = <ExpenseCategory>[].obs;
  final categoryGroups = <ExpenseCategoryGroup>[].obs;
  final categorySelected = ''.obs;

  /// budgets
  final budgetsList = <SupaBudgets>[].obs;
  final monthlyExpenseByGroup = RxMap<String, num>();
  final totalAllBudget = 0.obs;
  final totalSumAllBudget = 0.obs;

  /// assets
  final assetsList = <SupaAssets>[].obs;
  final totalAssets = 0.obs;

  /// goals & notes
  final goalsList = <SupaGoals>[].obs;
  final notesList = <SupaNotes>[].obs;

  /// expense
  final userProfile = SupaUserProfile().obs;
  final expenseList = <SupaExpense>[].obs;
  final tfSearchExpense = TextEditingController().obs;

  /// count
  final countOfDay = 0.0.obs;
  final countOfMonth = 0.obs;
  final rpcSpenderDay = [].obs;
  final countMaxBudget = 0.obs;
  final countRemainingBudget = 0.obs;

  /// flag
  final isSearchMode = false.obs;
  final isFirstLoad = true.obs;

  // advance search
  final isAdvanceSearch = false.obs;
  final advanceSearchText = ''.obs;

  final footerStatus = ''.obs;

  /// init ~~
  @override
  Future<void> onInit() async {
    selectedDays.add(DateTime.now());
    loadCategories();
    await refreshBudgetsList();
    await getExpense();
    await getCount1Month(DateTime.now());
    await onCalenderRefreshEvent(period: focusedDay.value.toStringEx(format: yM));
    await loadAssetsSummary();
    await loadGoalsList();
    await loadNotesList();

    rpcSpenderDay.value = await repo.rpcGetSpenderDay(focusedDay.value);
    userProfile.value = await repo.getUserProfile().then((value) => value[0]);
    await HomeRT.initRealtime();
    update();
    super.onInit();
  }

  @override
  Future<void> onReady() async {
    await HelperNewUser.gettingStart();
    super.onReady();
  }

  Future<void> loadAssetsSummary() async {
    try {
      final assets = await repo.getAssets();
      assetsList.assignAll(assets);
      totalAssets.value = assets.fold<num>(0, (sum, e) => sum + (e.amount ?? 0)).toInt();
    } catch (e) {
      await HelperErrorLog.record(
        page: 'home',
        action: 'loadAssetsSummary',
        stack: e.toString(),
      );
      assetsList.clear();
      totalAssets.value = 0;
    }
  }

  Future<void> loadGoalsList() async {
    try {
      final goals = await repo.getGoals();
      goalsList.assignAll(goals);
    } catch (e) {
      await HelperErrorLog.record(
        page: 'home',
        action: 'loadGoalsList',
        stack: e.toString(),
      );
      goalsList.clear();
    }
  }

  Future<void> loadNotesList() async {
    try {
      final notes = await repo.getNotes();
      notesList.assignAll(notes);
    } catch (e) {
      await HelperErrorLog.record(
        page: 'home',
        action: 'loadNotesList',
        stack: e.toString(),
      );
      notesList.clear();
    }
  }

  void _updateTotalBudgetAggregate() {
    totalAllBudget.value = budgetsList.fold(0, (sum, value) => sum + (value.amount ?? 0));
  }

  Future<void> refreshBudgetsList() async {
    try {
      final data = await repo.getBudgets();
      budgetsList.assignAll(data);
      _updateTotalBudgetAggregate();
      update();
    } catch (e) {
      await HelperErrorLog.record(page: 'home', action: 'refreshBudgetsList', stack: e.toString());
    }
  }

  /// calendar
  Future<void> onCalenderDayChange(DateTime sDay, DateTime fDay) async {
    closeDrawer();
    focusedDay.value = fDay;
    selectedDays.clear();
    selectedDays.add(fDay);
    await getExpense();
    await getCount1Month(fDay);
  }

  Future<void> onCalenderGoToday() async {
    selectedDays.clear();
    focusedDay.value = DateTime.now();
    selectedDays.add(DateTime.now());
    await getExpense();
    await getCount1Month(focusedDay.value);
    closeDrawer();
  }

  Future<void> onCalenderGoDate(DateTime dateTime) async {
    selectedDays.clear();
    focusedDay.value = dateTime;
    selectedDays.add(dateTime);
    await getExpense();
    await getCount1Month(focusedDay.value);
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
  }

  List<String> onCalenderLoadEvent(DateTime day) {
    final kEvents = LinkedHashMap<DateTime, List<String>>(equals: isSameDay, hashCode: hashDate);
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
      await loadMonthlyExpenseByGroup(dateTime);

      // count percentage of remain budget
      var sum = 0;
      for (var e in categoryList) {
        sum += e.defaultBudget ?? 0;
      }
      countMaxBudget.value = sum;
      countRemainingBudget.value = sum > 0 ? (countOfMonth.value / sum * 100).toInt() : 0;
    } catch (e) {
      await HelperErrorLog.record(page: 'home', action: 'getCount1Month', stack: e.toString());
      countMaxBudget.value = 0;
      countRemainingBudget.value = 0;
    }
  }

  Future<void> loadMonthlyExpenseByGroup(DateTime dateTime) async {
    try {
      final result = await repo.getMonthlyExpenseByBudgets(dateTime);
      monthlyExpenseByGroup.assignAll(result);
      monthlyExpenseByGroup.refresh();

      _updateTotalBudgetAggregate();
      totalSumAllBudget.value = monthlyExpenseByGroup.values.fold(0, (sum, value) => sum + value.toInt());
      update();
    } catch (e) {
      await HelperErrorLog.record(page: 'home', action: 'loadMonthlyExpenseByGroup', stack: e.toString());
      monthlyExpenseByGroup.clear();
    }
  }

  /// category
  void loadCategories() {
    categoryList.assignAll(expenseCategoryList);
    categoryGroups.assignAll(expenseCategoryGroups);
    if (categorySelected.value.isEmpty && categoryList.isNotEmpty) {
      categorySelected.value = categoryList.first.code;
    }
  }

  /// expense
  Future<void> getExpense({
    String? find,
    String? startDate,
    String? endDate,
    bool showLoading = true,
  }) async {
    if (find == null) {
      HomeRT.rtActiveSearchQuery = null;
      HomeRT.rtActiveStartDate = null;
      HomeRT.rtActiveEndDate = null;
    } else {
      HomeRT.rtActiveSearchQuery = find;
      HomeRT.rtActiveStartDate = startDate;
      HomeRT.rtActiveEndDate = endDate;
    }

    if (showLoading) change(0, status: RxStatus.loading());

    final date = focusedDay.value.toStringEx(format: yMd);
    try {
      if (find == null) {
        expenseList.value = await repo.getExpense(date);
        isSearchMode.value = false;
      } else {
        if (find.startsWith(RegExp(r'[0-9]'))) {
          expenseList.value = await repo.findExpenseByDateRange(find);
        } else {
          if (startDate != null && endDate != null) {
            isAdvanceSearch.value = true;
            advanceSearchText.value = 'Showing data from "$startDate - $endDate"';
          } else {
            isAdvanceSearch.value = false;
            advanceSearchText.value = '';
          }
          expenseList.value = await repo.findExpense(find, startDate: startDate, endDate: endDate);
        }
        isSearchMode.value = true;
      }
    } catch (e) {
      await HelperErrorLog.record(page: 'home', action: 'getExpense', stack: e.toString());
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

  @override
  void onClose() {
    unawaited(HomeRT.dispose());
    super.onClose();
  }
}
