import 'package:flutter/material.dart';

class MyCalendarHeader extends StatelessWidget {
  const MyCalendarHeader({
    Key? key,
    required this.focusedDay,
    required this.onGoPrevMonth,
    required this.onGoToday,
    required this.onGoNextMonth,
  }) : super(key: key);

  final Widget focusedDay;
  final void Function() onGoPrevMonth;
  final void Function() onGoToday;
  final void Function() onGoNextMonth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          focusedDay,
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
