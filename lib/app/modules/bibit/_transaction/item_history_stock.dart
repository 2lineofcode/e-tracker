import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/app_color.dart';
import '../../../helpers/helpers.dart';
import 'section_bibit_transaction_controller.dart';

class ItemHistoryStock extends GetView<SectionBibitTransactionController> {
  const ItemHistoryStock({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: controller.historyListStock.length,
      physics: NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) {
        final item = controller.historyListStock[index];
        final isDepoOrWD = item.summary?.action == 'DEPOSIT' || item.summary?.action == 'WITHDRAW';

        if (isDepoOrWD) {
          return ListTile(
            leading: ExAvatarView(source: 'assets/icons/ic_lot.svg', size: 24, borderColor: Colors.transparent),
            title: '${item.summary?.action.toTitleCase}'.text.size(12).bold.make(),
            subtitle: '${item.summary?.createdDate} • RDN Wallet'.text.size(11).minFontSize(11).make(),
            trailing: '${item.summary?.totalAmount?.moneyFormat()}'.text.color(item.summary?.action == 'DEPOSIT' ? AppColor.bibit : AppColor.red).make(),
          );
        } else {
          return ListTile(
            leading: ExAvatarView(source: '${item.details?.companyIconUrl}', size: 24, borderColor: Colors.transparent),
            title: '${item.details?.symbol} (${item.summary?.action.toTitleCase})'.text.size(12).bold.make(),
            subtitle: '${item.summary?.createdDate} • ${item.summary?.label?.toTitleCase}'.text.size(11).minFontSize(11).make(),
            onTap: () => controller.goDetailStock(item.details?.symbol ?? ''),
            trailing: '${item.summary?.totalAmount?.moneyFormat()}'
                .text
                .color(
                  item.summary?.action == 'SELL' //
                      ? AppColor.red
                      : item.summary?.action == 'BUY' //
                          ? AppColor.bibit
                          : item.summary?.action == 'DIV' //
                              ? AppColor.blue
                              : Vx.white,
                )
                .make(),
          );
        }
      },
    );
  }
}
