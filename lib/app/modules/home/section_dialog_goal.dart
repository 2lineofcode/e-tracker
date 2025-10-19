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
import '../../core/const.dart';
import '../../helpers/helpers.dart';
import '../../models/supa_goals_entity.dart';
import 'home_controller.dart';

mixin DialogGoal {
  /// ------------------------------------------------------------------------
  /// Dialog Goal
  /// ------------------------------------------------------------------------
  static Future<void> openList() async {
    final _controller = Get.find<HomeController>();

    if (_controller.goalsList.isEmpty) {
      ExLoading.show(paddingSymmetric: Get.context!.isMobile ? 90 : 250, child: CupertinoActivityIndicator());
      await _controller.loadGoalsList();
      ExLoading.dismiss();
    }

    await Overlayment.show(
      context: Get.context!,
      OverPanel(
        alignment: Alignment.centerRight,
        width: 310,
        backgroundSettings: BackgroundSettings(color: AppColor.card, blur: 1),
        animation: OverSlideAnimation(begin: Offset(1, 0), end: Offset(0, 0), durationMilliseconds: 100, reverseDurationMilliseconds: 100),

        child: VStack([
          // title
          HStack([
            Icon(UIconsPro.solidRounded.location_crosshairs, size: 16).pOnly(right: 12),
            'Goals'.text.bold.make().pSymmetric(h: 8, v: 2).color(AppColor.border).cornerRadius(4),
            Spacer(),
            IconButton(
              icon: Icon(UIconsPro.solidRounded.plus, size: 16),
              onPressed: () => openAddEdit(),
            ),
          ]).pOnly(bottom: 8),

          // body
          Obx(() {
            final goals = _controller.goalsList;
            if (goals.isEmpty) {
              return VStack([
                Icon(Icons.indeterminate_check_box, size: 64, color: Vx.neutral400).centered(),
                12.heightBox,
                'No goals yet'.text.size(12).color(Vx.neutral400).makeCentered().pSymmetric(v: 12),
              ]).centered();
            }
            return ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: goals.length,
              separatorBuilder: (context, index) => 12.heightBox,
              itemBuilder: (context, index) {
                final item = goals[index];
                final percentage = ((item.amount ?? 0) / (item.target ?? 1)) * 100;

                final now = DateTime.now();
                final releaseDate = item.releaseDate?.toDateEx(format: yMd) ?? DateTime.now();
                final diffDays = releaseDate.difference(now).inDays;
                final moreMonths = diffDays ~/ 30;
                final remainingDays = diffDays % 30;
                String timeLeft = '';
                if (moreMonths > 0) timeLeft += '$moreMonths month${moreMonths > 1 ? 's' : ''}';
                if (remainingDays > 0) {
                  if (timeLeft.isNotEmpty) timeLeft += ', ';
                  timeLeft += '$remainingDays day${remainingDays > 1 ? 's' : ''}';
                }
                timeLeft = '$timeLeft left';

                final remainingFromTarget = (item.target ?? 0) - (item.amount ?? 0);
                final monthsLeft = moreMonths > 0 ? moreMonths : 1;
                final savingRecomend = monthsLeft == 0 ? remainingFromTarget : remainingFromTarget / monthsLeft;

                return Container(
                  decoration: ExDecorator.box(borderRadius: 12, borderColor: AppColor.border, fillColor: AppColor.box),

                  child: VStack(
                    [
                      HStack(
                        alignment: MainAxisAlignment.start,
                        crossAlignment: CrossAxisAlignment.start,
                        [
                          Icon(UIconsPro.solidRounded.circle, size: 12).pOnly(right: 8, top: 4),

                          VStack([
                            HStack([
                              '${item.title}'.text.size(12).bold.make(),
                              Spacer(),
                              '(${item.releaseDate?.reformatDate(from: yMd, to: 'dd MMM y')})'.text.size(11).minFontSize(11).color(AppColor.green).make(),
                            ]),

                            HStack([
                              ExProgressBar(value: percentage.toInt(), color1: AppColor.primary, color2: Vx.neutral400).h(4).expand(),
                              '${percentage.toInt()}%'.text.size(12).make().pOnly(left: 12),
                            ]).pSymmetric(v: 4),

                            HStack([
                              '${item.amount?.moneyFormatCompact()} / ${item.target?.moneyFormatCompact()}'.text.size(11).minFontSize(11).color(AppColor.neutral).make(),
                              Spacer(),
                              '${remainingFromTarget.moneyFormatCompact()} Left'.text.size(11).minFontSize(11).color(AppColor.neutral).make(),
                            ]).pOnly(bottom: 4),
                          ]).expand(),
                        ],
                      ).pSymmetric(h: 8, v: 8),

                      VStack([
                        '$timeLeft'.text.size(11).minFontSize(11).color(AppColor.blue).bold.make(),
                        HStack([
                          'Better if you saving: '.text.size(11).minFontSize(11).make(),
                          '${savingRecomend.moneyFormatCompact()} '.text.bold.size(11).minFontSize(11).color(AppColor.green).make(),
                          'per month'.text.size(11).minFontSize(11).make(),
                          Spacer(),
                        ]),
                      ]).pSymmetric(v: 8, h: 12).color(AppColor.box).cornerRadius(8),
                    ],
                  ),
                ).onInkTap(() => openAddEdit(goal: item));
              },
            );
          }).expand(),
        ]).p12(),
      ),
    );
  }

  static Future<void> openAddEdit({SupaGoals? goal}) async {
    await Overlayment.dismissLast();
    final _controller = Get.find<HomeController>();

    final _tfReleaseDate = TextEditingController(text: goal != null ? goal.releaseDate : '');
    final _tfTitle = TextEditingController(text: goal != null ? goal.title : '');
    final _fnTitle = FocusNode();
    final _tfAmount = TextEditingController(text: goal != null ? goal.amount!.moneyFormat() : '');
    final _tfTarget = TextEditingController(text: goal != null ? goal.target!.moneyFormat() : '');

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
                  Icon(UIconsPro.solidRounded.location_crosshairs, size: 16).pOnly(right: 12),
                  '${goal != null ? 'Edit Goal' : 'New Goal'}'.text.bold.make(),
                  Spacer(),
                  IconButton(
                    icon: Icon(UIconsPro.solidRounded.cross, size: 14),
                    onPressed: () async => await Overlayment.dismissLast(),
                  ),
                ],
              ).pOnly(bottom: 16, left: 4),

              /// field release date
              CupertinoTextField(
                controller: _tfReleaseDate,
                readOnly: true,
                placeholder: 'Due Date',
                decoration: BoxDecoration(color: Get.isDarkMode ? Vx.black : Vx.white, borderRadius: BorderRadius.circular(4)),
                placeholderStyle: TextStyle(fontSize: 13, color: AppColor.neutral),
                prefix: Icon(UIconsPro.solidRounded.calendar_heart, size: 13, color: AppColor.textReverse).pOnly(left: 12, right: 4),
                style: TextStyle(fontSize: 13, color: AppColor.textReverse),
                onTap: () => HelperOverlay.openDatePicker(
                  title: 'Due Date',
                  btnOKText: 'Pick Date',
                  initialDate: goal?.releaseDate?.toDateEx(format: yMd),
                  minDate: DateTime.now(),
                  maxDate: DateTime.now().add((365 * 30).days),
                  callback: (c) => _tfReleaseDate.text = c.toStringEx(format: yMd),
                ),
              ).pOnly(bottom: 16),

              /// field title
              CupertinoTextField(
                controller: _tfTitle,
                focusNode: _fnTitle,
                autofocus: true,
                placeholder: 'Ex: Nikah',
                placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
                decoration: BoxDecoration(color: Get.isDarkMode ? Vx.black : Vx.white, borderRadius: BorderRadius.circular(4)),
                style: TextStyle(fontSize: 13, color: AppColor.textReverse),
                prefix: Icon(UIconsPro.solidRounded.hastag, size: 13, color: AppColor.textReverse).pOnly(left: 12, right: 4),
              ).h(32),

              8.heightBox,

              /// field amount
              CupertinoTextField(
                controller: _tfAmount,
                placeholder: 'Saldo Sekarang',
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

              8.heightBox,

              /// field target
              CupertinoTextField(
                controller: _tfTarget,
                placeholder: 'Saldo Target',
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
              if (goal != null) ...[
                ExButtonText(
                  child: Text('Delete', style: TextStyle(fontSize: 13, color: AppColor.red)),
                  onPressed: () async {
                    await _controller.repo.deleteGoals(goal.id ?? '');
                    await _controller.loadGoalsList();
                    await Overlayment.dismissLast();
                  },
                ).expand(),
                Container(height: 24, width: 0.5, color: Vx.neutral700).pSymmetric(h: 8),
              ],
              ExButtonText(
                child: Text('Submit', style: TextStyle(fontSize: 13)),
                onPressed: () async {
                  final newGoal = SupaGoals(
                    id: goal?.id ?? UuidV4().generate(),
                    userId: db.auth.currentSession?.user.id ?? '',
                    title: _tfTitle.text,
                    amount: _tfAmount.text.moneyUnformat() ?? 0,
                    target: _tfTarget.text.moneyUnformat() ?? 0,
                    releaseDate: _tfReleaseDate.text,
                    createdAt: goal?.createdAt ?? DateTime.now().toStringEx(),
                    updatedAt: DateTime.now().toStringEx(),
                  );
                  if (goal != null) {
                    await _controller.repo.updateGoals(newGoal).then((s) {});
                  } else {
                    await _controller.repo.addGoals(newGoal).then((s) {});
                  }
                  await _controller.loadGoalsList();
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
