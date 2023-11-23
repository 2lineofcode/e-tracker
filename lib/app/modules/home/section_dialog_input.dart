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

    ExDialog.custom(
      title: 'Edit Category',
      titleTextStyle: TextStyle(fontWeight: FontWeight.bold),
      content: VStack(
        [
          TextField(
            controller: _tfCatName,
            decoration: MyDecoration.input(
              hint: 'Name',
              label: 'Category Name',
              suffixIcon: Icon(CupertinoIcons.textformat_abc, size: 16, color: AppColor.textReverse),
            ),
            style: TextStyle(fontSize: 13),
          ).pOnly(bottom: 12),
          TextField(
            controller: _tfMaxBudget,
            decoration: MyDecoration.input(
              hint: '1.000.000',
              label: 'Max Budget (Monthtly)',
              suffixIcon: Icon(CupertinoIcons.archivebox_fill, size: 16, color: AppColor.textReverse),
            ),
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
                ).wh(220, 24),
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
                ExDialog.custom(
                  title: 'Pick Custom Color',
                  titleTextStyle: TextStyle(),
                  content: VStack(
                    [
                      Text('Current color set:', style: TextStyle(fontSize: 12)).pOnly(bottom: 8),
                      Wrap(
                        children: [
                          for (var i = 0; i < _controller.categoryList.length; i++) ...[
                            Icon(
                              _controller.categoryList[i].icon?.getIconData() ?? Icons.circle_outlined,
                              color: _controller.categoryList[i].color?.fromHex,
                              size: 20,
                            ).pOnly(right: 8),
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
                      ).pSymmetric(v: 8),
                      TextButton(onPressed: Get.back, child: Text('Close')).w(300).centered(),
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
                          AppNotif.show('Category ${entity?.name} Deleted', color: Vx.red600);
                          Get.close(2);
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
                  await _controller.getExpense();
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
    final _tfDescription = TextEditingController(text: expense != null ? expense.detail : '');
    final _tfCategory = '${expense != null ? '${expense.categoryName}' : '${_controller.categoryList[0].name}'}'.obs;
    final _tfAmount = TextEditingController(text: expense != null ? expense.amount!.moneyFormat() : '');
    final isShowDetail = expense?.detail.isNotEmptyAndNotNull.obs;
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
              decoration: MyDecoration.input(
                hint: 'Date',
                label: 'Date',
                suffixIcon: Icon(CupertinoIcons.calendar_today, size: 16, color: AppColor.textReverse),
              ),
              style: TextStyle(fontSize: 13),
              onTap: () => ExDatePicker.datePickerMaterial(callback: (c) => _tfDate.text = c.toStringEx(format: yMd)),
            ).wh(250, 42).pOnly(bottom: 16),
          ],
          MyAutoComplete(
            autofocus: expense == null,
            initialValue: _tfNote.value,
            asyncSuggestions: (s) async {
              if (s.text.isBlank!) return [];
              return await _repo.findAutoCompleteStringNote(s.text);
            },
            decoration: MyDecoration.input(
              hint: 'Nasi Padang',
              label: 'Notes',
              suffixIcon: IconButton(
                icon: Icon(CupertinoIcons.doc_plaintext, size: 16, color: AppColor.textReverse),
                onPressed: () async => isShowDetail?.value = !isShowDetail.value,
              ),
            ),
            onChanged: (s) => _tfNote.text = s,
            onSelected: (s) async {
              _tfNote.text = s;
              await _repo.findAutoCompleteFullObject(s).then((res) {
                _tfCategory.value = res[0].categoryName ?? '';
                _tfAmount.text = res[0].amount?.toInt()?.moneyFormat() ?? '';
              });
            },
          ).wh(250, 42).pOnly(bottom: 16),

          /// description / detail
          Obx(
            () => Visibility(
              visible: isShowDetail?.value ?? false,
              child: TextField(
                controller: _tfDescription,
                decoration: MyDecoration.input(
                  hint: 'Nama Toko/Waktu',
                  label: 'Detail',
                ),
                style: TextStyle(fontSize: 13),
              ).wh(250, 42).pOnly(bottom: 16),
            ),
          ),

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
            ).wh(250, 42).pOnly(bottom: 16),
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
                ),
                style: TextStyle(fontSize: 13),
                inputFormatters: [
                  CurrencyTextInputFormatter(symbol: 'Rp. ', decimalDigits: 0),
                  LengthLimitingTextInputFormatter(13),
                ],
                keyboardType: TextInputType.number,
                onSubmitted: (_) async => {
                  await _submitExpense(_tfNote.text, _tfDescription.text, _tfCategory.value, _tfAmount.text, expense: expense, tfDate: _tfDate.text),
                  await customCallback?.call(),
                },
              ).wh(250, 42),
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
                    AppNotif.show('Data ${expense.note} Deleted', color: Vx.red600);
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
                  await _submitExpense(_tfNote.text, _tfDescription.text, _tfCategory.value, _tfAmount.text, expense: expense, tfDate: _tfDate.text),
                  await customCallback?.call(),
                },
              ).expand(),
            ],
          ),
        ],
      ),
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
