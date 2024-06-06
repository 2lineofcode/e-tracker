import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:ex_kit/ex.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/app_color.dart';
import '../../../core/const.dart';
import '../../../helpers/helpers.dart';
import '../../../models/stockbit_chart_entity.dart';
import '../bibit_controller.dart';
import 'detail_stock_controller.dart';

class DetailStockTab1 extends GetView<DetailStockController> {
  const DetailStockTab1({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => VStack(
        [
          /// header
          header().pOnly(bottom: 16),

          /// chart
          _Chart(controller.chart.value.prices ?? []).wh(double.infinity, 200),

          /// period Button
          periodButton().pSymmetric(v: 12),

          /// myInvestment
          if (controller.portpolio.value.marketValue != null) ...[
            myInvestment().pOnly(bottom: 16),
          ],

          /// analysis
          if (state?.analystRating != null) ...[
            analysis().pOnly(bottom: 16),
          ],

          /// key stats
          keyStats().pOnly(bottom: 16),

          /// corporate Action
          if (state?.corpAction != null) ...[
            corpAction().pOnly(bottom: 16),
          ],

          /// releted stock
          if (controller.related.isNotEmpty) ...[
            reletedStock().pOnly(bottom: 16),
          ],

          /// about the company
          if (state?.companyAbout != null) ...[
            aboutCompany().pOnly(bottom: 16),
          ],
        ],
      ).p12().scrollVertical(),
    );
  }

  Widget header() {
    return VStack(
      [
        Container(
          width: double.infinity,
          decoration: ExDecorator.box(borderRadius: 4, borderColor: AppColor.neutral),
          child: HStack(
            [
              Obx(
                () => VStack(
                  [
                    ''
                        .richText
                        .withTextSpanChildren([
                          '${controller.productDetail.value.price?.moneyFormat() ?? '~'}'.textSpan.color(AppColor.textReverse).size(16).make(),
                          ' ${BibitHelper.getSymbol(controller.chart.value.change)}'.textSpan.size(12).make(),
                          ' ${controller.chart.value.change?.moneyFormat()}'.textSpan.size(12).make(),
                          ' (${controller.chart.value.percentage}%)'.textSpan.size(12).make(),
                        ])
                        .color(BibitHelper.getColor(controller.chart.value.change))
                        .make(),
                    HStack([
                      Container(
                        decoration: ExDecorator.box(
                          borderColor: AppColor.bibitDark,
                          fillColor: AppColor.bibitDark,
                          borderRadius: 4,
                        ),
                        child: '${controller.productDetail.value.subSector}'.text.size(12).color(AppColor.bibit).make().pSymmetric(h: 4, v: 1),
                      ).pOnly(right: 8),
                      ''
                          .richText
                          .withTextSpanChildren([
                            ' ${BibitHelper.getPeriodText(controller.periodSelected.value)}'.textSpan.orange400.make(),
                          ])
                          .neutral400
                          .size(12)
                          .make(),
                      if (Get.find<BibitController>().isMarketOpen.isFalse) ...[
                        CustomPopup(
                          content: VStack([
                            'Market Sedang Tutup'.text.size(12).black.bold.make(),
                            'Market akan buka kembali dalam:'.text.size(12).black.make(),
                            '${controller.productDetail.value.marketHours?.formattedTimeLeft}'.text.size(12).black.make(),
                          ]),
                          child: Icon(CupertinoIcons.moon_circle_fill, size: 14, color: AppColor.bibit).pOnly(left: 8),
                        ),
                      ]
                    ]).pOnly(top: 8),
                  ],
                ).p12(),
              ),
              Spacer(),
              ExAvatarView(
                source: controller.productDetail.value.iconUrl ?? '',
                size: 42,
              ).pOnly(right: 16),
            ],
          ),
        )
      ],
    );
  }

  Widget periodButton() {
    final chartMode = ['1D', '1M', '3M', 'YTD', '1Y', '3Y', '5Y'];
    return CustomRadioButton(
      height: 33,
      width: 44,
      elevation: 0,
      selectedColor: AppColor.green.withAlpha(100),
      unSelectedColor: Colors.transparent,
      unSelectedBorderColor: Colors.transparent,
      selectedBorderColor: Colors.transparent,
      defaultSelected: controller.periodSelected.value,
      buttonLables: chartMode.map((e) => e.toUpperCase()).toList(),
      buttonValues: chartMode.map((e) => e.toLowerCase()).toList(),
      buttonTextStyle: ButtonTextStyle(
        selectedColor: Vx.black,
        unSelectedColor: AppColor.textReverse,
        textStyle: TextStyle(fontSize: 12),
      ),
      radioButtonValue: (s) => controller.onPeriodChange(s),
    );
  }

  Widget myInvestment() {
    final data = controller.portpolio.value;
    return VStack(
      [
        Container(
          decoration: ExDecorator.box(borderColor: AppColor.neutral),
          child: VStack([
            // 1
            HStack([
              'Investasi Saya'.text.bold.make(),
              Spacer(),
              CustomPopup(
                content: VStack([
                  'Total Modal Investasi: ${data.investedAmount?.moneyFormat()}'.text.black.size(12).make(),
                  'Total Nilai Sekarang: ${data.marketValue?.moneyFormat()}'.text.black.size(12).make(),
                  'Total Keuntungan: ${data.profitLossAmount?.moneyFormat()}'.text.color(BibitHelper.getColor(data.profitLossAmount)).size(12).make(),
                  12.heightBox,
                  'Harga beli rata-rata: ${data.averagePrice?.moneyFormat()}'.text.black.size(12).make(),
                ]),
                child: IconButton(onPressed: null, icon: Icon(CupertinoIcons.forward, color: AppColor.bibit)),
              ),
            ]),

            // 2
            HStack(
              [
                HStack(
                  [
                    SvgPicture.asset('assets/icons/ic_diamond.svg').pOnly(right: 8),
                    VStack([
                      'Nilai Sekarang'.text.size(12).neutral400.make(),
                      '${data.marketValue?.moneyFormat()}'.text.size(13).make(),
                    ]),
                  ],
                ).w(160),
                HStack(
                  [
                    SvgPicture.asset('assets/icons/ic_roi.svg').pOnly(right: 8),
                    VStack([
                      'Profit'.text.size(12).neutral400.make(),
                      AnimatedTextKit(
                        repeatForever: true,
                        pause: 10.milliseconds,
                        animatedTexts: [
                          FadeAnimatedText(
                            '${BibitHelper.getSymbol(data.profitLossPercentage)} ${data.profitLossAmount?.moneyFormat(symbol: 'Rp') ?? '~'}',
                            textStyle: TextStyle(fontSize: 13, color: BibitHelper.getColor(data.profitLossPercentage)),
                          ),
                          FadeAnimatedText(
                            '${BibitHelper.getSymbol(data.profitLossPercentage)} ${data.profitLossPercentage?.percentageFormat() ?? '~'}',
                            textStyle: TextStyle(fontSize: 13, color: BibitHelper.getColor(data.profitLossPercentage)),
                          ),
                        ],
                      ).wh(120, 20),
                    ]),
                  ],
                ),
              ],
            ),

            12.heightBox,
            // 3
            HStack(
              [
                HStack(
                  [
                    SvgPicture.asset('assets/icons/ic_tag.svg').pOnly(right: 8),
                    VStack([
                      'Harga Beli'.text.size(12).neutral400.make(),
                      '${data.averagePrice?.moneyFormat()}'.text.size(13).make(),
                    ]),
                  ],
                ).w(160),
                HStack(
                  [
                    SvgPicture.asset('assets/icons/ic_lot.svg').pOnly(right: 8),
                    VStack([
                      'Lot'.text.size(12).neutral400.make(),
                      '${data.balanceLot}'.text.size(13).make(),
                    ]),
                  ],
                ),
              ],
            ),
          ]).p12(),
        ),
      ],
    );
  }

  Widget keyStats() {
    final data = controller.productDetail.value.keyStats;
    return VStack([
      Table(
        border: TableBorder.all(borderRadius: BorderRadius.circular(4), color: AppColor.neutral),
        children: [
          // row 1
          TableRow(
            children: [
              TableCell(
                child: VStack([
                  'P/E (Annualised)'.text.neutral400.size(12).makeCentered(),
                  '${data?.peAnnualised}'.text.size(13).makeCentered(),
                ]).p12(),
              ),
              TableCell(
                child: VStack([
                  'P/E (TTM)'.text.neutral400.size(12).makeCentered(),
                  '${data?.peTtm}'.text.size(13).makeCentered(),
                ]).p12(),
              ),
              TableCell(
                child: VStack([
                  'P/B'.text.neutral400.size(12).makeCentered(),
                  '${data?.pbvRatio}'.text.size(13).makeCentered(),
                ]).p12(),
              ),
            ],
          ),
          // row 2
          TableRow(
            children: [
              TableCell(
                child: VStack([
                  'NPM (Quarter)'.text.neutral400.size(12).makeCentered(),
                  '${data?.netProfitMargin}'.text.size(13).makeCentered(),
                ]).p12(),
              ),
              TableCell(
                child: VStack([
                  'Debt To Equity'.text.neutral400.size(12).makeCentered(),
                  '${data?.debtToEquity}'.text.size(13).makeCentered(),
                ]).p12(),
              ),
              TableCell(
                child: VStack([
                  'Total Debt'.text.neutral400.size(12).makeCentered(),
                  '${data?.totalDebt}'.text.size(13).makeCentered(),
                ]).p12(),
              ),
            ],
          ),
          // row 3
          TableRow(
            children: [
              TableCell(
                child: VStack([
                  'Total Cash'.text.neutral400.size(12).makeCentered(),
                  '${data?.totalCash}'.text.size(13).makeCentered(),
                ]).p12(),
              ),
              TableCell(
                child: VStack([
                  'Market Cap'.text.neutral400.size(12).makeCentered(),
                  '${data?.marketCap}'.text.size(13).makeCentered(),
                ]).p12(),
              ),
              TableCell(
                child: VStack([
                  'Volume'.text.neutral400.size(12).makeCentered(),
                  '${data?.volume}'.text.size(13).makeCentered(),
                ]).p12(),
              ),
            ],
          ),
          // row 4
          TableRow(
            children: [
              TableCell(
                child: VStack([
                  'Dividend Yield'.text.neutral400.size(12).makeCentered(),
                  '${data?.dividendYield}'.text.size(13).makeCentered(),
                ]).p12(),
              ),
              TableCell(
                child: VStack([
                  'Dividend (TTM)'.text.neutral400.size(12).makeCentered(),
                  '${data?.dividendTtm}'.text.size(13).makeCentered(),
                ]).p12(),
              ),
              TableCell(
                child: VStack([
                  'Volume Avg'.text.neutral400.size(12).makeCentered(),
                  '${data?.avgVolume}'.text.size(13).makeCentered(),
                ]).p12(),
              ),
            ],
          ),
        ],
      ),
    ]);
  }

  Widget analysis() {
    final data = controller.productDetail.value.analystRating;
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(borderColor: AppColor.neutral, borderRadius: 4),
      child: VStack([
        '${data?.totalAnalyst ?? 0} Analisa Penilaian'.text.bold.make().pOnly(bottom: 12),
        HStack(
          [
            VxCircle(
              radius: 24,
              backgroundColor: AppColor.bibitDark,
              child: '${data?.recommendation ?? ''}'.text.color(AppColor.bibit).makeCentered(),
            ).wh(60, 60).pOnly(right: 10),
            VStack([
              HStack([
                ExProgressBar(value: data?.totalBuy?.toInt() ?? 0, color1: AppColor.bibit, color2: AppColor.neutral, height: 8).expand(),
                'Buy ${data?.totalBuy ?? 0}'.text.size(11).minFontSize(11).make().pOnly(left: 10),
              ]).pOnly(bottom: 10),
              HStack([
                ExProgressBar(value: data?.totalHold?.toInt() ?? 0, color1: AppColor.orange, color2: AppColor.neutral, height: 8).expand(),
                'Hold ${data?.totalHold ?? 0}'.text.size(11).minFontSize(11).make().pOnly(left: 10),
              ]).pOnly(bottom: 10),
              HStack([
                ExProgressBar(value: data?.totalSell?.toInt() ?? 0, color1: AppColor.red, color2: AppColor.neutral, height: 8).expand(),
                'Sell ${data?.totalSell ?? 0}'.text.size(11).minFontSize(11).make().pOnly(left: 10),
              ]).pOnly(bottom: 10),
            ]).expand(),
          ],
        ),
        Divider(),
        'Target Harga Analis'.text.make().pOnly(bottom: 8),
        ''
            .richText
            .withTextSpanChildren([
              'Harga sekarang'.textSpan.make(),
              ' ${data?.priceTarget?.currentPrice?.moneyFormat() ?? 0}'.textSpan.orange500.make(),
              ' Target harga rata-rata'.textSpan.make(),
              ' ${data?.priceTarget?.bestTarget?.moneyFormat() ?? 0}'.textSpan.orange500.make(),
              ' dengan estimasi tinggi'.textSpan.make(),
              ' ${data?.priceTarget?.bestHighTarget?.moneyFormat() ?? 0}'.textSpan.orange500.make(),
              ' dan estimasi rendah'.textSpan.make(),
              ' ${data?.priceTarget?.bestLowTarget?.moneyFormat() ?? 0}.'.textSpan.orange500.make(),
            ])
            .size(12)
            .make(),
      ]).p12(),
    );
  }

  Widget corpAction() {
    final data = controller.productDetail.value.corpAction;
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(borderColor: AppColor.neutral, borderRadius: 4),
      child: VStack(
        [
          HStack([
            'Corporate Action'.text.bold.make(),
            Spacer(),
            '${data?.type?.toTitleCase ?? ''}'.text.color(AppColor.bibit).size(12).make(),
          ]).pOnly(bottom: 12),

          /// === type: stocksplit, rups, dividend ===
          if (data?.type == 'stocksplit') ...[
            Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                'Ratio:'.richText.withTextSpanChildren([' ${data?.info?.stocksplitOld}:${data?.info?.stocksplitNew}'.textSpan.neutral400.make()]).size(12).make(),
                'Split Factor:'.richText.withTextSpanChildren([' ${data?.info?.stocksplitFactor}'.textSpan.neutral400.make()]).size(12).make(),
                'Cum Date:'.richText.withTextSpanChildren([' ${data?.info?.stocksplitCumdate?.reformatDate(from: yMd, to: 'dd MMM yy')}'.textSpan.neutral400.make()]).size(12).make(),
                'Ex Date:'.richText.withTextSpanChildren([' ${data?.info?.stocksplitExdate?.reformatDate(from: yMd, to: 'dd MMM yy')}'.textSpan.neutral400.make()]).size(12).make(),
                'Rec Date:'.richText.withTextSpanChildren([' ${data?.info?.stocksplitRecdate?.reformatDate(from: yMd, to: 'dd MMM yy')}'.textSpan.neutral400.make()]).size(12).make(),
              ],
            )
          ],

          if (data?.type == 'rups') ...[
            Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                'Date:'.richText.withTextSpanChildren([' ${data?.info?.rupsDate?.reformatDate(from: yMd, to: 'dd MMM yy')}'.textSpan.neutral400.make()]).size(12).make(),
                'Time:'.richText.withTextSpanChildren([' ${data?.info?.rupsTime}'.textSpan.neutral400.make()]).size(12).make(),
                'Venue:'.richText.withTextSpanChildren([' ${data?.info?.rupsVenue}'.textSpan.neutral400.make()]).size(12).make(),
              ],
            )
          ],

          if (data?.type == 'dividend') ...[
            Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                'Dividend:'.richText.withTextSpanChildren([' ${data?.info?.dividendValue}'.textSpan.neutral400.make()]).size(12).make(),
                'Cum Date:'.richText.withTextSpanChildren([' ${data?.info?.dividendCumdate?.reformatDate(from: yMd, to: 'dd MMM yy')}'.textSpan.neutral400.make()]).size(12).make(),
                'Ex Date:'.richText.withTextSpanChildren([' ${data?.info?.dividendExdate?.reformatDate(from: yMd, to: 'dd MMM yy')}'.textSpan.neutral400.make()]).size(12).make(),
                'Rec Date:'.richText.withTextSpanChildren([' ${data?.info?.dividendRecdate?.reformatDate(from: yMd, to: 'dd MMM yy')}'.textSpan.neutral400.make()]).size(12).make(),
                'Payment Date:'.richText.withTextSpanChildren([' ${data?.info?.dividendPaydate?.reformatDate(from: yMd, to: 'dd MMM yy')}'.textSpan.neutral400.make()]).size(12).make(),
              ],
            )
          ],
        ],
      ).p12(),
    );
  }

  Widget reletedStock() {
    final data = controller.related;
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(borderColor: AppColor.neutral, borderRadius: 4),
      child: VStack(
        [
          'Saham terkait'.text.bold.make().pOnly(bottom: 12),
          ListView.builder(
            itemCount: data.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  ExAvatarView(source: data[index].iconUrl ?? '', size: 32).pOnly(bottom: 8),
                  '${data[index].symbol}'.text.size(12).make(),
                  '${data[index].percent?.toStringAsFixed(2)}%'.text.size(12).color(BibitHelper.getColor(data[index].percent)).make(),
                ],
              ).pOnly(right: 16).onTap(() async {
                await controller.onRefresh(data[index].symbol ?? '');
              });
            },
          ).h(75),
        ],
      ).p12(),
    );
  }

  Widget aboutCompany() {
    final data = controller.productDetail.value.companyAbout;
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(borderColor: AppColor.neutral, borderRadius: 4),
      child: VStack([
        'Tentang Perusahaan'.text.bold.make().pOnly(bottom: 12),
        '${data?.background ?? ''}'.selectableText.size(12).make(),
      ]).p12(),
    );
  }
}

class _Chart extends GetView<DetailStockController> {
  const _Chart(this.data);

  final List<StockbitChartDataPrices> data;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetailStockController>(
      init: DetailStockController(),
      initState: (_) {},
      builder: (_) {
        return LineChart(
          LineChartData(
            lineTouchData: lineTooltip(data),
            gridData: FlGridData(),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles()),
              rightTitles: AxisTitles(sideTitles: SideTitles()),
              topTitles: AxisTitles(sideTitles: SideTitles()),
              leftTitles: AxisTitles(sideTitles: SideTitles()),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                color: BibitHelper.getColor(controller.chart.value.percentage),
                belowBarData: BarAreaData(show: true, color: BibitHelper.getColor(controller.chart.value.percentage).withAlpha(50)),
                isCurved: true,
                barWidth: 1,
                dotData: FlDotData(show: false),
                spots: [
                  for (int i = 0; i < data.length; i++) ...[
                    FlSpot(
                      i.toDouble(),
                      data[i].value?.toDouble() ?? 0,
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  LineTouchData lineTooltip(List<StockbitChartDataPrices> chart) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Vx.white,
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((LineBarSpot touchedSpot) {
            if (controller.periodSelected.value == '1d') {
              final amount = touchedSpot.y.moneyFormat();
              final date = chart[touchedSpot.spotIndex].formattedDate!.toDate()?.toStringEx(format: 'HH:mm');
              final output = '$date\n $amount';
              final textStyle = TextStyle(color: Vx.black, fontSize: 11);
              return LineTooltipItem('$output', textStyle);
            } else {
              final amount = touchedSpot.y.moneyFormat();
              final date = chart[touchedSpot.spotIndex].formattedDate!.reformatDate(from: 'yyyy-MM-dd');
              final output = '$date\n $amount';
              final textStyle = TextStyle(color: Vx.black, fontSize: 11);
              return LineTooltipItem('$output', textStyle);
            }
          }).toList();
        },
      ),
    );
  }
}
