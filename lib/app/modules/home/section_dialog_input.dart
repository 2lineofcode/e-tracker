import 'dart:convert';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:ex_kit/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';
import 'package:get/get.dart';
import 'package:hsv_color_pickers/hsv_color_pickers.dart';
import 'package:intl/intl.dart';
import 'package:uuid/v4.dart';

import '../../core/app_api.dart';
import '../../core/app_color.dart';
import '../../core/app_setting.dart';
import '../../core/const.dart';
import '../../helpers/helpers.dart';
import '../../models/supa_autocomplete_entity.dart';
import '../../models/supa_category_entity.dart';
import '../../models/supa_expense_entity.dart';
import '../widgets/widget_autocomplete.dart';
import 'home_controller.dart';
import 'home_repository.dart';

/// [DialogInputHelper]
/// - [showDialogCategory]
/// - [showDialogExpense]
///   - [dialogExpenseAI]
///   - [_dialogExpenseMobile]
///   - [_dialogExpenseDesktop]
/// - [_deleteExpense]
/// - [_submitExpense]
/// This class provides helper methods for dialog input functionality.
/// It is designed to be shared and can be used in multiple pages.
/// The class includes methods for handling dialog categories.
mixin DialogInputHelper {
  /// ------------------------------------------------------------------------
  /// Dialog Category
  /// ------------------------------------------------------------------------
  static Future<void> showDialogCategory({SupaCategory? category, Function? callback}) async {
    final _controller = Get.find<HomeController>();

    final _tfCatName = TextEditingController(text: category?.name ?? '');
    final _tfCatColor = TextEditingController(text: category?.color ?? '');
    final _tfMaxBudget = TextEditingController(text: category?.maxBudget != null ? category?.maxBudget!.moneyFormat() : '');
    final _hueController = HueController(HSVColor.fromColor(_tfCatColor.text.fromHex)).obs;
    final _iconSelected = (category?.icon?.getIconData() ?? Icons.circle_outlined).obs;

    final isProtect = category!.name!.contains('Others') == false && category.name!.contains('Notes') == false;
    final isNotes = category.name!.contains('Notes');

    DialogHelper.ios(
      content: VStack(
        [
          Text('Edit Category', style: TextStyle(fontWeight: FontWeight.bold)).pOnly(bottom: 24),
          CupertinoTextField(
            controller: _tfCatName,
            placeholder: 'Category Name',
            placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
            prefix: Icon(CupertinoIcons.number, size: 16, color: AppColor.textReverse).pOnly(left: 8),
            style: TextStyle(fontSize: 13, color: AppColor.textReverse),
            enabled: isProtect,
          ).pOnly(bottom: 12),
          Visibility(
            visible: isNotes == false,
            child: CupertinoTextField(
              controller: _tfMaxBudget,
              placeholder: 'Max Budget (Monthtly)',
              placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
              prefix: Icon(CupertinoIcons.bag_fill, size: 16, color: AppColor.textReverse).pOnly(left: 8),
              style: TextStyle(fontSize: 13, color: AppColor.textReverse),
              inputFormatters: [
                CurrencyTextInputFormatter(NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp.', decimalDigits: 0)),
                LengthLimitingTextInputFormatter(16),
              ],
              keyboardType: TextInputType.number,
              onSubmitted: (_) async {
                await _submitCategory(
                  category: category,
                  name: _tfCatName.text,
                  color: _tfCatColor.text,
                  icon: _iconSelected.value.setIconData() ?? '',
                  maxBudget: _tfMaxBudget.text,
                  callback: callback,
                );
              },
            ).pOnly(bottom: 8),
          ),
          HStack(
            [
              /// icon preview
              GetBuilder<HomeController>(
                init: HomeController(),
                initState: (_) {},
                builder: (_) {
                  return Icon(
                    _iconSelected.value,
                    size: 18,
                    color: _hueController.value.value.toColor(),
                  ).pOnly(right: 8).tooltip('Click to change icon').onTap(() async {
                    await showIconPicker(
                      Get.context!,
                      configuration: SinglePickerConfiguration(
                        iconPickerShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        iconSize: 20,
                        searchComparator: (s, i) => s.toLowerCase().contains(i.name.replaceAll('_', ' ').toLowerCase()) || i.name.toLowerCase().contains(s.toLowerCase()),
                        constraints: BoxConstraints(maxWidth: 250, maxHeight: 250),
                        title: Text('Select Icon', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        iconPackModes: [
                          IconPack.lineAwesomeIcons,
                          IconPack.custom,
                          IconPack.cupertino,
                          IconPack.allMaterial,
                          IconPack.fontAwesomeIcons,
                        ],
                      ),
                    ).then((icon) {
                      if (icon != null) _iconSelected.value = icon.data;
                      _controller.update();
                    });
                  });
                },
              ),

              /// hue picker
              GetBuilder(
                init: HomeController(),
                initState: (_) {},
                builder: (_) {
                  return HuePicker(
                    controller: _hueController.value,
                    onChanged: (HSVColor color) {
                      _hueController.value.value = color;
                      _tfCatColor.text = color.toColor().toHex();
                      _controller.update();
                    },
                  ).wh(200, 24);
                },
              ),
            ],
          ).pSymmetric(v: 12),
          HStack(
            [
              Spacer(),
              Text(
                'More Color',
                style: TextStyle(fontSize: 11, decoration: TextDecoration.underline),
              ).pOnly(right: 8).onTap(() async {
                /// open dialog more color
                DialogHelper.ios(
                  content: VStack(
                    [
                      Text('Pick Custom Color', style: TextStyle(fontWeight: FontWeight.bold)).pOnly(bottom: 24),
                      Text('Current color set:', style: TextStyle(fontSize: 12)).pOnly(bottom: 8),
                      Wrap(
                        children: [
                          for (var i = 0; i < _controller.categoryList.length; i++) ...[
                            Icon(
                              _controller.categoryList[i].icon?.getIconData() ?? Icons.circle_outlined,
                              color: _controller.categoryList[i].color?.fromHex,
                              size: 20,
                            ).pOnly(right: 8, bottom: 8),
                          ],
                        ],
                      ).pOnly(bottom: 8),
                      Text('Edit For:', style: TextStyle(fontSize: 12)).pOnly(bottom: 8),
                      GetBuilder<HomeController>(
                        init: HomeController(),
                        initState: (_) {},
                        builder: (_) {
                          return Icon(
                            category.icon?.getIconData() ?? Icons.circle_outlined,
                            color: _hueController.value.value.toColor(),
                            size: 20,
                          );
                        },
                      ),
                      ColorPicker(
                        pickerColor: _tfCatColor.text.fromHex,
                        // colorPickerWidth: 300,
                        pickerAreaHeightPercent: 0.5,
                        labelTypes: [],
                        displayThumbColor: true,
                        paletteType: PaletteType.hsl,
                        pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(12)),
                        portraitOnly: true,
                        onColorChanged: (s) async {
                          _hueController.value.value = HSVColor.fromColor(s);
                          _tfCatColor.text = '#${s.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
                        },
                      ).pSymmetric(v: 8),
                    ],
                  ),
                  actions: [
                    CupertinoDialogAction(
                      child: Text('Submit', style: TextStyle(fontSize: 13)),
                      onPressed: () => Get.back(),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ).h(185),
      actions: [
        if (isProtect) ...[
          CupertinoDialogAction(
            child: Text('Delete', style: TextStyle(fontSize: 13, color: Vx.red500)),
            onPressed: () async => await _deleteCategory(category: category, callback: callback),
          ),
        ],
        CupertinoDialogAction(
          child: Text('Submit', style: TextStyle(fontSize: 13)),
          onPressed: () async {
            await _submitCategory(
              category: category,
              name: _tfCatName.text,
              color: _tfCatColor.text,
              icon: _iconSelected.value.setIconData() ?? '',
              maxBudget: _tfMaxBudget.text,
              callback: callback,
            );
          },
        ),
      ],
    );
  }

  /// ------------------------------------------------------------------------
  /// Dialog Expense
  /// ------------------------------------------------------------------------
  static Future<void> showDialogExpense({SupaExpense? expense, Function? customCallback}) async {
    if (Get.context!.isMobile) {
      await _dialogExpenseMobile(expense: expense, customCallback: customCallback);
    } else {
      await _dialogExpenseDesktop(expense: expense, customCallback: customCallback);
    }
  }

  static Future<void> _dialogExpenseMobile({SupaExpense? expense, Function? customCallback}) async {
    final _controller = Get.find<HomeController>();
    final _repo = Get.find<HomeRepository>();

    if (_controller.categoryList.isEmptyOrNull) {
      OverlayHelper.notification('Please Creete at least 1 category', color: Vx.red600, duration: 3.seconds);
      return;
    }

    final _tfDate = TextEditingController(text: expense != null ? expense.date : '');
    final _tfNote = TextEditingController(text: expense != null ? expense.note : '');
    final _tfDescription = TextEditingController(text: expense != null ? expense.detail : '');
    final _tfCategory = '${expense != null ? '${expense.categoryName}' : '${_controller.categoryList[0].name}'}'.obs;
    final _tfAmount = TextEditingController(text: expense != null ? expense.amount!.moneyFormat() : '');

    /// flag
    final isShowDetail = expense != null && expense.detail.isNotEmptyAndNotNull ? true.obs : false.obs;
    final isTypeNotes = expense != null && expense.categoryName == 'Notes' ? true.obs : false.obs;
    final debouncer = DebounceSearch(duration: 200.milliseconds);

    ExBottomSheet.basic(
      title: '${expense != null ? 'Edit Expense' : 'Add Expense'}',
      content: VStack(
        [
          if (expense != null) ...[
            CupertinoTextField(
              controller: _tfDate,
              readOnly: true,
              placeholder: 'Date',
              decoration: BoxDecoration(
                color: Get.isDarkMode ? Vx.black : Vx.white,
                borderRadius: BorderRadius.circular(4),
              ),
              placeholderStyle: TextStyle(fontSize: 13),
              prefix: Icon(CupertinoIcons.calendar_today, size: 16, color: AppColor.textReverse).pOnly(left: 8),
              style: TextStyle(fontSize: 13, color: AppColor.textReverse),
              onTap: () => ExDatePicker.materialDatePicker(
                initialDate: expense.date?.toDateEx(format: yMd),
                minDate: DateTime(2020),
                callback: (c) => _tfDate.text = c.toStringEx(format: yMd),
              ),
            ).pOnly(bottom: 16),
          ],

          MyAutoComplete(
            autofocus: expense == null,
            initialValue: _tfNote.value,
            decoration: BoxDecoration(
              color: Get.isDarkMode ? Vx.black : Vx.white,
              borderRadius: BorderRadius.circular(4),
            ),
            asyncSuggestions: (s) async {
              if (s.text.isBlank!) return [];
              return await debouncer.run(() async {
                return await _repo.findAutoCompleteStringNote(s.text);
              });
            },
            hint: 'Note: Nasi Padang',
            onChanged: (s) => _tfNote.text = s,
            onSelected: (s) async {
              _tfNote.text = s;
              await _repo.findAutoCompleteFullObject(s).then((res) {
                _tfCategory.value = res[0].categoryName ?? '';
                _tfAmount.text = res[0].amount?.toInt()?.moneyFormat() ?? '';
              });
            },
          ),

          HStack(
            [
              Spacer(),
              Text(
                'with Detail?',
                style: TextStyle(fontSize: 11, decoration: TextDecoration.underline),
              ).onInkTap(() {
                isShowDetail.value = !isShowDetail.value;
              }),
            ],
          ).pOnly(bottom: 12, top: 6),

          /// description / detail
          Obx(
            () => Visibility(
              visible: isShowDetail.value,
              child: CupertinoTextField(
                controller: _tfDescription,
                placeholder: 'Detail: Nama Toko/Waktu',
                placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
                style: TextStyle(fontSize: 13, color: AppColor.textReverse),
                minLines: 5,
                maxLines: 15,
                textAlignVertical: TextAlignVertical.top,
                textAlign: TextAlign.left,
                clearButtonMode: OverlayVisibilityMode.editing,
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? Vx.black : Vx.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ).pOnly(bottom: 16),
            ),
          ),

          /// field category
          Obx(
            () => DropdownButtonFormField(
              initialValue: '${_tfCategory.value}',
              style: TextStyle(fontSize: 12, color: AppColor.textReverse),
              decoration: DecorationHelper.input(
                fillColor: Get.isDarkMode ? Vx.black : Vx.white,
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 0,
                    style: BorderStyle.solid,
                    color: Get.isDarkMode ? Vx.black : Vx.white,
                  ),
                ),
              ),
              icon: 0.heightBox,
              items: _controller.categoryList.map((element) {
                return DropdownMenuItem(
                  value: '${element.name}',
                  child: HStack(
                    alignment: MainAxisAlignment.spaceEvenly,
                    [
                      Icon(
                        element.icon?.getIconData() ?? Icons.circle_outlined,
                        size: 16,
                        color: element.color?.fromHex,
                      ).pOnly(right: 8),
                      Text(element.name ?? ''),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (s) {
                _tfCategory.value = s ?? '';
                if (s!.contains('Notes')) {
                  _tfAmount.text = 'Rp. 0';
                  isTypeNotes.value = true;
                  isShowDetail.value = true;
                } else {
                  _tfAmount.text = expense?.amount?.moneyFormat() ?? '';
                  isTypeNotes.value = false;
                  isShowDetail.value = false;
                }
              },
            ).wh(double.infinity, 32).pOnly(bottom: 16),
          ),

          /// field amount
          Obx(
            () => Visibility(
              visible: isTypeNotes.isFalse,
              child: CupertinoTextField(
                controller: _tfAmount,
                placeholder: 'Rp. 10.000',
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? Vx.black : Vx.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
                style: TextStyle(fontSize: 13, color: AppColor.textReverse),
                prefix: IconButton(
                  icon: Icon(Icons.calculate, size: 14, color: AppColor.textReverse),
                  onPressed: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: Get.context!,
                      builder: (context) => FractionallySizedBox(
                        heightFactor: 0.7,
                        child: SimpleCalculator(
                          autofocus: true,
                          hideSurroundingBorder: true,
                          value: _tfAmount.text.moneyUnformat()?.toDouble() ?? 0.0,
                          onTappedDisplay: (p0, p1) => Get.back(),
                          onChanged: (key, value, expression) {
                            final moneyFormat = value!.toString().toInt()?.moneyFormat() ?? '';
                            _tfAmount.text = moneyFormat;
                          },
                        ),
                      ),
                    );
                  },
                ),
                inputFormatters: [
                  CurrencyTextInputFormatter(NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp.', decimalDigits: 0)),
                  LengthLimitingTextInputFormatter(16),
                ],
                keyboardType: TextInputType.number,
                onSubmitted: (_) async => {
                  await _submitExpense(_tfNote.text, _tfDescription.text, _tfCategory.value, _tfAmount.text, expense: expense, tfDate: _tfDate.text, customCallback: customCallback),
                },
              ).h(32),
            ),
          ),

          Divider().pSymmetric(v: 12),

          /// action
          HStack(
            [
              if (expense != null) ...[
                ExButtonElevated(
                  child: Text('Delete', style: TextStyle(color: Vx.red500, fontSize: 13)),
                  onPressed: () async => await _deleteExpense(expense: expense, callback: customCallback),
                ).pOnly(right: 12).expand(),
              ],
              ExButtonElevated(
                child: Text('Submit', style: TextStyle(fontSize: 13)),
                onPressed: () async {
                  await _submitExpense(_tfNote.text, _tfDescription.text, _tfCategory.value, _tfAmount.text, expense: expense, tfDate: _tfDate.text, customCallback: customCallback);
                },
              ).expand(),
            ],
          ).pOnly(bottom: 12),
        ],
      ),
    );
  }

  static Future<void> _dialogExpenseDesktop({SupaExpense? expense, Function? customCallback}) async {
    // local inject
    final _controller = Get.find<HomeController>();
    final _repo = Get.find<HomeRepository>();

    if (_controller.categoryList.isEmptyOrNull) {
      OverlayHelper.notification('Please Creete at least 1 category', color: Vx.red600, duration: 3.seconds);
      return;
    }

    final _tfDate = TextEditingController(text: expense != null ? expense.date : '');
    final _tfNote = TextEditingController(text: expense != null ? expense.note : '');
    final _tfDescription = TextEditingController(text: expense != null ? expense.detail : '');
    final _tfCategory = '${expense != null ? '${expense.categoryName}' : '${_controller.categoryList[0].name}'}'.obs;
    final _tfAmount = TextEditingController(text: expense != null ? expense.amount!.moneyFormat() : '');

    /// flag
    final isShowDetail = expense != null && expense.detail.isNotEmptyAndNotNull ? true.obs : false.obs;
    final isTypeNotes = expense != null && expense.categoryName == 'Notes' ? true.obs : false.obs;
    final debouncer = DebounceSearch(duration: 200.milliseconds);

    DialogHelper.ios(
      title: Text(
        '${expense != null ? 'Edit Expense' : 'Add Expense'}',
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.left,
      ).pOnly(bottom: 16),
      content: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.enter): () {
            _submitExpense(_tfNote.text, _tfDescription.text, _tfCategory.value, _tfAmount.text, expense: expense, tfDate: _tfDate.text, customCallback: customCallback);
          },
        },
        child: Focus(
          autofocus: false,
          child: VStack(
            [
              /// field select date: edit mode only
              if (expense != null) ...[
                CupertinoTextField(
                  controller: _tfDate,
                  readOnly: true,
                  placeholder: 'Date',
                  placeholderStyle: TextStyle(fontSize: 13),
                  decoration: BoxDecoration(
                    color: Get.isDarkMode ? Vx.black : Vx.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  prefix: Icon(CupertinoIcons.calendar_today, size: 16, color: AppColor.textReverse).pOnly(left: 8),
                  style: TextStyle(fontSize: 13, color: AppColor.textReverse),
                  onTap: () => ExDatePicker.materialDatePicker(
                    initialDate: expense.date?.toDateEx(format: yMd),
                    minDate: DateTime(2020),
                    callback: (c) => _tfDate.text = c.toStringEx(format: yMd),
                  ),
                ).pOnly(bottom: 16),
              ],

              MyAutoComplete(
                autofocus: false,
                initialValue: _tfNote.value,
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? Vx.black : Vx.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                asyncSuggestions: (s) async {
                  if (s.text.isBlank!) return [];
                  return await debouncer.run(() async {
                    return await _repo.findAutoCompleteStringNote(s.text);
                  });
                },
                hint: 'Note: Nasi Padang',
                onChanged: (s) => _tfNote.text = s,
                onSelected: (s) async {
                  _tfNote.text = s;
                  await _repo.findAutoCompleteFullObject(s).then((res) {
                    _tfCategory.value = res[0].categoryName ?? '';
                    _tfAmount.text = res[0].amount?.toInt()?.moneyFormat() ?? '';
                  });
                },
              ),

              HStack(
                [
                  Spacer(),
                  Text(
                    'with Detail?',
                    style: TextStyle(fontSize: 11, decoration: TextDecoration.underline),
                  ).onInkTap(() {
                    isShowDetail.value = !isShowDetail.value;
                  }),
                ],
              ).pOnly(bottom: 12, top: 6),

              /// description / detail
              Obx(
                () => Visibility(
                  visible: isShowDetail.value,
                  child: CupertinoTextField(
                    controller: _tfDescription,
                    placeholder: 'Detail: Nama Toko/Waktu',
                    decoration: BoxDecoration(
                      color: Get.isDarkMode ? Vx.black : Vx.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
                    style: TextStyle(fontSize: 13, color: AppColor.textReverse),
                    minLines: 3,
                    maxLines: 15,
                    clearButtonMode: OverlayVisibilityMode.editing,
                  ).pOnly(bottom: 16),
                ),
              ),

              /// field category
              Obx(
                () => DropdownButtonFormField(
                  initialValue: '${_tfCategory.value}',
                  style: TextStyle(fontSize: 12, color: AppColor.textReverse),
                  decoration: DecorationHelper.input(
                    fillColor: Get.isDarkMode ? Vx.black : Vx.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 0,
                        style: BorderStyle.solid,
                        color: Get.isDarkMode ? Vx.black : Vx.white,
                      ),
                    ),
                  ),
                  icon: 0.heightBox,
                  items: _controller.categoryList.map((element) {
                    return DropdownMenuItem(
                      value: '${element.name}',
                      child: HStack(
                        alignment: MainAxisAlignment.spaceEvenly,
                        [
                          Icon(
                            element.icon?.getIconData() ?? Icons.circle_outlined,
                            size: 16,
                            color: element.color?.fromHex,
                          ).pOnly(right: 8),
                          Text(element.name ?? ''),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (s) {
                    _tfCategory.value = s ?? '';
                    if (s!.contains('Notes')) {
                      _tfAmount.text = 'Rp. 0';
                      isTypeNotes.value = true;
                      isShowDetail.value = true;
                    } else {
                      _tfAmount.text = expense?.amount?.moneyFormat() ?? '';
                      isTypeNotes.value = false;
                      isShowDetail.value = false;
                    }
                  },
                ).wh(double.infinity, 32).pOnly(bottom: 16),
              ),

              /// field amount
              Obx(
                () => Visibility(
                  visible: isTypeNotes.isFalse,
                  child: CupertinoTextField(
                    controller: _tfAmount,
                    placeholder: 'Rp. 10.000',
                    placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
                    decoration: BoxDecoration(
                      color: Get.isDarkMode ? Vx.black : Vx.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    style: TextStyle(fontSize: 13, color: AppColor.textReverse),
                    prefix: IconButton(
                      icon: Icon(Icons.calculate, size: 14, color: AppColor.textReverse),
                      onPressed: () {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: Get.context!,
                          builder: (context) => FractionallySizedBox(
                            heightFactor: 0.7,
                            child: SimpleCalculator(
                              autofocus: true,
                              hideSurroundingBorder: true,
                              value: _tfAmount.text.moneyUnformat()?.toDouble() ?? 0.0,
                              onTappedDisplay: (p0, p1) => Get.back(),
                              onChanged: (key, value, expression) {
                                final moneyFormat = value!.toString().toInt()?.moneyFormat() ?? '';
                                _tfAmount.text = moneyFormat;
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    inputFormatters: [
                      CurrencyTextInputFormatter(NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp.', decimalDigits: 0)),
                      LengthLimitingTextInputFormatter(16),
                    ],
                    keyboardType: TextInputType.number,
                  ).h(32),
                ),
              ),
            ],
          ),
        ),
      ).h(isShowDetail.isTrue ? 262 : 187),
      actions: [
        if (expense != null) ...[
          CupertinoDialogAction(
            child: Text('Delete', style: TextStyle(color: Vx.red500, fontSize: 13)),
            onPressed: () async => await _deleteExpense(expense: expense, callback: customCallback),
          ),
        ],
        CupertinoDialogAction(
          child: Text('Submit', style: TextStyle(fontSize: 13)),
          onPressed: () async {
            await _submitExpense(_tfNote.text, _tfDescription.text, _tfCategory.value, _tfAmount.text, expense: expense, tfDate: _tfDate.text, customCallback: customCallback);
          },
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────
  // ⵌ dialog expense AI
  // ────────────────────────────────────────────────────────────────
  static Future<void> dialogExpenseAI() async {
   
    // ** desktop
    if (!Get.context!.isMobile) {
      final _tfText = TextEditingController();
      final _fnText = FocusNode();
      if (!_fnText.hasFocus) _fnText.requestFocus();

      DialogHelper.ios(
        title: Text(
          'Add Expense',
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ).pOnly(bottom: 16),
        content: VStack([
          CupertinoTextField(
            controller: _tfText,
            focusNode: _fnText,
            placeholder: 'Type your expense here...',
            placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
            style: TextStyle(fontSize: 13, color: AppColor.textReverse),
            onSubmitted: (s) async {
              Get.back();
              await processAIInput(s);
            },
          ).h(32),
        ]),
        actions: [
          CupertinoDialogAction(
            child: Text('Submit', style: TextStyle(fontSize: 13)),
            onPressed: () async {
              Get.back();
              await processAIInput(_tfText.text);
            },
          ),
        ],
      );
    }
    
    // ** mobile
    else {
      final _tfText = TextEditingController();
      final _fnText = FocusNode();

      ExBottomSheet.basic(
        title: 'Add Expense',
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: kIsWeb 
              ? MediaQuery.of(Get.context!).size.height * 0.35
              : MediaQuery.of(Get.context!).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    // iOS Safari requires user gesture to show keyboard
                    if (!_fnText.hasFocus) {
                      _fnText.requestFocus();
                    }
                  },
                  child: CupertinoTextField(
                    controller: _tfText,
                    focusNode: _fnText,
                    minLines: 3,
                    maxLines: 3,
                    autofocus: !kIsWeb,
                    placeholder: kIsWeb ? 'Tap here to type your expense...' : 'Type your expense here...',
                    placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
                    style: TextStyle(fontSize: 13, color: AppColor.textReverse),
                    onSubmitted: (s) async {
                      Get.back();
                      await processAIInput(s);
                    },
                  ),
                ),
                Divider().pOnly(top: 6, bottom: 0),
                ExButtonText(
                  label: 'Submit',
                  labelSize: 13,
                  onPressed: () async {
                    Get.back();
                    await processAIInput(_tfText.text);
                  },
                ).wFull(Get.context!),
                12.heightBox,
              ],
            ).pSymmetric(h: 24),
          ),
        ),
      );

      // iOS Safari: keyboard only shows on user gesture, not programmatic focus
      // User must tap the input field to show keyboard
    }
  }

  // ────────────────────────────────────────────────────────────────
  // ⵌ processAIInput
  // ────────────────────────────────────────────────────────────────
  static Future<void> processAIInput(String userText) async {
    final _controller = Get.find<HomeController>();

    _controller.footerStatus.value = 'Processing...';

    groq.startChat();
    groq.setCustomInstructionsWith('''
      You are an expert financial assistant. Your task is to analyze the user's text and extract transaction details.
      Interpret Indonesian currency shortcuts: 'k' or 'rb' means thousands (x1000), 'M' or 'jt' means millions (x1,000,000).
      You must pick a category value that aligns with the transaction type using the provided list.
      here the category list: ${_controller.categoryList.map((e) => e.name).join(', ')}

      `note` TitleCase format is required, simplify the detail.
      `description` is optional, if user input much detail, you can use it.
      `category` is required.
      `amount` is required.
      `date` is required.

      Return your response ONLY as a single, minified JSON object with the following structure. Do not add any other text or explanation.
      {
        "note": "string",             // string
        "description": "string",      // string
        "category": "category_value", // string
        "amount": "amount_value",     // string
        "date": "YYYY-MM-DD"          // string
      }
    ''');

    final response = await groq.sendMessage('''
      Current date: ${DateTime.now().toStringEx(format: yMd)}
      If the user does not specify a date, assume it is the current date.
      here the category list: ${_controller.categoryList.map((e) => e.name).join(', ')}
      If no category fits, use "Others"
      Analyze the following text:
      $userText
    ''');
    print(response.choices.first.message.content);

    final json = jsonDecode(response.choices.first.message.content);
    _controller.footerStatus.value = 'Insert to DB';
    await _submitExpense(
      json['note'] as String,
      json['description'] as String,
      json['category'] as String,
      json['amount'] as String,
      tfDate: json['date'] as String,
    ).catchError((e) {
      _controller.footerStatus.value = 'Failed: ${e.toString()}';
      OverlayHelper.notification(e.toString(), color: Vx.red600);
    });
    _controller.footerStatus.value = '';
  }

  // ------------------------------------------------------------------------
  /// delete
  // ------------------------------------------------------------------------
  static Future<void> _deleteExpense({required SupaExpense expense, Function? callback}) async {
    final _controller = Get.find<HomeController>();
    final _repo = Get.find<HomeRepository>();

    Get.back(); // close dialog first
    await _repo.deleteExpense(expense.id!);
    await _controller.getExpense();
    await _controller.onCalenderRefreshEvent(period: _controller.focusedDay.value.toStringEx(format: yM));
    await _controller.getCount1Month(_controller.focusedDay.value);
    _controller.rpcSpenderDay.value = await _repo.rpcGetSpenderDay(_controller.focusedDay.value);
    _controller.rpcSumByCategory.value = await _repo.rpcSumByCategory(_controller.focusedDay.value);
    await callback?.call();
    OverlayHelper.notification('Data ${expense.note} Deleted', color: Vx.red600);
  }

  static Future<void> _deleteCategory({required SupaCategory category, Function? callback}) async {
    final _controller = Get.find<HomeController>();
    final _repo = Get.find<HomeRepository>();
    ExAlert.confirm(
      title: 'Are you sure?',
      message: "you can't rollback this action",
      titleStyle: TextStyle(fontWeight: FontWeight.bold),
      messageStyle: TextStyle(fontSize: 13),
      onYes: () async {
        try {
          await _repo.deleteCategory(category.id ?? '');
          await _controller.getCategory();
          await callback?.call();
          OverlayHelper.notification('Category ${category.name} Deleted', color: Vx.red600);
          Get.close(2);
        } catch (e) {
          await ErrorLogHelper.record(page: 'section_dialog_input', action: '_deleteCategory', stack: e.toString());
          Get.close(2);
          ExSnackbar.danger(e);
        }
      },
    );
  }

  /// ------------------------------------------------------------------------
  /// submit
  /// ------------------------------------------------------------------------
  static Future<void> _submitExpense(
    String tfNote,
    String? tfDescription,
    String tfCategory,
    String tfAmount, {
    SupaExpense? expense,
    String? tfDate,
    Function? customCallback,
  }) async {
    final _controller = Get.find<HomeController>();
    final _repo = Get.find<HomeRepository>();

    if (tfNote.isEmptyOrNull) return;
    if (tfCategory.isEmptyOrNull) return;
    if (tfAmount.isEmptyOrNull) return;

    /// setup entity
    final newExpense = SupaExpense(
      id: expense != null ? expense.id : UuidV4().generate(),
      userId: db.auth.currentSession?.user.id ?? '',
      createdAt: DateTime.now().toStringEx(),
      date: tfDate.isNotEmptyAndNotNull ? tfDate : _controller.focusedDay.value.toStringEx(format: yMd),
      amount: tfAmount.moneyUnformat(),
      categoryName: tfCategory,
      note: '${tfNote.toTitleCase}',
      detail: tfDescription ?? '',
    );

    final newAutoComplete = SupaAutoComplete(
      id: UuidV4().generate(),
      userId: db.auth.currentSession?.user.id ?? '',
      createdAt: DateTime.now().toStringEx(),
      note: '${tfNote.toTitleCase}',
      categoryName: '${newExpense.categoryName}',
      amount: '${newExpense.amount}',
    );

    if (newExpense.categoryName == 'Notes') newExpense.amount = 0;

    /// process data
    try {
      /// insert to db
      expense != null ? await _repo.editExpense(newExpense) : await _repo.addExpense(newExpense);
      await _repo.addAutoComplete(newAutoComplete);

      /// refresh data after insert
      await _controller.getExpense(find: _controller.tfSearchExpense.value.text.isNotBlank ? _controller.tfSearchExpense.value.text : null);
      await _controller.getCount1Month(_controller.focusedDay.value);
      _controller.rpcSpenderDay.value = await _repo.rpcGetSpenderDay(_controller.focusedDay.value);
      _controller.rpcSumByCategory.value = await _repo.rpcSumByCategory(_controller.focusedDay.value);
      await customCallback?.call();
      OverlayHelper.notification('Successfully ${expense != null ? 'Edit' : 'Added'} $tfNote', color: Vx.green600);
      await _controller.onCalenderRefreshEvent(period: _controller.focusedDay.value.toStringEx(format: yM));
      Get.back(); // close dialog first
    } catch (e) {
      logE('e: $e');
      await ErrorLogHelper.record(page: 'section_dialog_input', action: '_submitExpense', stack: e.toString());
      OverlayHelper.notification('Failed to ${expense != null ? 'Edit' : 'Added'} Data', color: Vx.red600);
    }
  }

  static Future<void> _submitCategory({
    required SupaCategory category,
    Function? callback,
    required String name,
    required String color,
    required String icon,
    required String maxBudget,
  }) async {
    final _controller = Get.find<HomeController>();
    final _repo = Get.find<HomeRepository>();

    final newEntity = SupaCategory(
      id: category.id,
      userId: db.auth.currentSession?.user.id ?? '',
      createdAt: DateTime.now().toStringEx(),
      name: name,
      color: color,
      icon: icon,
      maxBudget: maxBudget.moneyUnformat(),
    );
    await _repo.editCategory(newEntity);
    await _controller.getCategory();
    await _controller.getExpense();
    await callback?.call();
    Get.back();
  }

  /// ------------------------------------------------------------------------
  /// ! home search filter
  /// ------------------------------------------------------------------------
  static Future<void> advenceFilterExpense(String s) async {
    final _controller = Get.find<HomeController>();
    final _tfStartDate = TextEditingController(text: '');
    final _tfEndDate = TextEditingController(text: '');
    DialogHelper.ios(
      title: Text(
        'Advance Search for "$s"',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        textAlign: TextAlign.left,
      ).pOnly(bottom: 16),
      content: VStack(
        [
          /// start date
          CupertinoTextField(
            controller: _tfStartDate,
            readOnly: true,
            placeholder: 'Start Date',
            placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
            prefix: Icon(CupertinoIcons.calendar_today, size: 16, color: AppColor.textReverse).pOnly(left: 8),
            style: TextStyle(fontSize: 13, color: AppColor.textReverse),
            onTap: () => ExDatePicker.materialDatePicker(
              // initialDate: expense.date?.toDateEx(format: yMd),
              minDate: DateTime(2020),
              callback: (c) => _tfStartDate.text = c.toStringEx(format: yMd),
            ),
          ).pOnly(bottom: 16),

          /// end date
          CupertinoTextField(
            controller: _tfEndDate,
            readOnly: true,
            placeholder: 'End Date',
            placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
            prefix: Icon(CupertinoIcons.calendar_today, size: 16, color: AppColor.textReverse).pOnly(left: 8),
            style: TextStyle(fontSize: 13, color: AppColor.textReverse),
            onTap: () => ExDatePicker.materialDatePicker(
              minDate: DateTime(2020),
              callback: (c) => _tfEndDate.text = c.toStringEx(format: yMd),
            ),
          ).pOnly(bottom: 16),

          HStack(
            [
              Text(
                'This Month',
                style: TextStyle(decoration: TextDecoration.underline),
                overflow: TextOverflow.ellipsis,
              ).onInkTap(() {
                _tfStartDate.text = DateTime.now().subtract(Duration(days: DateTime.now().day - 1)).toStringEx(format: yMd);
                _tfEndDate.text = DateTime.now().add(Duration(days: dayInMonth(DateTime.now()) - DateTime.now().day)).toStringEx(format: yMd);
              }),
              Spacer(),
              Text(
                '7 days',
                style: TextStyle(decoration: TextDecoration.underline),
                overflow: TextOverflow.ellipsis,
              ).onInkTap(() {
                _tfStartDate.text = DateTime.now().subtract(Duration(days: 7)).toStringEx(format: yMd);
                _tfEndDate.text = DateTime.now().toStringEx(format: yMd);
              }),
              Spacer(),
              Text(
                '30 days',
                style: TextStyle(decoration: TextDecoration.underline),
                overflow: TextOverflow.ellipsis,
              ).onInkTap(() {
                _tfStartDate.text = DateTime.now().subtract(Duration(days: 30)).toStringEx(format: yMd);
                _tfEndDate.text = DateTime.now().toStringEx(format: yMd);
              }),
            ],
          ),
        ],
      ).h(110),
      actions: [
        CupertinoDialogAction(
          child: Text('Submit', style: TextStyle(fontSize: 13)),
          onPressed: () async {
            if (_tfStartDate.text.isNotBlank && _tfEndDate.text.isNotBlank) {
              await _controller.getExpense(find: s, startDate: _tfStartDate.text, endDate: _tfEndDate.text);
              Get.back();
            } else {
              OverlayHelper.notification('Please select date range', color: Vx.red600);
            }
          },
        ),
      ],
    );
  }
}
