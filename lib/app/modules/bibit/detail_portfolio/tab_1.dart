import 'dart:async';

import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:overlayment/overlayment.dart';

import '../../../core/app_color.dart';
import '../../../core/const.dart';
import '../../../helpers/helpers.dart';
import '../../../models/bibit_portpolio_detail_entity.dart';

import 'detail_portfolio_controller.dart';

class DetailPortpolioTab1 extends GetView<DetailPortfolioController> {
  const DetailPortpolioTab1({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (data) => VStack(
        [
          /// header
          header(data),

          24.heightBox,

          /// items
          if (data!.results!.isEmpty) ...[
            /// empty
            ExUiErrorOrEmpty(
              illustration: SvgPicture.network(
                'https://app.bibit.id/static/media/goal-empty-new-dark.fef950088e8a5706a79a6485484a54b0.svg',
                colorFilter: ColorFilter.mode(AppColor.neutralLight, BlendMode.srcATop),
              ),
              title: 'Tidak ada data',
              message: 'Temukan produk investasi sesuai kebutuhan dan capai tujuan keuanganmu',
            ).pOnly(bottom: 90).expand(),
          ]

          /// :stock
          else ...[
            if (data.categoryname == 'Bibit Saham') ...[
              ListView.separated(
                itemCount: data.results?.length ?? 0,
                separatorBuilder: (c, i) => 8.heightBox,
                itemBuilder: (c, i) {
                  final item = data.results?[i];
                  return itemStock(item);
                },
              ).expand(),
            ]

            /// :mutual
            else ...[
              ListView.separated(
                itemCount: data.results?.length ?? 0,
                separatorBuilder: (c, i) => 8.heightBox,
                itemBuilder: (c, i) {
                  final item = data.results?[i];
                  return itemMutual(item);
                },
              ).expand(),
            ],
          ],
        ],
      ).p8(),
    );
  }

  Widget header(BibitPortpolioDetailData? data) {
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(borderColor: AppColor.neutral, borderRadius: 4),
      child: VStack(
        [
          /// 1: portofolio
          HStack(
            [
              VStack([
                'Porto ${data?.categoryname ?? '...'}'.text.size(12).neutral400.make(),
                '${data?.totalporto?.moneyFormat()}'.text.bold.size(15).make(),
              ]),
              Spacer(),
              VStack(
                crossAlignment: CrossAxisAlignment.end,
                [
                  'Keuntungan:'.text.size(12).neutral400.make(),
                  '${data?.profitloss?.moneyFormat()} (${data?.percentage?.percentageFormat()})'.text.color(BibitHelper.getColor(data?.percentage)).make(),
                ],
              ),
            ],
          ),

          /// 2: goal setting
          if (data?.robo == 1 && data?.goalsetting != null) ...[
            Container(
              width: double.infinity,
              decoration: ExDecorator.box(borderRadius: 16, borderColor: AppColor.neutral),
              child: VStack(
                [
                  HStack([
                    ExAvatarView(
                      source: 'https://app.bibit.id/static/media/goal-setting-icon-dark.70bfe1775ee6924037f612cd99c10d07.svg',
                      size: 38,
                      borderColor: Colors.transparent,
                    ).pOnly(right: 8),
                    // Icon(CupertinoIcons.archivebox_fill, size: 38).pOnly(right: 8),
                    VStack([
                      HStack([
                        'Target'.text.size(12).make().pOnly(right: 4),
                        if (data?.goalsetting?.ontrack == 0) ...[
                          '(off track)'.text.size(11).minFontSize(11).orange500.make(),
                        ] else ...[
                          '(on track)'.text.size(11).minFontSize(11).green300.make(),
                        ],
                      ]),
                      '${data?.goalsetting?.targetamount?.moneyFormat()}'.text.size(12).make(),
                    ]).expand(),
                    Container(
                      decoration: ExDecorator.box(borderRadius: 90, fillColor: AppColor.bibitDark, borderColor: AppColor.bibitDark),
                      child: CustomPopup(
                        content: VStack([
                          'Tanggal Target tercapai'.text.size(11).black.make(),
                          '${data?.goalsetting?.targetdate?.reformatDate(from: yMd, to: 'd MMM y')}'.text.size(11).black.make(),
                          '(${data?.goalsetting?.targetdate?.toDateEx(format: yMd).timeDiff()})'.text.black.size(12).make(),
                          Divider().w(180),
                          'Baiknya nabung rutin:'.text.size(11).black.make(),
                          Container(
                            decoration: ExDecorator.box(fillColor: AppColor.bibit.withAlpha(50), borderRadius: 0),
                            child: '${data?.goalsetting?.recurringAmount?.moneyFormat()} /Perbulan'.text.size(11).black.make().p4(),
                          ),
                        ]),
                        child: '${data?.goalsetting?.targetdate?.reformatDate(from: yMd, to: 'MMM y')}'.text.size(11).minFontSize(11).make().pSymmetric(v: 4, h: 8),
                      ),
                    ),
                  ]),
                  CustomPopup(
                    content: 'Selisih ${(data!.goalsetting!.targetamount! - data.totalporto!).moneyFormat()} lagi dari target'.text.black.size(12).make(),
                    child: HStack([
                      ExProgressBar(
                        value: (data.totalporto! / data.goalsetting!.targetamount! * 100).toInt(),
                        color1: AppColor.bibit,
                        color2: AppColor.bibitDark,
                        height: 8,
                      ).expand(),
                      '${(data.totalporto! / data.goalsetting!.targetamount! * 100).toDouble().toStringAsFixed(2)}%'.text.size(12).make().pOnly(left: 8),
                    ]).pOnly(top: 8),
                  ),
                ],
              ).p8(),
            ).pOnly(top: 16),
          ],
        ],
      ).p12(),
    );
  }

  Widget itemMutual(BibitPortpolioDetailDataResults? item) {
    return Container(
      decoration: ExDecorator.box(borderRadius: 4, borderColor: AppColor.neutral),
      child: HStack(
        [
          Container(width: 4, height: 110, color: BibitHelper.getColorByType(item?.name ?? '')).pOnly(right: 8),
          VStack([
            HStack([
              '${item?.name ?? ''}'.text.bold.size(12).make(),
              '(${item?.items?.length ?? ''} Product)'.text.size(12).neutral500.make().pSymmetric(h: 4),
            ]).pSymmetric(v: 8),
            HStack([
              'Investasi'.text.neutral400.size(12).make().expand(),
              '${item?.totalporto?.moneyFormat()}'.text.size(12).bold.make(),
            ]).pOnly(right: 8, bottom: 8),

            // :1
            HStack([
              'Alokasi'.text.neutral400.size(12).make().w(65),
              '${item?.current?.toNum()?.percentageFormat()}'.text.size(12).make().w(45),
              ExProgressBar(
                value: (item!.current!.toNum()! * 100).toInt(),
                color1: BibitHelper.getColorByType(item.name ?? ''),
                color2: BibitHelper.getColorByType(item.name ?? '').withAlpha(40),
                height: 8,
              ).expand(),
            ]).pOnly(right: 8, bottom: 8),

            // :2
            HStack([
              'Target'.text.neutral400.size(12).make().w(65),
              '${item.target?.toNum()?.percentageFormat()}'.text.size(12).make().w(45),
              ExProgressBar(
                value: (item.target!.toNum()! * 100).toInt(),
                color1: BibitHelper.getColorByType(item.name ?? ''),
                color2: BibitHelper.getColorByType(item.name ?? '').withAlpha(40),
                height: 8,
              ).expand(),
            ]).pOnly(right: 8, bottom: 8),
          ]).expand(),
        ],
      ),
    ).onInkTap(() async {
      unawaited(showDetailPortfolio(item));
    });
  }

  Widget itemStock(BibitPortpolioDetailDataResults? item) {
    return Container(
      decoration: ExDecorator.box(borderRadius: 4, borderColor: AppColor.neutral),
      child: HStack(
        [
          ExAvatarView(source: '${item?.iconUrl}', size: 32).pOnly(right: 8),
          VStack([
            '${item?.symbol}'.text.make(),
            '${item?.companyName}'.text.size(12).neutral400.make(),
          ]).expand(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              '${item?.marketValue?.moneyFormat()}'.text.size(12).bold.make(),
              '${item?.profitLossAmount?.moneyFormat()} (${item?.profitLossPercentage?.percentageFormat()})'.text.color(BibitHelper.getColor(item?.profitLossPercentage)).size(12).make(),
            ],
          ),
        ],
      ).p12(),
    ).onInkTap(() {
      controller.goDetailStock(item?.symbol ?? '');
    });
  }

  Future<void> showDetailPortfolio(BibitPortpolioDetailDataResults data) async {
    unawaited(Overlayment.show(
      context: Get.context!,
      OverPanel(
        alignment: Alignment.centerRight,
        width: 300,
        child: Column(
          children: [
            '${data.name}'.text.makeCentered(),
            '${data.items?[0].categoryname}'.text.size(11).minFontSize(11).neutral400.makeCentered().pOnly(bottom: 12),
            ListView.separated(
              shrinkWrap: true,
              itemCount: data.items?.length ?? 0,
              separatorBuilder: (_, _) => 12.heightBox,
              itemBuilder: (context, index) {
                final item = data.items?[index];
                return Container(
                  decoration: ExDecorator.box(borderRadius: 4, borderColor: AppColor.neutral),
                  child: VStack(
                    [
                      ///
                      HStack([
                        ExAvatarView(
                          source: 'https://app.bibit.id/assets/logos/investment-manager/square/${item?.product?.investmentManager?.ojkCode}.svg',
                          size: 28,
                          borderColor: Colors.white,
                        ).pOnly(right: 8),
                        '${item?.product?.name}'.text.maxLines(2).ellipsis.make().expand(),
                      ]),
                      Divider().pSymmetric(v: 8),

                      ///
                      HStack([
                        'Nilai Sekarang'.text.neutral500.size(12).make(),
                        Spacer(),
                        '${item?.current?.moneyFormat()}'.text.size(12).bold.make(),
                      ]).pOnly(bottom: 8),

                      ///
                      HStack([
                        'Modal Investasi'.text.neutral500.size(12).make(),
                        Spacer(),
                        '${item?.invested?.moneyFormat()}'.text.size(12).bold.make(),
                      ]).pOnly(bottom: 8),

                      ///
                      HStack([
                        'Keuntungan'.text.neutral500.size(12).make(),
                        Spacer(),
                        '${item?.profitloss?.moneyFormat()} (${item?.percentage?.percentageFormat()})'.text.size(12).bold.color(BibitHelper.getColor(item?.percentage)).make(),
                      ]).pOnly(bottom: 8),

                      ///
                      HStack([
                        'Harga Beli'.text.neutral500.size(12).make(),
                        Spacer(),
                        'Rp. ${item?.avgprice?.toStringAsFixed(2)}'.text.size(12).bold.make(),
                      ]).pOnly(bottom: 8),

                      ///
                      HStack([
                        'Jumlah Unit'.text.neutral500.size(12).make(),
                        Spacer(),
                        '${item?.units?.toStringAsFixed(2)}'.text.size(12).bold.make(),
                      ]).pOnly(bottom: 8),
                    ],
                  ).p8(),
                ).onTap(() {
                  controller.goDetailMutual(item?.product?.symbol ?? '');
                });
              },
            ),
          ],
        ).p12(),
      ),
    ));
  }
}
