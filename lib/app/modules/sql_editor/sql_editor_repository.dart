import 'dart:async';

import 'package:postgres/postgres.dart';

class SqlExecutionResult {
  const SqlExecutionResult({
    required this.columns,
    required this.rows,
    required this.affectedRows,
    required this.elapsed,
  });

  final List<String> columns;
  final List<List<dynamic>> rows;
  final int affectedRows;
  final Duration elapsed;

  int get rowCount => rows.length;
  bool get hasRows => rows.isNotEmpty;
}

class SqlEditorRepository {
  SqlEditorRepository({
    String? connectionString,
  }) : _connectionString = (connectionString ?? _defaultConnectionString).trim();

  final String _connectionString;

  static const String _defaultConnectionString = String.fromEnvironment(
    'SQL_EDITOR_DB_URL',
    defaultValue: 'postgres://postgres.nytddmoffawejkpzggzr:AdityaPratama@aws-0-ap-southeast-1.pooler.supabase.com:6543/postgres?sslmode=require',
  );

  Future<SqlExecutionResult> run(String sql) async {
    final normalized = sql.trim();
    if (normalized.isEmpty) {
      throw ArgumentError('Query SQL nggak boleh kosong');
    }
    if (_connectionString.isEmpty) {
      throw StateError(
        'Connection string belum diatur. Isi SQL_EDITOR_DB_URL saat build.',
      );
    }

    final stopwatch = Stopwatch()..start();
    final connection = await _openConnection();
    try {
      final result = await connection.execute(normalized);
      stopwatch.stop();

      final schema = result.schema.columns;
      final columns = <String>[];
      for (var i = 0; i < schema.length; i++) {
        final columnName = schema[i].columnName;
        columns.add(
          (columnName == null || columnName.trim().isEmpty) ? 'column_${i + 1}' : columnName,
        );
      }

      final rows = <List<dynamic>>[];
      for (final row in result) {
        rows.add(List<dynamic>.from(row));
      }

      return SqlExecutionResult(
        columns: columns,
        rows: rows,
        affectedRows: result.affectedRows,
        elapsed: stopwatch.elapsed,
      );
    } finally {
      await connection.close();
    }
  }

  Future<Connection> _openConnection() {
    final uri = Uri.parse(_connectionString);
    if (uri.scheme != 'postgres' && uri.scheme != 'postgresql') {
      throw ArgumentError(
        'Skema connection string "${uri.scheme}" nggak didukung. '
        'Pakai postgres:// atau postgresql://.',
      );
    }

    final userInfo = uri.userInfo;
    if (userInfo.isEmpty) {
      throw ArgumentError('Connection string harus menyertakan credentials.');
    }
    final separator = userInfo.indexOf(':');
    final username = separator == -1 ? userInfo : userInfo.substring(0, separator);
    final password = separator == -1 ? '' : userInfo.substring(separator + 1);

    final endpoint = Endpoint(
      host: uri.host,
      port: uri.hasPort ? uri.port : 5432,
      database: uri.pathSegments.isEmpty ? 'postgres' : uri.pathSegments.first,
      username: Uri.decodeComponent(username),
      password: Uri.decodeComponent(password),
    );

    final sslParam = uri.queryParameters['sslmode']?.toLowerCase();
    final sslMode = switch (sslParam) {
      'disable' => SslMode.disable,
      'verify-full' => SslMode.verifyFull,
      _ => SslMode.require,
    };

    return Connection.open(
      endpoint,
      settings: ConnectionSettings(
        sslMode: sslMode,
        connectTimeout: const Duration(seconds: 8),
        queryTimeout: const Duration(seconds: 30),
      ),
    );
  }
}
