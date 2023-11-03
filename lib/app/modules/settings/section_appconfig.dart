import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      decoration: ExDecorator.box(fillColor: Vx.neutral900, borderColor: Vx.neutral900, borderRadius: 4),
      child: VStack(
        [
          HStack(
            [
              'Basic'.text.bold.make(),
              Spacer(),
              ExButtonOutline(
                label: 'Apply',
                labelColor: Colors.white,
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
            'Max Flag Hemat Day:'.text.make().w(200),
            TextField(
              decoration: MyDecorationHelper.inputDecorator(hint: '< 50.000', prefixIcon: 'Rp. '.text.make().pOnly(top: 4, left: 12)),
              style: TextStyle(fontSize: 13),
            ).h(28).expand(),
            Icon(Icons.circle, color: Vx.green300, size: 8).pOnly(left: 8),
          ]),
          Divider().pSymmetric(v: 8),

          /// 2
          HStack([
            'Max Flag Standart Day:'.text.make().w(200),
            TextField(
              decoration: MyDecorationHelper.inputDecorator(hint: '< 100.000', prefixIcon: 'Rp. '.text.make().pOnly(top: 4, left: 12)),
              style: TextStyle(fontSize: 13),
            ).h(28).expand(),
            Icon(Icons.circle, color: Vx.orange300, size: 8).pOnly(left: 8),
          ]),
          Divider().pSymmetric(v: 8),

          /// 3
          HStack([
            'Max Flag Boros Day:'.text.make().w(200),
            TextField(
              decoration: MyDecorationHelper.inputDecorator(hint: '> 100.000', prefixIcon: 'Rp. '.text.make().pOnly(top: 4, left: 12)),
              style: TextStyle(fontSize: 13),
            ).h(28).expand(),
            Icon(Icons.circle, color: Vx.red500, size: 8).pOnly(left: 8),
          ]),
        ],
      ).p12(),
    );
  }

  Widget settingCurrency() {
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(fillColor: Vx.neutral900, borderColor: Vx.neutral900, borderRadius: 4),
      child: VStack(
        [
          HStack(
            [
              'Currency'.text.bold.make(),
              Spacer(),
              ExButtonOutline(
                label: 'Apply',
                labelColor: Colors.white,
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
