import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:ex_kit/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/v4.dart';

import '../../env.g.dart';
import '../core/app_api.dart';
import '../models/supa_autocomplete_entity.dart';
import '../models/supa_category_entity.dart';
import '../models/supa_expense_entity.dart';
import '../modules/home/home_controller.dart';
import '../modules/settings/settings_controller.dart';
import 'helpers.dart';

mixin ImportExportHelper {
  /// export to csv
  static Future<void> exportToCSV({String? customPath, Function(File)? customCallback}) async {
    try {
      String? path;

      /// get path
      if (customPath == null) {
        final abPath = await FilePicker.platform.getDirectoryPath(dialogTitle: 'Save to');
        path = abPath?.replaceAll('/Volumes/Macintosh HD', '');
        if (path == null) return;
      } else {
        path = customPath;
      }

      /// get data
      if (currentUserId == null) {
        ExSnackbar.danger('User not authenticated');
        return;
      }
      final ex = await db //
          .from('expense')
          .select('*, category(*)')
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
        File(csvFilePath).writeAsStringSync(ListToCsvConverter().convert(csvData));
        ExSnackbar.success(csvFilePath);
      } else {
        File(csvFilePath).writeAsStringSync(ListToCsvConverter().convert(csvData));
        customCallback.call(File(csvFilePath));
      }
    } catch (e) {
      ExSnackbar.danger('$e');
    }
  }

  /// import from csv
  static Future<void> importFromCSV({String? customPath, Function()? customCallback}) async {
    try {
      String? path;

      /// get path
      if (customPath == null) {
        final result = await FilePicker.platform.pickFiles(allowedExtensions: ['csv'], type: FileType.custom);
        if (result == null) return;
        path = result.files.first.path ?? '';
      } else {
        path = customPath;
      }

      /// ----------------------------------------------------------------------------------
      /// # CVS TO JSON ####################################################################
      /// ----------------------------------------------------------------------------------
      final csvString = await File(path).readAsString();
      List<List<dynamic>> csvTable = CsvToListConverter().convert(csvString);
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
      for (var e in jsonList)
        supaExpense.add(
          SupaExpense(
            id: UuidV4().generate(),
            userId: currentUserId ?? '',
            createdAt: e['created_at'].toString(),
            date: e['date'].toString(),
            categoryName: e['category_name'].toString(),
            note: e['note'].toString(),
            detail: e['detail'].toString(),
            amount: e['amount'].toString().toNum() ?? 0,
          ),
        );
      log('total expense: ${supaExpense.length}');

      /// ----------------------------------------------------------------------------------
      /// # CATEGORY #######################################################################
      /// ----------------------------------------------------------------------------------
      final supaCategory = <SupaCategory>[];
      for (var e in supaExpense) {
        // add into supaCategory, unique by e.categoryName
        if (!supaCategory.any((element) => element.name == e.categoryName)) {
          supaCategory.add(
            SupaCategory(
              id: UuidV4().generate(),
              userId: currentUserId ?? '',
              createdAt: DateTime.now().toStringEx(),
              color: Vx.randomPrimaryColor.toHex(),
              icon: 'code=59513&family=LineAwesomeIcons&pack=flutter_iconpicker_plus',
              maxBudget: null,
              name: '${e.categoryName}',
              isProtect: false,
            ),
          );
        }
      }

      /// add new category, but do not edit existing data.
      final oldCategory = Get.find<HomeController>().categoryList;
      final newCategory = <SupaCategory>[];
      for (var e in supaCategory) {
        if (!oldCategory.any((element) => element.name == e.name)) {
          newCategory.add(e);
        }
      }
      log('total category: ${newCategory.length}');

      /// ----------------------------------------------------------------------------------
      /// # AUTOCOMPLETE ###################################################################
      /// ----------------------------------------------------------------------------------
      final supaAutoComplete = <SupaAutoComplete>[];
      for (var e in supaExpense) {
        supaAutoComplete.add(
          SupaAutoComplete(
            id: UuidV4().generate(),
            userId: currentUserId ?? '',
            createdAt: DateTime.now().toStringEx(),
            amount: e.amount.toString(),
            categoryName: e.categoryName.toString(),
            note: e.note?.toTitleCase ?? '',
          ),
        );
      }

      /// `supaAutoComplete` remove duplicate by note
      List<SupaAutoComplete> removeDuplicates(List<SupaAutoComplete> list) {
        List<SupaAutoComplete> uniqueList = [];
        Set<String> seen = {};
        for (var obj in list) {
          if (seen.add(obj.note ?? '')) uniqueList.add(obj);
        }
        return uniqueList;
      }

      final uniqueAutoComplete = removeDuplicates(supaAutoComplete);

      /// add new autocomplete, but do not edit existing data.
      final oldAutoComplete = Get.find<SettingsController>().autoCompleteList;
      final newAutoComplete = <SupaAutoComplete>[];
      for (var e in uniqueAutoComplete) {
        if (!oldAutoComplete.any((element) => element.note == e.note)) {
          newAutoComplete.add(e);
        }
      }
      log('total autocomplete: ${newAutoComplete.length}');

      /// ----------------------------------------------------------------------------------
      /// # INSERT INTO DB #################################################################
      /// ----------------------------------------------------------------------------------
      ExLoading.show(
        paddingSymmetric: Get.context!.isMobile ? 90 : 200,
        child: VStack([
          CupertinoActivityIndicator().centered(),
          'Importing...'.text.size(11).minFontSize(11).makeCentered().pSymmetric(v: 8),
          '${supaExpense.length} expense data'.text.size(11).minFontSize(11).makeCentered(),
          '${newCategory.length} new category'.text.size(11).minFontSize(11).makeCentered(),
          '${newAutoComplete.length} autocomplete data'.text.size(11).minFontSize(11).makeCentered(),
        ]),
      );

      /// -> category
      await db.from('category').upsert(newCategory.map((e) => e.toJson()).toList());

      /// -> expense
      await db.from('expense').insert(supaExpense.map((e) => e.toJson()).toList());

      /// -> autocomplete
      await db.from('autocomplete').upsert(newAutoComplete.map((e) => e.toJson()).toList());

      /// refresh all
      await __refresh__();
      ExLoading.dismiss();

      if (customCallback == null) {
        OverlayHelper.notification('Import Done', duration: 4.seconds);
      } else {
        customCallback.call();
      }
    } catch (e) {
      ExLoading.dismiss();
      ExAlert.error(title: 'Import Failed', message: '$e');
    }
  }

  /// delete all data
  static Future<void> deleteAllData({bool withRefresh = true}) async {
    ExLoading.show(paddingSymmetric: Get.context!.isMobile ? 90 : 250, child: CupertinoActivityIndicator());
    try {
      if (currentUserId == null) return;
      await db.from('expense').delete().match({'user_id': currentUserId!});
      await db.from('autocomplete').delete().match({'user_id': currentUserId!});
      await db.from('category').delete().match({'user_id': currentUserId!});
      if (withRefresh) await __refresh__();

      ExLoading.dismiss();
    } catch (e) {
      ExLoading.dismiss();
      ExAlert.error(title: 'Delete Failed', message: '$e');
    }
  }

  /// delete account
  static Future<void> deleteAccount() async {
    final dbAdmin = SupabaseClient(Env.supabaseUrl, Env.supabaseServiceRole);

    ExLoading.show(paddingSymmetric: Get.context!.isMobile ? 90 : 250, child: CupertinoActivityIndicator());
    try {
      await deleteAllData(withRefresh: false);

      if (currentUserId == null) return;
      await db.storage.from('avatars').remove(['$currentUserId.png']);
      await dbAdmin.auth.admin.deleteUser(currentUserId!);
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
