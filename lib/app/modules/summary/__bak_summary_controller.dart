// import 'package:ex_kit/ex.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../core/app_setting.dart';
// import '../../core/const.dart';
// import '../../helpers/helper_misc.dart';
// import '../../models/rpc_sum_all_month_entity.dart';
// import '../../models/rpc_sum_by_category_entity.dart';
// import '../../models/rpc_sum_note_times_entity.dart';
// import '../../models/supa_expense_entity.dart';
// import '../../routes/app_pages.dart';
// import 'summary_repository.dart';

// class SummaryController extends GetxController with StateMixin {
//   // repo
//   final repo = Get.find<SummaryRepository>();

//   // calander
//   final yearSelected = DateTime.now().toStringEx(format: 'y').obs;
//   final monthSelected = DateTime.now().toStringEx(format: 'MMMM').obs;

//   // data
//   final rpcSumAllMonth = <RpcSumAllMonth>[].obs; // for sidemenu
//   final rpcSumByCategory = <RpcSumByCategory>[].obs; // for body
//   final rpcSumNoteTimes = <RpcSumNoteTimes>[].obs; // for noteTimes perMonth
//   final expenses = <SupaExpense>[].obs;
//   final highSpender = <SupaExpense>[].obs;

//   // count header
//   final countBudget = 0.obs;
//   final countRemainingBudget = 0.obs;
//   final countPercentage = 0.0.obs;
//   final countOnly1Month = 0.obs;
//   final countOnly1Year = 0.obs;

//   // flag
//   final isShowAllYear = false.obs;
//   final menuSelected = 1.obs;
//   final isShowAIAnalysis = false.obs;
//   final aiAnalysisOutput = ''.obs;
//   final isAIAnalysisRunning = false.obs;

//   // chat
//   final chatMessages = <Map<String, dynamic>>[].obs;
//   final chatInputController = TextEditingController();
//   final chatInputFocusNode = FocusNode();

//   // !income
//   final income = 0.obs;
//   final surplus = 0.obs;

//   @override
//   Future<void> onInit() async {
//     yearSelected.value = Get.parameters['period'].toString().reformatDate(from: yM, to: 'y');
//     monthSelected.value = Get.parameters['period'].toString().reformatDate(from: yM, to: 'MMMM');

//     await getExpenses(year: yearSelected.value, month: monthSelected.value);
//     await getSumAllMonth(year: yearSelected.value);
//     await getSumByCategory(year: yearSelected.value, month: monthSelected.value);
//     await getSumNoteTimes(year: yearSelected.value, month: monthSelected.value);
//     await calculateBudgetStatForHeader();
//     income.value = await repo.getIncome();
//     surplus.value = income.value - countOnly1Month.value;

//     // Listen to menuSelected changes and focus chat input when menu 5 is selected
//     ever(menuSelected, (value) {
//       if (value == 5) {
//         chatInputFocusNode.requestFocus();
//       }
//     });

//     await setupGroq();
//     change(0, status: RxStatus.success());
//     super.onInit();
//   }

//   Future<void> onMonthChange(String month) async {
//     closeDrawer();
//     change(0, status: RxStatus.loading());
//     monthSelected.value = month;
//     isShowAllYear.value = false;
//     aiAnalysisOutput.value = '';

//     await getExpenses(year: yearSelected.value, month: monthSelected.value);
//     await getSumByCategory(year: yearSelected.value, month: monthSelected.value);
//     await getSumNoteTimes(year: yearSelected.value, month: monthSelected.value);
//     await calculateBudgetStatForHeader();
//     surplus.value = income.value - countOnly1Month.value;

//     await setupGroq();
//     change(0, status: RxStatus.success());
//   }

//   Future<void> onShowAllYear() async {
//     change(0, status: RxStatus.loading());
//     if (isShowAllYear.value == false) {
//       closeDrawer();
//       isShowAllYear.value = true;
//       monthSelected.value = '';

//       await getExpenses(year: yearSelected.value);
//       await getSumByCategory(year: yearSelected.value);
//       await getSumNoteTimes(year: yearSelected.value);
//     } else {
//       isShowAllYear.value = false;
//       monthSelected.value = '${DateTime.now().toStringEx(format: 'MMMM')}';
//       await onMonthChange(monthSelected.value);
//     }

//     await calculateBudgetStatForHeader();
//     change(0, status: RxStatus.success());
//   }

//   Future<void> onYearPrev() async {
//     change(0, status: RxStatus.loading());
//     yearSelected.value = (yearSelected.value.toInt()! - 1).toString();

//     await getSumAllMonth(year: yearSelected.value);

//     //
//     if (isShowAllYear.isFalse) {
//       await onMonthChange(monthSelected.value);
//     } else {
//       await getExpenses(year: yearSelected.value);
//       await getSumByCategory(year: yearSelected.value);
//       await getSumNoteTimes(year: yearSelected.value);
//     }

//     await calculateBudgetStatForHeader();
//     change(0, status: RxStatus.success());
//   }

//   Future<void> onYearNow() async {
//     isShowAllYear.value = false;
//     yearSelected.value = DateTime.now().toStringEx(format: 'yyyy');
//     monthSelected.value = DateTime.now().toStringEx(format: 'MMMM');
//     await getSumAllMonth(year: yearSelected.value);
//     await onMonthChange(monthSelected.value);
//     await calculateBudgetStatForHeader();
//   }

//   Future<void> onYearNext() async {
//     change(0, status: RxStatus.loading());
//     yearSelected.value = (yearSelected.value.toInt()! + 1).toString();
//     await getSumAllMonth(year: yearSelected.value);

//     //
//     if (isShowAllYear.isFalse) {
//       await onMonthChange(monthSelected.value);
//     } else {
//       await getExpenses(year: yearSelected.value);
//       await getSumByCategory(year: yearSelected.value);
//       await getSumNoteTimes(year: yearSelected.value);
//     }

//     await calculateBudgetStatForHeader();
//     change(0, status: RxStatus.success());
//   }

//   Future<void> getExpenses({required String year, String? month}) async {
//     expenses.value = await repo.getExpenses(year: year, month: month);

//     /// grouping expenses by date
//     final _expensesByDate = <String, List<SupaExpense>>{};
//     for (var e in expenses) {
//       if (_expensesByDate.containsKey(e.date!)) {
//         _expensesByDate[e.date!]!.add(e);
//       } else {
//         _expensesByDate[e.date!] = [e];
//       }
//     }

//     /// apply group by date to expenses
//     expenses.clear();
//     _expensesByDate.forEach((key, value) {
//       final _total = value.map((e) => e.amount!).reduce((a, b) => a + b);
//       expenses.add(SupaExpense(date: key, amount: _total));
//     });

//     /// add data to expenseHigh by kFlagSpender from pref
//     final isHigh = pref.read<num>(kFlagSpender) ?? 100000;
//     if (expenses.isNotEmpty) {
//       highSpender.clear();
//       for (var e in expenses) {
//         if (e.amount! > isHigh) {
//           highSpender.add(SupaExpense(date: e.date, amount: e.amount));
//         }
//       }
//     }

//     /// sort expenseHigh by amount
//     final sortByAmount = highSpender.sortedBy((a, b) => b.amount!.compareTo(a.amount!));
//     highSpender.value = sortByAmount;
//   }

//   Future<void> getSumAllMonth({required String year}) async {
//     rpcSumAllMonth.value = await repo.getSumAllMonth(year: year);
//   }

//   Future<void> getSumByCategory({required String year, String? month}) async {
//     rpcSumByCategory.value = await repo.getSumByCategory(year: year, month: month);
//   }

//   Future<void> getSumNoteTimes({required String year, String? month}) async {
//     rpcSumNoteTimes.value = await repo.getSumNoteTimes(year: year, month: month);
//   }

//   Future<void> calculateBudgetStatForHeader() async {
//     /// set value for header
//     final _month = 0.obs;
//     final _totalAllyear = 0.obs;
//     final _maxBudget = 0.obs;
//     final _percentage = 0.0.obs;
//     final _remainingBudget = 0.obs;

//     /// formula...
//     rpcSumAllMonth.forEach((element) {
//       if (element.total != null) _totalAllyear.value = _totalAllyear.value + element.total!;
//     });

//     rpcSumByCategory.forEach((element) {
//       if (element.maxBudget != null) _maxBudget.value = _maxBudget.value + element.maxBudget!;
//     });

//     if (isShowAllYear.isFalse) {
//       _month.value = monthSelected.value.reformatDate(from: 'MMMM', to: 'MM').toInt()! - 1;
//     }

//     _remainingBudget.value = _maxBudget.value - rpcSumAllMonth[_month.value].total!;

//     if (_maxBudget.value.isZero) {
//       _percentage.value = 0;
//     } else {
//       _percentage.value = rpcSumAllMonth[_month.value].total! / _maxBudget.value * 100;
//     }

//     /// apply
//     countBudget.value = _maxBudget.value;
//     countRemainingBudget.value = _remainingBudget.value;
//     countPercentage.value = _percentage.value;
//     countOnly1Month.value = rpcSumAllMonth[_month.value].total ?? 0;
//     countOnly1Year.value = _totalAllyear.value;
//   }

//   /// @param: category, startDate, endDate
//   void goAdvanceFilter(String categoryName) {
//     if (isShowAllYear.isFalse) {
//       Get.toNamed(Routes.FILTERING, arguments: [
//         categoryName,
//         '${yearSelected.value}-${monthSelected.value.reformatDate(from: 'MMMM', to: 'MM')}-01',
//         '${yearSelected.value}-${monthSelected.value.reformatDate(from: 'MMMM', to: 'MM')}-31',
//       ]);
//     } else {
//       Get.toNamed(Routes.FILTERING, arguments: [
//         categoryName,
//         '${yearSelected.value}-01-01',
//         '${yearSelected.value}-12-31',
//       ]);
//     }
//   }

//   Future<void> setupGroq() async {
//     logI('setupGroq');

//     try {
//       groq.clearChat();
//       chatMessages.clear();
//     } catch (_) {}

//     // Prepare data for AI
//     List<SupaExpense> dataExpense = [];
//     if (isShowAllYear.isTrue) {
//       dataExpense = await repo.getExpenses(year: yearSelected.value);
//     } else {
//       dataExpense = await repo.getExpenses(year: yearSelected.value, month: monthSelected.value);
//     }

//     final dataExpenseSend = [];
//     final dataBudget = await repo.getCategory();
//     final dataBudgetSend = [];
//     final dataPersonal = await repo.getUserProfile();
//     final dataPersonalSend = dataPersonal[0];

//     Map<String, num> totalAmountByDate = {};
//     for (var item in dataExpense) {
//       var date = item.date!;
//       var amount = item.amount;
//       if (totalAmountByDate.containsKey(date)) {
//         totalAmountByDate[date] = totalAmountByDate[date]! + amount!;
//       } else {
//         totalAmountByDate[date] = amount ?? 0;
//       }
//     }
//     var sortedResults = totalAmountByDate.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
//     for (var entry in sortedResults) {
//       dataExpenseSend.add({
//         'date': entry.key,
//         'amount': entry.value,
//       });
//     }

//     dataBudget.forEach((el) {
//       dataBudgetSend.add({
//         'category': el.name,
//         'budget': el.maxBudget ?? 0,
//       });
//     });

//     final systemMessage = '''
//       You are an assistant that helps users manage their budgets and expenses effectively.
//       User profile data:
//       Name: ${dataPersonalSend.fullName}, Age: ${dataPersonalSend.age}, Income: ${dataPersonalSend.income}, Savings: ${dataPersonalSend.balance}.
//       Do not expose private financial data (income or savings) in your responses. Only nick name and age can be mentioned if relevant.
//       This is user budget data:
//       $dataBudgetSend
//       This is user expense data:
//       $dataExpense
//       All responses must be in Indonesian language.
//       dont use italic font, for currency use `Rp.` text only dont use any symbol like â or â.
//     ''';

//     groq.startChat();
//     groq.setCustomInstructionsWith(systemMessage);
//   }

//   Future<void> sendMessage() async {
//     final message = chatInputController.text.trim();
//     if (message.isEmpty) return;

//     // Add user message
//     chatMessages.add({
//       'text': message,
//       'isUser': true,
//     });

//     // Clear input
//     chatInputController.clear();

//     // Add temporary AI message
//     chatMessages.add({
//       'text': 'Typing...',
//       'isUser': false,
//     });

//     final aiMessageIndex = chatMessages.length - 1;

//     // Prepare system message with context
//     await groq.sendMessage('$message').then((response) {
//       chatMessages[aiMessageIndex] = {
//         'text': response.choices.first.message.content,
//         'isUser': false,
//       };
//     }).catchError((e) {
//       chatMessages[aiMessageIndex] = {
//         'text': '${e.toString()}',
//         'isUser': false,
//       };
//     });
//     chatInputFocusNode.requestFocus();
//   }

//   @override
//   void onClose() {
//     chatInputController.dispose();
//     chatInputFocusNode.dispose();
//     super.onClose();
//   }
// }
