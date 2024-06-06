import 'package:ex_kit/ex.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/app_color.dart';
import '../../../core/const.dart';
import '../../../helpers/helpers.dart';

import '../../../models/bibit_portpolio_goal_chart_entity.dart';
import 'detail_portfolio_controller.dart';

class DetailPortpolioTab2 extends GetView<DetailPortfolioController> {
  const DetailPortpolioTab2({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (data) {
        if (data?.goalsetting == null) {
          return ExUiErrorOrEmpty(
            illustration: SvgPicture.network(
              'https://app.bibit.id/static/media/goal-empty-new-dark.fef950088e8a5706a79a6485484a54b0.svg',
              colorFilter: ColorFilter.mode(AppColor.neutralLight, BlendMode.srcATop),
            ),
            title: 'Tidak ada data',
            message: 'Temukan produk investasi sesuai kebutuhan dan capai tujuan keuanganmu',
          ).pOnly(bottom: 90);
        } else {
          return VStack(
            [
              // :0
              HStack(
                [
                  VStack([
                    'Saat ini'.text.size(12).neutral500.make(),
                    '${data?.totalporto?.moneyFormat()}'.text.make(),
                  ]),
                  Spacer(),
                  VStack(
                    crossAlignment: CrossAxisAlignment.end,
                    [
                      'Goal'.text.size(12).neutral500.make(),
                      '${data?.goalsetting?.targetamount?.moneyFormat()}'.text.make(),
                    ],
                  ),
                ],
              ),

              // :1
              _Chart(
                controller.goalChart.value.goal ?? [],
                controller.goalChart.value.progress ?? [],
              ).h(200).pSymmetric(v: 12),

              // :2
              CustomPopup(
                content: 'Selisih ${(data!.goalsetting!.targetamount! - data.totalporto!).moneyFormat()} lagi dari target'.text.black.size(12).make(),
                child: HStack([
                  'Progress:  '.text.size(12).make(),
                  ExProgressBar(
                    value: (data.totalporto! / data.goalsetting!.targetamount! * 100).toInt(),
                    color1: AppColor.bibit,
                    color2: AppColor.bibitDark,
                    radius: 90,
                  ).expand(),
                  '${(data.totalporto! / data.goalsetting!.targetamount! * 100).toDouble().toStringAsFixed(2)}%'.text.size(12).make().pOnly(left: 8),
                ]).pOnly(top: 8),
              ),

              // :3
              if (data.goalsetting?.ontrack == 0) ...[
                'Mulai ada penurunan di portofoliomu. Ayo atur lagi tabunganmu supaya kembali on track! 💪'.text.neutral500.size(12).make().pSymmetric(v: 12),
              ],

              // :4
              Container(
                width: double.infinity,
                decoration: ExDecorator.box(borderRadius: 4, borderColor: AppColor.neutral),
                child: VStack([
                  'Tabungan yang Kurang'.text.size(12).make(),
                  '${controller.goalOntrack.value.targetAmountOnTrack?.moneyFormat()}'.text.red400.bold.make(),
                  Divider().pSymmetric(v: 8),
                  'Target Nabung Per Bulan'.text.size(12).make(),
                  '${controller.goalDetail.value.recurringAmount?.moneyFormat()}'.text.bold.make(),
                ]).p12(),
              ),
            ],
          ).p12();
        }
      },
    );
  }
}

class _Chart extends GetView<DetailPortfolioController> {
  const _Chart(this.dataGoal, this.dataProgress);

  final List<BibitPortpolioGoalChartDataGoal> dataGoal;
  final List<BibitPortpolioGoalChartDataProgress> dataProgress;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetailPortfolioController>(
      init: DetailPortfolioController(),
      initState: (_) {},
      builder: (_) {
        return LineChart(
          LineChartData(
            lineTouchData: lineTooltip(dataGoal),
            gridData: FlGridData(),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                color: AppColor.bibit,
                belowBarData: BarAreaData(show: true, color: AppColor.bibit.withAlpha(50)),
                isCurved: true,
                barWidth: 1,
                dotData: FlDotData(show: false),
                spots: [
                  // :1
                  for (int i = 0; i < dataGoal.length; i++) ...[
                    FlSpot(i.toDouble(), dataGoal[i].value?.toDouble() ?? 0),
                  ],
                ],
              ),
              LineChartBarData(
                color: AppColor.orange,
                isCurved: true,
                isStrokeCapRound: true,
                barWidth: 4,
                dotData: FlDotData(show: false),
                spots: [
                  // :2
                  for (int i = 0; i < dataProgress.length; i++) ...[
                    FlSpot(i.toDouble(), dataProgress[i].value?.toDouble() ?? 0),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  LineTouchData lineTooltip(List<BibitPortpolioGoalChartDataGoal> chart) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Vx.white,
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map(
            (LineBarSpot touchedSpot) {
              final amount = touchedSpot.y.moneyFormat();
              final date = chart[touchedSpot.spotIndex].date!.reformatDate(from: yMd, to: 'MMM y');
              final output = '$date\n $amount';
              final textStyle = TextStyle(color: Vx.black, fontSize: 11);
              return LineTooltipItem('$output', textStyle);
            },
          ).toList();
        },
      ),
    );
  }
}
