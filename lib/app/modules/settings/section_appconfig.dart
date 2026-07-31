import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
        boxAccount(),
        20.heightBox,
        boxCommonConfig(),
      ]).scrollVertical(),
      onLoading: ExUiLoading(
        message: 'Getting your data...'.text.makeCentered(),
      ),
    );
  }

  Widget boxAccount() {
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(
        fillColor: AppColor.box,
        borderColor: AppColor.border,
        borderRadius: 12,
      ),
      child: VStack(
        [
          HStack(
            [
              VStack([
                'Account'.text.size(15).bold.make(),
                'Manage your profile and session'.text
                    .size(11)
                    .color(AppColor.neutral)
                    .make(),
              ]).expand(),
              IconButton.outlined(
                tooltip: 'Edit profile',
                onPressed: () => controller.onEditProfile(),
                icon: Icon(Icons.edit_outlined, size: 16),
              ),
            ],
          ).pOnly(bottom: 18),
          Obx(
            () {
              final avatarUrl = db.storage
                  .from('avatars')
                  .getPublicUrl('${db.auth.currentSession?.user.id}.png');

              return controller.userProfile.value.id == null
                  ? CircularProgressIndicator.adaptive().p16()
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final profile = HStack([
                          ExImageNoCacheView(
                            url: avatarUrl,
                            size: 64,
                            radius: 90,
                            errorBuilder: (p0, p1, p2) => ExAvatarView(
                              source: '',
                              name: controller.userProfile.value.fullName,
                              size: 64,
                            ),
                          ).onInkTap(() => launchUrlString(avatarUrl)),
                          VStack([
                            if (controller.userProfile.value.fullName.isEmptyOrNull)
                              'No Name'.text.color(AppColor.neutral).make()
                            else
                              '${controller.userProfile.value.fullName}'.text
                                  .size(14)
                                  .bold
                                  .make(),
                            '${db.auth.currentSession?.user.email}'.text
                                .size(12)
                                .color(AppColor.neutral)
                                .make(),
                            '${controller.userProfile.value.calculatedAge ?? '-'} years old'
                                .text
                                .size(11)
                                .color(AppColor.orange)
                                .make(),
                          ]).pOnly(left: 14),
                        ]);

                        if (constraints.maxWidth < 440) {
                          return VStack([
                            profile,
                            18.heightBox,
                            logoutButton(),
                          ]);
                        }

                        return HStack([
                          profile.expand(),
                          logoutButton().w(120),
                        ]);
                      },
                    );
            },
          ),
        ],
      ).p16(),
    );
  }

  Widget logoutButton() {
    return OutlinedButton.icon(
      onPressed: () => controller.onLogout(),
      icon: Icon(Icons.logout_rounded, size: 15),
      label: 'Logout'.text.size(12).make(),
    ).h(38);
  }

  Widget boxCommonConfig() {
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(
        fillColor: AppColor.box,
        borderColor: AppColor.border,
        borderRadius: 12,
      ),
      child: VStack(
        [
          'Preferences'.text.size(15).bold.make(),
          'Customize how the app looks and categorizes daily spending'.text
              .size(11)
              .color(AppColor.neutral)
              .make()
              .pOnly(bottom: 20),

          settingRow(
            title: 'Dark mode',
            subtitle: 'Use a darker color scheme',
            child: Switch.adaptive(
              value: pref.read<bool>(kIsDarkMode) ?? true,
              onChanged: (s) async => await AppTheme.switchTheme(),
            ),
          ),

          settingRow(
            title: 'Theme color',
            subtitle: 'Choose your accent color',
            child: Obx(
              () => Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: AppColor.themeColors.map((colorValue) {
                  final color = Color(colorValue);
                  final isSelected =
                      controller.selectedThemeColor.value == colorValue;

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async =>
                        await controller.onThemeColorChange(colorValue),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColor.textReverse
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check_rounded,
                              size: 15,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          Divider(color: AppColor.divider).pSymmetric(v: 10),
          'Spending flags'.text.size(13).bold.make(),
          'Set the daily limits used by your expense summary'.text
              .size(11)
              .color(AppColor.neutral)
              .make()
              .pOnly(bottom: 16),

          settingRow(
            title: 'Eco day',
            subtitle: 'Spending at or below this amount',
            indicatorColor: AppColor.green,
            child: configInput(
              controller: controller.tfEco,
              hint: 'Rp.50.000',
              prefix: '≤',
              formatCurrency: true,
            ),
          ),
          settingRow(
            title: 'Average day',
            subtitle: 'Upper limit for average spending',
            indicatorColor: AppColor.orange,
            child: configInput(
              controller: controller.tfAverage,
              hint: 'Rp.100.000',
              prefix: '≤',
              formatCurrency: true,
              onChanged: (s) => controller.tfSpender.text = s,
            ),
          ),
          settingRow(
            title: 'Spender day',
            subtitle: 'Anything above the average limit',
            indicatorColor: AppColor.red,
            child: configInput(
              controller: controller.tfSpender,
              hint: 'Rp.100.000',
              prefix: '>',
              enabled: false,
              formatCurrency: true,
            ),
          ),
          settingRow(
            title: 'Calendar start day',
            subtitle: 'Day used to begin each monthly period',
            child: configInput(
              controller: controller.tfCalendarStartDay,
              hint: '1',
              suffix: Icon(
                Icons.calendar_month_outlined,
                color: AppColor.blue,
                size: 16,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
            ),
          ),

          Divider(color: AppColor.divider).pSymmetric(v: 10),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 12,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () async {
                  controller.tfEco.text = 50000.moneyFormat();
                  controller.tfAverage.text = 100000.moneyFormat();
                  controller.tfSpender.text = 100000.moneyFormat();
                  controller.tfCurrencySymbol.text = 'Rp. ';
                  controller.tfCalendarStartDay.text = '1';
                  await controller.onThemeColorChange(
                    AppColor.defaultThemeColor,
                  );
                },
                child: 'Reset to default'.text.size(11).make(),
              ).h(38),
              FilledButton(
                onPressed: () async => await controller.onSaveConfig(),
                child: 'Apply changes'.text.size(11).make(),
              ).h(38),
            ],
          ).objectCenterRight(),
        ],
      ).p20(),
    );
  }

  Widget settingRow({
    required String title,
    required String subtitle,
    required Widget child,
    Color? indicatorColor,
  }) {
    final label = HStack([
      if (indicatorColor != null)
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: indicatorColor,
            shape: BoxShape.circle,
          ),
        ).pOnly(right: 10),
      VStack([
        title.text.size(12).bold.make(),
        subtitle.text.size(10).color(AppColor.neutral).make(),
      ]).expand(),
    ]);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 500) {
          return VStack([
            label,
            10.heightBox,
            child,
          ]).pOnly(bottom: 18);
        }

        return HStack([
          label.expand(),
          child.w(220),
        ]).pOnly(bottom: 16);
      },
    );
  }

  Widget configInput({
    required TextEditingController controller,
    required String hint,
    String? prefix,
    Widget? suffix,
    bool enabled = true,
    bool formatCurrency = false,
    ValueChanged<String>? onChanged,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      enabled: enabled,
      controller: controller,
      decoration: HelperDecoration.input(
        hint: hint,
        prefixIcon:
            prefix?.text.size(12).bold.make().pOnly(left: 12, top: 5),
        suffixIcon: suffix,
        fillColor: AppColor.textFieldPrimary,
      ),
      style: TextStyle(fontSize: 12),
      keyboardType: TextInputType.number,
      inputFormatters: inputFormatters ??
          (formatCurrency
              ? [
                  CurrencyTextInputFormatter(
                    NumberFormat.simpleCurrency(
                      locale: 'id_ID',
                      name: 'Rp.',
                      decimalDigits: 0,
                    ),
                  ),
                  LengthLimitingTextInputFormatter(16),
                ]
              : null),
      onChanged: onChanged,
    ).h(36);
  }
}
