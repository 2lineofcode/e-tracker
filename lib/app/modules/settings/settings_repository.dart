import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../env.g.dart';
import '../../core/app_api.dart';
import '../../models/supa_autocomplete_entity.dart';
import '../../models/supa_cron_entity.dart';
import '../../models/supa_expense_entity.dart';
import '../../models/supa_user_profile_entity.dart';

mixin SectionMenu {
  static const AUTO_COMPLETE = 'Auto Complete';
  static const APP_CONFIG = 'App Config';
  static const REPEAT_SETTING = 'Repeat Setting';
  static const IMPORT_EXPORT = 'Import/Export';
}

class SettingsRepository {
  Future<List<String>> getMenuList() async {
    return [
      SectionMenu.APP_CONFIG,
      SectionMenu.AUTO_COMPLETE,
      SectionMenu.REPEAT_SETTING,
      SectionMenu.IMPORT_EXPORT,
    ];
  }

  /// ------------------------------------------------------------------------
  /// ! autocomplete
  /// ------------------------------------------------------------------------
  Future<List<SupaAutoComplete>> getAutoComplete() async {
    if (currentUserId == null) return [];
    final response = await db //
        .from('autocomplete')
        .select()
        .eq('user_id', currentUserId!)
        .order('note', ascending: true)
        .withConverter<List<SupaAutoComplete>>((data) {
      return (data).map((e) => SupaAutoComplete.fromJson(e)).toList();
    });
    return response;
  }

  Future<List<SupaAutoComplete>> findAutoComplete(String q) async {
    if (currentUserId == null) return [];
    final response = await db //
        .from('autocomplete')
        .select()
        .eq('user_id', currentUserId!)
        .ilike('note', '%$q%')
        .order('note', ascending: true)
        .withConverter<List<SupaAutoComplete>>((data) {
      return (data).map((e) => SupaAutoComplete.fromJson(e)).toList();
    });
    return response;
  }

  Future<void> addAutoComplete(SupaAutoComplete autocompleteEntity) async {
    final response = await db.from('autocomplete').upsert(autocompleteEntity.toJson());
    return response;
  }

  Future<void> deleteAutoComplete(String note) async {
    if (currentUserId == null) return;
    final response = await db.from('autocomplete').delete().match({
      'note': note,
      'user_id': currentUserId!,
    });
    return response;
  }

  /// ------------------------------------------------------------------------
  /// ! count data
  /// ------------------------------------------------------------------------
  Future<int> countExpense() async {
    if (currentUserId == null) return 0;
    final response = await db.from('expense').count().eq('user_id', currentUserId!);
    return response;
  }

  Future<int> countCategory() async {
    if (currentUserId == null) return 0;
    final response = await db.from('category').count().eq('user_id', currentUserId!);
    return response;
  }

  Future<int> countAutoComplete() async {
    if (currentUserId == null) return 0;
    final response = await db.from('autocomplete').count().eq('user_id', currentUserId!);
    return response;
  }

  /// ------------------------------------------------------------------------
  /// ! storage
  /// ------------------------------------------------------------------------
  Future<List<FileObject>> getBackupList() async {
    final response = await db.storage.from('backup').list(
          searchOptions: SearchOptions(
            search: '%${db.auth.currentSession!.user.email}%',
            sortBy: SortBy(column: 'created_at', order: 'desc'),
          ),
        );
    return response;
  }

  /// ------------------------------------------------------------------------
  /// ! profile
  /// ------------------------------------------------------------------------
  ///
  Future<List<SupaUserProfile>> getUserProfile() async {
    if (currentUserId == null) return [];
    final response = await db //
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
    final response = await db //
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
    final res = await sb //
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
    final response = await db //
        .from('expense')
        .select()
        .eq('user_id', currentUserId!)
        .withConverter<List<SupaExpense>>((data) {
      return (data).map((e) => SupaExpense.fromJson(e)).toList();
    });

    response.forEach((element) => totalExpense = totalExpense + element.amount!);
    return totalExpense;
  }
}
