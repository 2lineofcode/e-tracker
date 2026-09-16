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
import '../../models/supa_expense_entity.dart';
import '../../models/supa_goals_entity.dart';
import '../../models/supa_notes_entity.dart';
import '../../models/supa_recurring_expense_entity.dart';
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
  final assetSnapshots = <SupaAssetSnapshot>[].obs;
  final totalAssets = 0.obs;

  /// goals & notes
  final goalsList = <SupaGoals>[].obs;
  final notesList = <SupaNotes>[].obs;
  final recurringList = <SupaRecurringExpense>[].obs;

  /// expense
  final userProfile = SupaUserProfile().obs;
  final expenseList = <SupaExpense>[].obs;
  final recentExpenses = <SupaExpense>[].obs;
  final tfSearchExpense = TextEditingController().obs;
  final searchFocusNode = FocusNode();

  final budgetSuggestions = <String, num>{}.obs;

  /// count
  final countOfDay = 0.0.obs;
  final countOfMonth = 0.obs;
  final payCycleExpense = 0.obs;
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
    await onCalenderRefreshEvent();
    await loadAssetsSummary();
    await loadGoalsList();
    await loadNotesList();
    await loadRecurringList();
    await loadRecentExpenses();
    await loadBudgetSuggestions();

    final period = focusedPeriod;
    rpcSpenderDay.value = await repo.rpcGetSpenderDay(period.start, period.end);
    userProfile.value = await repo.getUserProfile().then((value) => value[0]);
    await loadPayCycleExpense();
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
      assetSnapshots.assignAll(await repo.getAssetSnapshots());
      if (assets.isNotEmpty && assetSnapshots.isEmpty) {
        await saveAssetSnapshot();
      }
    } catch (e) {
      await HelperErrorLog.record(
        page: 'home',
        action: 'loadAssetsSummary',
        stack: e.toString(),
      );
      assetsList.clear();
      totalAssets.value = 0;
      assetSnapshots.clear();
    }
  }

  Future<void> saveAssetSnapshot() async {
    await repo.saveAssetSnapshot(totalAssets.value);
    assetSnapshots.assignAll(await repo.getAssetSnapshots());
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

  Future<void> loadRecurringList() async {
    try {
      final recurring = await repo.getRecurringExpenses();
      recurringList.assignAll(recurring);
    } catch (e) {
      await HelperErrorLog.record(
        page: 'home',
        action: 'loadRecurringList',
        stack: e.toString(),
      );
      recurringList.clear();
    }
    update();
  }

  Future<void> loadRecentExpenses() async {
    try {
      recentExpenses.assignAll(await repo.getRecentExpenses());
    } catch (e) {
      await HelperErrorLog.record(
        page: 'home',
        action: 'loadRecentExpenses',
        stack: e.toString(),
      );
      recentExpenses.clear();
    }
  }

  List<SupaExpense> merchantSuggestions(String input) {
    final query = input.trim().toLowerCase();
    if (query.length < 2) return [];

    final seen = <String>{};
    return recentExpenses.where((expense) {
      final note = expense.note?.trim() ?? '';
      final detail = expense.detail?.trim() ?? '';
      final normalizedNote = note.toLowerCase();
      final normalizedDetail = detail.toLowerCase();
      if (note.isEmpty ||
          (expense.amount ?? 0) <= 0 ||
          (!normalizedNote.contains(query) &&
              !normalizedDetail.contains(query))) {
        return false;
      }
      return seen.add('$normalizedNote|$normalizedDetail');
    }).take(5).toList();
  }

  int get noSpendStreak => calculateNoSpendStreak(recentExpenses);

  DateTime get budgetSuggestionMonth {
    final now = DateTime.now();
    final currentLabel = expensePeriodForDate(
      now,
      _calendarStartDay,
    ).end.subtract(1.days);
    return DateTime(currentLabel.year, currentLabel.month + 1, 1);
  }

  Future<void> loadBudgetSuggestions() async {
    try {
      final expenses = await repo.getBudgetSuggestionExpenses(
        budgetSuggestionMonth,
        _calendarStartDay,
      );
      budgetSuggestions.assignAll(
        calculateBudgetSuggestions(
          expenses,
          budgetSuggestionMonth,
          startDay: _calendarStartDay,
        ),
      );
    } catch (e) {
      await HelperErrorLog.record(
        page: 'home',
        action: 'loadBudgetSuggestions',
        stack: e.toString(),
      );
      budgetSuggestions.clear();
    }
  }

  List<SupaRecurringExpense> recurringExpensesForDay(DateTime day) {
    return recurringList.where((item) {
      final dueDate = recurringDateInMonth(item, day);
      return dueDate != null && isSameDay(dueDate, day);
    }).toList();
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
    await onCalenderGoDate(DateTime.now());
    closeDrawer();
  }

  Future<void> onCalenderGoDate(DateTime dateTime) async {
    selectedDays.clear();
    focusedDay.value = dateTime;
    selectedDays.add(dateTime);
    await getExpense();
    await getCount1Month(focusedDay.value);
    await onCalenderRefreshEvent();
    final period = focusedPeriod;
    rpcSpenderDay.value = await repo.rpcGetSpenderDay(period.start, period.end);
  }

  Future<void> onCalenderGoPrevMonth() async {
    if (_calendarStartDay != 1) {
      final current = focusedDay.value;
      await onCalenderGoDate(_shiftFocusedMonth(current, -1));
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
      return;
    }

    await calenderPageController.nextPage(
      duration: 300.milliseconds,
      curve: Curves.easeIn,
    );
  }

  int get _calendarStartDay => pref.read<int>(kCalendarStartDay) ?? 1;

  ({DateTime start, DateTime end}) get focusedPeriod =>
      expensePeriodForDate(focusedDay.value, _calendarStartDay);

  DateTime get focusedPeriodLabelDate => focusedPeriod.end.subtract(1.days);

  String get focusedPeriodLabel {
    final period = focusedPeriod;
    return '${period.start.toStringEx(format: 'd MMM')} – ${period.end.subtract(1.days).toStringEx(format: 'd MMM y')}';
  }

  DateTime _shiftFocusedMonth(DateTime dateTime, int monthOffset) {
    final target = DateTime(dateTime.year, dateTime.month + monthOffset, 1);
    final targetMonthDays = DateTime(target.year, target.month + 1, 0).day;
    return DateTime(
      target.year,
      target.month,
      dateTime.day.clamp(1, targetMonthDays),
    );
  }

  Future<void> onCalenderPageChanged(DateTime fd) async {
    focusedDay.value = fd;
    await onCalenderRefreshEvent();
    await getCount1Month(fd);
    final period = focusedPeriod;
    rpcSpenderDay.value = await repo.rpcGetSpenderDay(period.start, period.end);
  }

  List<String> onCalenderLoadEvent(DateTime day) {
    final kEvents = LinkedHashMap<DateTime, List<String>>(
      equals: isSameDay,
      hashCode: hashDate,
    );
    kEvents.addAll(events);
    return kEvents[day] ?? [];
  }

  Future<void> onCalenderRefreshEvent() async {
    events.clear();
    final range = focusedPeriod;
    final res = await repo.getExpenseAll(range.start, range.end);
    Map<DateTime, List<String>> groupedData = {};
    for (var item in res) {
      var date = item.date!.toDateEx(format: yMd);
      if (groupedData.containsKey(date)) {
        groupedData[date]!.add('${item.amount}');
      } else {
        groupedData[date] = ['${item.amount}'];
      }
    }
    events.addAll(groupedData);

    update();
  }

  /// count total per period
  Future<void> getCount1Month(DateTime dateTime) async {
    try {
      final period = expensePeriodForDate(dateTime, _calendarStartDay);
      countOfMonth.value = await repo.getExpenseTotal(period.start, period.end);
      if (userProfile.value.id != null) await loadPayCycleExpense();
      await loadMonthlyExpenseByGroup(period.start, period.end);

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

  Future<void> loadMonthlyExpenseByGroup(DateTime start, DateTime end) async {
    try {
      final result = await repo.getExpenseByBudgets(start, end);
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
            !query.startsWith('#')) {
          isAdvanceSearch.value = true;
          advanceSearchText.value =
              'Data dari $startDate sampai $endDate';
          if (query.startsWith(r'$')) {
            final amount = num.tryParse(
              query.substring(1).replaceAll(RegExp(r'[^0-9]'), ''),
            );
            expenseList.value = amount == null
                ? []
                : await repo.findExpenseByMinimumAmount(
                    amount,
                    startDate: startDate,
                    endDate: endDate,
                  );
          } else {
            final textQuery =
                query.startsWith('@') || query.startsWith('?')
                    ? query.substring(1).trim()
                    : query;
            expenseList.value = await repo.findExpense(
              textQuery,
              startDate: startDate,
              endDate: endDate,
            );
          }
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
            final period = expensePeriodForDate(now, _calendarStartDay);
            expenseList.value = await repo.findExpenseByDateRange(
              '${period.start.toStringEx(format: yMd)} ${period.end.subtract(1.days).toStringEx(format: yMd)}',
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
      expenseList.clear();
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
      parameters: {'period': focusedPeriodLabelDate.toStringEx(format: yM)},
    );
  }

  void goSetting() {
    Get.toNamed(Routes.SETTINGS);
  }

  int get focusedMonthDays => focusedPeriod.end.difference(focusedPeriod.start).inDays;

  List<num> get focusedMonthDailyTotals =>
      dailyExpenseTotals(events, focusedPeriod.start, focusedPeriod.end);

  bool get isFocusedCurrentMonth {
    final now = DateTime.now();
    final period = focusedPeriod;
    return !now.isBefore(period.start) && now.isBefore(period.end);
  }

  int get elapsedDaysForForecast {
    if (isFocusedCurrentMonth)
      return DateUtils.dateOnly(DateTime.now())
              .difference(focusedPeriod.start)
              .inDays +
          1;
    return focusedMonthDays;
  }

  int get remainingDaysForForecast {
    if (isFocusedCurrentMonth)
      return focusedPeriod.end
          .difference(DateUtils.dateOnly(DateTime.now()))
          .inDays
          .clamp(0, focusedMonthDays);
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

    for (final item in recurringList) {
      if (item.active == false) continue;
      final parsed = UpcomingRepeatTransaction.fromRecurring(item, now: now);
      if (parsed.dueDate.difference(now).inDays <= 31) {
        result.add(parsed);
      }
    }

    result.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return result;
  }

  int get paymentDay =>
      (userProfile.value.paymentDay ?? 28).toInt().clamp(1, 31).toInt();

  DateTime get currentPayCycleStart =>
      payCycleStartAt(DateTime.now(), paymentDay);

  DateTime get nextPayday => nextPaydayAt(DateTime.now(), paymentDay);

  Future<void> loadPayCycleExpense() async {
    payCycleExpense.value = await repo.getExpenseTotal(
      currentPayCycleStart,
      DateUtils.dateOnly(DateTime.now()).add(1.days),
    );
  }

  num get scheduledBeforePayday => upcomingRepeatTransactions
      .where((item) => !item.dueDate.isAfter(nextPayday))
      .fold<num>(0, (sum, item) => sum + item.amount);

  num get monthlyIncome => userProfile.value.income ?? 0;

  bool get hasCurrentMonthCashflow =>
      isFocusedCurrentMonth && monthlyIncome > 0;

  num get cashAfterScheduledBills =>
      calculateCashUntilPayday(
        monthlyIncome,
        payCycleExpense.value,
        scheduledBeforePayday,
      );

  int get daysUntilPayday => nextPayday
      .difference(DateUtils.dateOnly(DateTime.now()))
      .inDays
      .clamp(0, 366)
      .toInt();

  num get safeDailyUntilPayday => daysUntilPayday <= 0
      ? cashAfterScheduledBills
      : cashAfterScheduledBills / daysUntilPayday;

  @override
  void onClose() {
    unawaited(HomeRT.dispose());
    tfSearchExpense.value.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }
}

num calculateCashUntilPayday(num income, num spent, num scheduled) =>
    income - spent - scheduled;

List<num> dailyExpenseTotals(
  Map<DateTime, List<String>> events,
  DateTime start,
  DateTime end,
) {
  final totals = List<num>.filled(end.difference(start).inDays, 0);
  events.forEach((date, amounts) {
    if (date.isBefore(start) || !date.isBefore(end)) return;
    totals[date.difference(start).inDays] = amounts.fold<num>(
      0,
      (sum, amount) => sum + (num.tryParse(amount) ?? 0),
    );
  });
  return totals;
}

({int activeDays, num average, num highest, int highestDay})
monthlyExpenseStats(List<num> totals) {
  num total = 0;
  var activeDays = 0;
  num highest = 0;
  var highestDay = 0;
  for (var i = 0; i < totals.length; i++) {
    final amount = totals[i];
    total += amount;
    if (amount <= 0) continue;
    activeDays++;
    if (amount > highest) {
      highest = amount;
      highestDay = i + 1;
    }
  }
  return (
    activeDays: activeDays,
    average: activeDays == 0 ? 0 : total / activeDays,
    highest: highest,
    highestDay: highestDay,
  );
}

List<num> weeklyExpenseTotals(List<num> totals) {
  final weeks = List<num>.filled((totals.length + 6) ~/ 7, 0);
  for (var i = 0; i < totals.length; i++) {
    weeks[i ~/ 7] += totals[i];
  }
  return weeks;
}

DateTime paydayAt(int year, int month, int payDay) {
  final lastDay = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, payDay.clamp(1, lastDay).toInt());
}

DateTime payCycleStartAt(DateTime now, int payDay) {
  final today = DateUtils.dateOnly(now);
  final thisMonth = paydayAt(now.year, now.month, payDay);
  if (!thisMonth.isAfter(today)) return thisMonth;
  return paydayAt(now.year, now.month - 1, payDay);
}

DateTime nextPaydayAt(DateTime now, int payDay) {
  final start = payCycleStartAt(now, payDay);
  return paydayAt(start.year, start.month + 1, payDay);
}

int calculateNoSpendStreak(
  List<SupaExpense> expenses, {
  DateTime? now,
}) {
  final today = DateUtils.dateOnly(now ?? DateTime.now());
  DateTime? lastSpend;
  for (final expense in expenses) {
    if ((expense.amount ?? 0) <= 0) continue;
    final date = DateTime.tryParse(expense.date ?? '');
    if (date == null || date.isAfter(today)) continue;
    final spendDate = DateUtils.dateOnly(date);
    if (lastSpend == null || spendDate.isAfter(lastSpend)) {
      lastSpend = spendDate;
    }
  }
  return lastSpend == null ? 0 : today.difference(lastSpend).inDays;
}

DateTime? recurringDateInMonth(
  SupaRecurringExpense recurring,
  DateTime month,
) {
  if (recurring.active == false || recurring.archivedAt != null) return null;
  final interval = (recurring.intervalMonths ?? 1).clamp(1, 12).toInt();
  if ((month.month - (recurring.startMonth ?? 1)) % interval != 0) return null;

  final maxDay = DateTime(month.year, month.month + 1, 0).day;
  final dueDate = DateTime(
    month.year,
    month.month,
    (recurring.dueDay ?? 1).clamp(1, maxDay),
  );
  final createdAt = DateTime.tryParse(recurring.createdAt ?? '');
  if (createdAt != null && dueDate.isBefore(DateUtils.dateOnly(createdAt))) {
    return null;
  }
  return dueDate;
}

Map<String, num> calculateBudgetSuggestions(
  List<SupaExpense> expenses,
  DateTime targetMonth, {
  int startDay = 1,
}) {
  final months = List.generate(
    3,
    (index) => DateTime(targetMonth.year, targetMonth.month - 3 + index, 1),
  );
  final totals = <String, List<num>>{};

  for (final expense in expenses) {
    final date = DateTime.tryParse(expense.date ?? '');
    if (date == null || (expense.amount ?? 0) <= 0) continue;
    final label = expensePeriodForDate(date, startDay).end.subtract(1.days);
    final monthIndex = months.indexWhere(
      (month) => month.year == label.year && month.month == label.month,
    );
    if (monthIndex == -1) continue;
    final code = expense.resolvedCategory.code;
    if (code == 'expense:misc:notes') continue;
    final values = totals.putIfAbsent(code, () => List<num>.filled(3, 0));
    values[monthIndex] += expense.amount ?? 0;
  }

  final suggestions = <String, num>{};
  totals.forEach((code, values) {
    values.sort();
    if (values[1] > 0) suggestions[code] = values[1];
  });
  return suggestions;
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

  static UpcomingRepeatTransaction fromRecurring(
    SupaRecurringExpense recurring, {
    required DateTime now,
  }) {
    return UpcomingRepeatTransaction(
      note: recurring.note ?? '',
      category: resolveExpenseCategory(recurring.categoryName),
      amount: recurring.amount ?? 0,
      dueDate: recurring.nextRun(from: now),
    );
  }
}
