import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/app_color.dart';
import '../../helpers/helper_money.dart';
import '../widgets/widget_shimmer_summary.dart';
import 'summary_controller.dart';

class ViewNoteTimes extends GetView<SummaryController> {
  const ViewNoteTimes({super.key});

  @override
  Widget build(BuildContext context) {
    final item = controller.rpcSumNoteTimes;
    return controller.obx(
      (state) => VStack(
        [
          'Period: ${controller.monthSelected} ${controller.yearSelected}'.text.bold.make().pOnly(bottom: 16),
          if (controller.rpcSumNoteTimes.isNotEmpty) ...[
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
                'Note'.text.make().w(205),
                Icon(Icons.south_rounded, size: 16),
                Spacer(),
                'Total'.text.align(TextAlign.end).make().expand(),
              ]).p12(),
            ),

            /// detail
            SingleChildScrollView(
              child: Table(
                border: TableBorder.all(color: Vx.neutral600),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: {
                  0: FixedColumnWidth(200),
                  1: FixedColumnWidth(50),
                },
                children: [
                  // detail
                  for (var i = 0; i < item.length; i++) ...[
                    TableRow(
                      children: [
                        TableCell(
                          child: '${item[i].note}'.text.make().p8().onTap(
                                () async => await Clipboard.setData(ClipboardData(text: '${item[i].note}')),
                              ),
                        ),
                        TableCell(child: '${item[i].times}'.text.align(TextAlign.center).make().p8()),
                        TableCell(child: '${item[i].total?.moneyFormat()}'.text.align(TextAlign.end).make().p8()),
                      ],
                    ),
                  ],
                ],
              ),
            ).expand(),
          ] else ...[
            ExUiErrorOrEmpty(
              bgColor: AppColor.emptyStatePrimary,
              title: 'No data to see',
              message: 'You dont have any transaction on this period',
            ).h(250),
          ],
        ],
      ).p12(),
      onLoading: MyShimmerSummary(),
    );
  }
}
