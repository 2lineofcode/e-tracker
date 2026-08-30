import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart' as csv;
import 'package:ex_kit/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/v4.dart';

import '../core/app_api.dart';
import '../core/app_color.dart';
import '../core/const.dart';
import '../models/supa_category_entity.dart';
import '../models/supa_expense_entity.dart';
import '../modules/home/home_controller.dart';
import '../modules/settings/settings_controller.dart';
import 'helpers.dart';

mixin HelperImportExport {
  /// export to csv
  static Future<void> exportToCSV({String? customPath, Function(File)? customCallback}) async {
    try {
      String? path;

      /// get path
      if (customPath == null) {
        final abPath = await FilePicker.getDirectoryPath(dialogTitle: 'Pilih folder penyimpanan');
        path = abPath?.replaceAll('/Volumes/Macintosh HD', '');
        if (path == null) return;
      } else {
        path = customPath;
      }

      /// get data
      if (currentUserId == null) {
        ExSnackbar.danger('Kamu belum login');
        return;
      }
      final rows = await _safeSelectRows('expense');
      final ex = rows.map((e) => SupaExpense.fromJson(e)).toList()
        ..sort((a, b) => (b.date ?? '').compareTo(a.date ?? ''));

      final jsonFilePath = '$path/etracker_${DateTime.now().toStringEx(format: 'ddMMMy')}.json';
      final csvFilePath = '$path/etracker_${DateTime.now().toStringEx(format: 'ddMMMy')}.csv';

      /// Save Json Data in Json File
      File(jsonFilePath).writeAsStringSync(jsonEncode(ex));

      // read Json Data From Files
      var jsonContent = File(jsonFilePath).readAsStringSync();
      final jsonDataFromJsonFile = jsonDecode(jsonContent);

      /// Create CSV
      List<List<dynamic>> csvData = [];

      /// Header CSV
      csvData.add([
        'date',
        'category_name',
        'note',
        'detail',
        'amount',
        'created_at',
      ]);

      // Items CSV
      for (var data in jsonDataFromJsonFile) {
        csvData.add([
          data['date'].toString(),
          data['category_name'].toString().replaceAll('#${db.auth.currentUser!.email}', ''),
          data['note'].toString(),
          data['detail'].toString(),
          data['amount'].toString(),
          data['created_at'].toString(),
        ]);
      }

      /// delete json file
      File(jsonFilePath).deleteSync();

      /// export to csv
      if (customCallback == null) {
        File(csvFilePath).writeAsStringSync(csv.csv.encode(csvData));
        ExSnackbar.success(csvFilePath);
      } else {
        File(csvFilePath).writeAsStringSync(csv.csv.encode(csvData));
        customCallback.call(File(csvFilePath));
      }
    } catch (e) {
      ExSnackbar.danger('$e');
    }
  }

  static Future<void> exportFullBackupBundle({String? customPath, Function(File)? customCallback}) async {
    try {
      String? path;

      if (customPath == null) {
        final abPath = await FilePicker.getDirectoryPath(dialogTitle: 'Pilih folder backup');
        path = abPath?.replaceAll('/Volumes/Macintosh HD', '');
        if (path == null) return;
      } else {
        path = customPath;
      }

      if (currentUserId == null) {
        ExSnackbar.danger('Kamu belum login');
        return;
      }

      final data = <String, dynamic>{
        'meta': {
          'app': 'expense_tracker',
          'version': 1,
          'exported_at': DateTime.now().toStringEx(),
          'user_id': currentUserId,
        },
        'profiles': await _safeSelectRows('profiles', idColumn: 'id'),
        'expense': await _safeSelectRows('expense'),
        'budgets': await _safeSelectRows('budgets'),
        'assets': await _safeSelectRows('assets'),
        'asset_snapshots': await _safeSelectRows('asset_snapshots'),
        'goals': await _safeSelectRows('goals'),
        'notes': await _safeSelectRows('notes'),
        'recurring_expenses': await _safeSelectRows('recurring_expenses'),
        'agent_memory': await _safeSelectRows('agent_memory'),
      };

      final filePath = '$path/etracker_full_${DateTime.now().toStringEx(format: 'ddMMMy_HHmm')}.json';
      final file = File(filePath);
      file.writeAsStringSync(JsonEncoder.withIndent('  ').convert(data));

      if (customCallback == null) {
        ExSnackbar.success(filePath);
      } else {
        customCallback.call(file);
      }
    } catch (e) {
      ExSnackbar.danger('$e');
    }
  }

  static Future<List<dynamic>> _safeSelectRows(String table, {String idColumn = 'user_id'}) async {
    try {
      if (currentUserId == null) return [];
      const pageSize = 1000;
      final rows = <dynamic>[];
      while (true) {
        final page = await db
            .from(table)
            .select()
            .eq(idColumn, currentUserId!)
            .order('id')
            .range(rows.length, rows.length + pageSize - 1);
        rows.addAll(page);
        if (page.length < pageSize) return rows;
      }
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST205') {
        logW('$table table not found, skipping export');
        return [];
      }
      rethrow;
    }
  }

  /// import from csv
  static Future<void> importFromCSV({String? customPath, Function()? customCallback}) async {
    try {
      if (currentUserId == null) {
        await HelperToast.warn('Kamu belum login');
        return;
      }
      String? path;

      /// get path
      if (customPath == null) {
        final result = await FilePicker.pickFiles(allowedExtensions: ['csv'], type: FileType.custom);
        if (result == null) return;
        path = result.files.first.path ?? '';
      } else {
        path = customPath;
      }

      /// ----------------------------------------------------------------------------------
      /// # CVS TO JSON ####################################################################
      /// ----------------------------------------------------------------------------------
      final csvString = await File(path).readAsString();
      List<List<dynamic>> csvTable = csv.csv.decode(csvString);
      if (csvTable.length < 2) {
        await HelperToast.warn('CSV kosong');
        return;
      }
      List<String> headers = csvTable[0].map((header) => header.toString()).toList();

      final mapping = customPath == null
          ? await _pickImportMapping(headers)
          : <String, String>{
              'date': 'date',
              'note': 'note',
              'amount': 'amount',
              'category': 'category_name',
              'detail': 'detail',
              'created_at': 'created_at',
            };
      if (mapping == null) return;

      final jsonList = <Map<String, dynamic>>[];
      for (final row in csvTable.skip(1)) {
        jsonList.add({
          for (var i = 0; i < headers.length; i++)
            headers[i]: i < row.length ? row[i] : '',
        });
      }

      /// ----------------------------------------------------------------------------------
      /// # EXPENSE ########################################################################
      /// ----------------------------------------------------------------------------------
      final supaExpense = <SupaExpense>[];
      var invalidRows = 0;
      for (var e in jsonList) {
        final date = normalizeImportDate(e[mapping['date']].toString());
        final amount = normalizeImportAmount(e[mapping['amount']].toString());
        final note = e[mapping['note']].toString().trim();
        if (date == null || amount == null || amount == 0 || note.isEmpty) {
          invalidRows++;
          continue;
        }
        final category = resolveExpenseCategory(
          mapping['category'].isEmptyOrNull
              ? 'expense:unknown'
              : e[mapping['category']].toString(),
        );
        supaExpense.add(
          SupaExpense(
            id: UuidV4().generate(),
            userId: currentUserId ?? '',
            createdAt: mapping['created_at'].isEmptyOrNull
                ? DateTime.now().toStringEx()
                : e[mapping['created_at']].toString(),
            date: date,
            categoryName: category.code,
            note: note.toTitleCase,
            detail: mapping['detail'].isEmptyOrNull
                ? ''
                : e[mapping['detail']].toString(),
            amount: amount.abs(),
          ),
        );
      }

      var duplicateRows = 0;
      if (customPath == null && supaExpense.isNotEmpty) {
        supaExpense.sort((a, b) => a.date!.compareTo(b.date!));
        final existing = await db
            .from('expense')
            .select('date,note,amount')
            .eq('user_id', currentUserId!)
            .gte('date', supaExpense.first.date!)
            .lte('date', supaExpense.last.date!)
            .withConverter<List<SupaExpense>>(
              (data) => data.map((e) => SupaExpense.fromJson(e)).toList(),
            );
        final keys = existing.map(_expenseImportKey).toSet();
        final before = supaExpense.length;
        supaExpense.removeWhere((item) => !keys.add(_expenseImportKey(item)));
        duplicateRows = before - supaExpense.length;
      }

      if (customPath == null) {
        final confirmed = await _confirmImport(
          supaExpense,
          invalidRows: invalidRows,
          duplicateRows: duplicateRows,
        );
        if (!confirmed) return;
      }
      if (supaExpense.isEmpty) {
        await HelperToast.warn('Nggak ada transaksi baru untuk diimpor');
        return;
      }
      log('total expense: ${supaExpense.length}');

      /// ----------------------------------------------------------------------------------
      /// # INSERT INTO DB #################################################################
      /// ----------------------------------------------------------------------------------
      ExLoading.show(
        paddingSymmetric: Get.context!.isMobile ? 90 : 200,
        child: VStack([
          CupertinoActivityIndicator().centered(),
          'Lagi mengimpor...'.text.size(11).minFontSize(11).makeCentered().pSymmetric(v: 8),
          '${supaExpense.length} data pengeluaran'.text.size(11).minFontSize(11).makeCentered(),
        ]),
      );

      /// -> expense
      const batchSize = 500;
      for (var offset = 0; offset < supaExpense.length; offset += batchSize) {
        final end = offset + batchSize < supaExpense.length
            ? offset + batchSize
            : supaExpense.length;
        await db
            .from('expense')
            .insert(supaExpense.sublist(offset, end).map((e) => e.toJson()).toList());
      }

      /// refresh all
      await __refresh__();
      ExLoading.dismiss();

      if (customCallback == null) {
        await HelperToast.success('Impor selesai');
      } else {
        customCallback.call();
      }
    } catch (e) {
      ExLoading.dismiss();
      ExAlert.error(title: 'Impor gagal', message: '$e');
    }
  }

  static String _expenseImportKey(SupaExpense expense) {
    final note = _normalizeImportNote(expense.note ?? '');
    final amount = (expense.amount ?? 0).toDouble().toStringAsFixed(2);
    return '${expense.date}|$amount|$note';
  }

  static String _normalizeImportNote(String value) =>
      value.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');

  static Future<Map<String, String>?> _pickImportMapping(
    List<String> headers,
  ) async {
    String find(List<String> candidates) {
      for (final header in headers) {
        final normalized = header.toLowerCase().replaceAll(
          RegExp(r'[^a-z0-9]'),
          '',
        );
        if (candidates.any(normalized.contains)) return header;
      }
      return '';
    }

    final mapping = <String, String>{
      'date': find(['date', 'tanggal']),
      'note': find(['note', 'description', 'merchant', 'keterangan', 'transaksi']),
      'amount': find(['amount', 'nominal', 'debit', 'keluar']),
      'category': find(['category', 'kategori']),
      'detail': find(['detail', 'memo']),
      'created_at': find(['createdat', 'dibuat']),
    };

    return await showDialog<Map<String, String>>(
      context: Get.context!,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          Widget field(String key, String label, {bool required = false}) {
            return DropdownButtonFormField<String>(
              initialValue: mapping[key]!.isEmpty ? null : mapping[key],
              isExpanded: true,
              decoration: InputDecoration(labelText: label),
              items: [
                if (!required)
                  const DropdownMenuItem(value: '', child: Text('Tidak ada')),
                ...headers.map(
                  (header) => DropdownMenuItem(
                    value: header,
                    child: Text(header, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => mapping[key] = value ?? ''),
            ).pOnly(bottom: 10);
          }

          final valid = ['date', 'note', 'amount'].every(
            (key) => mapping[key].isNotEmptyAndNotNull,
          );
          return AlertDialog(
            title: const Text('Mapping kolom CSV'),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: VStack([
                  field('date', 'Tanggal', required: true),
                  field('note', 'Nama transaksi', required: true),
                  field('amount', 'Nominal', required: true),
                  field('category', 'Kategori'),
                  field('detail', 'Detail'),
                  field('created_at', 'Waktu dibuat'),
                ]),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: valid
                    ? () => Navigator.pop(context, Map.of(mapping))
                    : null,
                child: const Text('Lanjut'),
              ),
            ],
          );
        },
      ),
    );
  }

  static Future<bool> _confirmImport(
    List<SupaExpense> expenses, {
    required int invalidRows,
    required int duplicateRows,
  }) async {
    return await showDialog<bool>(
          context: Get.context!,
          builder: (context) => AlertDialog(
            title: const Text('Preview impor'),
            content: SizedBox(
              width: 440,
              child: VStack([
                '${expenses.length} transaksi siap diimpor'.text.bold.make(),
                if (duplicateRows > 0)
                  '$duplicateRows duplikat dilewati'.text
                      .size(11)
                      .color(AppColor.neutral)
                      .make(),
                if (invalidRows > 0)
                  '$invalidRows baris tidak valid dilewati'.text
                      .size(11)
                      .color(AppColor.red)
                      .make(),
                Divider().pSymmetric(v: 8),
                ...expenses.take(5).map(
                  (item) => HStack([
                    '${item.date} · ${item.note}'.text
                        .size(11)
                        .ellipsis
                        .make()
                        .expand(),
                    item.amount!.moneyFormatCompact().text.size(11).make(),
                  ]).pOnly(bottom: 6),
                ),
                if (expenses.length > 5)
                  '+${expenses.length - 5} lainnya'.text
                      .size(10)
                      .color(AppColor.neutral)
                      .make(),
              ]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: expenses.isEmpty
                    ? null
                    : () => Navigator.pop(context, true),
                child: const Text('Impor'),
              ),
            ],
          ),
        ) ??
        false;
  }

  static String? normalizeImportDate(String raw) {
    final value = raw.trim();
    final numeric = RegExp(r'^(\d{1,2})[/-](\d{1,2})[/-](\d{4})$').firstMatch(value);
    if (numeric != null) {
      final day = int.parse(numeric.group(1)!);
      final month = int.parse(numeric.group(2)!);
      final year = int.parse(numeric.group(3)!);
      final date = DateTime(year, month, day);
      if (date.year == year && date.month == month && date.day == day) {
        return DateFormat(yMd).format(date);
      }
      return null;
    }
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return DateFormat(yMd).format(parsed);
    for (final pattern in ['dd MMM yyyy']) {
      try {
        return DateFormat(yMd).format(DateFormat(pattern, 'id_ID').parseStrict(value));
      } catch (_) {}
    }
    return null;
  }

  static num? normalizeImportAmount(String raw) {
    final value = raw.trim().replaceAll(RegExp(r'[^0-9,.-]'), '');
    if (value.isEmpty) return null;
    final lastComma = value.lastIndexOf(',');
    final lastDot = value.lastIndexOf('.');
    final decimalIndex = lastComma > lastDot ? lastComma : lastDot;
    final decimalDigits = decimalIndex == -1 ? 0 : value.length - decimalIndex - 1;
    final normalized = decimalDigits == 2
        ? '${value.substring(0, decimalIndex).replaceAll(RegExp(r'[,.]'), '')}.${value.substring(decimalIndex + 1)}'
        : value.replaceAll(RegExp(r'[,.]'), '');
    return num.tryParse(normalized);
  }

  /// delete all data
  static Future<void> deleteAllData({bool withRefresh = true}) async {
    ExLoading.show(paddingSymmetric: Get.context!.isMobile ? 90 : 250, child: CupertinoActivityIndicator());
    try {
      if (currentUserId == null) return;
      final expenseImagePaths = (await _safeSelectRows('expense'))
          .map((row) => row['image_path']?.toString())
          .whereType<String>()
          .where((path) => path.isNotEmpty)
          .toList();
      await _removeStorageFiles('expense-images', expenseImagePaths);
      await db.from('expense').delete().match({'user_id': currentUserId!});
      for (final table in [
        'recurring_expenses',
        'budgets',
        'asset_snapshots',
        'assets',
        'goals',
        'notes',
        'agent_memory',
        'error_log',
      ]) {
        await db.from(table).delete().eq('user_id', currentUserId!);
      }
      if (withRefresh) await __refresh__();

      ExLoading.dismiss();
    } catch (e) {
      ExLoading.dismiss();
      ExAlert.error(title: 'Gagal menghapus', message: '$e');
    }
  }

  static Future<List<FileObject>> _listAllStorageFiles(
    String bucket, {
    String? path,
  }) async {
    const pageSize = 100;
    final files = <FileObject>[];
    while (true) {
      final page = await db.storage.from(bucket).list(
        path: path,
        searchOptions: SearchOptions(
          limit: pageSize,
          offset: files.length,
        ),
      );
      files.addAll(page);
      if (page.length < pageSize) return files;
    }
  }

  static Future<void> _removeStorageFiles(
    String bucket,
    List<String> paths,
  ) async {
    const batchSize = 1000;
    for (var offset = 0; offset < paths.length; offset += batchSize) {
      final end = offset + batchSize < paths.length
          ? offset + batchSize
          : paths.length;
      await db.storage.from(bucket).remove(paths.sublist(offset, end));
    }
  }

  /// delete account
  static Future<void> deleteAccount() async {
    final userId = currentUserId;
    if (userId == null) return;
    final userEmail = db.auth.currentSession?.user.email;

    ExLoading.show(paddingSymmetric: Get.context!.isMobile ? 90 : 250, child: CupertinoActivityIndicator());
    try {
      final backups = await _listAllStorageFiles('backup');
      final backupPaths = backups
          .where(
            (file) =>
                file.owner == userId ||
                (userEmail != null &&
                    file.name.startsWith('${userEmail}_')),
          )
          .map((file) => file.name)
          .toList();
      await _removeStorageFiles('backup', backupPaths);

      final expenseImages = await _listAllStorageFiles(
        'expense-images',
        path: userId,
      );
      final expenseImagePaths = expenseImages
          .map((file) => '$userId/${file.name}')
          .toList();
      await _removeStorageFiles('expense-images', expenseImagePaths);

      await db.storage.from('avatars').remove(['$userId.png']);
      await db.rpc('delete_own_account');
      await Get.find<SettingsController>().onLogout();
      ExLoading.dismiss();
    } catch (e) {
      ExLoading.dismiss();
      ExSnackbar.dangerTop('$e');
    }
  }

  // ignore: non_constant_identifier_names
  static Future<void> __refresh__() async {
    await Get.find<HomeController>().onInit();
    await Get.find<SettingsController>().onInit();
  }
}
