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
        width: Get.context!.isMobile ? Get.width * 0.92 : 340,
        backgroundSettings: BackgroundSettings(color: AppColor.card, blur: 1),
        animation: OverSlideAnimation(begin: Offset(1, 0), end: Offset(0, 0), durationMilliseconds: 100, reverseDurationMilliseconds: 100),

        child: VStack([
          // title
          HStack([
            Icon(UIconsPro.solidRounded.plant_seed_invest, size: 16).pOnly(right: 10),
            'Assets'.text.bold.make().pSymmetric(h: 10, v: 3).color(AppColor.border).cornerRadius(6),
            Spacer(),
            IconButton(
              icon: Icon(UIconsPro.solidRounded.plus, size: 16),
              onPressed: () => openAddEdit(),
            ),
          ]).pOnly(bottom: 12),

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
              padding: EdgeInsets.only(bottom: 12),
              itemCount: assets.length,
              separatorBuilder: (context, index) => 10.heightBox,
              itemBuilder: (context, index) {
                final item = assets[index];

                return _assetTile(item);
              },
            );
          }).expand(),

          // xx
          _assetTotalBar(_controller),
        ]).p12(),
      ),
    );
  }

  static Widget _assetTile(SupaAssets asset) {
    return Container(
      decoration: ExDecorator.box(
        borderRadius: 8,
        borderColor: AppColor.border,
        fillColor: AppColor.box,
      ),
      child: HStack(
        crossAlignment: CrossAxisAlignment.start,
        [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: ExDecorator.box(
              borderRadius: 8,
              borderColor: Colors.transparent,
              fillColor: AppColor.green.withAlpha(24),
            ),
            child: Icon(
              UIconsPro.solidRounded.plant_seed_invest,
              size: 17,
              color: AppColor.green,
            ),
          ).pOnly(right: 10, top: 2),
          VStack([
            '${asset.title}'.text.bold.size(12).maxLines(2).ellipsis.make().pOnly(bottom: 6),
            HStack([
              _assetPill(
                'Updated ${asset.updatedAt?.reformatDate(to: 'dd MMM yyyy')}',
                AppColor.neutral,
              ).expand(),
            ]),
          ]).expand(),
          10.widthBox,
          '${asset.amount?.moneyFormat()}'
              .text
              .bold
              .size(12)
              .minFontSize(10)
              .color(AppColor.green)
              .make()
              .pSymmetric(h: 8, v: 4)
              .box
              .color(AppColor.green.withAlpha(22))
              .make()
              .cornerRadius(90),
        ],
      ).pSymmetric(h: 12, v: 10),
    ).onInkTap(() => openAddEdit(asset: asset));
  }

  static Widget _assetPill(String label, Color color) {
    return label.text
        .size(10)
        .minFontSize(10)
        .maxLines(1)
        .ellipsis
        .color(color)
        .make()
        .pSymmetric(h: 8, v: 3)
        .box
        .color(color.withAlpha(22))
        .make()
        .cornerRadius(90);
  }

  static Widget _assetTotalBar(HomeController controller) {
    return Container(
      decoration: ExDecorator.box(
        borderRadius: 8,
        borderColor: Colors.transparent,
        fillColor: AppColor.primary,
      ),
      child: Obx(
        () => HStack([
          'Total Assets'.text.bold.size(12).color(AppColor.textOnBackground).make().expand(),
          '${controller.totalAssets.value.moneyFormat()}'.text.bold.color(AppColor.textOnBackground).size(12).make(),
        ]).pSymmetric(h: 14, v: 10),
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
            await 100.milliseconds.delay();
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
