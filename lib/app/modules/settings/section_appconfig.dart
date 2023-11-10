import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/app_color.dart';
import '../../core/app_setting.dart';
import '../../core/const.dart';
import '../../helpers/helper_decoration.dart';
import 'settings_controller.dart';

class SectionAppConfig extends GetView<SettingsController> {
  const SectionAppConfig({super.key});

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        settingCommon(),
        16.heightBox,
        settingCurrency(),
      ],
    );
  }

  Widget settingCommon() {
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(fillColor: AppColor.cardHeaderPrimary, borderColor: AppColor.cardHeaderPrimary, borderRadius: 4),
      child: VStack(
        [
          HStack(
            [
              'Basic'.text.bold.make(),
              Spacer(),
              ExButtonOutline(
                label: 'Apply',
                labelColor: AppColor.textReverse,
                borderColor: Vx.neutral500,
                labelSize: 11,
                height: 38,
                onPressed: () {},
              )
            ],
          ),

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
                  await 300.milliseconds.delay();
                  await Get.forceAppUpdate();
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
              decoration: MyDecorationHelper.inputDecorator(
                hint: '< 50.000',
                prefixIcon: '< '.text.make().pOnly(left: 12, top: 4),
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
              decoration: MyDecorationHelper.inputDecorator(
                hint: '< 100.000',
                prefixIcon: '< '.text.make().pOnly(left: 12, top: 4),
              ),
              style: TextStyle(fontSize: 13),
              inputFormatters: [CurrencyTextInputFormatter(symbol: 'Rp. ', decimalDigits: 0)],
            ).h(28).expand(),
            Icon(Icons.circle, color: AppColor.orange, size: 8).pOnly(left: 8),
          ]),
          Divider().pSymmetric(v: 8),

          /// 3
          HStack([
            'Max Flag Spender Day:'.text.make().w(200),
            TextField(
              controller: controller.tfSpender,
              decoration: MyDecorationHelper.inputDecorator(
                hint: '> 100.000',
                prefixIcon: '> '.text.make().pOnly(left: 12, top: 4),
              ),
              style: TextStyle(fontSize: 13),
              inputFormatters: [CurrencyTextInputFormatter(symbol: 'Rp. ', decimalDigits: 0)],
            ).h(28).expand(),
            Icon(Icons.circle, color: AppColor.red, size: 8).pOnly(left: 8),
          ]),
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
          HStack(
            [
              'Currency'.text.bold.make(),
              Spacer(),
              ExButtonOutline(
                label: 'Apply',
                labelColor: AppColor.textReverse,
                borderColor: Vx.neutral500,
                labelSize: 11,
                height: 38,
                onPressed: () {},
              )
            ],
          ),
          Divider().pSymmetric(v: 12),

          /// 1
          HStack([
            'Currency Symbol:'.text.make().w(200),
            TextField(
              decoration: MyDecorationHelper.inputDecorator(hint: 'Rp.'),
              style: TextStyle(fontSize: 13),
            ).h(28).expand(),
          ]),
        ],
      ).p12(),
    );
  }
}
