import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:ex_kit/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/app_api.dart';
import '../../core/app_color.dart';
import '../../core/app_setting.dart';
import '../../core/app_theme.dart';
import '../../core/const.dart';
import '../../helpers/helpers.dart';
import '../widgets/widget_image_no_cache_view.dart';
import 'settings_controller.dart';

class SectionAppConfig extends GetView<SettingsController> {
  const SectionAppConfig({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => VStack([
        boxCommonConfig(),
        16.heightBox,
        boxAccount(),
      ]).scrollVertical(),
      onLoading: ExUiLoading(
        message: 'Getting your data...'.text.makeCentered(),
      ),
    );
  }

  Widget boxAccount() {
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(fillColor: AppColor.box, borderColor: AppColor.border, borderRadius: 4),
      child: VStack(
        [
          HStack(
            [
              'Account'.text.bold.make().expand(),
              IconButton(
                onPressed: () => controller.onEditProfile(),
                icon: Icon(CupertinoIcons.pen),
              ),
            ],
          ),
          Obx(
            () => controller.userProfile.value.id == null
                ? CircularProgressIndicator.adaptive().p16()
                : HStack([
                    ExImageNoCacheView(
                      url: db.storage.from('avatars').getPublicUrl('${db.auth.currentSession?.user.id}.png'),
                      size: 32,
                      radius: 90,
                      errorBuilder: (p0, p1, p2) => ExAvatarView(source: '', name: controller.userProfile.value.fullName, size: 32),
                    ),
                    VStack([
                      if (controller.userProfile.value.fullName.isEmptyOrNull) ...[
                        'No Name'.text.neutral400.make(),
                      ] else ...[
                        '${controller.userProfile.value.fullName}'.text.make(),
                      ],
                      '${db.auth.currentSession?.user.email}'.text.size(12).make(),
                    ]).pSymmetric(h: 12),
                  ]).pOnly(bottom: 24),
          ),
          ExButtonElevated(
            width: double.infinity,
            label: 'Logout',
            onPressed: () => controller.onLogout(),
          ),
        ],
      ).p12(),
    );
  }

  Widget boxCommonConfig() {
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(fillColor: AppColor.box, borderColor: AppColor.border, borderRadius: 4),
      child: VStack(
        [
          HStack([
            'App Config'.text.bold.make(),
          ]).pOnly(bottom: 12),

          /// 1
          HStack(
            [
              'Dark Mode:'.text.make().w(200),
              Spacer(),
              Switch.adaptive(
                value: pref.read<bool>(kIsDarkMode) ?? true,
                onChanged: (s) async {
                  await AppTheme.switchTheme();
                },
              ),
            ],
          ).pOnly(bottom: 12),

          /// 2
          HStack(
            [
              'Max Flag Eco Day:'.text.make().w(200),
              TextField(
                controller: controller.tfEco,
                decoration: DecorationHelper.input(
                  hint: '≤ 50.000',
                  prefixIcon: '≤ '.text.make().pOnly(left: 12, top: 4),
                ),
                style: TextStyle(fontSize: 13),
                inputFormatters: [
                  CurrencyTextInputFormatter(NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp.', decimalDigits: 0)),
                  LengthLimitingTextInputFormatter(16),
                ],
              ).h(28).expand(),
              Icon(Icons.circle, color: AppColor.green, size: 8).pOnly(left: 8),
            ],
          ).pOnly(bottom: 12),

          /// 3
          HStack(
            [
              'Max Flag Average Day:'.text.make().w(200),
              TextField(
                controller: controller.tfAverage,
                decoration: DecorationHelper.input(
                  hint: '≤ 100.000',
                  prefixIcon: '≤ '.text.make().pOnly(left: 12, top: 4),
                ),
                style: TextStyle(fontSize: 13),
                inputFormatters: [
                  CurrencyTextInputFormatter(NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp.', decimalDigits: 0)),
                  LengthLimitingTextInputFormatter(16),
                ],
                onChanged: (s) => controller.tfSpender.text = s,
              ).h(28).expand(),
              Icon(Icons.circle, color: AppColor.orange, size: 8).pOnly(left: 8),
            ],
          ).pOnly(bottom: 12),

          /// 4
          HStack([
            'Max Flag Spender Day:'.text.make().w(200),
            TextField(
              enabled: false,
              controller: controller.tfSpender,
              decoration: DecorationHelper.input(
                hint: '> 100.000',
                prefixIcon: '> '.text.make().pOnly(left: 12, top: 4),
              ),
              style: TextStyle(fontSize: 13),
              inputFormatters: [
                CurrencyTextInputFormatter(NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp.', decimalDigits: 0)),
                LengthLimitingTextInputFormatter(16),
              ],
            ).h(28).expand(),
            Icon(Icons.circle, color: AppColor.red, size: 8).pOnly(left: 8),
          ]),

          Divider(color: AppColor.divider).pSymmetric(v: 8),
          HStack(
            [
              '📁'.text.make().onTap(() => controller.onGoAppPath()),
              Spacer(),
              ExButtonOutline(
                label: 'Reset to default',
                labelSize: 11,
                height: 38,
                onPressed: () {
                  controller.tfEco.text = 50000.moneyFormat();
                  controller.tfAverage.text = 100000.moneyFormat();
                  controller.tfSpender.text = 100000.moneyFormat();
                  controller.tfCurrencySymbol.text = 'Rp. ';
                },
              ),
              12.widthBox,
              ExButtonOutline(
                width: 120,
                label: 'Apply',
                labelSize: 11,
                height: 38,
                onPressed: () async => await controller.onSaveConfig(),
              ),
            ],
          ),
        ],
      ).p12(),
    );
  }
}
