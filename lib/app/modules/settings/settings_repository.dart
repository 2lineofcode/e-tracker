import '../../core/const.dart';
import '../../models/autocomplete_note_entity.dart';

const AUTO_COMPLETE = 'Auto Complete';
const APP_CONFIG = 'App Config';
const REPEAT_SETTING = 'Repeat Setting';
const IMPORT_EXPORT = 'Import/Export';

class SettingsRepository {
  Future<List<String>> getMenuList() async {
    final menus = <String>[];
    menus.add(AUTO_COMPLETE);
    menus.add(APP_CONFIG);
    menus.add(REPEAT_SETTING);
    menus.add(IMPORT_EXPORT);

    return menus;
  }

  Future<List<AutocompleteNoteEntity>> getAutocompleteNote() async {
    final response = await db.from('autocomplete_note').select().order('note', ascending: true).withConverter<List<AutocompleteNoteEntity>>((data) {
      return (data as List).map((e) => AutocompleteNoteEntity.fromJson(e)).toList();
    });
    return response;
  }

  Future<void> addAutocompleteNote(AutocompleteNoteEntity entity) async {
    final response = await db.from('autocomplete_note').insert(entity.toJson());
    return response;
  }

  Future<void> deleteAutocompleteNote(String note) async {
    final response = await db.from('autocomplete_note').delete().match({'note': note});
    return response;
  }
}
