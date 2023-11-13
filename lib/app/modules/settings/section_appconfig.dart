import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/app_base.dart';
import '../../core/app_color.dart';
import '../../core/app_setting.dart';
import '../../core/const.dart';
import '../../helpers/helper_decoration.dart';
import '../../helpers/helper_money.dart';
import 'settings_controller.dart';

class SectionAppConfig extends GetView<SettingsController> {
  const SectionAppConfig({super.key});

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        settingCommon(),
        16.heightBox,
      ],
    ).scrollVertical();
  }

  Widget settingCommon() {
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(fillColor: AppColor.cardHeaderPrimary, borderColor: AppColor.cardHeaderPrimary, borderRadius: 4),
      child: VStack(
        [
          HStack([
            'App Config'.text.bold.make(),
            Spacer(),
          ]),

          Divider().pSymmetric(v: 8),

          /// 0
          HStack(
            [
              'Dark Mode:'.text.make().w(200),
              Spacer(),
              Switch.adaptive(
                value: pref.read<bool>(kIsDarkMode) ?? true,
                onChanged: (s) async {
                  await Get.find<AppSettingService>().switchTheme();
                },
              ),
            ],
          ),
          Divider().pSymmetric(v: 8),

          /// 1
          HStack([
            'Max Flag Eco Day:'.text.make().w(200),
            TextField(
              controller: controller.tfEco,
              decoration: MyDecoration.input(
                hint: '≤ 50.000',
                prefixIcon: '≤ '.text.make().pOnly(left: 12, top: 4),
              ),
              style: TextStyle(fontSize: 13),
              inputFormatters: [CurrencyTextInputFormatter(symbol: 'Rp. ', decimalDigits: 0)],
            ).h(28).expand(),
            Icon(Icons.circle, color: AppColor.green, size: 8).pOnly(left: 8),
          ]),
          Divider().pSymmetric(v: 8),

          /// 2
          HStack([
            'Max Flag Average Day:'.text.make().w(200),
            TextField(
              controller: controller.tfAverage,
              decoration: MyDecoration.input(
                hint: '≤ 100.000',
                prefixIcon: '≤ '.text.make().pOnly(left: 12, top: 4),
              ),
              style: TextStyle(fontSize: 13),
              inputFormatters: [CurrencyTextInputFormatter(symbol: 'Rp. ', decimalDigits: 0)],
              onChanged: (s) => controller.tfSpender.text = s,
            ).h(28).expand(),
            Icon(Icons.circle, color: AppColor.orange, size: 8).pOnly(left: 8),
          ]),
          Divider().pSymmetric(v: 8),

          /// 3
          HStack([
            'Max Flag Spender Day:'.text.make().w(200),
            TextField(
              enabled: false,
              controller: controller.tfSpender,
              decoration: MyDecoration.input(
                hint: '> 100.000',
                prefixIcon: '> '.text.make().pOnly(left: 12, top: 4),
              ),
              style: TextStyle(fontSize: 13),
              inputFormatters: [CurrencyTextInputFormatter(symbol: 'Rp. ', decimalDigits: 0)],
            ).h(28).expand(),
            Icon(Icons.circle, color: AppColor.red, size: 8).pOnly(left: 8),
          ]),

          Divider().pSymmetric(v: 8),
          HStack(
            [
              Spacer(),
              ExButtonOutline(
                label: 'Reset to default',
                labelColor: AppColor.textReverse,
                borderColor: Vx.neutral500,
                labelSize: 11,
                height: 38,
                onPressed: () {
                  controller.tfEco.text = 50000.moneyFormat();
                  controller.tfAverage.text = 100000.moneyFormat();
                  controller.tfSpender.text = 100000.moneyFormat();
                },
              ),
              12.widthBox,
              ExButtonOutline(
                width: 120,
                label: 'Apply',
                labelColor: AppColor.textReverse,
                borderColor: Vx.neutral500,
                labelSize: 11,
                height: 38,
                onPressed: () async {
                  if (controller.tfAverage.text.moneyUnformat()! < controller.tfEco.text.moneyUnformat()!) {
                    ExSnackbar.danger('"average" must > "eco"');
                    return;
                  }
                  await pref.write(kFlagEco, controller.tfEco.text.moneyUnformat());
                  await pref.write(kFlagAverage, controller.tfAverage.text.moneyUnformat());
                  await pref.write(kFlagSpender, controller.tfSpender.text.moneyUnformat());
                  await Get.forceAppUpdate();
                  ExSnackbar.success('Saved');
                },
              ),
            ],
          ),
        ],
      ).p12(),
    );
  }

  Widget settingCurrency() {
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(fillColor: AppColor.cardHeaderPrimary, borderColor: AppColor.cardHeaderPrimary, borderRadius: 4),
      child: VStack(
        [
          HStack([
            'Currency'.text.bold.make(),
          ]),
          Divider().pSymmetric(v: 12),

          /// 1
          HStack([
            'Currency Symbol:'.text.make().w(200),
            TextField(
              decoration: MyDecoration.input(hint: 'Rp.'),
              style: TextStyle(fontSize: 13),
            ).h(28).expand(),
          ]),

          Divider().pSymmetric(v: 8),

          /// action
          HStack(
            [
              Spacer(),
              ExButtonOutline(
                label: 'Reset to default',
                labelColor: AppColor.textReverse,
                borderColor: Vx.neutral500,
                labelSize: 11,
                height: 38,
                onPressed: () {
                  //
                },
              ),
              12.widthBox,
              ExButtonOutline(
                width: 120,
                label: 'Apply',
                labelColor: AppColor.textReverse,
                borderColor: Vx.neutral500,
                labelSize: 11,
                height: 38,
                onPressed: () {
                  //
                },
              ),
            ],
          ),
        ],
      ).p12(),
    );
  }
}
