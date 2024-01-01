import '../../core/app_api.dart';
import '../../models/supa_autocomplete_entity.dart';
import '../../models/supa_user_profile_entity.dart';

const AUTO_COMPLETE = 'Auto Complete';
const APP_CONFIG = 'App Config';
const REPEAT_SETTING = 'Repeat Setting';
const IMPORT_EXPORT = 'Import/Export';

class SettingsRepository {
  Future<List<String>> getMenuList() async {
    return [
      APP_CONFIG,
      AUTO_COMPLETE,
      REPEAT_SETTING,
      IMPORT_EXPORT,
    ];
  }

  /// ------------------------------------------------------------------------
  /// ! autocomplete
  /// ------------------------------------------------------------------------
  Future<List<SupaAutoComplete>> getAutoComplete() async {
    final response = await db //
        .from('autocomplete')
        .select()
        .eq('user_id', db.auth.currentSession?.user.id ?? '')
        .order('note', ascending: true)
        .withConverter<List<SupaAutoComplete>>((data) {
      return (data).map((e) => SupaAutoComplete.fromJson(e)).toList();
    });
    return response;
  }

  Future<List<SupaAutoComplete>> findAutoComplete(String q) async {
    final response = await db //
        .from('autocomplete')
        .select()
        .eq('user_id', db.auth.currentSession?.user.id ?? '')
        .ilike('note', '%$q%')
        .order('note', ascending: true)
        .withConverter<List<SupaAutoComplete>>((data) {
      return (data).map((e) => SupaAutoComplete.fromJson(e)).toList();
    });
    return response;
  }

  Future<void> addAutoComplete(String autocompleteNote) async {
    final response = await db.from('autocomplete').upsert({
      'note': autocompleteNote,
      'user_id': db.auth.currentSession?.user.id ?? '',
    });
    return response;
  }

  Future<void> deleteAutoComplete(String note) async {
    final response = await db.from('autocomplete').delete().match({
      'note': note,
      'user_id': db.auth.currentSession?.user.id ?? '',
    });
    return response;
  }

  /// ------------------------------------------------------------------------
  /// ! profile
  /// ------------------------------------------------------------------------
  ///
  Future<List<SupaUserProfile>> getUserProfile() async {
    final response = await db //
        .from('profiles')
        .select()
        .eq('id', db.auth.currentSession?.user.id ?? '')
        .withConverter<List<SupaUserProfile>>((data) {
      return (data).map((e) => SupaUserProfile.fromJson(e)).toList();
    });
    return response;
  }
}
