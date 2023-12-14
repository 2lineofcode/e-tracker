import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:ex/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/v4.dart';

import '../core/app_base.dart';
import '../models/category_entity.dart';
import '../models/expense_entity.dart';

mixin SeedHelper {
  /// generate
  static void generate() async {
    await genCategory();
    await genExpense();
  }

  static Future<void> genCategory() async {
    /// check if category table is empty
    final check = await db.from('category').select().withConverter<List<CategoryEntity>>((data) {
      return (data).map((e) => CategoryEntity.fromJson(e)).toList();
    });

    /// if category table is empty just return~
    if (check.isNotEmpty) return;

    log('-- seed data category --');

    /// category table is empty, seed data
    final _catFood = CategoryEntity(
      id: UuidV4().generate(),
      name: 'Food',
      icon: 'code=58566&family=FontAwesomeSolid&pack=font_awesome_flutter',
      color: '#ffb7bdb9',
      maxBudget: 1000000,
      createdAt: DateTime.now().toStringEx(),
    ).toJson();
    final _catNotes = CategoryEntity(
      id: UuidV4().generate(),
      name: 'Notes',
      icon: 'code=63033&family=CupertinoIcons&pack=cupertino_icons',
      color: '#ffffffff',
      createdAt: DateTime.now().toStringEx(),
    ).toJson();
    final _catOthers = CategoryEntity(
      id: UuidV4().generate(),
      name: 'Others',
      color: Vx.purpleHex200,
      createdAt: DateTime.now().toStringEx(),
    ).toJson();

    await db.from('category').insert([_catFood, _catNotes, _catOthers]);
  }

  static Future<void> genExpense() async {
    /// check if expense table is empty
    final check = await db.from('expense').select().withConverter<List<ExpenseEntity>>((data) {
      return (data).map((e) => ExpenseEntity.fromJson(e)).toList();
    });

    /// if category table is empty just return~
    if (check.isNotEmpty) return;

    final _expense = ExpenseEntity(
      id: UuidV4().generate(),
      note: 'Example Note',
      categoryName: 'Notes',
      amount: 0,
      detail: 'here is detail of note',
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
      final ex = await db.from('expense').select('*').limit(100000).withConverter<List<ExpenseEntity>>((data) {
        return (data).map((e) => ExpenseEntity.fromJson(e)).toList();
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
        'id',
        'created_at',
        'category_name',
        'note',
        'amount',
        'date',
        'user_id',
        'detail',
      ]);

      // Items CSV
      for (var data in jsonDataFromJsonFile) {
        csvData.add([
          data['id'].toString(),
          data['created_at'].toString(),
          data['category_name'].toString(),
          data['note'].toString(),
          data['amount'].toString(),
          data['date'].toString(),
          data['user_id'].toString(),
          data['detail'].toString(),
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
}
