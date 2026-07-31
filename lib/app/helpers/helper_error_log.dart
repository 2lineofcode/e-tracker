import 'package:ex_kit/ex.dart';
import 'package:uuid/v4.dart';

import '../core/app_api.dart';
import '../models/supa_error_log_entity.dart';

mixin HelperErrorLog {
  static Future<void> record({
    String? userEmail,
    required String page,
    required String action,
    required String stack,
  }) async {
    if (db.auth.currentSession == null) return;

    final errObj = SupaErrorLog(
      id: UuidV4().generate(),
      createdAt: DateTime.now().toStringEx(),
      userEmail: userEmail ?? db.auth.currentSession?.user.email,
      page: page,
      action: action,
      stack: stack,
    );
    try {
      await db.from('error_log').insert(errObj.toJson());
    } catch (e) {
      logW('Remote error log skipped: $e');
    }
  }
}
