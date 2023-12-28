import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:ex/ex.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/app_color.dart';
import '../../../helpers/helpers.dart';
import '../../../models/bibit_performance_chart_entity.dart';
import '../../../models/bibit_performance_entity.dart';
import 'section_bibit_performance_controller.dart';

class SectionBibitPerformanceTab1 extends GetView<SectionBibitPerformanceController> {
  const SectionBibitPerformanceTab1({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => VStack(
        [
          /// chart
          _LineChart().wh(double.infinity, 200),

          /// period Button
          periodButton().pSymmetric(v: 12),

          /// summary
          summary(controller.performance.value),
        ],
      ).p12().scrollVertical(),
    );
  }

  Widget periodButton() {
    return CustomRadioButton(
      height: 33,
      width: 44,
      elevation: 0,
      selectedColor: AppColor.green.withAlpha(100),
      unSelectedColor: Colors.transparent,
      unSelectedBorderColor: Colors.transparent,
      selectedBorderColor: Colors.transparent,
      defaultSelected: controller.periodSelected.value,
      buttonLables: ['1D', '1M', '3M', 'YTD', '1Y', 'ALL'],
      buttonValues: ['1D', '1M', '3M', 'YTD', '1Y', 'ALL'],
      buttonTextStyle: ButtonTextStyle(
        selectedColor: Vx.black,
        unSelectedColor: AppColor.textReverse,
        textStyle: TextStyle(fontSize: 12),
      ),
      radioButtonValue: (s) async {
        controller.performanceChart.value = await controller.repo.getPerformanceByPeriod(s);
        controller.periodSelected.value = s;
        controller.update();
      },
    );
  }

  Widget summary(BibitPerformanceData dataPerforma) {
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(borderRadius: 3),
      child: VStack(
        [
          HStack([
            'Ringkasan'.text.bold.make(),
            Spacer(),
            'All Time'.text.make(),
          ]).pSymmetric(v: 8, h: 12).pOnly(top: 8),
          Divider(),
          VStack(
            [
              HStack([
                'Modal Investasi'.text.make(),
                Spacer(),
                '${dataPerforma.additionalParameters?.invested?.moneyFormat()}'.text.bold.make(),
              ]).pOnly(bottom: 12),
              HStack([
                'Keuntungan Terealisasi'.text.make(),
                Spacer(),
                '${dataPerforma.additionalParameters?.profitlossRealized?.moneyFormat()}'.text.bold.color(BibitHelper.getColor(dataPerforma.additionalParameters?.profitlossRealized)).make(),
              ]).pOnly(bottom: 12),
              HStack([
                'Total Pembelian'.text.make(),
                Spacer(),
                '${dataPerforma.additionalParameters?.totalDeposit?.moneyFormat()}'.text.bold.make(),
              ]).pOnly(bottom: 12),
              HStack([
                'Total Penjualan'.text.make(),
                Spacer(),
                '${dataPerforma.additionalParameters?.totalWithdrawal?.moneyFormat()}'.text.bold.make(),
              ]).pOnly(bottom: 12),
            ],
          ).p12(),
        ],
      ),
    );
  }
}

class _LineChart extends GetView<SectionBibitPerformanceController> {
  const _LineChart();

  @override
  Widget build(BuildContext context) {
    final data = controller.performanceChart.value.chart;
    return GetBuilder<SectionBibitPerformanceController>(
      init: SectionBibitPerformanceController(),
      initState: (_) {},
      builder: (_) {
        return LineChart(
          LineChartData(
            lineTouchData: lineTooltip(data ?? []),
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
                color: BibitHelper.getColor(controller.performanceChart.value.percent),
                belowBarData: BarAreaData(show: true, color: BibitHelper.getColor(controller.performanceChart.value.percent).withAlpha(50)),
                isCurved: true,
                // isStrokeCapRound: true,
                barWidth: 1,
                dotData: FlDotData(show: false),
                spots: [
                  for (int i = 0; i < data!.length; i++) ...[
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

  LineTouchData lineTooltip(List<BibitPerformanceChartDataChart> chart) {
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
