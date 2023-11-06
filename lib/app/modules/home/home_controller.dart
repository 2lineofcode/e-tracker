import 'dart:collection';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/v1.dart';

import '../../helpers/helper_decoration.dart';
import '../../helpers/helper_misc.dart';
import '../../helpers/helper_money.dart';
import '../../models/category_entity.dart';
import '../../models/expense_entity.dart';
import '../widgets/widgets.dart';
import 'home_repository.dart';

class HomeController extends GetxController with StateMixin {
  /// repo
  final repo = Get.find<HomeRepository>();

  /// calendar
  late PageController calenderPageController;
  final focusedDay = DateTime.now().obs;
  final selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
  );
  final events = <DateTime, List<String>>{}.obs;

  /// category
  final tfCategory = TextEditingController();
  final categoryList = <CategoryEntity>[].obs;
  final categorySelected = ''.obs;

  /// list
  final expenseList = <ExpenseEntity>[].obs;
  final autocompleteNote = <String>[].obs;
  final tfSearchExpense = TextEditingController();

  /// count
  final countOfDay = 0.obs;
  final countOfMonth = 0.obs;

  /// flag
  final isSearchMode = false.obs;
  final isFirstLoad = true.obs;

  /// init ~~
  @override
  Future<void> onInit() async {
    await getCategory();
    await getExpense();
    await _onCalenderRefreshEvent();
    super.onInit();
  }

  /// calendar
  Future<void> onCalenderDayChange(DateTime sDay, DateTime fDay) async {
    focusedDay.value = fDay;
    selectedDays.clear();
    selectedDays.add(fDay);
    await getExpense();
    await _onCalenderRefreshEvent();
  }

  Future<void> onCalenderGoToday() async {
    selectedDays.clear();
    focusedDay.value = DateTime.now();
    await getExpense();
    await _onCalenderRefreshEvent();
  }

  Future<void> onCalenderGoPrevMonth() async {
    calenderPageController.previousPage(duration: 300.milliseconds, curve: Curves.easeIn);
  }

  Future<void> onCalenderGoNextMonth() async {
    calenderPageController.nextPage(duration: 300.milliseconds, curve: Curves.easeIn);
  }

  List<String> onCalenderLoadEvent(DateTime day) {
    final kEvents = LinkedHashMap<DateTime, List<String>>(
      equals: isSameDay,
      hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
    );

    kEvents.addAll(events);
    return kEvents[day] ?? [];
  }

  Future<void> _onCalenderRefreshEvent() async {
    events.clear();
    await repo.getExpenseAll().then((res) {
      // Membuat Map untuk mengelompokkan data berdasarkan tanggal
      Map<DateTime, List<String>> groupedData = {};

      // Iterasi melalui data dan mengelompokkannya
      for (var item in res) {
        var date = item.date!.toDateEx(format: 'yyyy-MM-dd');
        if (groupedData.containsKey(date)) {
          groupedData[date]!.add('${item.amount}');
        } else {
          groupedData[date] = ['${item.amount}'];
        }
      }
      events.addAll(groupedData);
    });

    Get.forceAppUpdate();
  }

  /// category
  Future<void> getCategory() async {
    categoryList.value = await repo.getCategory();
  }

  Future<void> onAddCategory(String categoryName) async {
    if (categoryName.isEmptyOrNull) return;

    final categoryEntity = CategoryEntity(
      id: ExRandom.numeric(8).toInt(),
      name: categoryName,
      createdAt: DateTime.now().toStringEx(),
      color: Vx.randomOpaqueColor.toHex(),
    );
    await repo.addCategory(categoryEntity);
    await getCategory();
    tfCategory.clear();
  }

  Future<void> onEditCategory({CategoryEntity? entity}) async {
    final tfCatName = TextEditingController(text: entity?.name ?? '');
    final tfCatColor = TextEditingController(text: entity?.color ?? '');
    final tfMaxBudget = TextEditingController(text: entity?.maxBudget != null ? entity?.maxBudget!.moneyFormat() : '');

    ExDialog.custom(
      title: 'Edit Category',
      titleTextStyle: TextStyle(fontWeight: FontWeight.bold),
      content: VStack(
        [
          TextField(
            controller: tfCatName,
            decoration: MyDecorationHelper.inputDecorator(hint: 'Name', label: 'Category Name'),
            style: TextStyle(fontSize: 13),
          ).pOnly(bottom: 8),
          TextField(
            controller: tfCatColor,
            decoration: MyDecorationHelper.inputDecorator(hint: 'Color', label: 'Color Tag'),
            style: TextStyle(fontSize: 13, color: HexColor.fromHex(tfCatColor.text)),
            inputFormatters: [LengthLimitingTextInputFormatter(7)],
          ).pOnly(bottom: 8),
          TextField(
            controller: tfMaxBudget,
            decoration: MyDecorationHelper.inputDecorator(
              hint: '1.000.000',
              label: 'Max Budget (Monthtly)',
            ),
            inputFormatters: [
              CurrencyTextInputFormatter(symbol: 'Rp. ', decimalDigits: 0),
              LengthLimitingTextInputFormatter(13),
            ],
            style: TextStyle(fontSize: 13),
          ).pOnly(bottom: 8),
          Divider().pOnly(bottom: 8),
          HStack(
            [
              if (entity!.id!.length > 2) ...[
                ExButtonOutline(
                  label: 'Delete',
                  labelSize: 11,
                  isLabelBold: false,
                  labelColor: Vx.orange300,
                  borderColor: Vx.orange300,
                  radius: 4,
                  onPressed: () async {
                    try {
                      await repo.deleteCategory(entity.id ?? 0);
                      await getCategory();
                      Get.back();
                    } catch (e) {
                      Get.back();
                      ExSnackbar.danger(e);
                    }
                  },
                ),
                8.widthBox,
              ],
              ExButtonOutline(
                label: 'Submit',
                labelSize: 11,
                isLabelBold: false,
                labelColor: Vx.white,
                borderColor: Vx.white,
                radius: 4,
                onPressed: () async {
                  final newEntity = CategoryEntity(
                    id: entity.id,
                    name: tfCatName.text,
                    color: tfCatColor.text.isEmpty ? '#FFFFFF' : tfCatColor.text,
                    icon: null,
                    maxBudget: tfMaxBudget.text.moneyUnformat(),
                    createdAt: DateTime.now().toStringEx(),
                  );
                  await repo.editCategory(newEntity);
                  await getCategory();
                  Get.back();
                },
              ).expand(),
            ],
          ),
        ],
      ),
    );
  }

  /// expense
  Future<void> getExpense({String? find}) async {
    change(0, status: RxStatus.loading());

    final date = focusedDay.value.toStringEx(format: 'yyyy-MM-dd');
    try {
      if (find == null) {
        expenseList.value = await repo.getExpense(date);
        isSearchMode.value = false;
      } else {
        expenseList.value = await repo.findExpense(find);
        isSearchMode.value = true;
      }
    } catch (e) {
      change(0, status: RxStatus.error());
    }

    /// search
    if (find == null) {
      tfSearchExpense.clear();
      isSearchMode.value = false;
    }

    /// count a day
    countOfDay.value = 0;
    for (var element in expenseList) {
      countOfDay.value += element.amount ?? 0;
    }

    /// count a month
    countOfMonth.value = await repo.getCount1Month(focusedDay.value.toStringEx(format: 'yyyy-MM'));

    /// ui state
    if (expenseList.isEmpty) {
      change(0, status: RxStatus.empty());
    } else {
      change(0, status: RxStatus.success());
    }
  }

  Future<void> onShowDialogExpense({ExpenseEntity? expense, Function? customCallback}) async {
    final tfDate = TextEditingController(text: expense != null ? expense.date : '');
    final tfNote = TextEditingController(text: expense != null ? expense.note : '');
    final tfCategory = '${expense != null ? '${expense.categoryName}' : '${categoryList[0].name}'}'.obs;
    final tfAmount = TextEditingController(text: expense != null ? expense.amount!.moneyFormat() : '');

    ExDialog.custom(
      title: expense != null ? 'Edit Expense' : 'Add Expense',
      titleTextStyle: TextStyle(fontWeight: FontWeight.bold),
      width: 250,
      content: VStack(
        [
          if (expense != null) ...[
            TextField(
              controller: tfDate,
              decoration: MyDecorationHelper.inputDecorator(hint: 'Date', label: 'Date'),
              style: TextStyle(fontSize: 13),
              onTap: () => ExDatePicker.datePickerMaterial(callback: (c) => tfDate.text = c.toStringEx(format: 'yyyy-MM-dd')),
            ).wh(250, 33).pOnly(bottom: 16),
          ],
          if (PlatformUtil.isDesktop()) ...[
            MyAutoComplete(
              controller: tfNote,
              autofocus: expense == null,
              decoration: MyDecorationHelper.inputDecorator(hint: 'Nasi Padang', label: 'Notes'),
              inputTextStyle: TextStyle(fontSize: 13),
              asyncSuggestions: (s) async {
                if (s.isEmpty) {
                  return [];
                } else {
                  return await repo.findAutocompleteNote(s);
                }
              },
              progressIndicatorBuilder: CupertinoActivityIndicator(color: Colors.white),
              onChanged: (value) => tfNote.text = value,
              onSubmitted: (value) => tfNote.text = value,
            ).w(250).pOnly(bottom: 16),
          ] else ...[
            TextField(
              controller: tfNote,
              autofocus: expense == null,
              decoration: MyDecorationHelper.inputDecorator(hint: 'Nasi Padang', label: 'Notes'),
              style: TextStyle(fontSize: 13),
            ).wh(250, 33).pOnly(bottom: 16),
          ],
          Obx(
            () => DropdownButtonFormField(
              value: '${tfCategory.value}',
              items: categoryList.map((element) => DropdownMenuItem(value: '${element.name}', child: Text(element.name ?? ''))).toList(),
              style: TextStyle(fontSize: 12, color: Colors.white),
              decoration: MyDecorationHelper.inputDecorator(label: 'Category'),
              onChanged: (s) => tfCategory.value = s ?? '',
            ).wh(250, 33).pOnly(bottom: 16),
          ),
          TextField(
            controller: tfAmount,
            decoration: MyDecorationHelper.inputDecorator(hint: '10.000', label: 'Amount'),
            style: TextStyle(fontSize: 13),
            inputFormatters: [
              CurrencyTextInputFormatter(symbol: 'Rp. ', decimalDigits: 0),
              LengthLimitingTextInputFormatter(13),
            ],
            keyboardType: TextInputType.number,
            onSubmitted: (_) => {
              _submit(tfNote.text, tfCategory.value, tfAmount.text, expense: expense, tfDate: tfDate.text),
              customCallback?.call(),
            },
          ).wh(250, 33).pOnly(bottom: 8),
          Divider().pOnly(bottom: 8),
          HStack(
            [
              if (expense != null) ...[
                ExButtonOutline(
                  label: 'Delete',
                  labelSize: 11,
                  isLabelBold: false,
                  labelColor: Vx.orange300,
                  borderColor: Vx.orange300,
                  radius: 4,
                  onPressed: () async {
                    await repo.deleteExpense(expense.id!);
                    await getExpense();
                    await _onCalenderRefreshEvent();
                    customCallback?.call();

                    Get.back();
                  },
                ).pOnly(right: 8),
              ],
              ExButtonOutline(
                label: 'Submit',
                labelSize: 11,
                isLabelBold: false,
                labelColor: Vx.white,
                borderColor: Vx.white,
                radius: 4,
                onPressed: () => {
                  _submit(tfNote.text, tfCategory.value, tfAmount.text, expense: expense, tfDate: tfDate.text),
                  customCallback?.call(),
                },
              ).expand(),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submit(String tfNote, String tfCategory, String tfAmount, {ExpenseEntity? expense, String? tfDate}) async {
    if (tfNote.isEmptyOrNull) return;
    if (tfCategory.isEmptyOrNull) return;
    if (tfAmount.isEmptyOrNull) return;

    final entity = ExpenseEntity(
      id: expense != null ? expense.id : UuidV1().generate(),
      createdAt: DateTime.now().toStringEx(),
      date: tfDate.isNotEmptyAndNotNull ? tfDate : focusedDay.value.toStringEx(format: 'yyyy-MM-dd'),
      amount: tfAmount.moneyUnformat(),
      categoryName: tfCategory,
      note: tfNote,
    );

    try {
      if (expense != null) {
        await repo.editExpense(entity);
      } else {
        await repo.addExpense(entity);
      }
      await repo.addAutocompleteNote(tfNote);
      await getExpense();
    } catch (e) {
      ExSnackbar.danger('$e', duration: 5);
    }
    await _onCalenderRefreshEvent();
    Get.back(); // close dialog
  }
}
