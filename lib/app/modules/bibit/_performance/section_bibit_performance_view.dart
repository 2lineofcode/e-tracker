import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/app_color.dart';
import '../../../helpers/helpers.dart';
import 'section_bibit_performance_controller.dart';
import 'tab_1.dart';
import 'tab_2.dart';

class SectionBibitPerformanceView extends GetView<SectionBibitPerformanceController> {
  const SectionBibitPerformanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: VStack(
        [
          Obx(
            () {
              final performance = controller.performance.value;
              final chart = controller.performanceChart.value;
              return HStack([
                VStack(
                  [
                    'Nilai Portfolio'.text.size(12).make(),
                    '${performance.totalporto?.moneyFormat() ?? '~'}'.text.size(18).bold.make(),
                  ],
                ),
                Spacer(),
                ''.richText.withTextSpanChildren([
                  ' ${chart.change?.moneyFormat()}'.textSpan.color(BibitHelper.getColor(chart.percent)).make(),
                  ' (${chart.percent?.percentageFormat()})'.textSpan.color(BibitHelper.getColor(chart.percent)).make(),
                  ' ${BibitHelper.getSymbol(performance.percentage)}'.textSpan.color(BibitHelper.getColor(chart.percent)).make(),
                ]).make(),
              ]);
            },
          ),
          TabBar(
            physics: NeverScrollableScrollPhysics(),
            indicatorColor: AppColor.noteColor,
            labelColor: AppColor.textReverse,
            labelStyle: TextStyle(fontSize: 13),
            unselectedLabelColor: Vx.neutral400,
            unselectedLabelStyle: TextStyle(fontSize: 13),
            tabs: [
              Tab(text: 'Chart'),
              Tab(text: 'Alokasi'),
            ],
          ).pSymmetric(v: 12),
          TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              SectionBibitPerformanceTab1(),
              SectionBibitPerformanceTab2(),
            ],
          ).expand(),
        ],
      ),
    );
  }
}
