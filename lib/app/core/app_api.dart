import 'package:supabase_flutter/supabase_flutter.dart';

/// * handy call api -> supabase
final db = Supabase.instance.client;

/// * safe user id getter - returns null if not authenticated
String? get currentUserId => db.auth.currentSession?.user.id;
