import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/app_color.dart';
import '../../../helpers/helpers.dart';

import 'item_history_mutual.dart';
import 'item_history_stock.dart';
import 'section_bibit_transaction_controller.dart';

class SectionBibitTransactionView extends GetView<SectionBibitTransactionController> {
  const SectionBibitTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (data) => DefaultTabController(
        length: 2,
        child: VStack(
          [
            TabBar(
              physics: NeverScrollableScrollPhysics(),
              labelColor: AppColor.textReverse,
              tabs: [
                Tab(text: 'Cart'),
                // Tab(text: 'Order'),
                Tab(text: 'History'),
              ],
            ),
            TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                tabCart(),
                // tabOrder(),
                Obx(() => tabHistory()),
              ],
            ).expand(),
          ],
        ),
      ),
    );
  }

  Widget tabCart() {
    return VStack(
      [
        taxAlert().pSymmetric(v: 16),

        /// header
        for (var h in controller.cart.value.checkoutable!) ...[
          Container(
            width: double.infinity,
            decoration: ExDecorator.box(borderColor: AppColor.neutral, borderRadius: 4),
            child: VStack(
              [
                /// header
                HStack(
                  [
                    ExAvatarView(
                      source: Get.isDarkMode //
                          ? 'https://app.bibit.id/assets/images/portfolio/green/dark/${h.templateId}.svg'
                          : 'https://app.bibit.id/assets/images/portfolio/green/${h.templateId}.svg',
                      height: 24,
                      width: 24,
                      borderColor: Color(0xff1B2E25),
                      borderWidth: 0,
                    ),
                    ' ${h.portfolioName}'.text.bold.size(13).make().pOnly(left: 8, right: 8, bottom: 2),
                    if (h.portfolioRobo == 1) ...[
                      Image.asset(
                        'assets/icons/ic_robo.png',
                        height: 16,
                        width: 16,
                        color: Get.isDarkMode ? Colors.white70 : Colors.white,
                      ).pOnly(bottom: 2),
                    ],
                  ],
                ).p8(),

                /// body
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: h.items?.length ?? 0,
                  shrinkWrap: true,
                  itemBuilder: (c, i) {
                    final item = h.items![i];
                    return ListTile(
                      leading: ExAvatarView(
                        source: 'https://app.bibit.id/assets/logos/investment-manager/square/${item.product?.investmentManager?.ojkCode}.svg',
                        size: 24,
                      ).pOnly(top: 8),
                      title: '${item.product?.name}'.text.size(12).make(),
                      subtitle: '${item.product?.type}'.text.size(11).minFontSize(11).neutral400.make(),
                      trailing: '${item.amount?.moneyFormat()}'.text.make(),
                    );
                  },
                ),

                /// total
                Container(
                  width: double.infinity,
                  decoration: ExDecorator.box(
                    borderColor: Colors.transparent,
                    fillColor: Vx.black.withAlpha(55),
                    borderRadius: 0,
                  ),
                  child: HStack([
                    'Total: ${h.totalAmount?.moneyFormat()}'.text.size(12).make().pSymmetric(v: 8, h: 16),
                    Spacer(),
                    Icon(CupertinoIcons.delete, size: 16, color: Vx.white.withAlpha(180)).pOnly(right: 8),
                  ]),
                ),
              ],
            ),
          ).pOnly(bottom: 12),
        ],

        Spacer(),
        Container(
          color: Vx.black.withAlpha(55),
          child: 'Total ${controller.cart.value.totalAmount?.moneyFormat()}'.text.bold.size(13).makeCentered().p4(),
        ),
      ],
    );
  }

  Widget tabOrder() {
    return VStack(
      [
        // category().pSymmetric(v: 16),
        taxAlert().pSymmetric(v: 16),
      ],
    );
  }

  Widget tabHistory() {
    return VStack(
      [
        category().pSymmetric(v: 16),
        taxAlert().pOnly(bottom: 16),
        if (controller.selectedCategoryName.value == 'Reksa Dana') ...[
          ItemHistoryMutual(),
        ],
        if (controller.selectedCategoryName.value == 'Saham') ...[
          ItemHistoryStock(),
        ],
        if (controller.selectedCategoryName.value == 'Obligasi') ...[
          ExUiErrorOrEmpty(
            illustration: SvgPicture.network('https://app.bibit.id/static/media/dark.862baf94e01c2d684b188ca84da1382a.svg'),
            title: 'Belum Ada Riwayat Transaksi',
            message: 'Yuk, kembangkan terus investasimu.',
          ).pOnly(top: 90),
        ],
        if (controller.selectedCategoryName.value == 'Stable Earn') ...[
          ExUiErrorOrEmpty(
            illustration: SvgPicture.network('https://app.bibit.id/static/media/dark.862baf94e01c2d684b188ca84da1382a.svg'),
            title: 'Belum Ada Riwayat Transaksi',
            message: 'Yuk, kembangkan terus investasimu.',
          ).pOnly(top: 90),
        ],

        /// load more ~~
        Obx(
          () => Visibility(
            visible: controller.nextCursorMutual.isNotEmpty,
            child: ExButtonLoading(
              height: 33,
              width: 90,
              child: Text('Load more', style: TextStyle(fontSize: 12)),
              onTap: (startLoading, stopLoading, btnState) async {
                startLoading;
                await controller.onLoadMore();
                stopLoading;
              },
            ).centered(),
          ).pOnly(top: 16),
        ),
      ],
    ).scrollVertical();
  }

  Widget taxAlert() {
    return VStack(
      [
        Container(
          height: 60,
          color: Vx.yellow500.withAlpha(50),
          child: HStack([
            SvgPicture.asset('assets/icons/ic_tax.svg', height: 24, width: 24).pOnly(right: 8),
            VStack([
              'Tagihan Bea Meterai'.text.size(12).make(),
              '${controller.pendingTax.value.moneyFormat()}'.text.size(12).bold.make(),
            ]),
            Spacer(),
            ExButtonElevated(
              height: 33,
              label: 'Bayar',
              labelSize: 11,
              backgroundColor: AppColor.bibit,
              labelColor: Colors.white,
              onPressed: () {},
            ),
          ]).p12(),
        ).cornerRadius(8),
      ],
    );
  }

  Widget category() {
    return CustomRadioButton(
      height: 28,
      width: 90,
      elevation: 0,
      defaultSelected: controller.selectedCategoryName.value,
      buttonLables: ['Reksa Dana', 'Saham', 'Obligasi', 'Stable Earn'],
      buttonValues: ['Reksa Dana', 'Saham', 'Obligasi', 'Stable Earn'],
      radioButtonValue: (s) => controller.onCategoryChanged(s),
      selectedColor: AppColor.green.withAlpha(100),
      unSelectedColor: Colors.transparent,
      unSelectedBorderColor: Colors.transparent,
      selectedBorderColor: Colors.transparent,
      buttonTextStyle: ButtonTextStyle(
        selectedColor: Vx.black,
        unSelectedColor: AppColor.textReverse,
        textStyle: TextStyle(fontSize: 12),
      ),
    );
  }
}
