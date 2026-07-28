import '../../core/app_api.dart';
import '../../models/supa_notes_entity.dart';

class NotesRepository {
  Future<List<SupaNotes>> getNotes() async {
    if (currentUserId == null) return [];
    final response =
        await db //
            .from('notes')
            .select()
            .eq('user_id', currentUserId!)
            .order('updated_at', ascending: false)
            .withConverter<List<SupaNotes>>((data) {
              return (data).map((e) => SupaNotes.fromJson(e)).toList();
            });
    return response;
  }

  Future<void> addNotes(SupaNotes entity) async {
    if (currentUserId == null) return;
    final response =
        await db //
            .from('notes')
            .upsert(entity.toJson());
    return response;
  }

  Future<void> updateNotes(SupaNotes entity) async {
    if (currentUserId == null) return;
    final response =
        await db //
            .from('notes')
            .update(entity.toJson())
            .match({'id': entity.id ?? '', 'user_id': currentUserId!});
    return response;
  }

  Future<void> deleteNotes(String id) async {
    if (currentUserId == null) return;
    final response =
        await db //
            .from('notes')
            .delete()
            .match({'id': id, 'user_id': currentUserId!});
    return response;
  }
}
