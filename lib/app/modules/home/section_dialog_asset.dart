import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:ex_kit/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:overlayment/overlayment.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:uuid/v4.dart';

import '../../core/app_api.dart';
import '../../core/app_color.dart';
import '../../helpers/helpers.dart';
import '../../models/supa_assets_entity.dart';
import 'home_controller.dart';

mixin DialogAsset {
  /// ------------------------------------------------------------------------
  /// Dialog Asset
  /// ------------------------------------------------------------------------
  static Future<void> openList() async {
    final _controller = Get.find<HomeController>();

    if (_controller.assetsList.isEmpty) {
      ExLoading.show(paddingSymmetric: Get.context!.isMobile ? 90 : 250, child: CupertinoActivityIndicator());
      await _controller.loadAssetsSummary();
      ExLoading.dismiss();
    }

    await Overlayment.show(
      context: Get.context!,
      OverPanel(
        alignment: Alignment.centerRight,
        width: 300,
        backgroundSettings: BackgroundSettings(color: AppColor.card, blur: 1),
        animation: OverSlideAnimation(begin: Offset(1, 0), end: Offset(0, 0), durationMilliseconds: 100, reverseDurationMilliseconds: 100),

        child: VStack([
          // title
          HStack([
            Icon(UIconsPro.solidRounded.plant_seed_invest, size: 16).pOnly(right: 12),
            'Assets'.text.bold.make().pSymmetric(h: 8, v: 2).color(AppColor.border).cornerRadius(4),
            Spacer(),
            IconButton(
              icon: Icon(UIconsPro.solidRounded.plus, size: 16),
              onPressed: () => openAddEdit(),
            ),
          ]).pOnly(bottom: 8),

          // body
          Obx(() {
            final assets = _controller.assetsList;
            if (assets.isEmpty) {
              return VStack([
                Icon(Icons.indeterminate_check_box, size: 64, color: Vx.neutral400).centered(),
                12.heightBox,
                'No assets yet'.text.size(12).color(Vx.neutral400).makeCentered().pSymmetric(v: 12),
              ]).centered();
            }
            return ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: assets.length,
              separatorBuilder: (context, index) => 12.heightBox,
              itemBuilder: (context, index) {
                final item = assets[index];

                return Container(
                  decoration: ExDecorator.box(borderRadius: 12, borderColor: AppColor.border, fillColor: AppColor.box),
                  child: HStack([
                    Icon(UIconsPro.solidRounded.circle, size: 12).pOnly(right: 8),
                    VStack([
                      '${item.title}'.text.size(12).bold.make(),
                      '${item.updatedAt?.reformatDate(to: 'dd MMM yyyy')}'.text.size(10).minFontSize(10).color(AppColor.neutral).make(),
                    ]).expand(),
                    '${item.amount?.moneyFormat()}'.text.size(12).make(),
                  ]).pSymmetric(h: 8, v: 8),
                ).onInkTap(() => openAddEdit(asset: item));
              },
            );
          }).expand(),

          // xx
          Container(
            decoration: ExDecorator.box(borderRadius: 90, borderColor: AppColor.border, fillColor: AppColor.primary),
            child: VStack([
              Obx(
                () => HStack([
                  'Total Assets:'.text.bold.size(12).color(AppColor.textOnBackground).make().expand(),
                  '${_controller.totalAssets.value.moneyFormat()}'.text.bold.color(AppColor.textOnBackground).size(12).make(),
                ]).pOnly(bottom: 8),
              ),
            ]).pOnly(top: 8, left: 12, right: 12),
          ),
        ]).p12(),
      ),
    );
  }

  static Future<void> openAddEdit({SupaAssets? asset}) async {
    await Overlayment.dismissLast();
    final _controller = Get.find<HomeController>();

    final _tfTitle = TextEditingController(text: asset != null ? asset.title : '');
    final _fnTitle = FocusNode();
    final _tfAmount = TextEditingController(text: asset != null ? asset.amount!.moneyFormat() : '');

    await Overlayment.show(
      context: Get.context,
      OverPanel(
        width: 270,
        alignment: Alignment.center,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColor.appbarPrimary),
        backgroundSettings: BackgroundSettings(color: AppColor.card, blur: 1),
        animation: OverScaleAnimation(durationMilliseconds: 100, reverseDurationMilliseconds: 100),
        actions: OverlayActions(
          onReady: () async => _fnTitle.requestFocus(),
          onClose: (_) async {
            await Overlayment.dismissLast();
            await openList();
          },
        ),
        child: VStack([
          VStack(
            [
              HStack(
                [
                  Icon(UIconsPro.solidRounded.plant_seed_invest, size: 16).pOnly(right: 12),
                  '${asset != null ? 'Edit Asset' : 'New Asset'}'.text.bold.make(),
                  Spacer(),
                  IconButton(
                    icon: Icon(UIconsPro.solidRounded.cross, size: 14),
                    onPressed: () async => await Overlayment.dismissLast(),
                  ),
                ],
              ).pOnly(bottom: 16, left: 4),

              /// field title
              CupertinoTextField(
                controller: _tfTitle,
                focusNode: _fnTitle,
                autofocus: true,
                placeholder: 'Title',
                placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
                decoration: BoxDecoration(color: Get.isDarkMode ? Vx.black : Vx.white, borderRadius: BorderRadius.circular(4)),
                style: TextStyle(fontSize: 13, color: AppColor.textReverse),
                prefix: Icon(UIconsPro.solidRounded.hastag, size: 13, color: AppColor.textReverse).pOnly(left: 12, right: 4),
              ).h(32),

              8.heightBox,

              /// field amount
              CupertinoTextField(
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
            ],
          ).p12(),

          Divider(color: Vx.neutral700, thickness: 0.5),

          // ** action
          HStack(
            [
              if (asset != null) ...[
                ExButtonText(
                  child: Text('Delete', style: TextStyle(fontSize: 13, color: AppColor.red)),
                  onPressed: () async {
                    await _controller.repo.deleteAssets(asset.id ?? '');
                    await _controller.loadAssetsSummary();
                    await Overlayment.dismissLast();
                  },
                ).expand(),
                Container(height: 24, width: 0.5, color: Vx.neutral700).pSymmetric(h: 8),
              ],
              ExButtonText(
                child: Text('Submit', style: TextStyle(fontSize: 13)),
                onPressed: () async {
                  final newAsset = SupaAssets(
                    id: asset?.id ?? UuidV4().generate(),
                    userId: db.auth.currentSession?.user.id ?? '',
                    title: _tfTitle.text,
                    amount: _tfAmount.text.moneyUnformat() ?? 0,
                    createdAt: asset?.createdAt ?? DateTime.now().toStringEx(),
                    updatedAt: DateTime.now().toStringEx(),
                  );
                  if (asset != null) {
                    await _controller.repo.updateAssets(newAsset).then((s) {});
                  } else {
                    await _controller.repo.addAssets(newAsset).then((s) {});
                  }
                  await _controller.loadAssetsSummary();
                  await Overlayment.dismissLast();
                },
              ).expand(),
            ],
          ).pOnly(bottom: 8, left: 12, right: 12),
        ]),
      ),
    );
  }
}
