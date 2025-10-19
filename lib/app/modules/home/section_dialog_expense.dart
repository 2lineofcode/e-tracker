import 'dart:convert';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:ex_kit/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:overlayment/overlayment.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:uuid/v4.dart';

import '../../core/app_api.dart';
import '../../core/app_color.dart';
import '../../core/app_setting.dart';
import '../../core/const.dart';
import '../../helpers/helpers.dart';
import '../../models/supa_category_entity.dart';
import '../../models/supa_expense_entity.dart';
import 'home_controller.dart';
import 'home_repository.dart';

/// [DialogExpense]
/// [openManualInput]
///   [_manualInputForMobile]
///   [_manualInputForDesktop]
/// [openAIInput]
///   [_processAIInput]
///   [_deleteExpense]
///   [_submitExpense]
/// [openAdvenceFilter]
/// This class provides helper methods for dialog input functionality.
/// It is designed to be shared and can be used in multiple pages.
/// The class includes methods for handling dialog categories.
mixin DialogExpense {
  /// ------------------------------------------------------------------------
  /// Manual Input
  /// ------------------------------------------------------------------------
  static Future<void> openManualInput({
    SupaExpense? expense,
    Function? customCallback,
  }) async {
    if (Get.context!.isMobile) {
      await _manualInputForMobile(
        expense: expense,
        customCallback: customCallback,
      );
    } else {
      await _manualInputForDesktop(
        expense: expense,
        customCallback: customCallback,
      );
    }
  }

  static Future<void> _manualInputForMobile({SupaExpense? expense, Function? customCallback}) async {
    final _controller = Get.find<HomeController>();

    if (_controller.categoryList.isEmptyOrNull) {
      await HelperToast.warn('Please Creete at least 1 category');
      return;
    }

    final _tfDate = TextEditingController(text: expense != null ? expense.date : '');
    final _tfNote = TextEditingController(text: expense != null ? expense.note : '');
    final _tfDescription = TextEditingController(text: expense != null ? expense.detail : '');
    final _tfCategory = (expense != null ? expense.categoryName ?? '' : _controller.categoryList[0].code).obs;
    final _tfAmount = TextEditingController(text: expense != null ? expense.amount!.moneyFormat() : '');

    /// flag
    final isShowDetail = expense != null && expense.detail.isNotEmptyAndNotNull ? true.obs : false.obs;
    final isTypeNotes = expense != null && expense.resolvedCategory.code == 'expense:misc:notes' ? true.obs : false.obs;
    ExBottomSheet.basic(
      title: '${expense != null ? 'Edit Expense' : 'Add Expense'}',
      content: VStack(
        [
          if (expense != null) ...[
            CupertinoTextField(
              controller: _tfDate,
              readOnly: true,
              placeholder: 'Date',
              decoration: BoxDecoration(color: Get.isDarkMode ? Vx.black : Vx.white, borderRadius: BorderRadius.circular(4)),
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

          CupertinoTextField(
            controller: _tfNote,
            placeholder: 'Note: Nasi Padang',
            placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
            decoration: BoxDecoration(color: Get.isDarkMode ? Vx.black : Vx.white, borderRadius: BorderRadius.circular(4)),
            style: TextStyle(fontSize: 13, color: AppColor.textReverse),
          ).pOnly(bottom: 16),

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
                decoration: BoxDecoration(color: Get.isDarkMode ? Vx.black : Vx.white, borderRadius: BorderRadius.circular(4)),
              ).pOnly(bottom: 16),
            ),
          ),

          /// field category
          Obx(() {
            final items = <DropdownMenuItem<String>>[];
            for (final group in _controller.categoryGroups) {
              items.add(
                DropdownMenuItem<String>(
                  value: '__group__${group.label}',
                  enabled: false,
                  child: group.label.text.size(11).bold.make(),
                ),
              );
              items.addAll(
                group.items.map((element) {
                  return DropdownMenuItem<String>(
                    value: element.code,
                    child: HStack(
                      alignment: MainAxisAlignment.spaceEvenly,
                      [
                        Icon(element.icon ?? Icons.circle_outlined, size: 16, color: element.color).pOnly(right: 8),
                        Text(element.label),
                      ],
                    ),
                  );
                }),
              );
            }
            return DropdownButtonFormField<String>(
              initialValue: _tfCategory.value,
              style: TextStyle(fontSize: 12, color: AppColor.textReverse),
              decoration: HelperDecoration.input(
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
              items: items,
              onChanged: (value) {
                if (value == null || value.startsWith('__group__')) return;
                _tfCategory.value = value;
                if (value == 'expense:misc:notes') {
                  _tfAmount.text = 'Rp. 0';
                  isTypeNotes.value = true;
                  isShowDetail.value = true;
                } else {
                  _tfAmount.text = expense?.amount?.moneyFormat() ?? '';
                  isTypeNotes.value = false;
                  isShowDetail.value = false;
                }
              },
            ).wh(double.infinity, 32).pOnly(bottom: 16);
          }),

          /// field amount
          Obx(
            () => Visibility(
              visible: isTypeNotes.isFalse,
              child: CupertinoTextField(
                controller: _tfAmount,
                placeholder: 'Rp. 10.000',
                decoration: BoxDecoration(color: Get.isDarkMode ? Vx.black : Vx.white, borderRadius: BorderRadius.circular(4)),
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
                  await _submitExpense(
                    _tfNote.text,
                    _tfDescription.text,
                    _tfCategory.value,
                    _tfAmount.text,
                    expense: expense,
                    tfDate: _tfDate.text,
                    customCallback: customCallback,
                  ),
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
                  onPressed: () async => await _deleteExpense(
                    expense: expense,
                    callback: customCallback,
                  ),
                ).pOnly(right: 12).expand(),
              ],
              ExButtonElevated(
                child: Text('Submit', style: TextStyle(fontSize: 13)),
                onPressed: () async {
                  await _submitExpense(
                    _tfNote.text,
                    _tfDescription.text,
                    _tfCategory.value,
                    _tfAmount.text,
                    expense: expense,
                    tfDate: _tfDate.text,
                    customCallback: customCallback,
                  );
                },
              ).expand(),
            ],
          ).pOnly(bottom: 12),
        ],
      ),
    );
  }

  static Future<void> _manualInputForDesktop({SupaExpense? expense, Function? customCallback}) async {
    // local inject
    final _controller = Get.find<HomeController>();

    if (_controller.categoryList.isEmptyOrNull) {
      await HelperToast.warn('Please Creete at least 1 category');
      return;
    }

    final _tfDate = TextEditingController(text: expense != null ? expense.date : '');
    final _tfNote = TextEditingController(text: expense != null ? expense.note : '');
    final _fnNote = FocusNode();
    final _tfDescription = TextEditingController(text: expense != null ? expense.detail : '');
    final _tfCategory = TextEditingController(text: expense != null ? resolveExpenseCategory(expense.categoryName ?? '').label : resolveExpenseCategory(_controller.categoryList[0].code).label);
    final _tfCategoryCode = (expense != null ? expense.categoryName ?? '' : _controller.categoryList[0].code).obs;

    final _tfAmount = TextEditingController(text: expense != null ? expense.amount!.moneyFormat() : '');

    /// flag
    final isShowDetail = expense != null && expense.detail.isNotEmptyAndNotNull ? true.obs : false.obs;
    final isTypeNotes = expense != null && expense.resolvedCategory.code == 'expense:misc:notes' ? true.obs : false.obs;

    await Overlayment.show(
      context: Get.context!,
      OverPanel(
        width: 270,
        alignment: Alignment.center,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColor.appbarPrimary),
        backgroundSettings: BackgroundSettings(color: Colors.black54, blur: 1),
        animation: OverScaleAnimation(durationMilliseconds: 100, reverseDurationMilliseconds: 100),
        actions: OverlayActions(
          onReady: () async => _fnNote.requestFocus(),
          onClose: (_) async => await Overlayment.dismissLast(),
        ),
        child: VStack(
          [
            VStack([
              // header
              HStack([
                '${expense != null ? 'Edit Expense' : 'Add Expense'}'.text.bold.make(),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close, size: 16, color: AppColor.textReverse),
                  onPressed: () async => await Overlayment.dismissLast(),
                ),
              ]).pOnly(bottom: 12),

              // body
              if (expense != null) ...[
                CupertinoTextField(
                  controller: _tfDate,
                  readOnly: true,
                  placeholder: 'Date',
                  placeholderStyle: TextStyle(fontSize: 13),
                  decoration: BoxDecoration(color: Get.isDarkMode ? Vx.black : Vx.white, borderRadius: BorderRadius.circular(4)),
                  prefix: Icon(UIconsPro.solidRounded.calendar_day, size: 13, color: AppColor.textReverse).pOnly(left: 12, right: 4),
                  style: TextStyle(fontSize: 13, color: AppColor.textReverse),
                  onTap: () => HelperOverlay.openDatePicker(
                    initialDate: expense.date?.toDateEx(format: yMd),
                    minDate: DateTime(2020),
                    callback: (c) => _tfDate.text = c.toStringEx(format: yMd),
                  ),
                ).pOnly(bottom: 16),
              ],
              CupertinoTextField(
                controller: _tfNote,
                focusNode: _fnNote,
                autofocus: true,
                placeholder: 'Note: Nasi Padang',
                placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
                decoration: BoxDecoration(color: Get.isDarkMode ? Vx.black : Vx.white, borderRadius: BorderRadius.circular(4)),
                style: TextStyle(fontSize: 13, color: AppColor.textReverse),
                prefix: Icon(UIconsPro.solidRounded.notebook, size: 13, color: AppColor.textReverse).pOnly(left: 12, right: 4),
              ).pOnly(bottom: 8),

              HStack([
                Spacer(),
                'with Detail?'.text.size(11).minFontSize(11).underline.make().onInkTap(() {
                  isShowDetail.value = !isShowDetail.value;
                }),
              ]).pOnly(bottom: 12),

              /// description / detail
              Obx(
                () => Visibility(
                  visible: isShowDetail.value,
                  child: CupertinoTextField(
                    controller: _tfDescription,
                    placeholder: 'Detail: Nama Toko/Waktu',
                    decoration: BoxDecoration(color: Get.isDarkMode ? Vx.black : Vx.white, borderRadius: BorderRadius.circular(4)),
                    placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
                    style: TextStyle(fontSize: 13, color: AppColor.textReverse),
                    minLines: 2,
                    maxLines: 4,
                    clearButtonMode: OverlayVisibilityMode.editing,
                  ).pOnly(bottom: 16),
                ),
              ),

              /// field category
              Obx(
                () => CupertinoTextField(
                  controller: _tfCategory,
                  readOnly: true,
                  placeholder: 'Select Category',
                  decoration: BoxDecoration(color: Get.isDarkMode ? Vx.black : Vx.white, borderRadius: BorderRadius.circular(4)),
                  placeholderStyle: TextStyle(fontSize: 13, color: AppColor.neutral),
                  prefix: Icon(resolveExpenseCategory(_tfCategoryCode.value).icon, size: 13, color: resolveExpenseCategory(_tfCategoryCode.value).color).pOnly(left: 12, right: 4),
                  suffix: Icon(UIconsPro.solidRounded.caret_down, size: 13, color: AppColor.textReverse).pOnly(right: 12),
                  style: TextStyle(fontSize: 13, color: AppColor.textReverse),
                  onTap: () => HelperOverlay.openCategoryPicker(
                    callback: (c) {
                      _tfCategory.text = resolveExpenseCategory(c).label;
                      _tfCategoryCode.value = c;
                    },
                  ),
                ).pOnly(bottom: 16),
              ),

              /// field amount
              Obx(
                () => Visibility(
                  visible: isTypeNotes.isFalse,
                  child: CupertinoTextField(
                    controller: _tfAmount,
                    placeholder: 'Rp. 10.000',
                    placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
                    decoration: BoxDecoration(color: Get.isDarkMode ? Vx.black : Vx.white, borderRadius: BorderRadius.circular(4)),
                    style: TextStyle(fontSize: 13, color: AppColor.textReverse),
                    prefix: Icon(UIconsPro.solidRounded.coins, size: 13, color: AppColor.textReverse).pOnly(left: 12, right: 4),
                    inputFormatters: [
                      CurrencyTextInputFormatter(NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp.', decimalDigits: 0)),
                      LengthLimitingTextInputFormatter(16),
                    ],
                    keyboardType: TextInputType.number,
                  ).h(32),
                ),
              ),
            ]).pSymmetric(h: 8).p12(),

            Divider(),

            // footer
            HStack([
              if (expense != null) ...[
                ExButtonText(
                  child: 'Delete'.text.color(AppColor.red).size(13).make(),
                  onPressed: () async {
                    await Overlayment.dismissLast();
                    await _deleteExpense(expense: expense, callback: customCallback);
                  },
                ).expand(),
                Container(width: 0.5, height: 24, color: AppColor.divider).pSymmetric(h: 4),
              ],
              ExButtonText(
                child: Text('Submit', style: TextStyle(fontSize: 13)),
                onPressed: () async {
                  await Overlayment.dismissLast();
                  await _submitExpense(_tfNote.text, _tfDescription.text, _tfCategoryCode.value, _tfAmount.text, expense: expense, tfDate: _tfDate.text, customCallback: customCallback);
                },
              ).expand(),
            ]).pOnly(bottom: 8, left: 12, right: 12),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // ⵌ AI Input
  // ────────────────────────────────────────────────────────────────
  static Future<void> openAIInput() async {
    // ** desktop
    if (!Get.context!.isMobile) {
      final _tfText = TextEditingController();
      final _fnText = FocusNode();
      if (!_fnText.hasFocus) _fnText.requestFocus();

      HelperDialog.ios(
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
              await _processAIInput(s);
            },
          ).h(32),
        ]),
        actions: [
          CupertinoDialogAction(
            child: Text('Submit', style: TextStyle(fontSize: 13)),
            onPressed: () async {
              Get.back();
              await _processAIInput(_tfText.text);
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
            maxHeight: kIsWeb ? MediaQuery.of(Get.context!).size.height * 0.35 : MediaQuery.of(Get.context!).size.height * 0.8,
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
                    placeholderStyle: TextStyle(
                      fontSize: 13,
                      color: Vx.neutral500,
                    ),
                    style: TextStyle(fontSize: 13, color: AppColor.textReverse),
                    onSubmitted: (s) async {
                      Get.back();
                      await _processAIInput(s);
                    },
                  ),
                ),
                Divider().pOnly(top: 6, bottom: 0),
                ExButtonText(
                  label: 'Submit',
                  labelSize: 13,
                  onPressed: () async {
                    Get.back();
                    await _processAIInput(_tfText.text);
                  },
                ).wFull(Get.context!),
                12.heightBox,
              ],
            ).pSymmetric(h: 24),
          ),
        ),
      );
    }
  }

  // ────────────────────────────────────────────────────────────────
  // ⵌ processAIInput
  // ────────────────────────────────────────────────────────────────
  static Future<void> _processAIInput(String userText) async {
    final _controller = Get.find<HomeController>();

    _controller.footerStatus.value = 'Processing...';

    groq.startChat();
    groq.setCustomInstructionsWith('''
      You are an expert financial assistant. Your task is to analyze the user's text and extract transaction details.
      Interpret Indonesian currency shortcuts: 'k' or 'rb' means thousands (x1000), 'M' or 'jt' means millions (x1,000,000).
      You must pick a category value that aligns with the transaction type using the provided list.
      here the category list: ${_controller.categoryList.map((e) => e.code).join(', ')}

      `note` TitleCase format is required, simplify the detail.
      `detail` if user put much detail, put it, but if small detail keep empty string.
      `category` is required.
      `amount` is required.
      `date` is required.

      Return your response ONLY as a single, minified JSON object with the following structure. Do not add any other text or explanation.
      {
        "note": "string",             // string
        "detail": "string",           // string
        "category": "category_value", // string
        "amount": "amount_value",     // string
        "date": "YYYY-MM-DD"          // string
      }
    ''');

    final response = await groq.sendMessage('''
      Current date: ${DateTime.now().toStringEx(format: yMd)}
      If the user does not specify a date, assume it is the current date.
      here the category list: ${_controller.categoryList.map((e) => e.code).join(', ')}
      If no category fits, use "expense:unkown"
      Analyze the following text:
      $userText
    ''');

    final json = jsonDecode(response.choices.first.message.content);
    logD('json -> $json');
    _controller.footerStatus.value = 'Insert to DB';
    await _submitExpense(
      json['note'] as String,
      json['detail'] as String,
      json['category'] as String,
      json['amount'] as String,
      tfDate: json['date'] as String,
    ).catchError((e) async {
      _controller.footerStatus.value = 'Failed: ${e.toString()}';
      await HelperToast.error(e.toString());
    });
    _controller.footerStatus.value = '';
  }

  // ------------------------------------------------------------------------
  /// delete
  // ------------------------------------------------------------------------
  static Future<void> _deleteExpense({
    required SupaExpense expense,
    Function? callback,
  }) async {
    final _controller = Get.find<HomeController>();
    final _repo = Get.find<HomeRepository>();

    await _repo.deleteExpense(expense.id!);
    await _controller.getExpense();
    await _controller.onCalenderRefreshEvent(
      period: _controller.focusedDay.value.toStringEx(format: yM),
    );
    await _controller.getCount1Month(_controller.focusedDay.value);
    _controller.rpcSpenderDay.value = await _repo.rpcGetSpenderDay(
      _controller.focusedDay.value,
    );
    await callback?.call();
    // await HelperToast.warn('Data ${expense.note} Deleted');
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

    if (resolveExpenseCategory(newExpense.categoryName).code == 'expense:misc:notes') {
      newExpense.amount = 0;
    }

    /// process data
    try {
      /// insert to db
      expense != null ? await _repo.editExpense(newExpense) : await _repo.addExpense(newExpense);

      /// refresh data after insert
      await _controller.getExpense(
        find: _controller.tfSearchExpense.value.text.isNotBlank ? _controller.tfSearchExpense.value.text : null,
      );
      await _controller.getCount1Month(_controller.focusedDay.value);
      _controller.rpcSpenderDay.value = await _repo.rpcGetSpenderDay(
        _controller.focusedDay.value,
      );
      await customCallback?.call();
      // await HelperToast.info('Successfully ${expense != null ? 'Edit' : 'Added'} $tfNote');
      await _controller.onCalenderRefreshEvent(period: _controller.focusedDay.value.toStringEx(format: yM));
    } catch (e) {
      logE('e: $e');
      await HelperErrorLog.record(page: 'section_dialog_input', action: '_submitExpense', stack: e.toString());
      await HelperToast.error('Failed to ${expense != null ? 'Edit' : 'Added'} Data');
    }
  }

  /// ------------------------------------------------------------------------
  /// ! home search filter
  /// ------------------------------------------------------------------------
  static Future<void> openAdvenceFilter(String s) async {
    final _controller = Get.find<HomeController>();
    final _tfStartDate = TextEditingController(text: '');
    final _tfEndDate = TextEditingController(text: '');
    HelperDialog.ios(
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
            prefix: Icon(
              CupertinoIcons.calendar_today,
              size: 16,
              color: AppColor.textReverse,
            ).pOnly(left: 8),
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
            prefix: Icon(
              CupertinoIcons.calendar_today,
              size: 16,
              color: AppColor.textReverse,
            ).pOnly(left: 8),
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
                _tfEndDate.text = DateTime.now()
                    .add(
                      Duration(
                        days: dayInMonth(DateTime.now()) - DateTime.now().day,
                      ),
                    )
                    .toStringEx(format: yMd);
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
              await HelperToast.warn('Please select date range');
            }
          },
        ),
      ],
    );
  }
}
