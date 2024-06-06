import 'package:ex_kit/ex.dart';
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
                VStack(
                  [
                    ''
                        .richText
                        .withTextSpanChildren([
                          'RoI dalam: '.textSpan.make(),
                          '${BibitHelper.getPeriodText(controller.periodSelected.value)}'.textSpan.color(AppColor.orange).make(),
                        ])
                        .size(11)
                        .make(),
                    ''
                        .richText
                        .withTextSpanChildren([
                          ' ${chart.change?.moneyFormat() ?? ''}'.textSpan.make(),
                          ' (${chart.percent?.percentageFormat() ?? ''})'.textSpan.make(),
                          ' ${BibitHelper.getSymbol(performance.percentage)}'.textSpan.make(),
                        ])
                        .color(BibitHelper.getColor(chart.percent))
                        .make(),
                  ],
                  alignment: MainAxisAlignment.end,
                  crossAlignment: CrossAxisAlignment.end,
                ),
              ]);
            },
          ),
          TabBar(
            physics: NeverScrollableScrollPhysics(),
            labelColor: AppColor.textReverse,
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
