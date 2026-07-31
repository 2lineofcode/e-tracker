import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart' as csv;
import 'package:ex_kit/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/v4.dart';

import '../core/app_api.dart';
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
      final ex =
          await db //
              .from('expense')
              .select('*')
              .eq('user_id', currentUserId!)
              .order('date', ascending: false)
              .withConverter<List<SupaExpense>>((data) {
                return (data).map((e) => SupaExpense.fromJson(e)).toList();
              });

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
        'goals': await _safeSelectRows('goals'),
        'notes': await _safeSelectRows('notes'),
        'category': await _safeSelectRows('category'),
        'autocomplete': await _safeSelectRows('autocomplete'),
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
      return await db.from(table).select().eq(idColumn, currentUserId!);
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
      List<Map<String, dynamic>> jsonList = [];
      List<String> headers = csvTable[0].map((header) => header.toString()).toList();

      for (int i = 1; i < csvTable.length; i++) {
        Map<String, dynamic> jsonMap = Map.fromIterables(headers, csvTable[i]);
        jsonList.add(jsonMap);
      }

      /// ----------------------------------------------------------------------------------
      /// # EXPENSE ########################################################################
      /// ----------------------------------------------------------------------------------
      final supaExpense = <SupaExpense>[];
      for (var e in jsonList) {
        final category = resolveExpenseCategory(e['category_name'].toString());
        supaExpense.add(
          SupaExpense(
            id: UuidV4().generate(),
            userId: currentUserId ?? '',
            createdAt: e['created_at'].toString(),
            date: e['date'].toString(),
            categoryName: category.code,
            note: e['note'].toString(),
            detail: e['detail'].toString(),
            amount: e['amount'].toString().toNum() ?? 0,
          ),
        );
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
      await db.from('expense').insert(supaExpense.map((e) => e.toJson()).toList());

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

  /// delete all data
  static Future<void> deleteAllData({bool withRefresh = true}) async {
    ExLoading.show(paddingSymmetric: Get.context!.isMobile ? 90 : 250, child: CupertinoActivityIndicator());
    try {
      if (currentUserId == null) return;
      await db.from('expense').delete().match({'user_id': currentUserId!});
      try {
        await db.from('autocomplete').delete().match({'user_id': currentUserId!});
      } on PostgrestException catch (e) {
        if (e.code != 'PGRST205') rethrow;
        logW('autocomplete table not found, skipping delete');
      }
      try {
        await db.from('category').delete().match({'user_id': currentUserId!});
      } on PostgrestException catch (e) {
        if (e.code != 'PGRST205') rethrow;
        logW('category table not found, skipping delete');
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
