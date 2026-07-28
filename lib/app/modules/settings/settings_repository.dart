import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uicons_pro/uicons_pro.dart';

import '../../../env.g.dart';
import '../../core/app_api.dart';
import '../../models/supa_category_entity.dart';
import '../../models/supa_cron_entity.dart';
import '../../models/supa_expense_entity.dart';
import '../../models/supa_user_profile_entity.dart';

mixin SectionMenu {
  static const APP_CONFIG = 'App Config';
  static const REPEAT_SETTING = 'Recurring';
  static const IMPORT_EXPORT = 'Import/Export';
}

class SettingsRepository {
  Future<List<Map<String, dynamic>>> getMenuList() async {
    return [
      {
        'label': SectionMenu.APP_CONFIG,
        'icon': UIconsPro.solidRounded.settings,
      },
      {
        'label': SectionMenu.REPEAT_SETTING,
        'icon': UIconsPro.solidRounded.calendar_clock,
      },
      {
        'label': SectionMenu.IMPORT_EXPORT,
        'icon': UIconsPro.solidRounded.file_export,
      },
    ];
  }

  /// ------------------------------------------------------------------------
  /// ! count data
  /// ------------------------------------------------------------------------
  Future<int> countExpense() async {
    if (currentUserId == null) return 0;
    final response = await db
        .from('expense')
        .count()
        .eq('user_id', currentUserId!);
    return response;
  }

  Future<int> countCategory() async {
    return expenseCategoryList.length;
  }

  /// ------------------------------------------------------------------------
  /// ! storage
  /// ------------------------------------------------------------------------
  Future<List<FileObject>> getBackupList() async {
    final email = db.auth.currentSession?.user.email;
    if (email == null) return [];

    final response = await db.storage
        .from('backup')
        .list(
          searchOptions: SearchOptions(
            sortBy: SortBy(column: 'created_at', order: 'desc'),
          ),
        );

    return response.where((file) => file.name.startsWith('${email}_')).toList();
  }

  /// ------------------------------------------------------------------------
  /// ! profile
  /// ------------------------------------------------------------------------
  ///
  Future<List<SupaUserProfile>> getUserProfile() async {
    if (currentUserId == null) return [];
    final response =
        await db //
            .from('profiles')
            .select()
            .eq('id', currentUserId!)
            .withConverter<List<SupaUserProfile>>((data) {
              return (data).map((e) => SupaUserProfile.fromJson(e)).toList();
            });
    return response;
  }

  // editProfile
  Future<void> editProfile(SupaUserProfile entity) async {
    if (currentUserId == null) return;
    final response =
        await db //
            .from('profiles')
            .update(entity.toJson())
            .eq('id', currentUserId!);
    return response;
  }

  /// ------------------------------------------------------------------------
  /// ! admin
  /// ------------------------------------------------------------------------
  Future<List<SupaCron>> getCron() async {
    final sb = SupabaseClient(Env.supabaseUrl, Env.supabaseServiceRole);
    final res =
        await sb //
            .schema('cron')
            .from('job')
            .select()
            .or('command.ilike.%${db.auth.currentSession?.user.id}%')
            .withConverter<List<SupaCron>>((data) {
              return (data).map((e) => SupaCron.fromJson(e)).toList();
            });
    return res;
  }

  Future<num> sumAllExpense() async {
    if (currentUserId == null) return 0;
    var totalExpense = 0 as num;
    final response =
        await db //
            .from('expense')
            .select()
            .eq('user_id', currentUserId!)
            .withConverter<List<SupaExpense>>((data) {
              return (data).map((e) => SupaExpense.fromJson(e)).toList();
            });

    response.forEach(
      (element) => totalExpense = totalExpense + element.amount!,
    );
    return totalExpense;
  }
}
