import 'dart:async';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_api.dart';
import '../../helpers/helper_error_log.dart';
import 'home_controller.dart';

mixin HomeRT {
  static HomeController get _home => Get.find<HomeController>();

  static RealtimeChannel? rtDataChannel;
  static Timer? rtExpenseDebounce;
  static bool isExpenseRTRefreshing = false;
  static bool isExpenseRTRefreshPending = false;
  static String? rtActiveSearchQuery;
  static String? rtActiveStartDate;
  static String? rtActiveEndDate;

  static Future<void> initExpenseRT() async {
    await dispose();
    final userId = currentUserId;
    if (userId == null) return;

    try {
      var channel = db.channel('home-data:$userId');
      for (final table in ['expense', 'recurring_expenses']) {
        channel = channel.onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: table,
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'user_id', value: userId),
          callback: (payload) {
            if (rtDataChannel == channel && currentUserId == userId) onExpenseRTEvent(payload);
          },
        );
      }
      rtDataChannel = channel;
      channel.subscribe((status, error) {
        if (rtDataChannel != channel || currentUserId != userId) return;
        if (status == RealtimeSubscribeStatus.subscribed) {
          unawaited(refreshExpenseRT());
        } else if (status == RealtimeSubscribeStatus.channelError) {
          HelperErrorLog.record(page: 'home', action: 'expenseRealtimeListen', stack: '$error');
        }
      });
    } catch (e, stack) {
      await HelperErrorLog.record(page: 'home', action: '_initExpenseRealtime', stack: '$e\n$stack');
    }
  }

  static void onExpenseRTEvent(PostgresChangePayload _) {
    rtExpenseDebounce?.cancel();
    rtExpenseDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!Get.isRegistered<HomeController>() || _home.isClosed) return;
      unawaited(refreshExpenseRT());
    });
  }

  static Future<void> refreshExpenseRT() async {
    if (!Get.isRegistered<HomeController>() || _home.isClosed) return;
    if (isExpenseRTRefreshing) {
      isExpenseRTRefreshPending = true;
      return;
    }
    isExpenseRTRefreshing = true;
    final home = _home;
    try {
      final query = rtActiveSearchQuery;
      final start = rtActiveStartDate;
      final end = rtActiveEndDate;

      if (query == null) {
        await home.getExpense(showLoading: false);
      } else {
        await home.getExpense(find: query, startDate: start, endDate: end, showLoading: false);
      }

      await home.loadRecurringList();
      await home.loadRecentExpenses();
      await home.loadBudgetSuggestions();
      await home.getCount1Month(home.focusedDay.value);
      await home.onCalenderRefreshEvent();
      final period = home.focusedPeriod;
      home.rpcSpenderDay.value = await home.repo.rpcGetSpenderDay(
        period.start,
        period.end,
      );
    } catch (e, stack) {
      await HelperErrorLog.record(page: 'home', action: '_refreshExpenseAfterRealtime', stack: '$e\n$stack');
    } finally {
      isExpenseRTRefreshing = false;
      if (isExpenseRTRefreshPending) {
        isExpenseRTRefreshPending = false;
        unawaited(refreshExpenseRT());
      }
    }
  }

  static Future<void> dispose() async {
    rtExpenseDebounce?.cancel();
    rtExpenseDebounce = null;
    isExpenseRTRefreshPending = false;
    final channel = rtDataChannel;
    rtDataChannel = null;
    if (channel != null) await db.removeChannel(channel);
  }
}
