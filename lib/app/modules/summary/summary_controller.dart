import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:get/get.dart';

import '../../core/app_setting.dart';
import '../../core/const.dart';
import '../../helpers/helper_misc.dart';
import '../../models/rpc_sum_all_month_entity.dart';
import '../../models/rpc_sum_note_times_entity.dart';
import '../../models/supa_category_entity.dart';
import '../../models/supa_expense_entity.dart';
import '../../routes/app_pages.dart';
import '../home/home_controller.dart';
import '../home/home_repository.dart';
import 'summary_repository.dart';

class SummaryController extends GetxController with StateMixin {
  // repo
  final repo = Get.find<SummaryRepository>();

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

  // flag
  final isShowAllYear = false.obs;
  final menuSelected = 1.obs;
  final isShowAIAnalysis = false.obs;
  final isAIAnalysisRunning = false.obs;

  // chat
  final chatMessages = <Map<String, dynamic>>[].obs;
  final chatInputController = TextEditingController();
  final chatInputFocusNode = FocusNode();
  final chatTemplates = [
    'hitung berapa pengeluaran rata2 ku bulan ini',
    'top 5 pengeluaran terbesar di bulan ini',
    'di kategori apa pengeluaran terbesar di bulan ini',
  ];

  // !income
  final income = 0.obs;
  final surplus = 0.obs;

  @override
  Future<void> onInit() async {
    yearSelected.value = Get.parameters['period'].toString().reformatDate(from: yM, to: 'y');
    monthSelected.value = Get.parameters['period'].toString().reformatDate(from: yM, to: 'MMMM');

    await getExpenses(year: yearSelected.value, month: monthSelected.value);
    await getSumAllMonth(year: yearSelected.value);
    await getSumNoteTimes(year: yearSelected.value, month: monthSelected.value);
    await calculateBudgetStatForHeader();
    income.value = await repo.getIncome();
    surplus.value = income.value - countOnly1Month.value;
    getDayRemaining();

    // Listen to menuSelected changes and focus chat input when menu 5 is selected
    ever(menuSelected, (value) {
      if (value == 5) {
        chatInputFocusNode.requestFocus();
      }
    });

    change(0, status: RxStatus.success());
    super.onInit();
  }

  void getDayRemaining() {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, 1);

    if (now.month == monthSelected.value.reformatDate(from: 'MMMM', to: 'MM').toInt()!) {
      dayRemaining.value = nextMonth.difference(now).inDays;
    } else {
      dayRemaining.value = 0;
    }
  }

  Future<void> onMonthChange(String month) async {
    closeDrawer();
    change(0, status: RxStatus.loading());
    monthSelected.value = month;
    isShowAllYear.value = false;

    await getExpenses(year: yearSelected.value, month: monthSelected.value);
    await getSumNoteTimes(year: yearSelected.value, month: monthSelected.value);
    await calculateBudgetStatForHeader();
    surplus.value = income.value - countOnly1Month.value;
    getDayRemaining();

    await clearChat();
    change(0, status: RxStatus.success());
  }

  Future<void> onShowAllYear() async {
    change(0, status: RxStatus.loading());
    if (isShowAllYear.value == false) {
      closeDrawer();
      isShowAllYear.value = true;
      monthSelected.value = '';

      await getExpenses(year: yearSelected.value);
      await getSumNoteTimes(year: yearSelected.value);
    } else {
      isShowAllYear.value = false;
      monthSelected.value = '${DateTime.now().toStringEx(format: 'MMMM')}';
      await onMonthChange(monthSelected.value);
    }

    await calculateBudgetStatForHeader();
    change(0, status: RxStatus.success());
  }

  Future<void> onYearPrev() async {
    change(0, status: RxStatus.loading());
    yearSelected.value = (yearSelected.value.toInt()! - 1).toString();

    await getSumAllMonth(year: yearSelected.value);

    //
    if (isShowAllYear.isFalse) {
      await onMonthChange(monthSelected.value);
    } else {
      await getExpenses(year: yearSelected.value);
      await getSumNoteTimes(year: yearSelected.value);
    }

    await calculateBudgetStatForHeader();
    change(0, status: RxStatus.success());
  }

  Future<void> onYearNow() async {
    isShowAllYear.value = false;
    yearSelected.value = DateTime.now().toStringEx(format: 'yyyy');
    monthSelected.value = DateTime.now().toStringEx(format: 'MMMM');
    await getSumAllMonth(year: yearSelected.value);
    await onMonthChange(monthSelected.value);
    await calculateBudgetStatForHeader();
  }

  Future<void> onYearNext() async {
    change(0, status: RxStatus.loading());
    yearSelected.value = (yearSelected.value.toInt()! + 1).toString();
    await getSumAllMonth(year: yearSelected.value);

    //
    if (isShowAllYear.isFalse) {
      await onMonthChange(monthSelected.value);
    } else {
      await getExpenses(year: yearSelected.value);
      await getSumNoteTimes(year: yearSelected.value);
    }

    await calculateBudgetStatForHeader();
    change(0, status: RxStatus.success());
  }

  Future<void> getExpenses({required String year, String? month}) async {
    final fetched = await repo.getExpenses(year: year, month: month);
    _recalculateCategorySummaries(fetched);

    /// grouping expenses by date
    final _expensesByDate = <String, List<SupaExpense>>{};
    for (var e in fetched) {
      if (_expensesByDate.containsKey(e.date!)) {
        _expensesByDate[e.date!]!.add(e);
      } else {
        _expensesByDate[e.date!] = [e];
      }
    }

    /// apply group by date to expenses
    expenses.clear();
    _expensesByDate.forEach((key, value) {
      final _total = value.map((e) => e.amount!).reduce((a, b) => a + b);
      expenses.add(SupaExpense(date: key, amount: _total));
    });

    /// add data to expenseHigh by kFlagSpender from pref
    final isHigh = pref.read<num>(kFlagSpender) ?? 100000;
    if (expenses.isNotEmpty) {
      highSpender.clear();
      for (var e in expenses) {
        if (e.amount! > isHigh) {
          highSpender.add(SupaExpense(date: e.date, amount: e.amount));
        }
      }
    }

    /// sort expenseHigh by amount
    final sortByAmount = highSpender.sortedBy((a, b) => b.amount!.compareTo(a.amount!));
    highSpender.value = sortByAmount;
  }

  Future<void> getSumAllMonth({required String year}) async {
    rpcSumAllMonth.value = await repo.getSumAllMonth(year: year);
  }

  Future<void> getSumNoteTimes({required String year, String? month}) async {
    rpcSumNoteTimes.value = await repo.getSumNoteTimes(year: year, month: month);
  }

  Future<void> calculateBudgetStatForHeader() async {
    /// set value for header
    final _month = 0.obs;
    final _totalAllyear = 0.obs;
    final _maxBudget = 0.obs;
    final _percentage = 0.0.obs;
    final _remainingBudget = 0.obs;

    /// formula...
    rpcSumAllMonth.forEach((element) {
      if (element.total != null) _totalAllyear.value = _totalAllyear.value + element.total!;
    });

    _maxBudget.value = Get.find<HomeController>().totalAllBudget.value;

    if (isShowAllYear.isFalse) {
      _month.value = monthSelected.value.reformatDate(from: 'MMMM', to: 'MM').toInt()! - 1;
    }

    _remainingBudget.value = _maxBudget.value - rpcSumAllMonth[_month.value].total!;

    if (_maxBudget.value.isZero) {
      _percentage.value = 0;
    } else {
      _percentage.value = rpcSumAllMonth[_month.value].total! / _maxBudget.value * 100;
    }

    /// apply
    countBudget.value = _maxBudget.value;
    countRemainingBudget.value = _remainingBudget.value;
    countPercentage.value = _percentage.value;
    countOnly1Month.value = rpcSumAllMonth[_month.value].total ?? 0;
    countOnly1Year.value = _totalAllyear.value;
  }

  /// @param: category, startDate, endDate
  void goAdvanceFilter(String categoryName) {
    if (isShowAllYear.isFalse) {
      Get.toNamed(
        Routes.FILTERING,
        arguments: [
          categoryName,
          '${yearSelected.value}-${monthSelected.value.reformatDate(from: 'MMMM', to: 'MM')}-01',
          '${yearSelected.value}-${monthSelected.value.reformatDate(from: 'MMMM', to: 'MM')}-31',
        ],
      );
    } else {
      Get.toNamed(
        Routes.FILTERING,
        arguments: [
          categoryName,
          '${yearSelected.value}-01-01',
          '${yearSelected.value}-12-31',
        ],
      );
    }
  }

  Future<void> clearChat() async {
    chatMessages.clear();
    chatInputFocusNode.requestFocus();
  }

  Future<void> sendMessage() async {
    final message = chatInputController.text.trim();
    if (message.isEmpty) return;

    // Add user message
    chatMessages.add({'text': message, 'isUser': true});

    // Clear input
    chatInputController.clear();

    // Prepare data for AI

    var dataExpense = <SupaExpense>[];
    final dataBudget = Get.find<HomeController>().budgetsList;
    final dataPersonal = await repo.getUserProfile();
    final dataGoals = await Get.find<HomeRepository>().getGoals();
    final dataCron = await repo.getCron();

    if (isShowAllYear.isTrue) {
      dataExpense = await repo.getExpenses(year: yearSelected.value);
    } else {
      dataExpense = await repo.getExpenses(year: yearSelected.value, month: monthSelected.value);
    }

    final dataExpenseSend = [];
    final dataBudgetSend = [];
    final dataPersonalSend = [];
    final dataGoalsSend = [];
    final dataCronSend = [];

    // Map<String, num> totalAmountByDate = {};
    // for (var item in dataExpense) {
    //   var date = item.date!;
    //   var amount = item.amount;
    //   if (totalAmountByDate.containsKey(date)) {
    //     totalAmountByDate[date] = totalAmountByDate[date]! + amount!;
    //   } else {
    //     totalAmountByDate[date] = amount ?? 0;
    //   }
    // }
    // var sortedResults = totalAmountByDate.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    // for (var entry in sortedResults) {
    //   dataExpenseSend.add({
    //     'date': entry.key,
    //     'amount': entry.value,
    //   });
    // }

    dataExpense.forEach((el) {
      final item = el;
      final category = resolveExpenseCategory(item.categoryName);
      dataExpenseSend.add({
        'date': item.date,
        'category': category.label,
        'note': item.note,
        'detail': item.detail ?? '',
        'amount': item.amount,
      });
    });

    dataBudget.forEach((el) {
      final item = el;
      final category = resolveExpenseCategory(item.categoryCode);
      final spent = Get.find<HomeController>().monthlyExpenseByGroup[category.code] ?? 0;
      final budgetAmount = item.amount ?? 0;
      final percent = budgetAmount > 0 ? (spent.toDouble() / budgetAmount) * 100 : 0.0;
      dataBudgetSend.add({
        'category': category.label,
        'budget': budgetAmount,
        'spent': spent,
        'use_percentage': '${percent.toInt()}%',
      });
    });

    dataPersonal.forEach((el) {
      dataPersonalSend.add({
        'name': el.fullName,
        'age': el.age,
        'payment_day': el.paymentDay,
        'income': el.income,
        'eco_day': el.ecoDay,
        'average_day': el.averageDay,
        'spender_day': el.spenderDay,
      });
    });

    dataGoals.forEach((el) {
      dataGoalsSend.add({
        'goal_name': el.title,
        'current_date': DateTime.now().toStringEx(format: yMd),
        'due_date': el.releaseDate,
        'balance': el.amount,
        'target': el.target,
      });
    });

    dataCron.forEach((el) {
      final command = el.command ?? '';
      final valuesRegex = RegExp(r"VALUES\s*\('([^']*)',\s*'([^']*)',\s*(\d+)");
      final match = valuesRegex.firstMatch(command);

      final note = match?.group(1) ?? '';
      final categoryFull = match?.group(2) ?? '';
      final categoryName = categoryFull.split('#').first.trim();
      final amount = num.tryParse(match?.group(3) ?? '0') ?? 0;
      final dueDate = el.schedule.allBetween('0 0 ', ' * *');

      dataCronSend.add({
        'cron_due_date': dueDate,
        'cron_note': note,
        'cron_category': resolveExpenseCategory(categoryName).label,
        'cron_amount': amount,
      });
    });

    // Add temporary AI message
    chatMessages.add({'text': 'Thinking...', 'isUser': false});

    final aiMessageIndex = chatMessages.length - 1;
    String aiResponse = '';

    // print('dataExpenseSend: $dataExpenseSend', name: 'xLOG');
    // print('dataBudgetSend: $dataBudgetSend', name: 'xLOG');
    // print('dataPersonalSend: $dataPersonalSend', name: 'xLOG');
    // print('dataGoalsSend: $dataGoalsSend', name: 'xLOG');
    // print('dataCronSend: $dataCronSend', name: 'xLOG');
    // return;

    // Stream AI response
    gemini
        .streamChat(
          [
            Content(
              role: 'model',
              parts: [
                Part.text('You are an assistant that helps users manage their budgets, expenses, and financial goals effectively.'),
                Part.text('Here is the user profile:'),
                Part.text('$dataPersonalSend'),
                Part.text('Important rules: Never expose private financial data (like income or balance) in your responses. You may mention only nickname and age if relevant.'),
                Part.text('User budget data:'),
                Part.text('$dataBudgetSend'),
                Part.text('User expense data:'),
                Part.text('$dataExpenseSend'),
                Part.text('User goals data:'),
                Part.text('$dataGoalsSend'),
                Part.text('User cron data (recurring monthly payments):'),
                Part.text('$dataCronSend'),
                Part.text('Your tone must mix Indonesian and English slang naturally — with a BETAWI vibe (casual, friendly, a bit playful).'),
                Part.text('Never use italic font in responses.'),
                Part.text('Keep spacing natural, like casual chat — it’s okay if not perfectly formatted.'),
              ],
            ),
            Content(
              role: 'user',
              parts: [
                Part.text(message),
              ],
            ),
          ],
        )
        .listen(
          (ai) {
            aiResponse += ai.output ?? '';
            chatMessages[aiMessageIndex] = {
              'text': aiResponse,
              'isUser': false,
            };
          },
          onDone: () => chatInputFocusNode.requestFocus(),
          onError: (error) {
            chatMessages[aiMessageIndex] = {
              'text': 'Maaf, terjadi kesalahan. Coba lagi nanti.',
              'isUser': false,
            };
          },
        );
  }

  @override
  void onClose() {
    chatInputController.dispose();
    chatInputFocusNode.dispose();
    super.onClose();
  }

  void _recalculateCategorySummaries(List<SupaExpense> source) {
    final totals = <String, num>{};
    for (final expense in source) {
      final code = resolveExpenseCategory(expense.categoryName).code;
      final amount = expense.amount ?? 0;
      totals.update(code, (value) => value + amount, ifAbsent: () => amount);
    }

    final mapped = totals.entries.where((entry) => entry.value > 0).map((entry) => CategorySpendSummary(categoryCode: entry.key, total: entry.value)).toList()
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
