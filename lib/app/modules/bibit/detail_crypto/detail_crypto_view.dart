import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:ex/ex.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../core/app_color.dart';
import '../../../helpers/helpers.dart';
import '../../../models/pintu_chart_entity.dart';
import '../../widgets/widgets.dart';
import 'detail_crypto_controller.dart';

class DetailCryptoView extends GetView<DetailCryptoController> {
  const DetailCryptoView({super.key});
  @override
  Widget build(BuildContext context) {
    return MyLayout(
      appBarTitle: appBarTitle(),
      sideMenuContent: sideMenuContent(),
      bodyContent: bodyContent(),
      footerContent: footerContent(),
    );
  }

  Widget appBarTitle() {
    return VStack([
      Text('${controller.productDetail.value.symbol}').text.size(13).bold.make(),
      Text('${controller.productDetail.value.name}').text.size(11).neutral400.make(),
    ]);
  }

  Widget sideMenuContent() {
    return Container();
  }

  Widget bodyContent() {
    return controller.obx(
      (state) => VStack(
        [
          /// header
          header().pOnly(bottom: 16),

          /// chart
          _Chart(controller.chart).wh(double.infinity, 200),

          /// period Button
          periodButton().pSymmetric(v: 12),

          /// marketCap
          marketCap().pOnly(bottom: 12),

          /// about
          aboutCoin().pOnly(bottom: 12),
        ],
      ).scrollVertical(),
    );
  }

  Widget footerContent() {
    return Container();
  }

  Widget header() {
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(borderRadius: 4, borderColor: AppColor.neutral),
      child: HStack(
        [
          ExAvatarView(
            source: controller.productDetail.value.logo ?? '',
            bgColor: controller.productDetail.value.color?.fromHex,
            borderColor: controller.productDetail.value.color?.fromHex,
            size: 32,
          ).pOnly(left: 16),
          VStack([
            '${DateTime.fromMillisecondsSinceEpoch(controller.chart.last.block!.toInt() * 1000).toStringEx(format: 'dd MMM y HH:mm')}'.text.neutral400.size(12).make().pOnly(bottom: 4),
            HStack([
              '${controller.chart.last.close?.toNum()?.moneyFormat()}'.text.bold.make(),
              if (controller.periodSelected.value == 'day') ...[
                ' (${controller.productDetail.value.day}%)'.text.color(BibitHelper.getColor(controller.productDetail.value.day?.toDouble())).make(),
              ],
              if (controller.periodSelected.value == 'week') ...[
                ' (${controller.productDetail.value.week}%)'.text.color(BibitHelper.getColor(controller.productDetail.value.day?.toDouble())).make(),
              ],
              if (controller.periodSelected.value == 'month') ...[
                ' (${controller.productDetail.value.month}%)'.text.color(BibitHelper.getColor(controller.productDetail.value.day?.toDouble())).make(),
              ],
              if (controller.periodSelected.value == 'year') ...[
                ' (${controller.productDetail.value.year}%)'.text.color(BibitHelper.getColor(controller.productDetail.value.day?.toDouble())).make(),
              ],
            ]),
          ]).p12(),
        ],
      ),
    ).pSymmetric(h: 12);
  }

  Widget periodButton() {
    final chartMode = ['Day', 'Week', 'Month', 'Year', 'All'];
    return CustomRadioButton(
      height: 33,
      width: 70,
      elevation: 0,
      selectedColor: controller.productDetail.value.color!.fromHex.withAlpha(100),
      unSelectedColor: Colors.transparent,
      unSelectedBorderColor: Colors.transparent,
      selectedBorderColor: Colors.transparent,
      defaultSelected: controller.periodSelected.value,
      buttonLables: chartMode.map((e) => e.toUpperCase()).toList(),
      buttonValues: chartMode.map((e) => e.toLowerCase()).toList(),
      buttonTextStyle: ButtonTextStyle(
        selectedColor: Vx.white,
        unSelectedColor: AppColor.textReverse,
        textStyle: TextStyle(fontSize: 12),
      ),
      radioButtonValue: (s) => controller.onPeriodChange(s),
    );
  }

  Widget marketCap() {
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(borderRadius: 4, borderColor: AppColor.neutral),
      child: VStack([
        'Info ${controller.productDetail.value.symbol}'.text.bold.make().pOnly(bottom: 8),
        'Kapitalisasi Pasar: ${controller.marketCapital['payload']['marketCap']?.toString().toNum()?.moneyFormatCompact()}'.text.size(12).make().pOnly(bottom: 3),
        'Nilai Terdilusi Penuh: ${controller.marketCapital['payload']['fullyDilutedValuation']?.toString().toNum()?.moneyFormatCompact()}'.text.size(12).make().pOnly(bottom: 3),
        'Suplai yang Beredar: ${controller.marketCapital['payload']['circulatingSupply']?.toString().toNum()?.moneyFormatCompact()}'.text.size(12).make().pOnly(bottom: 3),
        'Suplai Maksimum: ${controller.marketCapital['payload']['maxSupply']?.toString().toNum()?.moneyFormatCompact()}'.text.size(12).make().pOnly(bottom: 3),
        'Volume Global (24 Jam): ${controller.marketCapital['payload']['tradingVolume24h']?.toString().toNum()?.moneyFormatCompact()}'.text.size(12).make().pOnly(bottom: 3),
        'Total Nilai Terkunci: ${controller.marketCapital['payload']['totalValueLock']?.toString().toNum()?.moneyFormatCompact()}'.text.size(12).make().pOnly(bottom: 3),
      ]).p12(),
    ).pSymmetric(h: 12);
  }

  Widget aboutCoin() {
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(borderRadius: 4, borderColor: AppColor.neutral),
      child: VStack([
        'Tentang ${controller.productDetail.value.name}'.text.bold.make().pOnly(bottom: 8),
        '${controller.aboutCoin['about']}'.text.size(12).neutral400.make(),
      ]).p12(),
    ).pSymmetric(h: 12);
  }
}

class _Chart extends GetView<DetailCryptoController> {
  const _Chart(this.data);

  final List<PintuChartPayloadChart> data;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetailCryptoController>(
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
                color: controller.productDetail.value.color?.fromHex,
                belowBarData: BarAreaData(show: true, color: controller.productDetail.value.color?.fromHex.withAlpha(10)),
                isCurved: true,
                barWidth: 1,
                dotData: FlDotData(show: false),
                spots: [
                  for (int i = 0; i < data.length; i++) ...[
                    FlSpot(
                      i.toDouble(),
                      data[i].close?.toDouble() ?? 0,
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

  LineTouchData lineTooltip(List<PintuChartPayloadChart> chart) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Vx.white,
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((LineBarSpot touchedSpot) {
            final amount = touchedSpot.y.moneyFormat();
            final date = DateTime.fromMillisecondsSinceEpoch(chart[touchedSpot.spotIndex].block!.toInt() * 1000).toStringEx(format: 'dd MMM y HH:mm');
            final output = '$date\n $amount';
            final textStyle = TextStyle(color: Vx.black, fontSize: 11);
            return LineTooltipItem('$output', textStyle);
          }).toList();
        },
      ),
    );
  }
}
