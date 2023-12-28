import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:ex/ex.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/app_color.dart';
import '../../../core/const.dart';
import '../../../helpers/helpers.dart';
import '../../../models/bibit_product_detail_aum_entity.dart';
import '../../../models/bibit_product_detail_chart_entity.dart';
import '../../../models/bibit_product_detail_entity.dart';
import '../../widgets/widgets.dart';
import 'detail_mutual_controller.dart';

class DetailMutualTab1 extends GetView<DetailMutualController> {
  const DetailMutualTab1({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => VStack(
        [
          /// header
          header().pOnly(bottom: 16),

          /// chart or aum
          Obx(
            () => controller.uiModeSelected.value == 'CHART' //
                ? _Chart(controller.chart.value.chart ?? []).wh(double.infinity, 200)
                : _Aum(controller.aum.value.chart ?? []).wh(double.infinity, 200),
          ),

          /// period Button
          periodButton().pSymmetric(v: 12),

          /// myInvestment
          if (controller.allocation.value.totalPortfolio != 0) ...[
            myInvestment().pOnly(bottom: 16),
          ],

          /// assetAllocation
          assetAllocation(state).pOnly(bottom: 16),

          /// key stats
          keyStats().pOnly(bottom: 16),
        ],
      ).p12().scrollVertical(),
    );
  }

  Widget myInvestment() {
    final data = controller.allocation.value;
    return VStack(
      [
        Container(
          decoration: ExDecorator.box(borderColor: AppColor.neutral),
          child: VStack([
            // 1
            HStack([
              'My Portpolio'.text.bold.make(),
              Spacer(),
              CustomPopup(
                content: VStack([
                  'Total Modal Investasi: ${data.totalInvestedAmount?.moneyFormat()}'.text.black.size(12).make(),
                  'Total Nilai Sekarang: ${data.totalPortfolio?.moneyFormat()}'.text.black.size(12).make(),
                  'Total Keuntungan: ${data.profitLossAmount?.moneyFormat()}'.text.color(BibitHelper.getColor(data.profitLossAmount)).size(12).make(),
                  12.heightBox,
                  'Harga beli rata-rata: ${data.averagePrice?.moneyFormat()}'.text.black.size(12).make(),
                  Divider().w(200),
                  'Bagian Dari Porto:'.text.black.size(12).make().pOnly(bottom: 4),
                  for (var el in data.portfolioPlacements!) ...[
                    '- ${el.portfolioName}'.text.size(12).black.make(),
                  ],
                ]),
                child: IconButton(
                  onPressed: null,
                  icon: Icon(CupertinoIcons.forward, color: AppColor.bibit),
                ),
              ),
            ]),

            // 2
            HStack(
              [
                HStack(
                  [
                    SvgPicture.asset('assets/icons/ic_diamond.svg').pOnly(right: 8),
                    VStack([
                      'Investment'.text.size(12).neutral400.make(),
                      '${data.totalPortfolio?.moneyFormat()}'.text.size(13).make(),
                    ]),
                  ],
                ),
                42.widthBox,
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
          ]).p12(),
        ),
      ],
    );
  }

  Widget assetAllocation(BibitProductDetailData? state) {
    return Container(
      decoration: ExDecorator.box(borderColor: AppColor.neutral),
      child: VStack([
        'Alokasi Asset'.text.bold.make().pOnly(bottom: 12),
        StackProgressBar(data: state?.asset ?? []).h(12).cornerRadius(12).pOnly(bottom: 16),
        for (var el in state!.asset!) ...[
          if (el.percentage != 0) ...[
            HStack([
              Icon(Icons.circle, size: 6, color: StackProgressBarColorHelper.fromName(el.name ?? '')).pOnly(right: 8),
              '${el.name.maxWords(6)?.replaceAll(r'&/', '&')}'.text.maxLines(1).minFontSize(12).size(12).ellipsis.make().expand(),
              4.heightBox,
              '${el.percentage}%'.text.maxLines(1).minFontSize(12).size(12).ellipsis.make(),
            ]),
          ]
        ]
      ]).p12(),
    );
  }

  Widget keyStats() {
    final data = controller.productDetail.value;
    final xSelected = controller.periodSelected.replaceAll('1D', '1Y').replaceAll('1M', '1Y').replaceAll('3M', '1Y').replaceAll('YTD', '1Y');
    num? xCagrSelected = 0.0;
    num? xDrowDownSelected = 0.0;
    switch (xSelected) {
      case '1Y':
        xCagrSelected = data.cagrAdjusted?.x1y ?? 0;
        xDrowDownSelected = data.maxdrawdown?.x1y ?? 0;
        break;
      case '3Y':
        xCagrSelected = data.cagrAdjusted?.x3y ?? 0;
        xDrowDownSelected = data.maxdrawdown?.x3y ?? 0;
        break;
      case '5Y':
        xCagrSelected = data.cagrAdjusted?.x5y ?? 0;
        xDrowDownSelected = data.maxdrawdown?.x5y ?? 0;
        break;
      case '10Y':
        xCagrSelected = data.cagrAdjusted?.x10y ?? 0;
        xDrowDownSelected = data.maxdrawdown?.x10y ?? 0;
        break;
      case 'All':
        xCagrSelected = data.cagrAdjusted?.all ?? 0;
        xDrowDownSelected = data.maxdrawdown?.all ?? 0;
        break;
      default:
        xCagrSelected = 0;
        xDrowDownSelected = 0;
        break;
    }
    return VStack([
      Table(
        border: TableBorder.all(borderRadius: BorderRadius.circular(12), color: AppColor.neutral),
        children: [
          // row 1
          TableRow(
            children: [
              TableCell(
                child: VStack([
                  'CAGR $xSelected'.text.neutral400.size(12).makeCentered(),
                  '${xCagrSelected?.percentageFormat()}'.text.color(BibitHelper.getColor(xCagrSelected)).size(13).makeCentered(),
                ]).p12(),
              ),
              TableCell(
                child: VStack([
                  'Drawdown $xSelected'.text.neutral400.size(12).makeCentered(),
                  '${xDrowDownSelected.percentageFormat()}'.text.color(BibitHelper.getColor(xDrowDownSelected)).size(13).makeCentered(),
                ]).p12(),
              ),
              TableCell(
                child: VStack([
                  'Expense Ratio'.text.neutral400.size(12).makeCentered(),
                  '${data.expenseratio?.percentage?.percentageFormat()}'.text.size(13).makeCentered(),
                ]).p12(),
              ),
            ],
          ),
          // row 2
          TableRow(
            children: [
              TableCell(
                child: VStack([
                  'Total AUM'.text.neutral400.size(12).makeCentered(),
                  '${data.aum?.value?.moneyFormatCompact()}'.text.size(13).makeCentered(),
                ]).p12(),
              ),
              TableCell(
                child: VStack([
                  'Jenis Produk'.text.neutral400.size(12).makeCentered(),
                  '${data.type}'.text.size(13).makeCentered(),
                ]).p12(),
              ),
              TableCell(
                child: VStack([
                  'Tingkat Resiko'.text.neutral400.size(12).makeCentered(),
                  if (data.type == 'Saham') //
                    'Tinggi'.text.makeCentered()
                  else if (data.type == 'Obligasi')
                    'Moderat'.text.makeCentered()
                  else
                    'Rendah'.text.size(13).makeCentered(),
                ]).p12(),
              ),
            ],
          ),
        ],
      ),
    ]);
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
                () => controller.uiModeSelected.value == 'CHART' //
                    ? VStack(
                        [
                          ''
                              .richText
                              .withTextSpanChildren([
                                '${controller.productDetail.value.nav?.value?.moneyFormat() ?? '~'}'.textSpan.color(AppColor.textReverse).size(16).make(),
                                ' ${BibitHelper.getSymbol(controller.chart.value.change)}'.textSpan.size(12).make(),
                                ' ${controller.chart.value.change?.toStringAsFixed(2).replaceAll('-', '')}'.textSpan.size(12).make(),
                                ' (${controller.chart.value.percent?.percentageFormat()})'.textSpan.size(12).make(),
                              ])
                              .color(BibitHelper.getColor(controller.chart.value.change))
                              .make(),
                          ''
                              .richText
                              .withTextSpanChildren([
                                'Past'.textSpan.make(),
                                ' ${controller.periodSelected},'.textSpan.orange400.make(),
                                ' Last upd'.textSpan.make(),
                                ' ${controller.productDetail.value.nav?.date?.reformatDate(from: yMd, to: 'dd MMM yy') ?? '~'}'.textSpan.orange400.make(),
                              ])
                              .neutral400
                              .size(12)
                              .make(),
                        ],
                      ).p12()
                    : VStack(
                        [
                          ''
                              .richText
                              .withTextSpanChildren([
                                '${controller.productDetail.value.aum?.value?.moneyFormatCompact() ?? '~'}'.textSpan.color(AppColor.textReverse).size(16).make(),
                                ' ${BibitHelper.getSymbol(controller.aum.value.change)}'.textSpan.size(12).make(),
                                ' ${controller.aum.value.change?.moneyFormatCompact().replaceAll('-', '')}'.textSpan.size(12).make(),
                                ' (${controller.aum.value.percent?.percentageFormat()})'.textSpan.size(12).make(),
                              ])
                              .color(BibitHelper.getColor(controller.aum.value.change))
                              .make(),
                          ''
                              .richText
                              .withTextSpanChildren([
                                'Past'.textSpan.make(),
                                ' ${controller.periodSelected},'.textSpan.orange400.make(),
                                ' Last upd'.textSpan.make(),
                                ' ${controller.productDetail.value.aum?.date?.reformatDate(from: yMd, to: 'dd MMM yy') ?? '~'}'.textSpan.orange400.make(),
                              ])
                              .neutral400
                              .size(12)
                              .make(),
                        ],
                      ).p12(),
              ),
              Spacer(),
              CustomRadioButton(
                height: 33,
                width: 70,
                elevation: 0,
                selectedColor: AppColor.green.withAlpha(100),
                unSelectedColor: Colors.transparent,
                unSelectedBorderColor: Colors.transparent,
                selectedBorderColor: Colors.transparent,
                defaultSelected: controller.uiModeSelected.value,
                buttonLables: ['CHART', 'AUM'],
                buttonValues: ['CHART', 'AUM'],
                buttonTextStyle: ButtonTextStyle(
                  selectedColor: Vx.black,
                  unSelectedColor: AppColor.textReverse,
                  textStyle: TextStyle(fontSize: 12),
                ),
                radioButtonValue: (s) => controller.onUiModeChange(s),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget periodButton() {
    final chartMode = ['1D', '1M', '3M', 'YTD', '1Y', '3Y', '5Y', 'ALL'];
    final aumMode = ['1M', '3M', 'YTD', '1Y', '3Y', '5Y', 'ALL'];
    final lSelected = controller.uiModeSelected.value == 'CHART' ? chartMode : aumMode;
    return CustomRadioButton(
      height: 33,
      width: 44,
      elevation: 0,
      selectedColor: AppColor.green.withAlpha(100),
      unSelectedColor: Colors.transparent,
      unSelectedBorderColor: Colors.transparent,
      selectedBorderColor: Colors.transparent,
      defaultSelected: controller.periodSelected.value,
      buttonLables: lSelected,
      buttonValues: lSelected,
      buttonTextStyle: ButtonTextStyle(
        selectedColor: Vx.black,
        unSelectedColor: AppColor.textReverse,
        textStyle: TextStyle(fontSize: 12),
      ),
      radioButtonValue: (s) => controller.onPeriodChange(s),
    );
  }
}

class _Chart extends GetView<DetailMutualController> {
  const _Chart(this.data);

  final List<BibitProductDetailChartChart> data;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetailMutualController>(
      init: DetailMutualController(),
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
                color: BibitHelper.getColor(controller.chart.value.percent),
                belowBarData: BarAreaData(show: true, color: BibitHelper.getColor(controller.chart.value.percent).withAlpha(50)),
                isCurved: true,
                // isStrokeCapRound: true,
                barWidth: 1,
                dotData: FlDotData(show: false),
                spots: [
                  for (int i = 0; i < data.length; i++) ...[
                    FlSpot(data[i].date?.toDouble() ?? 0, data[i].value?.toDouble() ?? 0),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  LineTouchData lineTooltip(List<BibitProductDetailChartChart> chart) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Vx.white,
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((LineBarSpot touchedSpot) {
            final amount = touchedSpot.y.moneyFormat();
            final date = chart[touchedSpot.spotIndex].formatedDate!.reformatDate(from: 'yyyy-MM-dd');
            final output = '$date\n $amount';
            final textStyle = TextStyle(color: Vx.black, fontSize: 11);
            return LineTooltipItem('$output', textStyle);
          }).toList();
        },
      ),
    );
  }
}

class _Aum extends GetView<DetailMutualController> {
  const _Aum(this.data);

  final List<BibitProductDetailAumChart> data;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetailMutualController>(
      init: DetailMutualController(),
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
                color: BibitHelper.getColor(controller.chart.value.percent),
                belowBarData: BarAreaData(show: true, color: BibitHelper.getColor(controller.chart.value.percent).withAlpha(50)),
                isCurved: true,
                // isStrokeCapRound: true,
                barWidth: 1,
                dotData: FlDotData(show: false),
                spots: [
                  for (int i = 0; i < data.length; i++) ...[
                    FlSpot(data[i].date?.toDouble() ?? 0, data[i].value?.toDouble() ?? 0),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  LineTouchData lineTooltip(List<BibitProductDetailAumChart> chart) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Vx.white,
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((LineBarSpot touchedSpot) {
            final amount = touchedSpot.y.moneyFormatCompact();
            final date = chart[touchedSpot.spotIndex].formatedDate!.reformatDate(from: 'yyyy-MM-dd');
            final output = '$date\n $amount';
            final textStyle = TextStyle(color: Vx.black, fontSize: 11);
            return LineTooltipItem('$output', textStyle);
          }).toList();
        },
      ),
    );
  }
}
