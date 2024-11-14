import 'package:ex_kit/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:get/get.dart';

class MyMonthYearPicker extends StatelessWidget {
  const MyMonthYearPicker({
    super.key,
    required this.onGoDate,
    required this.child,
  });

  final void Function(DateTime) onGoDate;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final focusedDay = DateTime.now();
    final monthSelected = focusedDay.toStringEx(format: 'M').obs;
    final yearSelected = focusedDay.toStringEx(format: 'y').obs;

    return CustomPopup(
      content: VStack([
        /// year
        HStack([
          IconButton(
            onPressed: () => yearSelected.value = (yearSelected.value.toInt()! - 1).toString(),
            icon: Icon(CupertinoIcons.back, color: Vx.black, size: 18),
          ),
          Spacer(),
          Obx(() => '${yearSelected.value}'.text.bold.black.make()),
          Spacer(),
          IconButton(
            onPressed: () => yearSelected.value = (yearSelected.value.toInt()! + 1).toString(),
            icon: Icon(CupertinoIcons.forward, color: Vx.black, size: 18),
          ),
        ]),

        Divider(),

        /// month
        Obx(
          () => Wrap(
            children: [
              for (var i = 0; i < 12; i++) ...[
                TextButton(
                  onPressed: () {
                    monthSelected.value = (i + 1).toString();
                    final dt = DateTime(int.parse(yearSelected.value), int.parse(monthSelected.value));
                    onGoDate.call(dt);
                    Get.back();
                  },
                  child: '${(i + 1).toString().reformatDate(from: 'M', to: 'MMM')}' //
                      .text
                      .color(monthSelected.value == (i + 1).toString() ? Vx.blue500 : Vx.neutral500)
                      .make(),
                ).p8(),
              ],
            ],
          ),
        ),
      ]).w(220),
      child: child,
    );
  }
}
