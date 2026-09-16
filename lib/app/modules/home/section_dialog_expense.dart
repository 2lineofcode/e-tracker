import 'dart:convert';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:ex_kit/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:overlayment/overlayment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/v4.dart';

import '../../core/app_api.dart';
import '../../core/app_color.dart';
import '../../core/app_setting.dart';
import '../../core/const.dart';
import '../../helpers/helpers.dart';
import '../../models/supa_category_entity.dart';
import '../../models/supa_expense_entity.dart';
import '../widgets/widget_image_no_cache_view.dart';
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
  static const _expenseImageBucket = 'expense-images';

  static Future<String?> _uploadExpenseImage({
    required String expenseId,
    required Rx<Uint8List?> previewBytes,
  }) async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.image,
      );
      if (file == null) return null;

      final bytes = await compressImage(await file.readAsBytes());
      if (bytes.length > 5 * 1024 * 1024) {
        await HelperToast.error('Maks. 5 MB');
        return null;
      }
      final fileName =
          '${db.auth.currentSession?.user.id ?? currentUserId}/$expenseId.jpg';

      await db.storage
          .from(_expenseImageBucket)
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              cacheControl: '1',
              contentType: 'image/jpeg',
            ),
          );

      previewBytes.value = bytes;
      return fileName;
    } catch (e) {
      if (e is FormatException) {
        await HelperToast.error(e.message);
      } else if (e is StorageException) {
        await HelperToast.error('${e.message}\nMaks. 5 MB');
      } else {
        await HelperErrorLog.record(
          page: 'section_dialog_input',
          action: '_uploadExpenseImage',
          stack: e.toString(),
        );
        await HelperToast.error('Gagal mengunggah gambar');
      }
      return null;
    }
  }

  static String? _expenseImagePath(String value) {
    if (value.isEmptyOrNull) return null;

    if (!value.startsWith('http')) return value;

    final uri = Uri.tryParse(value);
    if (uri == null) return null;

    final bucketIndex = uri.pathSegments.indexOf(_expenseImageBucket);
    if (bucketIndex == -1 || bucketIndex == uri.pathSegments.length - 1) {
      return null;
    }

    return uri.pathSegments
        .skip(bucketIndex + 1)
        .map(Uri.decodeComponent)
        .join('/');
  }

  static Future<void> _deleteExpenseImagesFromStorage(
    List<String> imageUrls,
  ) async {
    final paths = imageUrls
        .map(_expenseImagePath)
        .whereType<String>()
        .toSet()
        .toList();
    if (paths.isEmpty) return;

    try {
      await db.storage.from(_expenseImageBucket).remove(paths);
    } catch (e) {
      await HelperErrorLog.record(
        page: 'section_dialog_input',
        action: '_deleteExpenseImagesFromStorage',
        stack: e.toString(),
      );
      await HelperToast.warn('Pengeluaran tersimpan, tapi gambar lama gagal dihapus');
    }
  }

  static void _openExpenseImagePreview({
    required String imageUrl,
    required Uint8List? previewBytes,
  }) async {
    if (imageUrl.isNotEmptyAndNotNull) {
      final path = _expenseImagePath(imageUrl);
      if (path != null) {
        final signedUrl = await db.storage
            .from(_expenseImageBucket)
            .createSignedUrl(path, 300);
        await launchUrlString(signedUrl);
      }
      return;
    }

    if (previewBytes == null) return;

    await showDialog(
      context: Get.context!,
      barrierColor: Colors.black87,
      builder: (_) => Dialog.fullscreen(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Image.memory(previewBytes, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: Icon(Icons.close, color: Vx.white, size: 24),
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _expenseImagePicker({
    required SupaExpense expense,
    required RxString imageUrl,
    required Rx<Uint8List?> previewBytes,
    required RxList<String> imageUrlsToDelete,
  }) {
    return Obx(() {
      final hasImage =
          previewBytes.value != null || imageUrl.value.isNotEmptyAndNotNull;

      void queueDelete(String url) {
        if (url.isEmptyOrNull || imageUrlsToDelete.contains(url)) return;
        imageUrlsToDelete.add(url);
      }

      return VStack([
        if (hasImage) ...[
          ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: previewBytes.value != null
                    ? Image.memory(
                        previewBytes.value!,
                        width: double.infinity,
                        height: 120,
                        fit: BoxFit.cover,
                      )
                    : FutureBuilder<String>(
                        future: db.storage
                            .from(_expenseImageBucket)
                            .createSignedUrl(imageUrl.value, 300),
                        builder: (_, snapshot) => ExImageNoCacheView(
                          url: snapshot.data ?? '',
                          width: double.infinity,
                          height: 120,
                          radius: 6,
                        ),
                      ),
              )
              .onInkTap(
                () => _openExpenseImagePreview(
                  imageUrl: imageUrl.value,
                  previewBytes: previewBytes.value,
                ),
              )
              .pOnly(bottom: 10),
        ],
        HStack([
          ExButtonElevated(
            height: 32,
            onPressed: () async {
              final previousImageUrl = imageUrl.value;
              final uploadedUrl = await _uploadExpenseImage(
                expenseId: expense.id ?? UuidV4().generate(),
                previewBytes: previewBytes,
              );
              if (uploadedUrl.isNotEmptyAndNotNull) {
                queueDelete(previousImageUrl);
                imageUrl.value = uploadedUrl!;
              }
            },
            child: HStack([
              Icon(
                Icons.image_outlined,
                size: 13,
                color: AppColor.textReverse,
              ).pOnly(right: 6),
              (hasImage ? 'Ganti gambar' : 'Tambah gambar').text
                  .size(11)
                  .minFontSize(11)
                  .make(),
            ]).centered(),
          ).expand(),
          if (hasImage) ...[
            8.widthBox,
            ExButtonElevated(
              height: 32,
              onPressed: () {
                queueDelete(imageUrl.value);
                imageUrl.value = '';
                previewBytes.value = null;
              },
              child: Icon(
                CupertinoIcons.trash,
                size: 13,
                color: AppColor.red,
              ),
            ).w(42),
          ],
        ]),
      ]).pOnly(top: 14, bottom: 22);
    });
  }

  static Widget _merchantField({
    required HomeController controller,
    required TextEditingController textController,
    required FocusNode focusNode,
    required ValueChanged<SupaExpense> onSelected,
    Widget? prefix,
  }) {
    return RawAutocomplete<SupaExpense>(
      textEditingController: textController,
      focusNode: focusNode,
      displayStringForOption: (option) => option.note ?? '',
      optionsBuilder: (value) => controller.merchantSuggestions(value.text),
      onSelected: onSelected,
      fieldViewBuilder: (context, fieldController, fieldFocusNode, _) {
        return CupertinoTextField(
          controller: fieldController,
          focusNode: fieldFocusNode,
          autofocus: !Get.context!.isMobile,
          placeholder: 'Note: Nasi Padang',
          placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
          decoration: BoxDecoration(
            color: Get.isDarkMode ? Vx.black : Vx.white,
            borderRadius: BorderRadius.circular(4),
          ),
          style: TextStyle(fontSize: 13, color: AppColor.textReverse),
          prefix: prefix,
        );
      },
      optionsViewBuilder: (context, select, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 8,
            color: AppColor.card,
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: Get.context!.isMobile ? Get.width - 48 : 238,
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: 4),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return InkWell(
                    onTap: () => select(option),
                    child: HStack([
                      Icon(
                        option.resolvedCategory.icon,
                        size: 13,
                        color: option.resolvedCategory.color,
                      ).pOnly(right: 8),
                      VStack([
                        '${option.note}'.text.size(12).ellipsis.make(),
                        [
                          option.resolvedCategory.label,
                          if (option.detail?.trim().isNotEmpty == true)
                            option.detail!.trim(),
                        ].join(' · ').text
                            .size(9)
                            .minFontSize(9)
                            .color(AppColor.neutral)
                            .make(),
                      ]).expand(),
                      '${option.amount?.moneyFormatCompact()}'.text
                          .size(10)
                          .minFontSize(10)
                          .make(),
                    ]).pSymmetric(h: 10, v: 7),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// ------------------------------------------------------------------------
  /// Manual Input
  /// ------------------------------------------------------------------------
  static Future<void> openManualInput({
    SupaExpense? expense,
    SupaExpense? draft,
    Function? customCallback,
  }) async {
    if (Get.context!.isMobile) {
      await _manualInputForMobile(
        expense: expense,
        draft: draft,
        customCallback: customCallback,
      );
    } else {
      await _manualInputForDesktop(
        expense: expense,
        draft: draft,
        customCallback: customCallback,
      );
    }
  }

  static Future<void> repeatExpense(SupaExpense source) async {
    await openManualInput(
      draft: SupaExpense(
        date: DateTime.now().toStringEx(format: yMd),
        note: source.note,
        detail: source.detail,
        categoryName: source.categoryName,
        amount: source.amount,
      ),
    );
  }

  static Future<void> _manualInputForMobile({
    SupaExpense? expense,
    SupaExpense? draft,
    Function? customCallback,
  }) async {
    final _controller = Get.find<HomeController>();

    if (_controller.categoryList.isEmptyOrNull) {
      await HelperToast.warn('Buat minimal 1 kategori dulu');
      return;
    }

    final initial = expense ?? draft;
    final _tfDate = TextEditingController(text: initial?.date ?? '');
    final _tfNote = TextEditingController(
      text: initial?.note ?? '',
    );
    final _fnNote = FocusNode();
    final _tfDescription = TextEditingController(
      text: initial?.detail ?? '',
    );
    final _tfCategory =
        (initial != null
                ? initial.categoryName ?? ''
                : _controller.categoryList[0].code)
            .obs;
    final _tfAmount = TextEditingController(
      text: initial?.amount?.moneyFormat() ?? '',
    );
    final _imageUrl = (initial?.imagePath ?? '').obs;
    final _imagePreview = Rx<Uint8List?>(null);
    final _imageUrlsToDelete = <String>[].obs;

    /// flag
    final isShowDetail = initial != null && initial.detail.isNotEmptyAndNotNull
        ? true.obs
        : false.obs;
    final isTypeNotes =
        initial != null && initial.resolvedCategory.code == 'expense:misc:notes'
        ? true.obs
        : false.obs;
    ExBottomSheet.basic(
      title: '${expense != null ? 'Edit pengeluaran' : 'Tambah pengeluaran'}',
      backgroundColor: AppColor.appbarPrimary,
      barrierColor: Colors.black54,
      content: VStack(
        [
          if (initial != null) ...[
            CupertinoTextField(
              controller: _tfDate,
              readOnly: true,
              placeholder: 'Tanggal',
              decoration: BoxDecoration(
                color: Get.isDarkMode ? Vx.black : Vx.white,
                borderRadius: BorderRadius.circular(4),
              ),
              placeholderStyle: TextStyle(fontSize: 13),
              prefix: Icon(
                CupertinoIcons.calendar_today,
                size: 16,
                color: AppColor.textReverse,
              ).pOnly(left: 8),
              style: TextStyle(fontSize: 13, color: AppColor.textReverse),
              onTap: () => ExDatePicker.materialDatePicker(
                initialDate: initial.date?.toDateEx(format: yMd),
                minDate: DateTime(2020),
                callback: (c) => _tfDate.text = c.toStringEx(format: yMd),
              ),
            ).pOnly(bottom: 16),
          ],

          _merchantField(
            controller: _controller,
            textController: _tfNote,
            focusNode: _fnNote,
            onSelected: (suggestion) {
              _tfDescription.text = suggestion.detail ?? '';
              _tfCategory.value = suggestion.resolvedCategory.code;
              _tfAmount.text = suggestion.amount?.moneyFormat() ?? '';
              isShowDetail.value = _tfDescription.text.isNotEmpty;
              isTypeNotes.value = false;
            },
          ).pOnly(bottom: 16),

          HStack(
            [
              Spacer(),
              Text(
                'Tambah detail?',
                style: TextStyle(
                  fontSize: 11,
                  decoration: TextDecoration.underline,
                ),
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
                placeholder: 'Detail: Toko/waktu',
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
                    child: Row(
                      children: [
                        Icon(
                          element.icon ?? Icons.circle_outlined,
                          size: 16,
                          color: element.color,
                        ).pOnly(right: 8),
                        Expanded(
                          child: Text(
                            '${element.label}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              );
            }
            return DropdownButtonFormField<String>(
              isExpanded: true,
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
                  _tfAmount.text = initial?.amount?.moneyFormat() ?? '';
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
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? Vx.black : Vx.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
                style: TextStyle(fontSize: 13, color: AppColor.textReverse),
                prefix: IconButton(
                  icon: Icon(
                    Icons.calculate,
                    size: 14,
                    color: AppColor.textReverse,
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: Get.context!,
                      builder: (context) => FractionallySizedBox(
                        heightFactor: 0.7,
                        child: SimpleCalculator(
                          autofocus: true,
                          hideSurroundingBorder: true,
                          value:
                              _tfAmount.text.moneyUnformat()?.toDouble() ?? 0.0,
                          onTappedDisplay: (p0, p1) => Get.back(),
                          onChanged: (key, value, expression) {
                            final moneyFormat =
                                value!.toString().toInt()?.moneyFormat() ?? '';
                            _tfAmount.text = moneyFormat;
                          },
                        ),
                      ),
                    );
                  },
                ),
                inputFormatters: [
                  CurrencyTextInputFormatter(
                    NumberFormat.simpleCurrency(
                      locale: 'id_ID',
                      name: 'Rp.',
                      decimalDigits: 0,
                    ),
                  ),
                  LengthLimitingTextInputFormatter(16),
                ],
                keyboardType: TextInputType.number,
                onSubmitted: (_) async => {
                  Get.back(),
                  await _submitExpense(
                    _tfNote.text,
                    _tfDescription.text,
                    _tfCategory.value,
                    _tfAmount.text,
                    expense: expense,
                    tfDate: _tfDate.text,
                    imageUrl: _imageUrl.value,
                    imageUrlsToDelete: _imageUrlsToDelete.toList(),
                    customCallback: customCallback,
                  ),
                },
              ).h(32),
            ),
          ),

          if (expense != null) ...[
            _expenseImagePicker(
              expense: expense,
              imageUrl: _imageUrl,
              previewBytes: _imagePreview,
              imageUrlsToDelete: _imageUrlsToDelete,
            ),
          ],

          Divider().pSymmetric(v: 12),

          /// action
          HStack(
            [
              if (expense != null) ...[
                ExButtonElevated(
                  child: Text(
                    'Hapus',
                    style: TextStyle(color: Vx.red500, fontSize: 13),
                  ),
                  onPressed: () async {
                    Get.back();
                    await _deleteExpense(
                      expense: expense,
                      callback: customCallback,
                    );
                  },
                ).pOnly(right: 12).expand(),
              ],
              ExButtonElevated(
                child: Text('Simpan', style: TextStyle(fontSize: 13)),
                onPressed: () async {
                  Get.back();
                  await _submitExpense(
                    _tfNote.text,
                    _tfDescription.text,
                    _tfCategory.value,
                    _tfAmount.text,
                    expense: expense,
                    tfDate: _tfDate.text,
                    imageUrl: _imageUrl.value,
                    imageUrlsToDelete: _imageUrlsToDelete.toList(),
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

  static Future<void> _manualInputForDesktop({
    SupaExpense? expense,
    SupaExpense? draft,
    Function? customCallback,
  }) async {
    // local inject
    final _controller = Get.find<HomeController>();

    if (_controller.categoryList.isEmptyOrNull) {
      await HelperToast.warn('Buat minimal 1 kategori dulu');
      return;
    }

    final initial = expense ?? draft;
    final _tfDate = TextEditingController(text: initial?.date ?? '');
    final _tfNote = TextEditingController(
      text: initial?.note ?? '',
    );
    final _fnNote = FocusNode();
    final _tfDescription = TextEditingController(
      text: initial?.detail ?? '',
    );
    final _tfCategory = TextEditingController(
      text: initial != null
          ? resolveExpenseCategory(initial.categoryName ?? '').label
          : resolveExpenseCategory(_controller.categoryList[0].code).label,
    );
    final _tfCategoryCode =
        (initial != null
                ? initial.categoryName ?? ''
                : _controller.categoryList[0].code)
            .obs;

    final _tfAmount = TextEditingController(
      text: initial?.amount?.moneyFormat() ?? '',
    );
    final _imageUrl = (initial?.imagePath ?? '').obs;
    final _imagePreview = Rx<Uint8List?>(null);
    final _imageUrlsToDelete = <String>[].obs;

    /// flag
    final isShowDetail = initial != null && initial.detail.isNotEmptyAndNotNull
        ? true.obs
        : false.obs;
    final isTypeNotes =
        initial != null && initial.resolvedCategory.code == 'expense:misc:notes'
        ? true.obs
        : false.obs;

    await Overlayment.show(
      context: Get.context!,
      OverPanel(
        width: 270,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColor.appbarPrimary,
        ),
        backgroundSettings: BackgroundSettings(color: Colors.black54, blur: 1),
        animation: OverScaleAnimation(
          durationMilliseconds: 100,
          reverseDurationMilliseconds: 100,
        ),
        actions: OverlayActions(
          onReady: () async => _fnNote.requestFocus(),
        ),
        child: VStack(
          [
            VStack([
              // header
              HStack([
                '${expense != null ? 'Edit pengeluaran' : 'Tambah pengeluaran'}'.text.bold
                    .make(),
                Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 16,
                    color: AppColor.textReverse,
                  ),
                  onPressed: () async => await Overlayment.dismissLast(),
                ),
              ]).pOnly(bottom: 12),

              // body
              if (initial != null) ...[
                CupertinoTextField(
                  controller: _tfDate,
                  readOnly: true,
                  placeholder: 'Tanggal',
                  placeholderStyle: TextStyle(fontSize: 13),
                  decoration: BoxDecoration(
                    color: Get.isDarkMode ? Vx.black : Vx.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  prefix: Icon(
                    UIconsPro.solidRounded.calendar_day,
                    size: 13,
                    color: AppColor.textReverse,
                  ).pOnly(left: 12, right: 4),
                  style: TextStyle(fontSize: 13, color: AppColor.textReverse),
                  onTap: () => HelperOverlay.openDatePicker(
                    initialDate: initial.date?.toDateEx(format: yMd),
                    minDate: DateTime(2020),
                    callback: (c) => _tfDate.text = c.toStringEx(format: yMd),
                  ),
                ).pOnly(bottom: 16),
              ],
              _merchantField(
                controller: _controller,
                textController: _tfNote,
                focusNode: _fnNote,
                onSelected: (suggestion) {
                  _tfDescription.text = suggestion.detail ?? '';
                  _tfCategory.text = suggestion.resolvedCategory.label;
                  _tfCategoryCode.value = suggestion.resolvedCategory.code;
                  _tfAmount.text = suggestion.amount?.moneyFormat() ?? '';
                  isShowDetail.value = _tfDescription.text.isNotEmpty;
                  isTypeNotes.value = false;
                },
                prefix: Icon(
                  UIconsPro.solidRounded.notebook,
                  size: 13,
                  color: AppColor.textReverse,
                ).pOnly(left: 12, right: 4),
              ).pOnly(bottom: 8),

              HStack([
                Spacer(),
                'Tambah detail?'.text
                    .size(11)
                    .minFontSize(11)
                    .underline
                    .make()
                    .onInkTap(() {
                      isShowDetail.value = !isShowDetail.value;
                    }),
              ]).pOnly(bottom: 12),

              /// description / detail
              Obx(
                () => Visibility(
                  visible: isShowDetail.value,
                  child: CupertinoTextField(
                    controller: _tfDescription,
                    placeholder: 'Detail: Toko/waktu',
                    decoration: BoxDecoration(
                      color: Get.isDarkMode ? Vx.black : Vx.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    placeholderStyle: TextStyle(
                      fontSize: 13,
                      color: Vx.neutral500,
                    ),
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
                  placeholder: 'Pilih kategori',
                  decoration: BoxDecoration(
                    color: Get.isDarkMode ? Vx.black : Vx.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  placeholderStyle: TextStyle(
                    fontSize: 13,
                    color: AppColor.neutral,
                  ),
                  prefix: Icon(
                    resolveExpenseCategory(_tfCategoryCode.value).icon,
                    size: 13,
                    color: resolveExpenseCategory(_tfCategoryCode.value).color,
                  ).pOnly(left: 12, right: 4),
                  suffix: Icon(
                    UIconsPro.solidRounded.caret_down,
                    size: 13,
                    color: AppColor.textReverse,
                  ).pOnly(right: 12),
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
                    placeholderStyle: TextStyle(
                      fontSize: 13,
                      color: Vx.neutral500,
                    ),
                    decoration: BoxDecoration(
                      color: Get.isDarkMode ? Vx.black : Vx.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    style: TextStyle(fontSize: 13, color: AppColor.textReverse),
                    prefix: Icon(
                      UIconsPro.solidRounded.coins,
                      size: 13,
                      color: AppColor.textReverse,
                    ).pOnly(left: 12, right: 4),
                    inputFormatters: [
                      CurrencyTextInputFormatter(
                        NumberFormat.simpleCurrency(
                          locale: 'id_ID',
                          name: 'Rp.',
                          decimalDigits: 0,
                        ),
                      ),
                      LengthLimitingTextInputFormatter(16),
                    ],
                    keyboardType: TextInputType.number,
                  ).h(32),
                ),
              ),

              if (expense != null) ...[
                _expenseImagePicker(
                  expense: expense,
                  imageUrl: _imageUrl,
                  previewBytes: _imagePreview,
                  imageUrlsToDelete: _imageUrlsToDelete,
                ),
              ],
            ]).pSymmetric(h: 8).p12(),

            Divider(),

            // footer
            HStack([
              if (expense != null) ...[
                ExButtonText(
                  child: 'Hapus'.text.color(AppColor.red).size(13).make(),
                  onPressed: () async {
                    await Overlayment.dismissLast();
                    await _deleteExpense(
                      expense: expense,
                      callback: customCallback,
                    );
                  },
                ).expand(),
                Container(
                  width: 0.5,
                  height: 24,
                  color: AppColor.divider,
                ).pSymmetric(h: 4),
              ],
              ExButtonText(
                child: Text('Simpan', style: TextStyle(fontSize: 13)),
                onPressed: () async {
                  await Overlayment.dismissLast();
                  await _submitExpense(
                    _tfNote.text,
                    _tfDescription.text,
                    _tfCategoryCode.value,
                    _tfAmount.text,
                    expense: expense,
                    tfDate: _tfDate.text,
                    imageUrl: _imageUrl.value,
                    imageUrlsToDelete: _imageUrlsToDelete.toList(),
                    customCallback: customCallback,
                  );
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
          'Tambah pengeluaran',
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ).pOnly(bottom: 16),
        content: VStack([
          CupertinoTextField(
            controller: _tfText,
            focusNode: _fnText,
            placeholder: 'Tulis pengeluaranmu di sini...',
            placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
            style: TextStyle(fontSize: 13, color: AppColor.textReverse),
            onSubmitted: (s) async {
              if (s.trim().isEmpty) {
                await HelperToast.warn('Tulis pengeluarannya dulu');
                return;
              }
              Get.back();
              await _processAIInput(s);
            },
          ).h(32),
        ]),
        actions: [
          CupertinoDialogAction(
            child: Text('Scan struk', style: TextStyle(fontSize: 13)),
            onPressed: () async {
              Get.back();
              await openReceiptScanner();
            },
          ),
          CupertinoDialogAction(
            child: Text('Simpan', style: TextStyle(fontSize: 13)),
            onPressed: () async {
              if (_tfText.text.trim().isEmpty) {
                await HelperToast.warn('Tulis pengeluarannya dulu');
                return;
              }
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
      final _isListening = false.obs;
      final _isVoiceSupported = kIsWeb && HelperVoiceInput.isSupported;
      var _voiceBaseText = '';

      void applyVoiceText(String text) {
        _tfText.text = [
          _voiceBaseText,
          text,
        ].where((value) => value.isNotEmpty).join(' ');
        _tfText.selection = TextSelection.fromPosition(
          TextPosition(offset: _tfText.text.length),
        );
      }

      ExBottomSheet.basic(
        title: 'Tambah pengeluaran',
        backgroundColor: AppColor.appbarPrimary,
        barrierColor: Colors.black54,
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
                    placeholder: kIsWeb
                        ? 'Ketuk di sini untuk mulai mengetik...'
                        : 'Tulis pengeluaranmu di sini...',
                    placeholderStyle: TextStyle(
                      fontSize: 13,
                      color: Vx.neutral500,
                    ),
                    style: TextStyle(fontSize: 13, color: AppColor.textReverse),
                    onSubmitted: (s) async {
                      if (s.trim().isEmpty) {
                        await HelperToast.warn('Tulis pengeluarannya dulu');
                        return;
                      }
                      Get.back();
                      await _processAIInput(s);
                    },
                  ),
                ),
                Divider().pOnly(top: 6, bottom: 0),
                HStack([
                  ExButtonText(
                    label: 'Scan struk',
                    labelSize: 12,
                    onPressed: () async {
                      HelperVoiceInput.stopListening();
                      Get.back();
                      await openReceiptScanner();
                    },
                  ).expand(),
                  Container(
                    height: 24,
                    width: 0.5,
                    color: AppColor.border,
                  ).pSymmetric(h: 8),
                  if (_isVoiceSupported) ...[
                    Obx(
                      () => ExButtonText(
                        onPressed: () {
                          if (_isListening.value) {
                            _isListening.value = false;
                            HelperVoiceInput.stopListening();
                            return;
                          }

                          _fnText.unfocus();
                          _voiceBaseText = _tfText.text.trim();
                          _isListening.value = true;
                          HelperVoiceInput.listenIndonesian(
                            onStart: () => _isListening.value = true,
                            onEnd: () => _isListening.value = false,
                            onResult: applyVoiceText,
                            onError: (e) async {
                              _isListening.value = false;
                              await HelperToast.warn(
                                HelperVoiceInput.errorMessage(e),
                              );
                            },
                          );
                        },
                        child: HStack([
                          Icon(
                            _isListening.value
                                ? CupertinoIcons.waveform
                                : CupertinoIcons.mic_fill,
                            size: 14,
                            color: _isListening.value
                                ? AppColor.red
                                : AppColor.textReverse,
                          ).pOnly(right: 6),
                          (_isListening.value ? 'Stop' : 'Suara').text
                              .size(12)
                              .minFontSize(12)
                              .make(),
                        ]).centered(),
                      ).expand(),
                    ),
                    Container(
                      height: 24,
                      width: 0.5,
                      color: AppColor.border,
                    ).pSymmetric(h: 8),
                  ],
                  ExButtonText(
                    label: 'Simpan',
                    labelSize: 13,
                    onPressed: () async {
                      if (_tfText.text.trim().isEmpty) {
                        await HelperToast.warn('Tulis pengeluarannya dulu');
                        return;
                      }
                      HelperVoiceInput.stopListening();
                      Get.back();
                      await _processAIInput(_tfText.text);
                    },
                  ).expand(),
                ]).wFull(Get.context!),
                12.heightBox,
              ],
            ).pSymmetric(h: 24),
          ),
        ),
      );
    }
  }

  static Future<void> openReceiptScanner() async {
    final file = await FilePicker.pickFile(
      type: FileType.image,
    );
    if (file == null) return;
    final controller = Get.find<HomeController>();
    ExLoading.show(
      paddingSymmetric: Get.context!.isMobile ? 90 : 250,
      child: VStack([
        CupertinoActivityIndicator().centered(),
        'Lagi membaca struk...'.text.size(11).makeCentered().pOnly(top: 8),
      ]),
    );

    SupaExpense? draft;
    try {
      final sourceBytes = await file.readAsBytes();
      if (sourceBytes.isEmpty) {
        throw FormatException('Gambar nggak bisa dibaca');
      }
      final bytes = await compressImage(sourceBytes);
      if (bytes.length > 3 * 1024 * 1024) {
        throw FormatException('Ukuran gambar maksimal 3 MB');
      }

      final response = await db.functions.invoke(
        'agent-proxy',
        body: {
          'action': 'receipt_scan',
          'image': base64Encode(bytes),
          'current_date': DateTime.now().toStringEx(format: yMd),
          'category_codes': controller.categoryList
              .map((category) => category.code)
              .toList(),
        },
      );
      if (response.data is! Map) {
        throw FormatException('Respons scan struk tidak valid');
      }
      final payload = Map<String, dynamic>.from(response.data as Map);
      final choices = payload['choices'];
      if (choices is! List || choices.isEmpty) {
        throw FormatException('Respons scan struk tidak valid');
      }
      final choice = choices.first;
      if (choice is! Map || choice['message'] is! Map) {
        throw FormatException('Respons scan struk tidak valid');
      }
      final content = (choice['message'] as Map)['content'];
      if (content is! String) {
        throw FormatException('Respons scan struk tidak valid');
      }
      final receipt = jsonDecode(content) as Map<String, dynamic>;
      final amount = receipt['amount'].toString().moneyUnformat() ?? 0;
      final date = DateTime.tryParse(receipt['date']?.toString() ?? '') == null
          ? DateTime.now().toStringEx(format: yMd)
          : receipt['date'].toString();

      draft = SupaExpense(
        note: receipt['note']?.toString() ?? '',
        detail: receipt['detail']?.toString() ?? '',
        categoryName: resolveExpenseCategory(
          receipt['category']?.toString(),
        ).code,
        amount: amount,
        date: date,
      );
    } catch (e) {
      await HelperErrorLog.record(
        page: 'home',
        action: 'openReceiptScanner',
        stack: e.toString(),
      );
      await HelperToast.error(
        e is FormatException ? e.message.toString() : 'Struk gagal dibaca',
      );
    } finally {
      ExLoading.dismiss();
    }

    if (draft != null) await openManualInput(draft: draft);
  }

  // ────────────────────────────────────────────────────────────────
  // ⵌ processAIInput
  // ────────────────────────────────────────────────────────────────
  static Future<void> _processAIInput(String userText) async {
    final _controller = Get.find<HomeController>();

    _controller.footerStatus.value = 'Lagi diproses...';

    groq.startChat();
    groq.setCustomInstructionsWith('''
      You are an expert financial assistant. Your task is to analyze the user's text and extract transaction details.
      Interpret Indonesian currency shortcuts: 'k' or 'rb' means thousands (x1000), 'M' or 'jt' means millions (x1,000,000).
      You must pick a category value that aligns with the transaction type using the provided list.
      here the category list: ${_controller.categoryList.map((e) => e.code).join(', ')}

      `note` TitleCase format is required, simplify the detail. better use indonesia language
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

    // If the user does not specify a date, assume it is the current date.
    // here the category list: ${_controller.categoryList.map((e) => e.code).join(', ')}

    final response = await groq.sendMessage('''
      Current date: ${DateTime.now().toStringEx(format: yMd)}
      date selected is: ${_controller.focusedDay.value.toStringEx(format: yMd)}
      If no category fits, use "expense:unknown"
      Analyze the following text:
      $userText
    ''');

    final json = jsonDecode(response.choices.first.message.content);
    logD('json -> $json');
    _controller.footerStatus.value = 'Lagi disimpan...';
    await _submitExpense(
      json['note'] as String,
      json['detail'] as String,
      json['category'] as String,
      json['amount'] as String,
      tfDate: json['date'] as String,
    ).catchError((e) async {
      _controller.footerStatus.value = 'Gagal: ${e.toString()}';
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
    await _controller.loadRecentExpenses();
    await _controller.loadBudgetSuggestions();
    await _controller.onCalenderRefreshEvent();
    await _controller.getCount1Month(_controller.focusedDay.value);
    final period = _controller.focusedPeriod;
    _controller.rpcSpenderDay.value = await _repo.rpcGetSpenderDay(
      period.start,
      period.end,
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
    String? imageUrl,
    List<String> imageUrlsToDelete = const [],
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
      date: tfDate.isNotEmptyAndNotNull
          ? tfDate
          : _controller.focusedDay.value.toStringEx(format: yMd),
      amount: tfAmount.moneyUnformat(),
      categoryName: tfCategory,
      note: '${tfNote.toTitleCase}',
      detail: tfDescription ?? '',
      imagePath: imageUrl ?? expense?.imagePath,
    );

    if (resolveExpenseCategory(newExpense.categoryName).code ==
        'expense:misc:notes') {
      newExpense.amount = 0;
    }

    final duplicates = await _repo.findPotentialDuplicate(
      date:
          newExpense.date ??
          _controller.focusedDay.value.toStringEx(format: yMd),
      note: newExpense.note ?? '',
      amount: newExpense.amount ?? 0,
      excludeId: expense?.id,
    );

    if (duplicates.isNotEmpty) {
      final duplicate = duplicates.first;
      ExAlert.confirm(
        title: 'Kemungkinan duplikat',
        message:
            '${duplicate.note} (${duplicate.amount?.moneyFormat()}) sudah ada pada ${duplicate.date?.reformatDate(from: yMd, to: 'dd MMM y')}.\n\nTetap simpan transaksi ini?',
        btnYesText: 'Tetap simpan',
        onYes: () async {
          Get.back();
          await _persistExpense(
            newExpense,
            isEdit: expense != null,
            imageUrlsToDelete: imageUrlsToDelete,
            customCallback: customCallback,
          );
        },
      );
      return;
    }

    await _persistExpense(
      newExpense,
      isEdit: expense != null,
      imageUrlsToDelete: imageUrlsToDelete,
      customCallback: customCallback,
    );
  }

  static Future<void> _persistExpense(
    SupaExpense newExpense, {
    required bool isEdit,
    List<String> imageUrlsToDelete = const [],
    Function? customCallback,
  }) async {
    final _controller = Get.find<HomeController>();
    final _repo = Get.find<HomeRepository>();

    /// process data
    try {
      /// insert to db
      isEdit
          ? await _repo.editExpense(newExpense)
          : await _repo.addExpense(newExpense);

      await _deleteExpenseImagesFromStorage(imageUrlsToDelete);

      /// refresh data after insert
      await _controller.getExpense(
        find: _controller.tfSearchExpense.value.text.isNotBlank
            ? _controller.tfSearchExpense.value.text
            : null,
      );
      await _controller.loadRecentExpenses();
      await _controller.loadBudgetSuggestions();
      await _controller.getCount1Month(_controller.focusedDay.value);
      final period = _controller.focusedPeriod;
      _controller.rpcSpenderDay.value = await _repo.rpcGetSpenderDay(
        period.start,
        period.end,
      );
      await customCallback?.call();
      // await HelperToast.info('Successfully ${expense != null ? 'Edit' : 'Added'} $tfNote');
      await _controller.onCalenderRefreshEvent();
    } catch (e) {
      logE('e: $e');
      await HelperErrorLog.record(
        page: 'section_dialog_input',
        action: '_persistExpense',
        stack: e.toString(),
      );
      await HelperToast.error('Gagal ${isEdit ? 'mengubah' : 'menambah'} pengeluaran');
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
        'Filter lanjutan untuk "$s"',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        textAlign: TextAlign.left,
      ).pOnly(bottom: 16),
      content: VStack(
        [
          /// start date
          CupertinoTextField(
            controller: _tfStartDate,
            readOnly: true,
            placeholder: 'Tanggal mulai',
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
            placeholder: 'Tanggal akhir',
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
                'Bulan ini',
                style: TextStyle(decoration: TextDecoration.underline),
                overflow: TextOverflow.ellipsis,
              ).onInkTap(() {
                _tfStartDate.text = DateTime.now()
                    .subtract(Duration(days: DateTime.now().day - 1))
                    .toStringEx(format: yMd);
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
                '7 hari',
                style: TextStyle(decoration: TextDecoration.underline),
                overflow: TextOverflow.ellipsis,
              ).onInkTap(() {
                _tfStartDate.text = DateTime.now()
                    .subtract(Duration(days: 7))
                    .toStringEx(format: yMd);
                _tfEndDate.text = DateTime.now().toStringEx(format: yMd);
              }),
              Spacer(),
              Text(
                '30 hari',
                style: TextStyle(decoration: TextDecoration.underline),
                overflow: TextOverflow.ellipsis,
              ).onInkTap(() {
                _tfStartDate.text = DateTime.now()
                    .subtract(Duration(days: 30))
                    .toStringEx(format: yMd);
                _tfEndDate.text = DateTime.now().toStringEx(format: yMd);
              }),
            ],
          ),
        ],
      ).h(110),
      actions: [
        CupertinoDialogAction(
          child: Text('Terapkan', style: TextStyle(fontSize: 13)),
          onPressed: () async {
            if (_tfStartDate.text.isNotBlank && _tfEndDate.text.isNotBlank) {
              await _controller.getExpense(
                find: s,
                startDate: _tfStartDate.text,
                endDate: _tfEndDate.text,
              );
              Get.back();
            } else {
              await HelperToast.warn('Pilih rentang tanggal dulu');
            }
          },
        ),
      ],
    );
  }
}
