import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_iconpicker_plus/IconPicker/icons.dart';
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
import '../../helpers/helper_notif.dart';
import '../../models/category_entity.dart';
import '../../models/expense_entity.dart';
import '../widgets/widget_autocomplete.dart';
import 'home_controller.dart';
import 'home_repository.dart';

/// * @{HomeDialogInput}
/// ? seperate dialog input part coz this function is shared (can be use to another page)
/// ? this code too long coz to many customize and i dont want put in controller
/// ~
///
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

    ExAlert.adaptive(
        content: VStack(
          [
            Text(
              'Edit Category',
              style: TextStyle(fontWeight: FontWeight.bold),
            ).pOnly(bottom: 24),
            CupertinoTextField(
              controller: _tfCatName,
              placeholder: 'Category Name',
              placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
              prefix: Icon(CupertinoIcons.number, size: 16, color: AppColor.textReverse).pOnly(left: 8),
              style: TextStyle(fontSize: 13, color: AppColor.textReverse),
            ).pOnly(bottom: 12),
            CupertinoTextField(
              controller: _tfMaxBudget,
              placeholder: 'Max Budget (Monthtly)',
              placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
              prefix: Icon(CupertinoIcons.money_dollar, size: 16, color: AppColor.textReverse).pOnly(left: 8),
              style: TextStyle(fontSize: 13, color: AppColor.textReverse),
              inputFormatters: [
                CurrencyTextInputFormatter(symbol: 'Rp. ', decimalDigits: 0),
                LengthLimitingTextInputFormatter(13),
              ],
              keyboardType: TextInputType.number,
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
                    iconPackModes: [
                      IconPack.lineAwesomeIcons,
                      IconPack.custom,
                      IconPack.cupertino,
                      IconPack.material,
                      IconPack.fontAwesomeIcons,
                      IconPack.custom,
                    ],
                    iconSize: 20,
                    customIconPack: {},
                    constraints: BoxConstraints(maxWidth: 250, maxHeight: 250),
                  ).then((icon) {
                    if (icon != null) _iconSelected.value = icon;
                  });
                }),

                /// hue picker
                Obx(
                  () => HuePicker(
                    controller: _hueController.value,
                    onChanged: (HSVColor color) {
                      _hueController.value.value = color;
                      _tfCatColor.text = color.toColor().toHex();
                      Get.forceAppUpdate();
                    },
                  ).wh(200, 24),
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
                  ExAlert.adaptive(
                    content: VStack(
                      [
                        Text(
                          'Pick Custom Color',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ).pOnly(bottom: 24),
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
                        Obx(() => Icon(
                              entity?.icon?.getIconData() ?? Icons.circle_outlined,
                              color: _hueController.value.value.toColor(),
                              size: 20,
                            )),
                        ColorPicker(
                          pickerColor: _tfCatColor.text.fromHex,
                          // colorPickerWidth: 300,
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
        ),
        actions: [
          CupertinoDialogAction(
            child: Text('Delete', style: TextStyle(fontSize: 13, color: Vx.red500)),
            onPressed: () {
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
                      AppNotif.show('Category ${entity?.name} Deleted', color: Vx.red600);
                      Get.close(2);
                    } catch (e) {
                      Get.close(2);
                      ExSnackbar.danger(e);
                    }
                  });
            },
          ),
          CupertinoDialogAction(
            child: Text('Submit', style: TextStyle(fontSize: 13)),
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
              await _controller.getExpense();
              await callback?.call();
              Get.back();
            },
          ),
        ]);
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
    final _tfDescription = TextEditingController(text: expense != null ? expense.detail : '');
    final _tfCategory = '${expense != null ? '${expense.categoryName}' : '${_controller.categoryList[0].name}'}'.obs;
    final _tfAmount = TextEditingController(text: expense != null ? expense.amount!.moneyFormat() : '');
    final isShowDetail = expense != null && expense.detail.isNotEmptyAndNotNull ? true.obs : false.obs;
    ExAlert.adaptive(
      title: Text(
        '${expense != null ? 'Edit Expense' : 'Add Expense'}',
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.left,
      ).pOnly(bottom: 16),
      content: VStack(
        [
          /// field select date: edit mode only
          if (expense != null) ...[
            CupertinoTextField(
              controller: _tfDate,
              readOnly: true,
              placeholder: 'Date',
              placeholderStyle: TextStyle(fontSize: 13),
              prefix: Icon(CupertinoIcons.calendar_today, size: 16, color: AppColor.textReverse).pOnly(left: 8),
              style: TextStyle(fontSize: 13, color: AppColor.textReverse),
              onTap: () => ExDatePicker.adaptiveDatePicker(
                minDate: DateTime(2020),
                callback: (c) => _tfDate.text = c.toStringEx(format: yMd),
              ),
            ).pOnly(bottom: 16),
          ],
          MyAutoComplete(
            autofocus: expense == null,
            initialValue: _tfNote.value,
            asyncSuggestions: (s) async {
              if (s.text.isBlank!) return [];
              return await _repo.findAutoCompleteStringNote(s.text);
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
          ).pOnly(bottom: 12, top: 3),

          /// description / detail
          Obx(
            () => Visibility(
              visible: isShowDetail.value,
              child: CupertinoTextField(
                controller: _tfDescription,
                placeholder: 'Detail: Nama Toko/Waktu',
                placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
                style: TextStyle(fontSize: 13, color: AppColor.textReverse),
                minLines: 2,
                maxLines: 2,
                clearButtonMode: OverlayVisibilityMode.editing,
              ).pOnly(bottom: 16),
            ),
          ),

          /// field category
          Obx(
            () => DropdownButtonFormField(
              value: '${_tfCategory.value}',
              style: TextStyle(fontSize: 12, color: AppColor.textReverse),
              decoration: MyDecoration.input(
                fillColor: Get.isDarkMode ? Vx.black : Vx.white,
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    style: BorderStyle.solid,
                    color: Get.isDarkMode ? Vx.neutral800 : Vx.neutral300,
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
              onChanged: (s) => _tfCategory.value = s ?? '',
            ).wh(double.infinity, 32).pOnly(bottom: 16),
          ),

          /// field amount
          CupertinoTextField(
            controller: _tfAmount,
            placeholder: 'Rp. 10.000',
            placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
            style: TextStyle(fontSize: 13, color: AppColor.textReverse),
            prefix: IconButton(
              icon: Icon(fontAwesomeIcons['calculator'], size: 14, color: AppColor.textReverse),
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
              CurrencyTextInputFormatter(symbol: 'Rp. ', decimalDigits: 0),
              LengthLimitingTextInputFormatter(13),
            ],
            keyboardType: TextInputType.number,
            onSubmitted: (_) async => {
              await _submitExpense(_tfNote.text, _tfDescription.text, _tfCategory.value, _tfAmount.text, expense: expense, tfDate: _tfDate.text),
              await customCallback?.call(),
            },
          ).h(32),
        ],
      ),
      actions: [
        if (expense != null) ...[
          CupertinoDialogAction(
            child: Text('Delete', style: TextStyle(color: Vx.red500, fontSize: 13)),
            onPressed: () async {
              await _repo.deleteExpense(expense.id!);
              await _controller.getExpense();
              await _controller.onCalenderRefreshEvent();
              await customCallback?.call();
              AppNotif.show('Data ${expense.note} Deleted', color: Vx.red600);
              Get.back();
            },
          ),
        ],
        CupertinoDialogAction(
          child: Text('Submit', style: TextStyle(fontSize: 13)),
          onPressed: () async {
            await _submitExpense(_tfNote.text, _tfDescription.text, _tfCategory.value, _tfAmount.text, expense: expense, tfDate: _tfDate.text);
            await customCallback?.call();
          },
        ),
      ],
    );
  }

  static Future<void> _submitExpense(String tfNote, String? tfDescription, String tfCategory, String tfAmount, {ExpenseEntity? expense, String? tfDate}) async {
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
      detail: tfDescription ?? '',
    );

    if (entity.categoryName == 'Notes') entity.amount = 0;

    try {
      expense != null ? await _repo.editExpense(entity) : await _repo.addExpense(entity);
      await _repo.addAutoComplete('${tfNote.toTitleCase}', categoryName: '${entity.categoryName}', amount: '${entity.amount}');
      await _controller.getExpense(find: _controller.tfSearchExpense.value.text.isNotBlank ? _controller.tfSearchExpense.value.text : null);
      AppNotif.show('Successfully ${expense != null ? 'Edit' : 'Added'} $tfNote', color: Vx.green600);
      Get.back();
    } catch (e) {
      logE('e: $e');
      AppNotif.show('$e', color: Vx.green600);
    }
    await _controller.onCalenderRefreshEvent();
    Get.back(); // close dialog
  }
}
