import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:ex/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:uuid/v4.dart';

import '../core/app_api.dart';
import '../models/category_entity.dart';
import '../models/expense_entity.dart';
import '../modules/home/home_controller.dart';

mixin SeedHelper {
  /// generate
  static Future<void> generate() async {
    // await genCategory();
    // await genExpense();
  }

  static Future<void> genCategory() async {
    /// check if category table is empty
    final check = await db //
        .from('category')
        .select()
        .eq('user_id', db.auth.currentSession?.user.id ?? '')
        .withConverter<List<Category>>((data) {
      return (data).map((e) => Category.fromJson(e)).toList();
    });

    /// if category table is empty just return~
    if (check.isNotEmpty) return;

    log('-- seed data category --');

    /// category table is empty, seed data
    final _catFood = Category(
      id: UuidV4().generate(),
      userId: db.auth.currentSession?.user.id ?? '',
      name: 'Food',
      icon: 'code=58566&family=FontAwesomeSolid&pack=font_awesome_flutter',
      color: '#ffb7bdb9',
      maxBudget: 1000000,
      createdAt: DateTime.now().toStringEx(),
    ).toJson();
    final _catNotes = Category(
      id: UuidV4().generate(),
      userId: db.auth.currentSession?.user.id ?? '',
      name: 'Notes',
      icon: 'code=63033&family=CupertinoIcons&pack=cupertino_icons',
      color: '#ffffffff',
      createdAt: DateTime.now().toStringEx(),
    ).toJson();
    final _catOthers = Category(
      id: UuidV4().generate(),
      userId: db.auth.currentSession?.user.id ?? '',
      name: 'Others',
      color: Vx.purpleHex200,
      createdAt: DateTime.now().toStringEx(),
    ).toJson();

    await db.from('category').insert([_catFood, _catNotes, _catOthers]);
  }

  static Future<void> genExpense() async {
    /// check if expense table is empty
    final check = await db //
        .from('expense')
        .select()
        .eq('user_id', db.auth.currentSession?.user.id ?? '')
        .withConverter<List<Expense>>((data) {
      return (data).map((e) => Expense.fromJson(e)).toList();
    });

    /// if category table is empty just return~
    if (check.isNotEmpty) return;

    final _expense = Expense(
      id: UuidV4().generate(),
      userId: db.auth.currentSession?.user.id ?? '',
      categoryName: 'Notes',
      note: 'Hi, Welcome!',
      detail: 'First day of starting the habit of recording expenses',
      amount: 0,
      date: DateTime.now().toStringEx(format: 'yyyy-MM-dd'),
      createdAt: DateTime.now().toStringEx(),
    ).toJson();
    await db.from('expense').insert(_expense);
  }

  static Future<void> exportToCSV() async {
    try {
      /// select directory
      String? abPath = await FilePicker.platform.getDirectoryPath(dialogTitle: 'Save to');
      final path = abPath?.replaceAll('/Volumes/Macintosh HD', '');
      if (path == null) return;

      /// get data
      final ex = await db //
          .from('expense')
          .select('*')
          .eq('user_id', db.auth.currentSession?.user.id ?? '')
          .order('date', ascending: false)
          .withConverter<List<Expense>>((data) {
        return (data).map((e) => Expense.fromJson(e)).toList();
      });

      final jsonFilePath = '$path/output.json';
      final csvFilePath = '$path/output.csv';

      /// Save Json Data in Json File
      File(jsonFilePath).writeAsStringSync(jsonEncode(ex));

      // read Json Data From Files
      var jsonContent = File(jsonFilePath).readAsStringSync();
      final jsonDataFromJsonFile = jsonDecode(jsonContent);

      /// Create CSV
      List<List<dynamic>> csvData = [];

      /// Header CSV
      csvData.add([
        // 'id',
        // 'created_at',
        'date',
        'category_name',
        'note',
        'detail',
        'amount',
        // 'user_id',
      ]);

      // Items CSV
      for (var data in jsonDataFromJsonFile) {
        csvData.add([
          // data['id'].toString(),
          // data['created_at'].toString(),
          data['date'].toString(),
          data['category_name'].toString(),
          data['note'].toString(),
          data['detail'].toString(),
          // data['user_id'].toString(),
          data['amount'].toString(),
        ]);
      }

      /// delete json file
      File(jsonFilePath).deleteSync();

      /// export to csv
      File(csvFilePath).writeAsStringSync(ListToCsvConverter().convert(csvData));
      ExSnackbar.success(csvFilePath);
    } catch (e) {
      ExSnackbar.danger('$e');
    }
  }

  static Future<void> importFromCSV() async {
    try {
      final result = await FilePicker.platform.pickFiles(allowedExtensions: ['csv'], type: FileType.custom);
      if (result == null) return;

      String path = result.files.first.path ?? '';

      final csvString = await File(path).readAsString();
      List<List<dynamic>> csvTable = CsvToListConverter().convert(csvString);

      List<Map<String, dynamic>> jsonList = [];
      List<String> headers = csvTable[0].map((header) => header.toString()).toList();

      for (int i = 1; i < csvTable.length; i++) {
        Map<String, dynamic> jsonMap = Map.fromIterables(headers, csvTable[i]);
        jsonList.add(jsonMap);
      }

      String jsonString = jsonEncode(jsonList);
      // log('jsonString: $jsonString');

      ExLoading.show();
      await db.from('expense').insert(jsonString);
      await Get.find<HomeController>().getExpense();
      ExLoading.dismiss();
      ExSnackbar.success('Task Done');
    } catch (e) {
      ExSnackbar.danger('$e');
    }
  }
}
