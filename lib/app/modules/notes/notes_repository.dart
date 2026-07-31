import '../../core/app_api.dart';
import '../../models/supa_notes_entity.dart';

class NotesRepository {
  String get _userId {
    final userId = currentUserId;
    if (userId == null) throw StateError('User not authenticated');
    return userId;
  }

  Future<List<SupaNotes>> getNotes() async {
    final userId = _userId;
    final response =
        await db //
            .from('notes')
            .select()
            .eq('user_id', userId)
            .order('is_pinned', ascending: false)
            .order('updated_at', ascending: false)
            .withConverter<List<SupaNotes>>((data) {
              return (data).map((e) => SupaNotes.fromJson(e)).toList();
            });
    return response;
  }

  Future<void> addNotes(SupaNotes entity) async {
    entity.userId = _userId;
    final response =
        await db //
            .from('notes')
            .upsert(entity.toJson());
    return response;
  }

  Future<void> updateNotes(SupaNotes entity) async {
    final userId = _userId;
    entity.userId = userId;
    final response =
        await db //
            .from('notes')
            .update(entity.toJson())
            .match({'id': entity.id ?? '', 'user_id': userId});
    return response;
  }

  Future<void> deleteNotes(String id) async {
    final userId = _userId;
    final response =
        await db //
            .from('notes')
            .delete()
            .match({'id': id, 'user_id': userId});
    return response;
  }

  Future<void> updatePinned(String id, bool isPinned) async {
    final userId = _userId;
    await db
        .from('notes')
        .update({'is_pinned': isPinned})
        .match({'id': id, 'user_id': userId});
  }
}
