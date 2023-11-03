class AutocompleteNoteEntity {
  String? createdAt;
  String? note;

  AutocompleteNoteEntity({this.createdAt, this.note});

  AutocompleteNoteEntity.fromJson(Map<String, dynamic> json) {
    createdAt = json['created_at'];
    note = json['note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['created_at'] = createdAt;
    data['note'] = note;
    return data;
  }
}
