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
        width: Get.context!.isMobile ? Get.width * 0.92 : 340,
        backgroundSettings: BackgroundSettings(color: AppColor.card.withAlpha(150), blur: isMobileWeb ? null : 1),
        animation: OverSlideAnimation(begin: Offset(1, 0), end: Offset(0, 0), durationMilliseconds: 100, reverseDurationMilliseconds: 100),

        child: VStack([
          // title
          HStack([
            Icon(UIconsPro.solidRounded.location_crosshairs, size: 16).pOnly(right: 10),
            'Goal'.text.bold.make().pSymmetric(h: 10, v: 3).color(AppColor.border).cornerRadius(6),
            Spacer(),
            IconButton(
              icon: Icon(UIconsPro.solidRounded.plus, size: 16),
              onPressed: () => openAddEdit(),
            ),
            IconButton(
              icon: Icon(UIconsPro.solidRounded.cross, size: 14),
              onPressed: () async => await Overlayment.dismissLast(),
            ),
          ]).pOnly(bottom: 12),

          // body
          Obx(() {
            final goals = _controller.goalsList;
            if (goals.isEmpty) {
              return VStack([
                Icon(Icons.indeterminate_check_box, size: 64, color: Vx.neutral400).centered(),
                12.heightBox,
                'Belum ada goal'.text.size(12).color(Vx.neutral400).makeCentered().pSymmetric(v: 12),
              ]).centered();
            }
            return ListView.separated(
              padding: EdgeInsets.only(bottom: 12),
              itemCount: goals.length,
              separatorBuilder: (context, index) => 10.heightBox,
              itemBuilder: (context, index) {
                final item = goals[index];
                final amount = item.amount ?? 0;
                final target = item.target ?? 0;
                final percentage = target > 0 ? (amount / target) * 100 : 0.0;
                final progressValue = percentage.isFinite ? percentage.clamp(0, 100).toDouble() : 0.0;

                final now = DateTime.now();
                final releaseDate = item.releaseDate?.toDateEx(format: yMd) ?? DateTime.now();
                final diffDays = releaseDate.difference(now).inDays;
                final moreMonths = diffDays ~/ 30;
                final remainingDays = diffDays % 30;
                final timeLeft = _formatTimeLeft(diffDays, moreMonths, remainingDays);
                final remainingFromTarget = target - amount;
                final monthsLeft = moreMonths > 0 ? moreMonths : 1;
                final savingRecomend = monthsLeft == 0 ? remainingFromTarget : remainingFromTarget / monthsLeft;
                final safeDaysLeft = diffDays > 0 ? diffDays : 1;
                final dailySaving = remainingFromTarget > 0 ? remainingFromTarget / safeDaysLeft : 0;

                return _goalTile(
                  goal: item,
                  percentage: percentage,
                  progressValue: progressValue,
                  remainingFromTarget: remainingFromTarget,
                  timeLeft: timeLeft,
                  savingRecomend: savingRecomend,
                  dailySaving: dailySaving,
                );
              },
            );
          }).expand(),
        ]).p12(),
      ),
    );
  }

  static Widget _goalTile({
    required SupaGoals goal,
    required double percentage,
    required double progressValue,
    required num remainingFromTarget,
    required String timeLeft,
    required num savingRecomend,
    required num dailySaving,
  }) {
    final isCompleted = remainingFromTarget <= 0;
    final percentLabel = '${percentage.isFinite ? percentage.clamp(0, 999).round() : 0}%';

    return Container(
      decoration: ExDecorator.box(
        borderRadius: 8,
        borderColor: AppColor.border,
        fillColor: AppColor.box,
      ),
      child: VStack([
        HStack(
          crossAlignment: CrossAxisAlignment.start,
          [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: ExDecorator.box(
                borderRadius: 8,
                borderColor: Colors.transparent,
                fillColor: AppColor.blue.withAlpha(24),
              ),
              child: Icon(
                UIconsPro.solidRounded.location_crosshairs,
                size: 17,
                color: AppColor.blue,
              ),
            ).pOnly(right: 10, top: 2),
            VStack([
              HStack([
                '${goal.title}'.text.bold.size(12).maxLines(2).ellipsis.make().expand(),
                _goalBadge(percentLabel, isCompleted).pOnly(left: 8),
              ]).pOnly(bottom: 4),
              HStack([
                '${goal.amount?.moneyFormatCompact()} / ${goal.target?.moneyFormatCompact()}'
                    .text
                    .size(11)
                    .minFontSize(11)
                    .color(AppColor.neutral)
                    .make()
                    .expand(),
                '${goal.releaseDate?.reformatDate(from: yMd, to: 'dd MMM y')}'
                    .text
                    .size(10)
                    .minFontSize(10)
                    .color(AppColor.green)
                    .make(),
              ]),
            ]).expand(),
          ],
        ).pOnly(bottom: 10),

        ExProgressBar(
          value: progressValue.toInt(),
          color1: isCompleted ? AppColor.green : AppColor.primary,
          color2: Vx.neutral400,
          height: 5,
        ).pOnly(bottom: 8),

        HStack([
          _goalPill(
            isCompleted
                ? 'Tercapai'
                : 'Sisa ${remainingFromTarget.moneyFormatCompact()}',
            isCompleted ? AppColor.green : AppColor.neutral,
          ),
          Spacer(),
          _goalPill(timeLeft, timeLeft == 'Terlambat' ? AppColor.red : AppColor.blue),
        ]).pOnly(bottom: 8),

        Container(
          decoration: ExDecorator.box(
            borderRadius: 8,
            borderColor: Colors.transparent,
            fillColor: AppColor.card,
          ),
          child: HStack([
            _goalMetric(
              title: 'Per bulan',
              value: savingRecomend > 0 ? savingRecomend.moneyFormatCompact() : '-',
              color: AppColor.green,
            ).expand(),
            Container(width: 1, height: 28, color: AppColor.border).pSymmetric(h: 10),
            _goalMetric(
              title: 'Per hari',
              value: dailySaving > 0 ? dailySaving.moneyFormatCompact() : '-',
              color: AppColor.blue,
            ).expand(),
          ]).pSymmetric(h: 10, v: 8),
        ),
      ]).pSymmetric(h: 12, v: 10),
    ).onInkTap(() => openAddEdit(goal: goal));
  }

  static Widget _goalBadge(String label, bool isCompleted) {
    return label.text
        .size(11)
        .minFontSize(11)
        .bold
        .color(isCompleted ? AppColor.green : AppColor.textReverse)
        .make()
        .pSymmetric(h: 8, v: 3)
        .box
        .color(AppColor.card)
        .make()
        .cornerRadius(90);
  }

  static Widget _goalPill(String label, Color color) {
    return label.text
        .size(10)
        .minFontSize(10)
        .color(color)
        .make()
        .pSymmetric(h: 8, v: 3)
        .box
        .color(color.withAlpha(22))
        .make()
        .cornerRadius(90);
  }

  static Widget _goalMetric({
    required String title,
    required String value,
    required Color color,
  }) {
    return VStack([
      title.text.size(10).minFontSize(10).color(AppColor.neutral).make(),
      value.text.bold.size(12).minFontSize(12).color(color).make(),
    ]);
  }

  static String _formatTimeLeft(int diffDays, int moreMonths, int remainingDays) {
    if (diffDays < 0) return 'Terlambat';
    if (diffDays == 0) return 'Jatuh tempo hari ini';

    var output = '';
    if (moreMonths > 0) output += '$moreMonths bulan';
    if (remainingDays > 0) {
      if (output.isNotEmpty) output += ', ';
      output += '$remainingDays hari';
    }
    return '$output lagi';
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
        backgroundSettings: BackgroundSettings(color: AppColor.card.withAlpha(150), blur: isMobileWeb ? null : 1),
        animation: OverScaleAnimation(durationMilliseconds: 100, reverseDurationMilliseconds: 100),
        actions: OverlayActions(
          onReady: () async => _fnTitle.requestFocus(),
          onClose: (_) async {
            await 100.milliseconds.delay();
            await openList();
          },
        ),
        child: VStack([
          VStack(
            [
              HStack(
                [
                  Icon(UIconsPro.solidRounded.location_crosshairs, size: 16).pOnly(right: 12),
                  '${goal != null ? 'Edit goal' : 'Tambah goal'}'.text.bold.make(),
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
                placeholder: 'Tanggal goal',
                decoration: BoxDecoration(color: Get.isDarkMode ? Vx.black : Vx.white, borderRadius: BorderRadius.circular(4)),
                placeholderStyle: TextStyle(fontSize: 13, color: AppColor.neutral),
                prefix: Icon(UIconsPro.solidRounded.calendar_heart, size: 13, color: AppColor.textReverse).pOnly(left: 12, right: 4),
                style: TextStyle(fontSize: 13, color: AppColor.textReverse),
                onTap: () => HelperOverlay.openDatePicker(
                  title: 'Tanggal goal',
                  btnOKText: 'Pilih tanggal',
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
                placeholder: 'Contoh: Nikah',
                placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
                decoration: BoxDecoration(color: Get.isDarkMode ? Vx.black : Vx.white, borderRadius: BorderRadius.circular(4)),
                style: TextStyle(fontSize: 13, color: AppColor.textReverse),
                prefix: Icon(UIconsPro.solidRounded.hastag, size: 13, color: AppColor.textReverse).pOnly(left: 12, right: 4),
              ).h(32),

              8.heightBox,

              /// field amount
              CupertinoTextField(
                controller: _tfAmount,
                placeholder: 'Saldo sekarang',
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
                placeholder: 'Saldo goal',
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
                  child: Text('Hapus', style: TextStyle(fontSize: 13, color: AppColor.red)),
                  onPressed: () async {
                    await _controller.repo.deleteGoals(goal.id ?? '');
                    await _controller.loadGoalsList();
                    await Overlayment.dismissLast();
                  },
                ).expand(),
                Container(height: 24, width: 0.5, color: Vx.neutral700).pSymmetric(h: 8),
              ],
              ExButtonText(
                child: Text('Simpan', style: TextStyle(fontSize: 13)),
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
