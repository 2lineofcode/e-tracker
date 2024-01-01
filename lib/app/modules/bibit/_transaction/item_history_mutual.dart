import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';

import '../../../core/app_color.dart';
import '../../../core/const.dart';
import '../../../helpers/helpers.dart';
import '../../../models/bibit_history_mutual_entity.dart';
import 'section_bibit_transaction_controller.dart';

class ItemHistoryMutual extends GetView<SectionBibitTransactionController> {
  const ItemHistoryMutual({super.key});

  @override
  Widget build(BuildContext context) {
    return GroupedListView<BibitHistoryMutualDataTransactions, String>(
      elements: controller.historyListMutual,
      groupBy: (element) => element.lastupdate?.reformatDate(to: yMd) ?? '',
      order: GroupedListOrder.DESC,
      shrinkWrap: true,
      groupHeaderBuilder: (item) => '${item.lastupdate?.reformatDate() ?? ''}'.text.size(12).make(),
      itemBuilder: (c, item) {
        /// type ROBO
        if (item.items != null) {
          return ListTile(
            leading: ExAvatarView(source: 'assets/icons/ic_lot.svg', size: 32),
            title: 'ROBO - ${item.name}'.text.size(12).bold.make(),
            subtitle: VStack([
              for (var i in item.items!) ...[
                '• ${i.product?.name}'.text.size(11).minFontSize(11).make().onTap(() {
                  controller.goDetailMutual(i.symbol ?? '');
                }),
              ],
            ]),
            trailing: '${item.amount?.moneyFormat()}'.text.color(AppColor.bibit).make(),
          );
        }

        /// type: non ROBO
        else {
          return ListTile(
            leading: ExAvatarView(
              source: item.product?.name != null //
                  ? 'https://app.bibit.id/assets/logos/investment-manager/square/${item.product?.investmentManager?.ojkCode}.svg'
                  : 'assets/icons/ic_tax.svg',
              size: 32,
            ),
            title: '${item.product?.name ?? 'Bea Materai'}'.text.size(12).bold.make(),
            subtitle: VStack([
              '${getHistoryStatusText(item.type)} • ${item.name}'.text.size(11).minFontSize(11).make().pOnly(bottom: 8),
            ]),
            trailing: '${item.amount?.moneyFormat()}'.text.color(getHistoryStatusColorText(item.type)).make(),
            onTap: item.product?.name == null ? null : () => controller.goDetailMutual(item.symbol ?? ''),
          );
        }
      },
    );
  }
}

/// ------------------------------------------------------------------------
/// ! local helper
/// ------------------------------------------------------------------------
String getHistoryStatusText(num? templateId) {
  switch (templateId) {
    case 0:
      return 'Penjualan';
    case 2:
      return 'Pembelian';
    case 8:
      return 'Penerimaan Dividen';
    case 16:
      return 'Pembayaran Pajak';
    default:
      return 'Pembelian';
  }
}

Color getHistoryStatusColorText(num? type) {
  switch (type) {
    case 0:
      return AppColor.red;
    case 2:
      return AppColor.bibit;
    case 8:
      return AppColor.blue;
    case 16:
      return AppColor.orange;
    default:
      return AppColor.bibit;
  }
}
