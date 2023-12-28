import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../core/app_color.dart';
import 'detail_stock_controller.dart';

class DetailStockTab2 extends GetView<DetailStockController> {
  const DetailStockTab2({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => VStack([
        ListView.separated(
          itemCount: controller.news.length,
          separatorBuilder: (c, i) => Divider(),
          itemBuilder: (c, i) {
            final item = controller.news[i];
            return ListTile(
              leading: ExAvatarView(
                source: item.image ?? '',
                size: 32,
                bgColor: AppColor.bibitDark,
                borderColor: AppColor.bibitDark,
              ),
              title: '${item.title}'.text.size(13).minFontSize(13).bold.ellipsis.maxLines(1).make(),
              subtitle: '${item.source} • ${item.createdAt}'.text.size(12).neutral400.make(),
              onTap: () => launchUrlString(item.sourceUrl ?? ''),
            );
          },
        ).expand(),
      ]),
    );
  }
}
