import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/app_setting.dart';
import '../../core/const.dart';
import '../../helpers/helper_misc.dart';
import '../../helpers/helper_money.dart';
import '../../models/rpc_sum_all_month_entity.dart';
import '../../models/rpc_sum_note_times_entity.dart';
import '../../models/supa_category_entity.dart';
import '../../models/supa_expense_entity.dart';
import '../../routes/app_pages.dart';
import '../home/home_controller.dart';
import 'agent_controller.dart';
import 'summary_repository.dart';

class SummaryController extends GetxController with StateMixin {
  // repo
  final repo = Get.find<SummaryRepository>();
  AgentController get agent => Get.find<AgentController>();
  RxBool get isAIAnalysisRunning => agent.isAIAnalysisRunning;

  // calander
  final yearSelected = DateTime.now().toStringEx(format: 'y').obs;
  final monthSelected = DateTime.now().toStringEx(format: 'MMMM').obs;

  final dayRemaining = 0.obs;

  // data
  final rpcSumAllMonth = <RpcSumAllMonth>[].obs; // for sidemenu
  final rpcSumNoteTimes = <RpcSumNoteTimes>[].obs; // for noteTimes perMonth
  final categorySummaries = <CategorySpendSummary>[].obs;
  final expenses = <SupaExpense>[].obs;
  final highSpender = <SupaExpense>[].obs;

  // count header
  final countBudget = 0.obs;
  final countRemainingBudget = 0.obs;
  final countPercentage = 0.0.obs;
  final countOnly1Month = 0.obs;
  final countOnly1Year = 0.obs;
  final countPreviousPeriod = 0.obs;

  // flag
  final isShowAllYear = false.obs;
  final menuSelected = 1.obs;
  final isShowAIAnalysis = false.obs;

  final hasPreviousPeriod = false.obs;

  // !income
  final income = 0.obs;
  final surplus = 0.obs;

  int get _selectedYear =>
      yearSelected.value.toInt() ?? DateTime.now().year;

  int get _selectedMonth {
    return monthSelected.value
            .reformatDate(from: 'MMMM', to: 'MM')
            .toInt() ??
        DateTime.now().month;
  }

  int get calendarStartDay => pref.read<int>(kCalendarStartDay) ?? 1;

  ({DateTime start, DateTime end}) get selectedPeriod => isShowAllYear.isTrue
      ? expensePeriodForYear(_selectedYear, calendarStartDay)
      : expensePeriodForMonth(_selectedYear, _selectedMonth, calendarStartDay);

  String get selectedPeriodLabel {
    final period = selectedPeriod;
    return '${period.start.toStringEx(format: 'd MMM')} – ${period.end.subtract(1.days).toStringEx(format: 'd MMM y')}';
  }

  bool get isCurrentSelectedMonth {
    if (isShowAllYear.isTrue) return false;
    final now = DateTime.now();
    final period = selectedPeriod;
    return !now.isBefore(period.start) && now.isBefore(period.end);
  }

  bool get _isCurrentSelectedYear {
    if (isShowAllYear.isFalse) return false;
    final now = DateTime.now();
    final period = selectedPeriod;
    return !now.isBefore(period.start) && now.isBefore(period.end);
  }

  num get selectedPeriodTotal {
    return isShowAllYear.isTrue
        ? countOnly1Year.value
        : countOnly1Month.value;
  }

  int get _daysInSelectedPeriod {
    return selectedPeriod.end.difference(selectedPeriod.start).inDays;
  }

  int get _elapsedDaysInSelectedPeriod {
    final now = DateTime.now();
    final period = selectedPeriod;
    if (_isCurrentSelectedYear || isCurrentSelectedMonth) {
      return DateUtils.dateOnly(now).difference(period.start).inDays + 1;
    }
    if (period.start.isAfter(DateUtils.dateOnly(now))) return 0;
    return _daysInSelectedPeriod;
  }

  num get dailyAverageSpend {
    final days = _elapsedDaysInSelectedPeriod;
    return days > 0 ? selectedPeriodTotal / days : 0;
  }

  int get activeDays => expenses.length;

  int get inactiveDays =>
      (_elapsedDaysInSelectedPeriod - activeDays)
          .clamp(0, _daysInSelectedPeriod)
          .toInt();

  num get projectedPeriodSpend {
    if (!isCurrentSelectedMonth) return selectedPeriodTotal;
    final days = _elapsedDaysInSelectedPeriod;
    return days > 0
        ? selectedPeriodTotal / days * _daysInSelectedPeriod
        : selectedPeriodTotal;
  }

  num get dailySafeAllowance {
    if (!isCurrentSelectedMonth ||
        countRemainingBudget.value <= 0 ||
        dayRemaining.value <= 0) {
      return 0;
    }
    return countRemainingBudget.value / dayRemaining.value;
  }

  double get budgetPacePercentage {
    if (isShowAllYear.isTrue || countBudget.value <= 0) return 0;
    final value = projectedPeriodSpend / countBudget.value * 100;
    return value.isFinite ? value.clamp(0, 999).toDouble() : 0;
  }

  num? get previousPeriodTotalValue {
    return hasPreviousPeriod.isTrue ? countPreviousPeriod.value : null;
  }

  num? get periodTrendDelta {
    final previous = previousPeriodTotalValue;
    return previous == null ? null : selectedPeriodTotal - previous;
  }

  double? get periodTrendPercentage {
    final previous = previousPeriodTotalValue;
    final delta = periodTrendDelta;
    if (previous == null || previous <= 0 || delta == null) return null;
    return delta / previous * 100;
  }

  String get previousPeriodLabel {
    if (isShowAllYear.isTrue) {
      final previous = expensePeriodForYear(
        _selectedYear - 1,
        calendarStartDay,
      );
      return '${previous.start.toStringEx(format: 'd MMM y')} – ${previous.end.subtract(1.days).toStringEx(format: 'd MMM y')}${_isCurrentSelectedYear ? ' (durasi berjalan sama)' : ''}';
    }
    final previous = expensePeriodForMonth(
      _selectedYear,
      _selectedMonth - 1,
      calendarStartDay,
    );
    final label = '${previous.start.toStringEx(format: 'd MMM')} – ${previous.end.subtract(1.days).toStringEx(format: 'd MMM y')}';
    return '$label${isCurrentSelectedMonth ? ' (durasi berjalan sama)' : ''}';
  }

  String get periodDecisionTitle {
    if (selectedPeriodTotal <= 0) return 'Belum ada data pengeluaran';
    if (isCurrentSelectedMonth && countBudget.value > 0) {
      return projectedPeriodSpend > countBudget.value
          ? 'Berisiko melebihi budget'
          : 'Masih aman';
    }
    final delta = periodTrendDelta;
    if (delta == null || delta == 0) return 'Pengeluaran tetap stabil';
    return delta > 0 ? 'Pengeluaran naik' : 'Pengeluaran turun';
  }

  String get periodDecisionBody {
    if (selectedPeriodTotal <= 0) {
      return 'Belum ada transaksi di periode ini. Coba tanya ditdhewAI soal periode lain atau seluruh riwayat.';
    }

    final topCategory = categorySummaries.isEmpty
        ? ''
        : ' Pengeluaran terbesar: ${categorySummaries.first.resolvedCategory.label} sebesar ${categorySummaries.first.total.moneyFormatCompact()}.';
    if (isCurrentSelectedMonth && countBudget.value > 0) {
      final delta = countBudget.value - projectedPeriodSpend;
      return 'Proyeksi akhir periode ${projectedPeriodSpend.moneyFormatCompact()}, ${delta >= 0 ? '${delta.moneyFormatCompact()} di bawah' : '${delta.abs().moneyFormatCompact()} di atas'} budget.$topCategory';
    }

    final delta = periodTrendDelta;
    final percentage = periodTrendPercentage;
    if (delta != null) {
      if (delta == 0) {
        return 'Pengeluaran sama dengan $previousPeriodLabel.$topCategory';
      }
      final percentageLabel = percentage == null
          ? ''
          : ' (${percentage.abs().toStringAsFixed(0)}%)';
      return '${delta.abs().moneyFormatCompact()}$percentageLabel ${delta >= 0 ? 'lebih tinggi' : 'lebih rendah'} dari $previousPeriodLabel.$topCategory';
    }
    return 'Pengeluaran periode ini ${selectedPeriodTotal.moneyFormatCompact()}.$topCategory';
  }

  String get monthlySummaryText {
    final lines = <String>[
      'Ringkasan $selectedPeriodLabel',
      'Pengeluaran: ${countOnly1Month.value.moneyFormat()}',
    ];
    if (countBudget.value > 0) {
      lines.add('Budget: ${countBudget.value.moneyFormat()}');
      lines.add('Sisa budget: ${countRemainingBudget.value.moneyFormat()}');
    }
    if (categorySummaries.isNotEmpty) {
      final top = categorySummaries.first;
      lines.add(
        'Kategori terbesar: ${top.resolvedCategory.label} (${top.total.moneyFormat()})',
      );
    }
    if (isCurrentSelectedMonth) {
      lines.add('Proyeksi akhir periode: ${projectedPeriodSpend.moneyFormat()}');
    }
    final delta = periodTrendDelta;
    if (delta != null) {
      lines.add(
        'Dibanding $previousPeriodLabel: ${delta >= 0 ? '+' : '-'}${delta.abs().moneyFormat()}',
      );
    }
    return lines.join('\n');
  }

  @override
  Future<void> onInit() async {
    yearSelected.value = Get.parameters['period'].toString().reformatDate(
      from: yM,
      to: 'y',
    );
    monthSelected.value = Get.parameters['period'].toString().reformatDate(
      from: yM,
      to: 'MMMM',
    );
    await getExpenses(year: yearSelected.value, month: monthSelected.value);
    await getSumAllMonth(year: yearSelected.value);
    await getSumNoteTimes(year: yearSelected.value, month: monthSelected.value);
    await calculateBudgetStatForHeader();
    income.value = await repo.getIncome();
    surplus.value = income.value - countOnly1Month.value;
    getDayRemaining();

    change(0, status: RxStatus.success());
    super.onInit();
  }

  void getDayRemaining() {
    dayRemaining.value = remainingDaysForPeriod(
      year: _selectedYear,
      month: _selectedMonth,
      allYear: isShowAllYear.value,
      startDay: calendarStartDay,
    );
  }

  @visibleForTesting
  static int remainingDaysForPeriod({
    required int year,
    required int month,
    required bool allYear,
    int startDay = 1,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    if (allYear) return 0;
    final period = expensePeriodForMonth(year, month, startDay);
    final date = DateUtils.dateOnly(today);
    if (date.isBefore(period.start) || !date.isBefore(period.end)) return 0;
    return period.end.difference(date).inDays;
  }

  Future<void> onMonthChange(String month) async {
    if (isAIAnalysisRunning.isTrue) return;
    closeDrawer();
    change(0, status: RxStatus.loading());
    monthSelected.value = month;
    isShowAllYear.value = false;
    await agent.restoreChatMessages();

    await getExpenses(year: yearSelected.value, month: monthSelected.value);
    await getSumNoteTimes(year: yearSelected.value, month: monthSelected.value);
    await calculateBudgetStatForHeader();
    surplus.value = income.value - countOnly1Month.value;
    getDayRemaining();

    change(0, status: RxStatus.success());
  }

  Future<void> onShowAllYear() async {
    if (isAIAnalysisRunning.isTrue) return;
    change(0, status: RxStatus.loading());
    if (isShowAllYear.value == false) {
      closeDrawer();
      isShowAllYear.value = true;
      monthSelected.value = '';

      await getExpenses(year: yearSelected.value);
      await getSumNoteTimes(year: yearSelected.value);
    } else {
      isShowAllYear.value = false;
      final currentLabel = expensePeriodForDate(
        DateTime.now(),
        calendarStartDay,
      ).end.subtract(1.days);
      yearSelected.value = currentLabel.toStringEx(format: 'yyyy');
      monthSelected.value = currentLabel.toStringEx(format: 'MMMM');
      await getSumAllMonth(year: yearSelected.value);
      await getExpenses(
        year: yearSelected.value,
        month: monthSelected.value,
      );
      await getSumNoteTimes(
        year: yearSelected.value,
        month: monthSelected.value,
      );
    }

    await agent.restoreChatMessages();
    await calculateBudgetStatForHeader();
    surplus.value = income.value - countOnly1Month.value;
    getDayRemaining();
    change(0, status: RxStatus.success());
  }

  Future<void> onYearPrev() async {
    if (isAIAnalysisRunning.isTrue) return;
    change(0, status: RxStatus.loading());
    yearSelected.value = (yearSelected.value.toInt()! - 1).toString();
    await agent.restoreChatMessages();

    await getSumAllMonth(year: yearSelected.value);

    if (isShowAllYear.isFalse) {
      await getExpenses(
        year: yearSelected.value,
        month: monthSelected.value,
      );
      await getSumNoteTimes(
        year: yearSelected.value,
        month: monthSelected.value,
      );
    } else {
      await getExpenses(year: yearSelected.value);
      await getSumNoteTimes(year: yearSelected.value);
    }

    await calculateBudgetStatForHeader();
    surplus.value = income.value - countOnly1Month.value;
    getDayRemaining();
    change(0, status: RxStatus.success());
  }

  Future<void> onYearNow() async {
    if (isAIAnalysisRunning.isTrue) return;
    change(0, status: RxStatus.loading());
    isShowAllYear.value = false;
    final currentLabel = expensePeriodForDate(
      DateTime.now(),
      calendarStartDay,
    ).end.subtract(1.days);
    yearSelected.value = currentLabel.toStringEx(format: 'yyyy');
    monthSelected.value = currentLabel.toStringEx(format: 'MMMM');
    await agent.restoreChatMessages();
    await getSumAllMonth(year: yearSelected.value);
    await getExpenses(
      year: yearSelected.value,
      month: monthSelected.value,
    );
    await getSumNoteTimes(
      year: yearSelected.value,
      month: monthSelected.value,
    );
    await calculateBudgetStatForHeader();
    surplus.value = income.value - countOnly1Month.value;
    getDayRemaining();
    change(0, status: RxStatus.success());
  }

  Future<void> onYearNext() async {
    if (isAIAnalysisRunning.isTrue) return;
    change(0, status: RxStatus.loading());
    yearSelected.value = (yearSelected.value.toInt()! + 1).toString();
    await agent.restoreChatMessages();
    await getSumAllMonth(year: yearSelected.value);

    if (isShowAllYear.isFalse) {
      await getExpenses(
        year: yearSelected.value,
        month: monthSelected.value,
      );
      await getSumNoteTimes(
        year: yearSelected.value,
        month: monthSelected.value,
      );
    } else {
      await getExpenses(year: yearSelected.value);
      await getSumNoteTimes(year: yearSelected.value);
    }

    await calculateBudgetStatForHeader();
    surplus.value = income.value - countOnly1Month.value;
    getDayRemaining();
    change(0, status: RxStatus.success());
  }

  Future<void> getExpenses({required String year, String? month}) async {
    final selectedYear = year.toInt() ?? DateTime.now().year;
    final selectedMonth = month
        ?.reformatDate(from: 'MMMM', to: 'MM')
        .toInt();
    final period = selectedMonth == null
        ? expensePeriodForYear(selectedYear, calendarStartDay)
        : expensePeriodForMonth(
            selectedYear,
            selectedMonth,
            calendarStartDay,
          );
    final previousPeriod = selectedMonth == null
        ? expensePeriodForYear(selectedYear - 1, calendarStartDay)
        : expensePeriodForMonth(
            selectedYear,
            selectedMonth - 1,
            calendarStartDay,
          );
    final fetched = await repo.getExpenses(period.start, period.end);
    try {
      final previous = comparablePreviousExpenses(
        await repo.getExpenses(previousPeriod.start, previousPeriod.end),
        selectedYear: selectedYear,
        selectedMonth: selectedMonth,
        startDay: calendarStartDay,
      );
      countPreviousPeriod.value = previous.fold<int>(
        0,
        (total, item) => total + (item.amount ?? 0).toInt(),
      );
      hasPreviousPeriod.value = true;
    } catch (error) {
      logW('Previous period comparison unavailable: $error');
      countPreviousPeriod.value = 0;
      hasPreviousPeriod.value = false;
    }
    _recalculateCategorySummaries(fetched);

    /// grouping expenses by date
    final _expensesByDate = <String, List<SupaExpense>>{};
    for (var e in fetched) {
      final date = e.date;
      if (date == null || date.isEmpty) continue;
      if (_expensesByDate.containsKey(date)) {
        _expensesByDate[date]!.add(e);
      } else {
        _expensesByDate[date] = [e];
      }
    }

    /// apply group by date to expenses
    expenses.clear();
    _expensesByDate.forEach((key, value) {
      final _total = value.fold<num>(
        0,
        (total, item) => total + (item.amount ?? 0),
      );
      expenses.add(SupaExpense(date: key, amount: _total));
    });

    /// add data to expenseHigh by kFlagSpender from pref
    final isHigh = pref.read<num>(kFlagSpender) ?? 100000;
    highSpender.clear();
    for (var e in expenses) {
      if ((e.amount ?? 0) > isHigh) {
        highSpender.add(SupaExpense(date: e.date, amount: e.amount));
      }
    }

    /// sort expenseHigh by amount
    final sortByAmount = highSpender.sortedBy(
      (a, b) => (b.amount ?? 0).compareTo(a.amount ?? 0),
    );
    highSpender.value = sortByAmount;
  }

  @visibleForTesting
  static List<SupaExpense> comparablePreviousExpenses(
    List<SupaExpense> source, {
    required int selectedYear,
    int? selectedMonth,
    int startDay = 1,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final currentPeriod = selectedMonth == null
        ? expensePeriodForYear(selectedYear, startDay)
        : expensePeriodForMonth(selectedYear, selectedMonth, startDay);
    final date = DateUtils.dateOnly(today);
    final isCurrentPeriod =
        !date.isBefore(currentPeriod.start) && date.isBefore(currentPeriod.end);
    if (!isCurrentPeriod) return source;

    final previousPeriod = selectedMonth == null
        ? expensePeriodForYear(selectedYear - 1, startDay)
        : expensePeriodForMonth(selectedYear, selectedMonth - 1, startDay);
    final elapsed = date.difference(currentPeriod.start).inDays + 1;
    final cutoff = previousPeriod.start.add(
      elapsed
          .clamp(0, previousPeriod.end.difference(previousPeriod.start).inDays)
          .toInt()
          .days,
    );

    return source.where((expense) {
      final date = DateTime.tryParse(expense.date ?? '');
      return date != null && date.isBefore(cutoff);
    }).toList();
  }

  Future<void> getSumAllMonth({required String year}) async {
    rpcSumAllMonth.value = await repo.getSumAllMonth(
      year: year,
      startDay: calendarStartDay,
    );
  }

  Future<void> getSumNoteTimes({required String year, String? month}) async {
    final selectedYear = year.toInt() ?? DateTime.now().year;
    final selectedMonth = month
        ?.reformatDate(from: 'MMMM', to: 'MM')
        .toInt();
    final period = selectedMonth == null
        ? expensePeriodForYear(selectedYear, calendarStartDay)
        : expensePeriodForMonth(
            selectedYear,
            selectedMonth,
            calendarStartDay,
          );
    rpcSumNoteTimes.value = await repo.getSumNoteTimes(
      start: period.start,
      end: period.end,
      startDay: calendarStartDay,
    );
  }

  Future<void> calculateBudgetStatForHeader() async {
    final totalAllYear = rpcSumAllMonth.fold<int>(
      0,
      (total, item) => total + (item.total ?? 0),
    );
    final maxBudget = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>().totalAllBudget.value
        : 0;

    countBudget.value = maxBudget;
    countOnly1Year.value = totalAllYear;
    if (isShowAllYear.isTrue) {
      countOnly1Month.value = 0;
      countRemainingBudget.value = 0;
      countPercentage.value = 0;
      return;
    }

    final monthTotal = monthTotalFor(
      rpcSumAllMonth,
      year: _selectedYear,
      month: _selectedMonth,
    );
    countOnly1Month.value = monthTotal;
    countRemainingBudget.value = maxBudget - monthTotal;
    countPercentage.value = maxBudget > 0
        ? monthTotal / maxBudget * 100
        : 0;
  }

  @visibleForTesting
  static int monthTotalFor(
    List<RpcSumAllMonth> source, {
    required int year,
    required int month,
  }) {
    final period =
        '$year-${month.toString().padLeft(2, '0')}';
    for (final item in source) {
      if (item.period == period) return item.total ?? 0;
    }
    return 0;
  }

  /// @param: category, startDate, endDate
  void goAdvanceFilter(String categoryName) {
    if (isShowAllYear.isFalse) {
      final period = selectedPeriod;
      Get.toNamed(
        Routes.FILTERING,
        arguments: [
          categoryName,
          _isoDate(period.start),
          _isoDate(period.end.subtract(1.days)),
        ],
      );
    } else {
      final period = selectedPeriod;
      Get.toNamed(
        Routes.FILTERING,
        arguments: [
          categoryName,
          _isoDate(period.start),
          _isoDate(period.end.subtract(1.days)),
        ],
      );
    }
  }

  String _isoDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }



  void _recalculateCategorySummaries(List<SupaExpense> source) {
    final totals = <String, num>{};
    final budgets = <String, num>{};
    if (isShowAllYear.isFalse && Get.isRegistered<HomeController>()) {
      for (final budget in Get.find<HomeController>().budgetsList) {
        final code = resolveExpenseCategory(budget.categoryCode).code;
        final amount = budget.amount ?? 0;
        if (amount > 0) budgets[code] = amount;
      }
    }
    for (final expense in source) {
      final code = resolveExpenseCategory(expense.categoryName).code;
      final amount = expense.amount ?? 0;
      totals.update(code, (value) => value + amount, ifAbsent: () => amount);
    }

    final mapped =
        totals.entries
            .where((entry) => entry.value > 0)
            .map(
              (entry) {
                final budget = budgets[entry.key];
                return CategorySpendSummary(
                  categoryCode: entry.key,
                  total: entry.value,
                  maxBudget: budget,
                  remainingBudget: budget == null
                      ? null
                      : budget - entry.value,
                  usePercentage: budget == null
                      ? null
                      : (entry.value / budget * 100).round(),
                );
              },
            )
            .toList()
          ..sort((a, b) => b.total.compareTo(a.total));

    categorySummaries.value = mapped;
  }
}

class CategorySpendSummary {
  CategorySpendSummary({
    required this.categoryCode,
    required this.total,
    this.maxBudget,
    this.remainingBudget,
    this.usePercentage,
  });

  final String categoryCode;
  final num total;
  final num? maxBudget;
  final num? remainingBudget;
  final int? usePercentage;

  ExpenseCategory get resolvedCategory => resolveExpenseCategory(categoryCode);
}
