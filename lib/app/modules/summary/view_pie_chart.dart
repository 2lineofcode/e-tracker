import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
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
                borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
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
                              CustomPopup(
                                content: VStack([
                                  if (item[i].maxBudget != null) ...[
                                    'Usage ${item[i].usePercentage ?? '0'}%'.text.black.make(),
                                    'Remaining ${item[i].remainingBudget?.moneyFormat() ?? 'Rp. 0'} / ${item[i].maxBudget?.moneyFormat() ?? 'Rp. 0'}'.text.black.make(),
                                  ] else ...[
                                    'No Budget'.text.black.make(),
                                  ],
                                ]),
                                child: Icon(
                                  item[i].categoryIcon?.getIconData() ?? Icons.circle_outlined,
                                  size: 12,
                                  color: item[i].categoryColor?.fromHex,
                                ).pOnly(right: 8),
                              ),
                              '${item[i].categoryName}'.text.make().onTap(() {
                                controller.goAdvanceFilter(item[i].categoryName ?? '');
                              }),
                              ' (${item[i].usePercentage}%)'.text.size(9).minFontSize(9).make(),
                            ],
                          ).p8(),
                        ),
                        TableCell(
                          child: '${item[i].total?.moneyFormat()}'.text.align(TextAlign.end).make().p8(),
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ] else ...[
            ExUiErrorOrEmpty(
              bgColor: AppColor.emptyStatePrimary,
              title: 'No data to see',
              message: 'You dont have any transaction on this period',
            ).h(530),
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
        data as PieChartDataModel;
        return Text(
          '${data.name}: ${data.total!.toInt().moneyFormat()}',
          style: TextStyle(fontSize: 11, color: Get.isDarkMode ? Colors.black : Colors.white),
        ).p8();
      },
    );
  }

  /// Returns the pie series with smart data labels.
  List<PieSeries<PieChartDataModel, String>> setupChartDataSeries() {
    var dataMap = <PieChartDataModel>[];

    dataMap.clear();
    controller.rpcSumByCategory.forEach((element) {
      dataMap.add(PieChartDataModel(
        name: element.categoryName,
        total: element.total,
        color: element.categoryColor,
        usePercentage: element.usePercentage,
      ));
    });

    return <PieSeries<PieChartDataModel, String>>[
      PieSeries<PieChartDataModel, String>(
        dataSource: dataMap,
        xValueMapper: (data, _) => data.name,
        yValueMapper: (data, _) => data.total,
        dataLabelMapper: (data, _) => data.name,
        radius: '55%',
        pointColorMapper: (datum, index) => datum.color?.fromHex,
        animationDuration: 500,
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

class PieChartDataModel {
  PieChartDataModel({
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
