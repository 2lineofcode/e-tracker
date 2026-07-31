import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:ex_kit/ex.dart';
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
        boxAccount(),
        20.heightBox,
        boxCommonConfig(),
      ]).scrollVertical(),
      onLoading: ExUiLoading(
        message: 'Lagi ambil data...'.text.makeCentered(),
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
                'Akun'.text.size(15).bold.make(),
                'Kelola profil dan sesi akun'.text
                    .size(11)
                    .color(AppColor.neutral)
                    .make(),
              ]).expand(),
              IconButton.outlined(
                tooltip: 'Edit profil',
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
                            boxFit: BoxFit.cover,
                            errorBuilder: (p0, p1, p2) => ExAvatarView(
                              source: '',
                              name: controller.userProfile.value.fullName,
                              size: 64,
                            ),
                          ).onInkTap(() => ExImagePreview.showUrl(avatarUrl)),
                          VStack([
                            if (controller.userProfile.value.fullName.isEmptyOrNull)
                              'Belum ada nama'.text.color(AppColor.neutral).make()
                            else
                              '${controller.userProfile.value.fullName}'.text
                                  .size(14)
                                  .bold
                                  .make(),
                            '${db.auth.currentSession?.user.email}'.text
                                .size(12)
                                .color(AppColor.neutral)
                                .make(),
                            '${controller.userProfile.value.calculatedAge ?? '-'} tahun'
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
      label: 'Keluar'.text.size(12).make(),
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
          'Preferensi'.text.size(15).bold.make(),
          'Atur tampilan dan batas pengeluaran harian'.text
              .size(11)
              .color(AppColor.neutral)
              .make()
              .pOnly(bottom: 20),

          settingRow(
            title: 'Mode gelap',
            subtitle: 'Pakai tampilan gelap',
            child: Switch.adaptive(
              value: pref.read<bool>(kIsDarkMode) ?? true,
              onChanged: (s) async => await AppTheme.switchTheme(),
            ),
          ),

          settingRow(
            title: 'Warna tema',
            subtitle: 'Pilih warna aksen',
            child: Obx(
              () => Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: AppColor.themeColors.map((colorValue) {
                  final color = Color(colorValue);
                  final isSelected =
                      controller.selectedThemeColor.value == colorValue;
                  final checkColor =
                      ThemeData.estimateBrightnessForColor(color) ==
                          Brightness.light
                      ? Colors.black
                      : Colors.white;

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
                              color: checkColor,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          Divider(color: AppColor.divider).pSymmetric(v: 10),
          'Penanda pengeluaran'.text.size(13).bold.make(),
          'Atur batas pengeluaran harian'.text
              .size(11)
              .color(AppColor.neutral)
              .make()
              .pOnly(bottom: 16),

          settingRow(
            title: 'Hari hemat',
            subtitle: 'Pengeluaran sampai nominal ini',
            indicatorColor: AppColor.green,
            child: configInput(
              controller: controller.tfEco,
              hint: 'Rp.50.000',
              prefix: '≤',
              formatCurrency: true,
            ),
          ),
          settingRow(
            title: 'Hari biasa',
            subtitle: 'Batas atas pengeluaran normal',
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
            title: 'Hari boros',
            subtitle: 'Pengeluaran di atas batas normal',
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
            title: 'Tanggal awal periode',
            subtitle: 'Mulai periode bulanan dari tanggal ini',
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
                child: 'Atur ulang'.text.size(11).make(),
              ).h(38),
              FilledButton(
                onPressed: () async => await controller.onSaveConfig(),
                child: 'Simpan'.text.size(11).make(),
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
