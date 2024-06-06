import 'package:ex_kit/ex.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../helpers/helpers.dart';
import 'section_bibit_performance_controller.dart';

class SectionBibitPerformanceTab2 extends GetView<SectionBibitPerformanceController> {
  SectionBibitPerformanceTab2({super.key});
  final colorList = ['#4CA870', '#4C96E1', '#997CD5'];

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        /// chart
        Container(
          decoration: ExDecorator.box(borderRadius: 4),
          child: Stack(
            children: [
              _PieChart().wh(double.infinity, 200),
              VStack(
                [
                  indicator('Psr. Uang', colorList[0].fromHex).pOnly(bottom: 4),
                  indicator('Obligasi', colorList[1].fromHex).pOnly(bottom: 4),
                  indicator('Saham', colorList[2].fromHex).pOnly(bottom: 4),
                ],
              ).positioned(bottom: 12, left: 12),
            ],
          ),
        ),

        /// summary
        summary().pOnly(top: 12),
      ],
    ).p12();
  }

  Widget indicator(String label, Color color) {
    return HStack([
      Container(
        decoration: ExDecorator.box(fillColor: color, borderColor: color, borderRadius: 90),
        height: 8,
        width: 8,
      ).pOnly(right: 4),
      '$label'.text.size(11).minFontSize(11).make(),
    ]);
  }

  Widget summary() {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: controller.allocation.length,
      separatorBuilder: (BuildContext context, int index) => Divider(),
      itemBuilder: (context, index) {
        final data = controller.allocation[index];
        return ListTile(
          leading: Container(
            width: 60,
            height: 30,
            decoration: ExDecorator.box(
              fillColor: colorList[index].fromHex.withAlpha(50),
              borderColor: colorList[index].fromHex,
              borderRadius: 90,
            ),
            child: '${data.current?.toDouble()?.percentageFormat()}'.text.color(colorList[index].fromHex).size(12).makeCentered(),
          ),
          title: VStack([
            '${data.name}'.text.bold.size(10).make().pOnly(bottom: 2),
            '${data.items} Produk'.text.neutral400.size(8).make(),
          ]),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              '${data.totalporto?.moneyFormat()}'.text.bold.make(),
              '${data.profitloss?.moneyFormat()}'.text.color(BibitHelper.getColor(data.profitloss)).make(),
            ],
          ),
        );
      },
    );
  }
}

class _PieChart extends GetView<SectionBibitPerformanceController> {
  const _PieChart();

  @override
  Widget build(BuildContext context) {
    final data = controller.allocation;
    return GetBuilder<SectionBibitPerformanceController>(
      init: SectionBibitPerformanceController(),
      initState: (_) {},
      builder: (_) {
        final colorList = ['#4CA870', '#4C96E1', '#997CD5'];
        return PieChart(
          PieChartData(
            centerSpaceRadius: 38,
            sections: [
              for (int i = 0; i < data.length; i++)
                PieChartSectionData(
                  color: colorList[i].fromHex,
                  value: data[i].current?.toDouble() ?? 0,
                  title: '${data[i].current?.toDouble()?.percentageFormat()}',
                  radius: 50,
                  titleStyle: TextStyle(fontSize: 10, color: Vx.white),
                  showTitle: true,
                ),
            ],
          ),
        );
      },
    );
  }
}
