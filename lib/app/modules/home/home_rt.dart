import 'dart:async';

import 'package:ex_kit/ex.dart';
import 'package:get/get.dart';

import '../../core/app_api.dart';
import '../../core/const.dart';
import '../../helpers/helper_error_log.dart';
import 'home_controller.dart';

mixin HomeRT {
  static HomeController get _home => Get.find<HomeController>();

  /// expense realtime states
  static StreamSubscription<List<Map<String, dynamic>>>? rtExpenseSub;
  static Timer? rtExpenseDebounce;
  static bool isExpenseRTHasSeeded = false;
  static bool isExpenseRTRefreshing = false;
  static String? rtActiveSearchQuery;
  static String? rtActiveStartDate;
  static String? rtActiveEndDate;

  /// assets realtime states
  static StreamSubscription<List<Map<String, dynamic>>>? rtAssetsSub;
  static Timer? rtAssetsDebounce;
  static bool isAssetsRTHasSeeded = false;
  static bool isAssetsRTRefreshing = false;

  /// goals realtime states
  static StreamSubscription<List<Map<String, dynamic>>>? rtGoalsSub;
  static Timer? rtGoalsDebounce;
  static bool isGoalsRTHasSeeded = false;
  static bool isGoalsRTRefreshing = false;

  /// notes realtime states
  static StreamSubscription<List<Map<String, dynamic>>>? rtNotesSub;
  static Timer? rtNotesDebounce;
  static bool isNotesRTHasSeeded = false;
  static bool isNotesRTRefreshing = false;

  static Future<void> initRealtime() async {
    await Future.wait([
      initExpenseRT(),
      initAssetsRT(),
      initGoalsRT(),
      initNotesRT(),
    ]);
  }

  static Future<void> dispose() async {
    await rtExpenseSub?.cancel();
    await rtAssetsSub?.cancel();
    await rtGoalsSub?.cancel();
    await rtNotesSub?.cancel();

    rtExpenseSub = null;
    rtAssetsSub = null;
    rtGoalsSub = null;
    rtNotesSub = null;

    rtExpenseDebounce?.cancel();
    rtAssetsDebounce?.cancel();
    rtGoalsDebounce?.cancel();
    rtNotesDebounce?.cancel();
  }

  // ────────────────────────────────────────────────────────────────
  // ! Realtime: Expense
  // ────────────────────────────────────────────────────────────────
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

      await _home.getCount1Month(_home.focusedDay.value);
      await _home.onCalenderRefreshEvent(
        period: _home.focusedDay.value.toStringEx(format: yM),
      );
      _home.rpcSpenderDay.value = await _home.repo.rpcGetSpenderDay(
        _home.focusedDay.value,
      );
    } catch (e, stack) {
      await HelperErrorLog.record(page: 'home', action: '_refreshExpenseAfterRealtime', stack: '$e\n$stack');
    } finally {
      isExpenseRTRefreshing = false;
    }
  }

  // ────────────────────────────────────────────────────────────────
  // ! Realtime: Assets
  // ────────────────────────────────────────────────────────────────
  static Future<void> initAssetsRT() async {
    if (currentUserId == null) return;

    await rtAssetsSub?.cancel();
    rtAssetsSub = null;
    rtAssetsDebounce?.cancel();
    isAssetsRTHasSeeded = false;

    try {
      final stream = db.from('assets').stream(primaryKey: ['id']).eq('user_id', currentUserId!);

      rtAssetsSub = stream.listen(
        _onAssetsRTEvent,
        onError: (Object error, StackTrace stackTrace) {
          HelperErrorLog.record(page: 'home', action: 'assetsRealtimeListen', stack: '$error\n$stackTrace');
          isAssetsRTHasSeeded = false;
        },
      );
    } catch (e, stack) {
      await HelperErrorLog.record(page: 'home', action: '_initAssetsRealtime', stack: '$e\n$stack');
    }
  }

  static void _onAssetsRTEvent(List<Map<String, dynamic>> _) {
    if (!isAssetsRTHasSeeded) {
      isAssetsRTHasSeeded = true;
      return;
    }

    rtAssetsDebounce?.cancel();
    rtAssetsDebounce = Timer(const Duration(milliseconds: 350), () {
      if (_home.isClosed) return;
      unawaited(_refreshAssetsRT());
    });
  }

  static Future<void> _refreshAssetsRT() async {
    if (isAssetsRTRefreshing) return;
    isAssetsRTRefreshing = true;
    try {
      await _home.loadAssetsSummary();
    } catch (e, stack) {
      await HelperErrorLog.record(page: 'home', action: '_refreshAssetsRealtime', stack: '$e\n$stack');
    } finally {
      isAssetsRTRefreshing = false;
    }
  }

  // ────────────────────────────────────────────────────────────────
  // ! Realtime: Goals
  // ────────────────────────────────────────────────────────────────
  static Future<void> initGoalsRT() async {
    if (currentUserId == null) return;

    await rtGoalsSub?.cancel();
    rtGoalsSub = null;
    rtGoalsDebounce?.cancel();
    isGoalsRTHasSeeded = false;

    try {
      final stream = db.from('goals').stream(primaryKey: ['id']).eq('user_id', currentUserId!);

      rtGoalsSub = stream.listen(
        _onGoalsRTEvent,
        onError: (Object error, StackTrace stackTrace) {
          HelperErrorLog.record(page: 'home', action: 'goalsRealtimeListen', stack: '$error\n$stackTrace');
          isGoalsRTHasSeeded = false;
        },
      );
    } catch (e, stack) {
      await HelperErrorLog.record(page: 'home', action: '_initGoalsRealtime', stack: '$e\n$stack');
    }
  }

  static void _onGoalsRTEvent(List<Map<String, dynamic>> _) {
    if (!isGoalsRTHasSeeded) {
      isGoalsRTHasSeeded = true;
      return;
    }

    rtGoalsDebounce?.cancel();
    rtGoalsDebounce = Timer(const Duration(milliseconds: 350), () {
      if (_home.isClosed) return;
      unawaited(_refreshGoalsRT());
    });
  }

  static Future<void> _refreshGoalsRT() async {
    if (isGoalsRTRefreshing) return;
    isGoalsRTRefreshing = true;
    try {
      await _home.loadGoalsList();
    } catch (e, stack) {
      await HelperErrorLog.record(page: 'home', action: '_refreshGoalsRealtime', stack: '$e\n$stack');
    } finally {
      isGoalsRTRefreshing = false;
    }
  }

  // ────────────────────────────────────────────────────────────────
  // ! Realtime: Notes
  // ────────────────────────────────────────────────────────────────
  static Future<void> initNotesRT() async {
    if (currentUserId == null) return;

    await rtNotesSub?.cancel();
    rtNotesSub = null;
    rtNotesDebounce?.cancel();
    isNotesRTHasSeeded = false;

    try {
      final stream = db.from('notes').stream(primaryKey: ['id']).eq('user_id', currentUserId!);

      rtNotesSub = stream.listen(
        _onNotesRTEvent,
        onError: (Object error, StackTrace stackTrace) {
          HelperErrorLog.record(page: 'home', action: 'notesRealtimeListen', stack: '$error\n$stackTrace');
          isNotesRTHasSeeded = false;
        },
      );
    } catch (e, stack) {
      await HelperErrorLog.record(page: 'home', action: '_initNotesRealtime', stack: '$e\n$stack');
    }
  }

  static void _onNotesRTEvent(List<Map<String, dynamic>> _) {
    if (!isNotesRTHasSeeded) {
      isNotesRTHasSeeded = true;
      return;
    }

    rtNotesDebounce?.cancel();
    rtNotesDebounce = Timer(const Duration(milliseconds: 350), () {
      if (_home.isClosed) return;
      unawaited(_refreshNotesRT());
    });
  }

  static Future<void> _refreshNotesRT() async {
    if (isNotesRTRefreshing) return;
    isNotesRTRefreshing = true;
    try {
      await _home.loadNotesList();
    } catch (e, stack) {
      await HelperErrorLog.record(page: 'home', action: '_refreshNotesRealtime', stack: '$e\n$stack');
    } finally {
      isNotesRTRefreshing = false;
    }
  }
}
