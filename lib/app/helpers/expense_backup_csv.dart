import 'package:csv/csv.dart' as csv;
import 'package:uuid/v4.dart';

class ExpenseBackupCsv {
  static const columns = [
    'id', 'user_id', 'date', 'category_name', 'note', 'detail', 'amount',
    'created_at', 'updated_at', 'image_path', 'source_recurring_id',
  ];

  static String encode(List<dynamic> rows) => csv.csv.encode([
    columns,
    for (final row in rows) [for (final column in columns) row[column] ?? ''],
  ]);

  static List<Map<String, dynamic>> decode(String content, String userId) {
    final table = csv.csv.decode(content);
    if (table.isEmpty) throw const FormatException('CSV kosong');
    final headers = table.first.map((value) => value.toString().replaceFirst('\uFEFF', '')).toList();
    if (headers.toSet().length != headers.length ||
        !['date', 'category_name', 'note', 'detail', 'amount', 'created_at'].every(headers.contains)) {
      throw const FormatException('Kolom backup tidak lengkap');
    }
    final ids = <String>{};
    final rows = <Map<String, dynamic>>[];
    for (var index = 1; index < table.length; index++) {
      final values = table[index];
      if (values.length != headers.length) throw FormatException('Baris ${index + 1} tidak lengkap');
      final row = <String, dynamic>{for (var i = 0; i < headers.length; i++) headers[i]: values[i].toString()};
      final amount = num.tryParse(row['amount']);
      final rawDate = row['date'] as String;
      final date = DateTime.tryParse(rawDate);
      final category = (row['category_name'] as String).split('#').first;
      if (amount == null || !amount.isFinite || amount < 0 || amount > 1000000000000000 || amount != amount.roundToDouble() ||
          !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(rawDate) || date == null ||
          date.toIso8601String().substring(0, 10) != rawDate || category.trim().isEmpty ||
          DateTime.tryParse(row['created_at']) == null) {
        throw FormatException('Baris ${index + 1} tidak valid');
      }
      row['id'] = (row['id'] as String?)?.isNotEmpty == true ? row['id'] : UuidV4().generate();
      if (!ids.add(row['id'])) throw FormatException('ID duplikat pada baris ${index + 1}');
      row['user_id'] = userId;
      row['category_name'] = category;
      row['amount'] = amount.toInt();
      for (final column in ['updated_at', 'image_path', 'source_recurring_id']) {
        if ((row[column] as String?)?.isNotEmpty != true) row[column] = null;
      }
      rows.add({for (final column in columns) column: row[column]});
    }
    return rows;
  }
}
