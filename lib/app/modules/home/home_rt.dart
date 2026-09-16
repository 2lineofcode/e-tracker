import 'dart:async';

import 'package:get/get.dart';

import '../../core/app_api.dart';
import '../../helpers/helper_error_log.dart';
import 'home_controller.dart';

mixin HomeRT {
  static HomeController get _home => Get.find<HomeController>();

  static StreamSubscription<List<Map<String, dynamic>>>? rtExpenseSub;
  static Timer? rtExpenseDebounce;
  static bool isExpenseRTHasSeeded = false;
  static bool isExpenseRTRefreshing = false;
  static String? rtActiveSearchQuery;
  static String? rtActiveStartDate;
  static String? rtActiveEndDate;

  static Future<void> initExpenseRT() async {
    if (currentUserId == null) return;

    await rtExpenseSub?.cancel();
    rtExpenseSub = null;
    rtExpenseDebounce?.cancel();
    isExpenseRTHasSeeded = false;

    try {
      final stream = db.from('expense').stream(primaryKey: ['id']).eq('user_id', currentUserId!);

      rtExpenseSub = stream.listen(
        onExpenseRTEvent,
        onError: (Object error, StackTrace stackTrace) {
          HelperErrorLog.record(page: 'home', action: 'expenseRealtimeListen', stack: '$error\n$stackTrace');
          isExpenseRTHasSeeded = false;
        },
      );
    } catch (e, stack) {
      await HelperErrorLog.record(page: 'home', action: '_initExpenseRealtime', stack: '$e\n$stack');
    }
  }

  static void onExpenseRTEvent(List<Map<String, dynamic>> _) {
    if (!isExpenseRTHasSeeded) {
      isExpenseRTHasSeeded = true;
      return;
    }

    rtExpenseDebounce?.cancel();
    rtExpenseDebounce = Timer(const Duration(milliseconds: 350), () {
      if (_home.isClosed) return;
      unawaited(refreshExpenseRT());
    });
  }

  static Future<void> refreshExpenseRT() async {
    if (isExpenseRTRefreshing) return;
    isExpenseRTRefreshing = true;
    try {
      final query = rtActiveSearchQuery;
      final start = rtActiveStartDate;
      final end = rtActiveEndDate;

      if (query == null) {
        await _home.getExpense(showLoading: false);
      } else {
        await _home.getExpense(find: query, startDate: start, endDate: end, showLoading: false);
      }

      await _home.loadRecentExpenses();
      await _home.loadBudgetSuggestions();
      await _home.getCount1Month(_home.focusedDay.value);
      await _home.onCalenderRefreshEvent();
      final period = _home.focusedPeriod;
      _home.rpcSpenderDay.value = await _home.repo.rpcGetSpenderDay(
        period.start,
        period.end,
      );
    } catch (e, stack) {
      await HelperErrorLog.record(page: 'home', action: '_refreshExpenseAfterRealtime', stack: '$e\n$stack');
    } finally {
      isExpenseRTRefreshing = false;
    }
  }

  static Future<void> dispose() async {
    await rtExpenseSub?.cancel();
    rtExpenseSub = null;
    rtExpenseDebounce?.cancel();
  }
}
