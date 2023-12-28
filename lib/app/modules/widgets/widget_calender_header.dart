import 'package:ex/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:get/get.dart';

class MyCalendarHeader extends StatelessWidget {
  const MyCalendarHeader({
    super.key,
    required this.focusedDay,
    required this.onGoPrevMonth,
    required this.onGoToday,
    required this.onGoNextMonth,
    required this.onGoDate,
  });

  final DateTime focusedDay;
  final void Function() onGoPrevMonth;
  final void Function() onGoToday;
  final void Function() onGoNextMonth;
  final void Function(DateTime) onGoDate;

  @override
  Widget build(BuildContext context) {
    final monthSelected = focusedDay.toStringEx(format: 'M').obs;
    final yearSelected = focusedDay.toStringEx(format: 'y').obs;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CustomPopup(
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
            child: '${focusedDay.toStringEx(format: 'MMMM yyyy')}'.text.bold.make().pSymmetric(h: 8),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.chevron_left, size: 18),
            onPressed: onGoPrevMonth,
          ),
          IconButton(
            icon: Icon(Icons.circle_outlined, size: 12),
            onPressed: onGoToday,
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, size: 18),
            onPressed: onGoNextMonth,
          ),
        ],
      ),
    );
  }
}
