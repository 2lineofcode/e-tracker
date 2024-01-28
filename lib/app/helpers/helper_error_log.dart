import 'package:ex/ex.dart';
import 'package:uuid/v4.dart';

import '../core/app_api.dart';
import '../models/supa_error_log_entity.dart';

mixin ErrorLogHelper {
  static Future<void> record({
    String? userEmail,
    required String page,
    required String action,
    required String stack,
  }) async {
    final errObj = SupaErrorLog(
      id: UuidV4().generate(),
      createdAt: DateTime.now().toStringEx(),
      userEmail: userEmail ?? db.auth.currentSession?.user.email,
      page: page,
      action: action,
      stack: stack,
    );
    await db.from('error_log').insert(errObj.toJson());
  }
}
