import 'package:ex_kit/ex.dart';
import 'package:get/get.dart';

import '../../core/app_setting.dart';
import '../../core/const.dart';
import '../../helpers/helper_misc.dart';
import '../../models/rpc_sum_all_month_entity.dart';
import '../../models/rpc_sum_by_category_entity.dart';
import '../../models/rpc_sum_note_times_entity.dart';
import '../../models/supa_expense_entity.dart';
import '../../routes/app_pages.dart';
import 'summary_repository.dart';

class SummaryController extends GetxController with StateMixin {
  // repo
  final repo = Get.find<SummaryRepository>();

  // calander
  final yearSelected = DateTime.now().toStringEx(format: 'y').obs;
  final monthSelected = DateTime.now().toStringEx(format: 'MMMM').obs;

  // data
  final rpcSumAllMonth = <RpcSumAllMonth>[].obs; // for sidemenu
  final rpcSumByCategory = <RpcSumByCategory>[].obs; // for body
  final rpcSumNoteTimes = <RpcSumNoteTimes>[].obs; // for noteTimes perMonth
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

  @override
  Future<void> onInit() async {
    yearSelected.value = Get.parameters['period'].toString().reformatDate(from: yM, to: 'y');
    monthSelected.value = Get.parameters['period'].toString().reformatDate(from: yM, to: 'MMMM');

    await getExpenses(year: yearSelected.value, month: monthSelected.value);
    await getSumAllMonth(year: yearSelected.value);
    await getSumByCategory(year: yearSelected.value, month: monthSelected.value);
    await getSumNoteTimes(year: yearSelected.value, month: monthSelected.value);
    await calculateBudgetStatForHeader();
    change(0, status: RxStatus.success());
    super.onInit();
  }

  Future<void> onMonthChange(String month) async {
    closeDrawer();
    change(0, status: RxStatus.loading());
    monthSelected.value = month;
    isShowAllYear.value = false;

    await getExpenses(year: yearSelected.value, month: monthSelected.value);
    await getSumByCategory(year: yearSelected.value, month: monthSelected.value);
    await getSumNoteTimes(year: yearSelected.value, month: monthSelected.value);
    await calculateBudgetStatForHeader();
    change(0, status: RxStatus.success());
  }

  Future<void> onShowAllYear() async {
    change(0, status: RxStatus.loading());
    if (isShowAllYear.value == false) {
      closeDrawer();
      isShowAllYear.value = true;
      monthSelected.value = '';

      await getExpenses(year: yearSelected.value);
      await getSumByCategory(year: yearSelected.value);
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
      await getSumByCategory(year: yearSelected.value);
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
      await getSumByCategory(year: yearSelected.value);
      await getSumNoteTimes(year: yearSelected.value);
    }

    await calculateBudgetStatForHeader();
    change(0, status: RxStatus.success());
  }

  Future<void> getExpenses({required String year, String? month}) async {
    expenses.value = await repo.getExpenses(year: year, month: month);

    /// grouping expenses by date
    final _expensesByDate = <String, List<SupaExpense>>{};
    for (var e in expenses) {
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

  Future<void> getSumByCategory({required String year, String? month}) async {
    rpcSumByCategory.value = await repo.getSumByCategory(year: year, month: month);
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

    rpcSumByCategory.forEach((element) {
      if (element.maxBudget != null) _maxBudget.value = _maxBudget.value + element.maxBudget!;
    });

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
      Get.toNamed(Routes.FILTERING, arguments: [
        categoryName,
        '${yearSelected.value}-${monthSelected.value.reformatDate(from: 'MMMM', to: 'MM')}-01',
        '${yearSelected.value}-${monthSelected.value.reformatDate(from: 'MMMM', to: 'MM')}-31',
      ]);
    } else {
      Get.toNamed(Routes.FILTERING, arguments: [
        categoryName,
        '${yearSelected.value}-01-01',
        '${yearSelected.value}-12-31',
      ]);
    }
  }
}
