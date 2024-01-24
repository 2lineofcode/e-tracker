import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/app_color.dart';
import 'settings_controller.dart';

class SectionRepeat extends GetView<SettingsController> {
  const SectionRepeat({super.key});

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        HStack(
          [
            'Repeat Transaction'.text.bold.make(),
            Spacer(),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.add),
            ),
          ],
        ).pOnly(bottom: 16),
        ListView.separated(
          itemCount: 2,
          separatorBuilder: (context, index) => 8.heightBox,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(Icons.schedule, color: AppColor.bibit),
              tileColor: AppColor.cardHeaderPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: AppColor.cardItemPrimary),
              ),
              title: 'Tagihan Indihome'.text.size(13).bold.make(),
              subtitle: 'Every 28th in a month'.text.size(12).make(),
              trailing: 'Rp. 130.980'.text.bold.make(),
            );
          },
        ).expand(),
      ],
    );
  }
}
