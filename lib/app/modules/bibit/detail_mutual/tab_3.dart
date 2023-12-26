import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/app_color.dart';
import '../../../core/const.dart';
import 'detail_mutual_controller.dart';

class DetailMutualTab3 extends GetView<DetailMutualController> {
  const DetailMutualTab3({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => DefaultTabController(
        length: 2,
        child: VStack(
          [
            TabBar(
              tabs: [
                Tab(text: 'Factsheets'),
                Tab(text: 'Prospectus'),
              ],
            ),
            TabBarView(
              children: [
                /// factsheets
                ListView.separated(
                    itemCount: controller.factsheets.length,
                    separatorBuilder: (c, i) => Divider(),
                    itemBuilder: (c, index) {
                      final item = controller.factsheets[index];
                      return ListTile(
                        title: '${item.name}'.text.size(12).maxLines(1).ellipsis.make(),
                        subtitle: '${item.date?.reformatDate(from: yMd, to: 'dd MMM yy')}'.text.size(12).make(),
                        trailing: IconButton(
                          icon: Icon(CupertinoIcons.arrow_down_circle, color: AppColor.bibit),
                          onPressed: () => controller.openFile(item),
                        ),
                      );
                    }),

                /// prospectus
                ListView.separated(
                    itemCount: controller.prospectus.length,
                    separatorBuilder: (c, i) => Divider(),
                    itemBuilder: (c, index) {
                      final item = controller.prospectus[index];
                      return ListTile(
                        title: '${item.name}'.text.size(12).maxLines(1).ellipsis.make(),
                        trailing: IconButton(
                          icon: Icon(CupertinoIcons.arrow_down_circle, color: AppColor.bibit),
                          onPressed: () => controller.openFile(item),
                        ),
                      );
                    }),
              ],
            ).expand(),
          ],
        ),
      ),
    );
  }
}
