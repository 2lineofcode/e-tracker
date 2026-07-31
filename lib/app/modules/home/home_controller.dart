import 'dart:async';
import 'dart:collection';

import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/app_setting.dart';
import '../../core/const.dart';
import '../../helpers/helpers.dart';
import '../../models/supa_assets_entity.dart';
import '../../models/supa_budgets_entity.dart';
import '../../models/supa_category_entity.dart';
import '../../models/supa_cron_entity.dart';
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
  final selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: hashDate,
  );

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
  final cronList = <SupaCron>[].obs;

  /// expense
  final userProfile = SupaUserProfile().obs;
  final expenseList = <SupaExpense>[].obs;
  final tfSearchExpense = TextEditingController().obs;
  final searchFocusNode = FocusNode();

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
    await onCalenderRefreshEvent(
      period: focusedDay.value.toStringEx(format: yM),
    );
    await loadAssetsSummary();
    await loadGoalsList();
    await loadNotesList();
    await loadCronList();

    rpcSpenderDay.value = await repo.rpcGetSpenderDay(focusedDay.value);
    userProfile.value = await repo.getUserProfile().then((value) => value[0]);
    await HomeRT.initExpenseRT();
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
      totalAssets.value = assets
          .fold<num>(0, (sum, e) => sum + (e.amount ?? 0))
          .toInt();
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

  Future<void> loadCronList() async {
    try {
      final cron = await repo.getCron();
      cronList.assignAll(cron);
    } catch (e) {
      await HelperErrorLog.record(
        page: 'home',
        action: 'loadCronList',
        stack: e.toString(),
      );
      cronList.clear();
    }
  }

  void _updateTotalBudgetAggregate() {
    totalAllBudget.value = budgetsList.fold(
      0,
      (sum, value) => sum + (value.amount ?? 0),
    );
  }

  Future<void> refreshBudgetsList() async {
    try {
      final data = await repo.getBudgets();
      budgetsList.assignAll(data);
      _updateTotalBudgetAggregate();
      update();
    } catch (e) {
      await HelperErrorLog.record(
        page: 'home',
        action: 'refreshBudgetsList',
        stack: e.toString(),
      );
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
    if (_calendarStartDay != 1) {
      final current = focusedDay.value;
      await onCalenderGoDate(_shiftFocusedMonth(current, -1));
      await onCalenderRefreshEvent(
        period: focusedDay.value.toStringEx(format: yM),
      );
      rpcSpenderDay.value = await repo.rpcGetSpenderDay(focusedDay.value);
      return;
    }

    await calenderPageController.previousPage(
      duration: 300.milliseconds,
      curve: Curves.easeIn,
    );
  }

  Future<void> onCalenderGoNextMonth() async {
    if (_calendarStartDay != 1) {
      final current = focusedDay.value;
      await onCalenderGoDate(_shiftFocusedMonth(current, 1));
      await onCalenderRefreshEvent(
        period: focusedDay.value.toStringEx(format: yM),
      );
      rpcSpenderDay.value = await repo.rpcGetSpenderDay(focusedDay.value);
      return;
    }

    await calenderPageController.nextPage(
      duration: 300.milliseconds,
      curve: Curves.easeIn,
    );
  }

  int get _calendarStartDay => pref.read<int>(kCalendarStartDay) ?? 1;

  DateTime _shiftFocusedMonth(DateTime dateTime, int monthOffset) {
    final target = DateTime(dateTime.year, dateTime.month + monthOffset, 1);
    final targetMonthDays = DateTime(target.year, target.month + 1, 0).day;
    return DateTime(
      target.year,
      target.month,
      dateTime.day.clamp(1, targetMonthDays),
    );
  }

  List<String> _calendarEventPeriods(DateTime dateTime) {
    final effectiveStartDay = _calendarStartDay.clamp(
      1,
      DateTime(dateTime.year, dateTime.month + 1, 0).day,
    );

    if (dateTime.day >= effectiveStartDay) {
      return [
        dateTime.toStringEx(format: yM),
        DateTime(dateTime.year, dateTime.month + 1, 1).toStringEx(format: yM),
      ];
    }

    return [
      DateTime(dateTime.year, dateTime.month - 1, 1).toStringEx(format: yM),
      dateTime.toStringEx(format: yM),
    ];
  }

  Future<void> onCalenderPageChanged(DateTime fd) async {
    focusedDay.value = fd;
    await onCalenderRefreshEvent(period: fd.toStringEx(format: yM));
    await getCount1Month(fd);
    rpcSpenderDay.value = await repo.rpcGetSpenderDay(fd);
  }

  List<String> onCalenderLoadEvent(DateTime day) {
    final kEvents = LinkedHashMap<DateTime, List<String>>(
      equals: isSameDay,
      hashCode: hashDate,
    );
    kEvents.addAll(events);
    return kEvents[day] ?? [];
  }

  Future<void> onCalenderRefreshEvent({String period = ''}) async {
    events.clear();
    final periodList = _calendarStartDay == 1
        ? [period]
        : _calendarEventPeriods(focusedDay.value);

    for (final itemPeriod in periodList) {
      await repo.getExpenseAll(period: itemPeriod).then((res) {
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
    }

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
      countRemainingBudget.value = sum > 0
          ? (countOfMonth.value / sum * 100).toInt()
          : 0;
    } catch (e) {
      await HelperErrorLog.record(
        page: 'home',
        action: 'getCount1Month',
        stack: e.toString(),
      );
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
      totalSumAllBudget.value = monthlyExpenseByGroup.values.fold(
        0,
        (sum, value) => sum + value.toInt(),
      );
      update();
    } catch (e) {
      await HelperErrorLog.record(
        page: 'home',
        action: 'loadMonthlyExpenseByGroup',
        stack: e.toString(),
      );
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
        final query = find.trim();
        isAdvanceSearch.value = false;
        advanceSearchText.value = '';

        if (startDate != null &&
            endDate != null &&
            !query.startsWith('#') &&
            !query.startsWith(r'$')) {
          isAdvanceSearch.value = true;
          advanceSearchText.value =
              'Showing data from "$startDate - $endDate"';
          final textQuery =
              query.startsWith('@') || query.startsWith('?')
                  ? query.substring(1).trim()
                  : query;
          expenseList.value = await repo.findExpense(
            textQuery,
            startDate: startDate,
            endDate: endDate,
          );
        } else if (query.startsWith('@')) {
          expenseList.value = await repo.findExpenseByCategory(
            query.substring(1).trim(),
          );
        } else if (query.startsWith('#')) {
          final dateQuery = query.substring(1).trim().toLowerCase();
          if (dateQuery == 'today') {
            expenseList.value = await repo.getExpense(
              DateTime.now().toStringEx(format: yMd),
            );
          } else if (dateQuery == 'month') {
            final now = DateTime.now();
            final firstDay = DateTime(now.year, now.month, 1);
            final lastDay = DateTime(now.year, now.month + 1, 0);
            expenseList.value = await repo.findExpenseByDateRange(
              '${firstDay.toStringEx(format: yMd)} ${lastDay.toStringEx(format: yMd)}',
            );
          } else if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateQuery)) {
            expenseList.value = await repo.getExpense(dateQuery);
          } else if (dateQuery.isEmpty) {
            expenseList.clear();
          } else {
            expenseList.value = await repo.findExpenseByDateRange(dateQuery);
          }
        } else if (query.startsWith(r'$')) {
          final amount = num.tryParse(
            query.substring(1).replaceAll(RegExp(r'[^0-9]'), ''),
          );
          expenseList.value = amount == null
              ? []
              : await repo.findExpenseByMinimumAmount(amount);
        } else if (query.startsWith('?')) {
          expenseList.value = await repo.findExpenseText(
            query.substring(1).trim(),
          );
        } else if (query.startsWith(RegExp(r'[0-9]'))) {
          expenseList.value = await repo.findExpenseByDateRange(query);
        } else {
          expenseList.value = await repo.findExpense(query);
        }
        isSearchMode.value = true;
      }
    } catch (e) {
      await HelperErrorLog.record(
        page: 'home',
        action: 'getExpense',
        stack: e.toString(),
      );
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
    Get.toNamed(
      Routes.SUMMARY,
      parameters: {'period': focusedDay.value.toStringEx(format: yM)},
    );
  }

  void goSetting() {
    Get.toNamed(Routes.SETTINGS);
  }

  int get focusedMonthDays => dayInMonth(focusedDay.value);

  bool get isFocusedCurrentMonth {
    final now = DateTime.now();
    return focusedDay.value.year == now.year &&
        focusedDay.value.month == now.month;
  }

  int get elapsedDaysForForecast {
    if (isFocusedCurrentMonth)
      return DateTime.now().day.clamp(1, focusedMonthDays);
    return focusedMonthDays;
  }

  int get remainingDaysForForecast {
    if (isFocusedCurrentMonth)
      return (focusedMonthDays - DateTime.now().day).clamp(0, focusedMonthDays);
    return 0;
  }

  num get projectedMonthSpend {
    if (countOfMonth.value <= 0) return 0;
    return countOfMonth.value / elapsedDaysForForecast * focusedMonthDays;
  }

  num get projectedBudgetDelta => totalAllBudget.value - projectedMonthSpend;

  int get projectedBudgetPercent {
    final budget = totalAllBudget.value;
    if (budget <= 0) return 0;
    final value = projectedMonthSpend / budget * 100;
    return value.isFinite ? value.clamp(0, 999).round() : 0;
  }

  num get dailyAllowance {
    final remainingBudget = totalAllBudget.value - countOfMonth.value;
    final days = remainingDaysForForecast;
    if (remainingBudget <= 0 || days <= 0) return 0;
    return remainingBudget / days;
  }

  int get budgetWarningCount {
    var count = 0;
    for (final budget in budgetsList) {
      final category = resolveExpenseCategory(budget.categoryCode);
      final budgetAmount = budget.amount ?? 0;
      final spent = monthlyExpenseByGroup[category.code] ?? 0;
      if (budgetAmount > 0 && spent / budgetAmount >= 0.8) count++;
    }
    return count;
  }

  List<MapEntry<ExpenseCategory, num>> get unbudgetedCategorySpending {
    final budgetedCodes = budgetsList
        .map((budget) => resolveExpenseCategory(budget.categoryCode).code)
        .toSet();
    final result = <MapEntry<ExpenseCategory, num>>[];

    monthlyExpenseByGroup.forEach((code, total) {
      final category = resolveExpenseCategory(code);
      if (total <= 0) return;
      if (category.code == 'expense:misc:notes') return;
      if (!budgetedCodes.contains(category.code)) {
        result.add(MapEntry(category, total));
      }
    });

    result.sort((a, b) => b.value.compareTo(a.value));
    return result;
  }

  List<UpcomingRepeatTransaction> get upcomingRepeatTransactions {
    final now = DateTime.now();
    final result = <UpcomingRepeatTransaction>[];

    for (final item in cronList) {
      if (item.active == false) continue;
      final parsed = UpcomingRepeatTransaction.fromCron(item, now: now);
      if (parsed == null) continue;
      if (parsed.dueDate.difference(now).inDays <= 31) {
        result.add(parsed);
      }
    }

    result.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return result;
  }

  @override
  void onClose() {
    unawaited(HomeRT.dispose());
    tfSearchExpense.value.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }
}

class UpcomingRepeatTransaction {
  final String note;
  final ExpenseCategory category;
  final num amount;
  final DateTime dueDate;

  UpcomingRepeatTransaction({
    required this.note,
    required this.category,
    required this.amount,
    required this.dueDate,
  });

  int get remainingDays {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays;
  }

  static UpcomingRepeatTransaction? fromCron(
    SupaCron cron, {
    required DateTime now,
  }) {
    final schedule = SupaCronSchedule.parse(cron.schedule);
    if (schedule == null) return null;

    final valuesMatch = RegExp(
      r"values\s*\('([^']*)',\s*'([^']*)',\s*([0-9.]+)",
      caseSensitive: false,
    ).firstMatch(cron.command ?? '');
    if (valuesMatch == null) return null;

    final note = valuesMatch.group(1) ?? cron.jobname ?? '';
    final categoryRaw = (valuesMatch.group(2) ?? '').split('#').first.trim();
    final amount = num.tryParse(valuesMatch.group(3) ?? '0') ?? 0;

    return UpcomingRepeatTransaction(
      note: note,
      category: resolveExpenseCategory(categoryRaw),
      amount: amount,
      dueDate: schedule.nextRun(from: now),
    );
  }
}
