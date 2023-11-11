import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../core/app_color.dart';
import '../../helpers/helper_misc.dart';
import '../../helpers/helper_money.dart';
import '../widgets/widget_shimmer_summary.dart';
import 'summary_controller.dart';

class ViewPieChart extends GetView<SummaryController> {
  const ViewPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    final item = controller.rpcSumByCategory;
    return controller.obx(
      (state) => VStack(
        [
          'Period: ${controller.monthSelected} ${controller.yearSelected}'.text.bold.make().pOnly(bottom: 16),

          ///
          if (controller.rpcSumNoteTimes.isNotEmpty) ...[
            SfCircularChart(
              series: setupChartDataSeries(),
              tooltipBehavior: setupTooltip(),
            ).w(double.infinity),

            /// header
            Container(
              decoration: BoxDecoration(
                color: AppColor.tableHeader,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                border: Border.all(color: Vx.neutral600),
              ),
              child: HStack([
                'Category'.text.make().w(205),
                Spacer(),
                'Total'.text.align(TextAlign.end).make().expand(),
              ]).p12(),
            ),
            Table(
              border: TableBorder.all(color: Vx.neutral600),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: {},
              children: [
                for (var i = 0; i < item.length; i++) ...[
                  if (item[i].total != 0) ...[
                    TableRow(
                      children: [
                        TableCell(
                          child: HStack(
                            [
                              Icon(
                                Icons.circle,
                                size: 8,
                                color: MyColor.fromHex(item[i].categoryColor!),
                              ).pOnly(right: 8),
                              '${item[i].categoryName}'.text.make(),
                            ],
                          ).p8(),
                        ),
                        TableCell(child: '${item[i].total?.moneyFormat()}'.text.align(TextAlign.end).make().p8()),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ] else ...[
            ExUiErrorOrEmpty(
              bgColor: AppColor.emptyStatePrimary,
              title: 'No data to see'.text.bold.make(),
              message: 'You dont have any transaction on this period'.text.make(),
            ).h(250),
          ],
        ],
        //
      ).p12().scrollVertical(),
      onLoading: MyShimmerSummary(),
    );
  }

  TooltipBehavior setupTooltip() {
    return TooltipBehavior(
      enable: true,
      format: 'point.x : point.y %',
      shouldAlwaysShow: false,
      decimalPlaces: 2,
      builder: (data, point, series, pointIndex, seriesIndex) {
        data as ChartSampleData;
        return Text(
          '${data.name}: ${data.total!.toInt().moneyFormat()}',
          style: TextStyle(fontSize: 11, color: Get.isDarkMode ? Colors.black : Colors.white),
        ).p8();
      },
    );
  }

  /// Returns the pie series with smart data labels.
  List<PieSeries<ChartSampleData, String>> setupChartDataSeries() {
    var dataMap = <ChartSampleData>[];

    dataMap.clear();
    controller.rpcSumByCategory.forEach((element) {
      dataMap.add(ChartSampleData(
        name: element.categoryName,
        total: element.total,
        color: element.categoryColor,
        usePercentage: element.usePercentage,
      ));
    });

    return <PieSeries<ChartSampleData, String>>[
      PieSeries<ChartSampleData, String>(
        dataSource: dataMap,
        xValueMapper: (ChartSampleData data, _) => data.name,
        yValueMapper: (ChartSampleData data, _) => data.total,
        dataLabelMapper: (ChartSampleData data, _) => data.name,
        radius: '55%',
        pointColorMapper: (datum, index) => MyColor.fromHex(datum.color ?? ''),
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          labelIntersectAction: LabelIntersectAction.hide,
          showZeroValue: false,
          labelPosition: ChartDataLabelPosition.outside,
          connectorLineSettings: ConnectorLineSettings(type: ConnectorType.curve),
        ),
      )
    ];
  }
}

class ChartSampleData {
  ChartSampleData({
    this.name,
    this.total,
    this.usePercentage,
    this.color,
  });

  final String? name;
  final int? total;
  final int? usePercentage;
  final String? color;
}
