import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_iconpicker_plus/flutter_iconpicker.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';
import 'package:get/get.dart';
import 'package:hsv_color_pickers/hsv_color_pickers.dart';
import 'package:uuid/v4.dart';

import '../../core/app_color.dart';
import '../../core/const.dart';
import '../../helpers/helper_decoration.dart';
import '../../helpers/helper_misc.dart';
import '../../helpers/helper_money.dart';
import '../../models/category_entity.dart';
import '../../models/expense_entity.dart';
import '../widgets/widget_autocomplete.dart';
import 'home_controller.dart';
import 'home_repository.dart';

/// * @{HomeDialogInput}
/// ? seperate dialog input part coz this function is shared (can be use to another page)
/// ?
/// ~

mixin HomeDialogInput {
  static final _controller = Get.find<HomeController>();
  static final _repo = Get.find<HomeRepository>();

  // ------------------------------------------------------------------------
  // Dialog Category
  // ------------------------------------------------------------------------
  static Future<void> onEditCategory({CategoryEntity? entity, Function? callback}) async {
    final _tfCatName = TextEditingController(text: entity?.name ?? '');
    final _tfCatColor = TextEditingController(text: entity?.color ?? '');
    final _tfMaxBudget = TextEditingController(text: entity?.maxBudget != null ? entity?.maxBudget!.moneyFormat() : '');
    final _hueController = HueController(HSVColor.fromColor(_tfCatColor.text.fromHex)).obs;
    final _iconSelected = (entity?.icon?.getIconData() ?? Icons.circle_outlined).obs;

    ExDialog.custom(
      title: 'Edit Category',
      titleTextStyle: TextStyle(fontWeight: FontWeight.bold),
      content: VStack(
        [
          TextField(
            controller: _tfCatName,
            decoration: MyDecoration.input(hint: 'Name', label: 'Category Name'),
            style: TextStyle(fontSize: 13),
          ).pOnly(bottom: 12),
          TextField(
            controller: _tfMaxBudget,
            decoration: MyDecoration.input(hint: '1.000.000', label: 'Max Budget (Monthtly)'),
            inputFormatters: [
              CurrencyTextInputFormatter(symbol: 'Rp. ', decimalDigits: 0),
              LengthLimitingTextInputFormatter(13),
            ],
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 13),
          ).pOnly(bottom: 8),
          HStack(
            [
              /// icon preview
              Obx(
                () => Icon(
                  _iconSelected.value,
                  size: 18,
                  color: _hueController.value.value.toColor(),
                ),
              ).pOnly(right: 8).tooltip('Click to change icon').onTap(() async {
                await FlutterIconPicker.showIconPicker(
                  Get.context!,
                  iconPackModes: [IconPack.lineAwesomeIcons, IconPack.custom, IconPack.cupertino, IconPack.material],
                  iconSize: 20,
                  constraints: BoxConstraints(maxWidth: 250, maxHeight: 250),
                ).then((icon) {
                  if (icon != null) {
                    _iconSelected.value = icon;
                  }
                });
              }),

              /// hue picker
              Obx(() => HuePicker(
                    controller: _hueController.value,
                    onChanged: (HSVColor color) {
                      _hueController.value.value = color;
                      _tfCatColor.text = color.toColor().toHex();
                      Get.forceAppUpdate();
                    },
                  ).wh(220, 24)),
            ],
          ).pSymmetric(v: 12),
          HStack(
            [
              Spacer(),
              Text(
                'More Color',
                style: TextStyle(fontSize: 11, decoration: TextDecoration.underline),
              ).pOnly(right: 8).onTap(() async {
                ExDialog.custom(
                  title: 'Pick Custom Color',
                  titleTextStyle: TextStyle(),
                  content: Column(
                    children: [
                      ColorPicker(
                        pickerColor: _tfCatColor.text.fromHex,
                        colorPickerWidth: 300,
                        pickerAreaHeightPercent: 0.5,
                        enableAlpha: true,
                        labelTypes: [],
                        displayThumbColor: true,
                        paletteType: PaletteType.hsl,
                        pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(12)),
                        portraitOnly: true,
                        onColorChanged: (s) async {
                          _hueController.value.value = HSVColor.fromColor(s);
                          _tfCatColor.text = s.toHex();
                        },
                      ),
                      TextButton(onPressed: Get.back, child: Text('Close')),
                    ],
                  ),
                );
              }),
            ],
          ),
          Divider().pOnly(bottom: 8),
          HStack(
            [
              ExButtonOutline(
                label: 'Delete',
                labelSize: 11,
                isLabelBold: false,
                labelColor: Vx.red400,
                borderColor: Vx.red400,
                radius: 90,
                onPressed: () async {
                  ExAlert.confirm(
                      title: 'Are you sure?',
                      message: "you can't rollback this action",
                      titleStyle: TextStyle(fontWeight: FontWeight.bold),
                      messageStyle: TextStyle(fontSize: 13),
                      onYes: () async {
                        try {
                          await _repo.deleteCategory(entity?.id ?? '');
                          await _controller.getCategory();
                          await callback?.call();
                          Get.close(2);
                          Get.back();
                        } catch (e) {
                          Get.close(2);
                          ExSnackbar.danger(e);
                        }
                      });
                },
              ),
              8.widthBox,
              ExButtonOutline(
                label: 'Submit',
                labelSize: 11,
                isLabelBold: false,
                labelColor: AppColor.textReverse,
                borderColor: AppColor.textReverse,
                radius: 90,
                onPressed: () async {
                  final newEntity = CategoryEntity(
                    id: entity?.id,
                    createdAt: DateTime.now().toStringEx(),
                    name: _tfCatName.text,
                    color: _tfCatColor.text,
                    icon: _iconSelected.value.setIconData(),
                    maxBudget: _tfMaxBudget.text.moneyUnformat(),
                  );
                  await _repo.editCategory(newEntity);
                  await _controller.getCategory();
                  await callback?.call();
                  Get.back();
                },
              ).expand(),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------------
  // Dialog Expense
  // ------------------------------------------------------------------------
  static Future<void> onShowDialogExpense({ExpenseEntity? expense, Function? customCallback}) async {
    if (_controller.categoryList.isEmptyOrNull) {
      ExSnackbar.danger('add some category first:))');
      return;
    }

    final _tfDate = TextEditingController(text: expense != null ? expense.date : '');
    final _tfNote = TextEditingController(text: expense != null ? expense.note : '');
    final _tfCategory = '${expense != null ? '${expense.categoryName}' : '${_controller.categoryList[0].name}'}'.obs;
    final _tfAmount = TextEditingController(text: expense != null ? expense.amount!.moneyFormat() : '');

    ExDialog.custom(
      title: expense != null ? 'Edit Expense' : 'Add Expense',
      titleTextStyle: TextStyle(fontWeight: FontWeight.bold),
      width: 250,
      content: VStack(
        [
          /// field select date: edit mode only
          if (expense != null) ...[
            TextField(
              controller: _tfDate,
              readOnly: true,
              decoration: MyDecoration.input(hint: 'Date', label: 'Date'),
              style: TextStyle(fontSize: 13),
              onTap: () => ExDatePicker.datePickerMaterial(callback: (c) => _tfDate.text = c.toStringEx(format: yMd)),
            ).wh(250, 38).pOnly(bottom: 16),
          ],
          MyAutoComplete(
            autofocus: expense == null,
            initialValue: _tfNote.value,
            asyncSuggestions: (s) async {
              if (s.text.isBlank!) return [];
              return await _repo.findAutoCompleteStringNote(s.text);
            },
            decoration: MyDecoration.input(hint: 'Nasi Padang', label: 'Notes'),
            onChanged: (s) => _tfNote.text = s,
            onSelected: (s) async {
              _tfNote.text = s;
              await _repo.findAutoCompleteFullObject(s).then((res) {
                _tfCategory.value = res[0].categoryName ?? '';
                _tfAmount.text = res[0].amount?.toInt()?.moneyFormat() ?? '';
              });
            },
          ).wh(250, 38).pOnly(bottom: 16),
          // ],

          /// field category
          Obx(
            () => DropdownButtonFormField(
              value: '${_tfCategory.value}',
              style: TextStyle(fontSize: 12, color: AppColor.textReverse),
              decoration: MyDecoration.input(label: 'Category'),
              items: _controller.categoryList.map((element) {
                return DropdownMenuItem(
                  value: '${element.name}',
                  child: HStack(
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
              onChanged: (s) => _tfCategory.value = s ?? '',
            ).wh(250, 38).pOnly(bottom: 16),
          ),

          /// field amount
          HStack(
            [
              TextField(
                controller: _tfAmount,
                decoration: MyDecoration.input(
                  hint: '10.000',
                  label: 'Amount',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calculate, size: 16, color: AppColor.textReverse),
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
                ),
                style: TextStyle(fontSize: 13),
                inputFormatters: [
                  CurrencyTextInputFormatter(symbol: 'Rp. ', decimalDigits: 0),
                  LengthLimitingTextInputFormatter(13),
                ],
                keyboardType: TextInputType.number,
                onSubmitted: (_) async => {
                  await _submitExpense(_tfNote.text, _tfCategory.value, _tfAmount.text, expense: expense, tfDate: _tfDate.text),
                  await customCallback?.call(),
                },
              ).wh(250, 38),
            ],
          ).pOnly(bottom: 8),
          Divider().pOnly(bottom: 8),

          /// action
          HStack(
            [
              if (expense != null) ...[
                ExButtonOutline(
                  label: 'Delete',
                  labelSize: 11,
                  isLabelBold: false,
                  labelColor: Vx.red400,
                  borderColor: Vx.red400,
                  radius: 90,
                  onPressed: () async {
                    await _repo.deleteExpense(expense.id!);
                    await _controller.getExpense();
                    await _controller.onCalenderRefreshEvent();
                    await customCallback?.call();

                    Get.back();
                  },
                ).pOnly(right: 8),
              ],
              ExButtonOutline(
                label: 'Submit',
                labelSize: 11,
                isLabelBold: false,
                labelColor: AppColor.textReverse,
                borderColor: AppColor.textReverse,
                radius: 90,
                onPressed: () async => {
                  await _submitExpense(_tfNote.text, _tfCategory.value, _tfAmount.text, expense: expense, tfDate: _tfDate.text),
                  await customCallback?.call(),
                },
              ).expand(),
            ],
          ),
        ],
      ),
    );
  }

  static Future<void> _submitExpense(String tfNote, String tfCategory, String tfAmount, {ExpenseEntity? expense, String? tfDate}) async {
    if (tfNote.isEmptyOrNull) return;
    if (tfCategory.isEmptyOrNull) return;
    if (tfAmount.isEmptyOrNull) return;

    final entity = ExpenseEntity(
      id: expense != null ? expense.id : UuidV4().generate(),
      createdAt: DateTime.now().toStringEx(),
      date: tfDate.isNotEmptyAndNotNull ? tfDate : _controller.focusedDay.value.toStringEx(format: yMd),
      amount: tfAmount.moneyUnformat(),
      categoryName: tfCategory,
      note: '${tfNote.toTitleCase}',
    );

    try {
      if (expense != null) {
        await _repo.editExpense(entity);
      } else {
        await _repo.addExpense(entity);
      }
      await _repo.addAutoComplete('${tfNote.toTitleCase}', categoryName: '${entity.categoryName}', amount: '${entity.amount}');
      await _controller.getExpense(find: _controller.tfSearchExpense.text.isNotBlank ? _controller.tfSearchExpense.text : null);
    } catch (e) {
      logE('e: $e');
      ExSnackbar.danger('$e', duration: 5);
    }
    await _controller.onCalenderRefreshEvent();
    Get.back(); // close dialog
  }
}
