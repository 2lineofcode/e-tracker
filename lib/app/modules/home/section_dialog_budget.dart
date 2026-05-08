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
import '../../models/supa_budgets_entity.dart';
import '../../models/supa_category_entity.dart';
import 'home_controller.dart';

mixin DialogBudget {
  /// ------------------------------------------------------------------------
  /// Dialog Budgets
  /// ------------------------------------------------------------------------

  static Future<void> openList() async {
    final _controller = Get.find<HomeController>();

    await Overlayment.show(
      context: Get.context!,
      OverPanel(
        alignment: Alignment.centerRight,
        width: 300,
        backgroundSettings: BackgroundSettings(color: AppColor.card, blur: 1),
        animation: OverSlideAnimation(
          begin: Offset(1, 0),
          end: Offset(0, 0),
          durationMilliseconds: 100,
          reverseDurationMilliseconds: 100,
        ),

        child: VStack([
          // title
          HStack([
            Icon(
              UIconsPro.solidRounded.piggy_bank_budget,
              size: 16,
            ).pOnly(right: 12),
            'Budgets'.text.bold.make().pSymmetric(h: 8, v: 2).color(AppColor.border).cornerRadius(4),
            Spacer(),
            IconButton(
              icon: Icon(UIconsPro.solidRounded.plus, size: 16),
              onPressed: () => openAddEdit(),
            ),
          ]).pOnly(bottom: 8),

          // body
          GetBuilder(
            init: HomeController(),
            builder: (controller) {
              final budgetsList = controller.budgetsList;
              if (budgetsList.isEmpty) {
                return VStack([
                  Icon(
                    Icons.indeterminate_check_box,
                    size: 64,
                    color: Vx.neutral400,
                  ).centered(),
                  12.heightBox,
                  'No budget yet'.text.size(12).color(Vx.neutral400).makeCentered().pSymmetric(v: 12),
                ]).centered();
              }
              return ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: budgetsList.length,
                separatorBuilder: (context, index) => 12.heightBox,
                itemBuilder: (context, index) {
                  final item = budgetsList[index];
                  final category = resolveExpenseCategory(item.categoryCode);
                  final spent = controller.monthlyExpenseByGroup[category.code] ?? 0;
                  final budgetAmount = item.amount ?? 0;
                  final percent = budgetAmount > 0 ? (spent.toDouble() / budgetAmount) * 100 : 0.0;
                  final progressValue = percent.isFinite ? percent.clamp(0, 100).toDouble() : 0.0;
                  final progressColor = HelperBibit.getColorForPercentage(percent);
                  final percentLabel = '${(percent.isFinite ? percent.clamp(0, 999).round() : 0)}%';
                  final remaining = budgetAmount - spent;
                  final isWarning = percent >= 80;

                  return Container(
                    decoration: ExDecorator.box(borderRadius: 12, borderColor: AppColor.border, fillColor: AppColor.box),
                    child: HStack([
                      Icon(category.icon ?? Icons.circle_outlined, size: 18, color: category.color ?? AppColor.textReverse).pOnly(right: 12),
                      VStack([
                        '${category.label}'.text.bold.size(12).maxLines(1).ellipsis.make().pOnly(bottom: 0),
                        HStack([
                          '${spent.moneyFormatCompact()} / ${budgetAmount.moneyFormatCompact()} Used'.text.size(11).minFontSize(11).color(AppColor.neutral).make().expand(),
                          percentLabel.text
                              .size(11)
                              .minFontSize(11)
                              .color(percent > 100 ? Colors.red : AppColor.textReverse)
                              .make()
                              .pSymmetric(h: 6, v: 2)
                              .box
                              .color(AppColor.card)
                              .make()
                              .cornerRadius(90),
                        ]).pOnly(bottom: 6),
                        ExProgressBar(
                          value: progressValue.toInt(),
                          color1: progressColor,
                          color2: Vx.neutral400,
                          height: 4,
                        ).pOnly(bottom: 4),
                        HStack([
                          (remaining >= 0 ? 'Remaining ${remaining.moneyFormatCompact()}' : 'Over ${remaining.abs().moneyFormatCompact()}')
                              .text
                              .size(10)
                              .minFontSize(10)
                              .color(remaining >= 0 ? AppColor.green : AppColor.red)
                              .make()
                              .expand(),
                          if (isWarning)
                            (percent >= 100 ? 'Over budget' : 'Watch pace')
                                .text
                                .size(10)
                                .minFontSize(10)
                                .color(AppColor.red)
                                .make(),
                        ]),
                      ]).expand(),
                    ]).pSymmetric(h: 8, v: 4),
                  ).onInkTap(() => openAddEdit(budget: item));
                },
              );
            },
          ).expand(),

          // xx
          Container(
            decoration: ExDecorator.box(borderRadius: 90, borderColor: AppColor.border, fillColor: AppColor.primary),
            child: VStack([
              HStack([
                'Total Budgets:'.text.bold.size(12).color(AppColor.textOnBackground).make().expand(),
                Obx(() {
                  final totalBudgetRaw = _controller.totalAllBudget.value;
                  final totalBudget = totalBudgetRaw.isFinite ? totalBudgetRaw : 0;
                  return '${totalBudget.moneyFormat()}'.text.bold.color(AppColor.textOnBackground).size(12).make();
                }),
              ]).pOnly(bottom: 8),
            ]).pOnly(top: 8, left: 12, right: 12),
          ),
        ]).p12(),
      ),
    );
  }

  static Future<void> openAddEdit({SupaBudgets? budget}) async {
    await Overlayment.dismissLast();
    final _controller = Get.find<HomeController>();

    final _tfCategory = TextEditingController(text: budget != null ? resolveExpenseCategory(budget.categoryCode ?? '').label : resolveExpenseCategory(_controller.categoryList[0].code).label);
    final _tfCategoryCode = (budget != null ? budget.categoryCode ?? '' : _controller.categoryList[0].code).obs;

    final _tfAmount = TextEditingController(text: budget != null ? budget.amount!.moneyFormat() : '');
    final _fnAmount = FocusNode();

    await Overlayment.show(
      context: Get.context,
      OverPanel(
        width: 270,
        alignment: Alignment.center,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColor.appbarPrimary),
        backgroundSettings: BackgroundSettings(color: AppColor.card, blur: 1),
        animation: OverScaleAnimation(durationMilliseconds: 100, reverseDurationMilliseconds: 100),
        actions: OverlayActions(
          onReady: () async => _fnAmount.requestFocus(),
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
                  Icon(UIconsPro.solidRounded.piggy_bank_budget, size: 16).pOnly(right: 12),
                  '${budget != null ? 'Edit Budget' : 'New Budget'}'.text.bold.make(),
                  Spacer(),
                  IconButton(
                    icon: Icon(UIconsPro.solidRounded.cross, size: 14),
                    onPressed: () async => await Overlayment.dismissLast(),
                  ),
                ],
              ).pOnly(bottom: 16, left: 4),

              /// field category
              Obx(
                () => CupertinoTextField(
                  controller: _tfCategory,
                  readOnly: true,
                  placeholder: 'Select Category',
                  decoration: BoxDecoration(color: Get.isDarkMode ? Vx.black : Vx.white, borderRadius: BorderRadius.circular(4)),
                  placeholderStyle: TextStyle(fontSize: 13, color: AppColor.neutral),
                  prefix: Icon(resolveExpenseCategory(_tfCategoryCode.value).icon, size: 13, color: resolveExpenseCategory(_tfCategoryCode.value).color).pOnly(left: 12, right: 4),
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
              if (budget != null) ...[
                ExButtonText(
                  child: Text('Delete', style: TextStyle(fontSize: 13, color: AppColor.red)),
                  onPressed: () async {
                    await _controller.repo.deleteBudgets(budget.id ?? '');
                    await _controller.refreshBudgetsList();
                    await Overlayment.dismissLast();
                  },
                ).expand(),
                Container(height: 24, width: 0.5, color: Vx.neutral700).pSymmetric(h: 8),
              ],

              ExButtonText(
                child: Text('Submit', style: TextStyle(fontSize: 13)),
                onPressed: () async {
                  final newBudget = SupaBudgets(
                    id: budget?.id ?? UuidV4().generate(),
                    userId: db.auth.currentSession?.user.id ?? '',
                    categoryCode: _tfCategoryCode.value,
                    amount: _tfAmount.text.moneyUnformat() ?? 0,
                    createdAt: DateTime.now().toStringEx(),
                  );

                  if (budget != null) {
                    await _controller.repo.updateBudgets(newBudget).then((s) {});
                  } else {
                    await _controller.repo.addBudgets(newBudget).then((s) {});
                  }

                  await _controller.refreshBudgetsList();
                  await Overlayment.dismissAll();
                },
              ).expand(),
            ],
          ).pOnly(bottom: 8, left: 12, right: 12),
        ]),
      ),
    );
  }
}
