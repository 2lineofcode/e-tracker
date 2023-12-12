import '../../core/app_base.dart';
import '../../models/autocomplete_entity.dart';

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
  Future<List<AutoCompleteEntity>> getAutoComplete() async {
    final response = await db.from('autocomplete').select().order('note', ascending: true).withConverter<List<AutoCompleteEntity>>((data) {
      return (data as List).map((e) => AutoCompleteEntity.fromJson(e)).toList();
    });
    return response;
  }

  Future<List<AutoCompleteEntity>> findAutoComplete(String q) async {
    final response = await db.from('autocomplete').select().ilike('note', '%$q%').order('note', ascending: true).withConverter<List<AutoCompleteEntity>>((data) {
      return (data as List).map((e) => AutoCompleteEntity.fromJson(e)).toList();
    });
    return response;
  }

  Future<void> addAutoComplete(String autocompleteNote) async {
    final response = await db.from('autocomplete').upsert({'note': autocompleteNote});
    return response;
  }

  Future<void> deleteAutoComplete(String note) async {
    final response = await db.from('autocomplete').delete().match({'note': note});
    return response;
  }
}
