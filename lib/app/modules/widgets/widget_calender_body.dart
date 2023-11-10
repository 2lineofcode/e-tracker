import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/app_color.dart';

class MyCalenderBody<T> extends StatelessWidget {
  const MyCalenderBody({
    super.key,
    required this.focusedDay,
    required this.minimumDate,
    required this.maximumDate,
    this.onCalendarCreated,
    this.onPageChanged,
    this.onDaySelected,
    this.selectedDayPredicate,
    this.eventLoader,
    this.calendarBuilders = const CalendarBuilders(),
  });

  /// basic
  final DateTime focusedDay;
  final DateTime minimumDate;
  final DateTime maximumDate;

  /// event
  final void Function(PageController pageController)? onCalendarCreated;
  final void Function(DateTime focusedDay)? onPageChanged;
  final OnDaySelected? onDaySelected;
  final bool Function(DateTime day)? selectedDayPredicate;
  final List<T> Function(DateTime day)? eventLoader;

  /// raw
  final CalendarBuilders<T>? calendarBuilders;

  @override
  Widget build(BuildContext context) {
    return TableCalendar<T>(
      // deff
      focusedDay: focusedDay,
      firstDay: minimumDate,
      lastDay: maximumDate,
      headerVisible: false,

      /// event
      onCalendarCreated: onCalendarCreated,
      onPageChanged: onPageChanged,
      onDaySelected: onDaySelected,
      selectedDayPredicate: selectedDayPredicate,
      eventLoader: eventLoader,
      calendarBuilders: calendarBuilders ?? CalendarBuilders(),

      /// config
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,

        // textstyle
        defaultTextStyle: TextStyle(fontSize: 11),
        todayTextStyle: TextStyle(fontSize: 12),
        selectedTextStyle: TextStyle(fontSize: 11),
        outsideTextStyle: TextStyle(fontSize: 11),
        weekendTextStyle: TextStyle(fontSize: 11, color: AppColor.calendarWeekEndColor),
        todayDecoration: BoxDecoration(color: AppColor.calendarTodayColor, shape: BoxShape.rectangle),
        selectedDecoration: BoxDecoration(color: AppColor.calendarSelectedColor, shape: BoxShape.rectangle),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(fontSize: 12),
        weekendStyle: TextStyle(fontSize: 12, color: AppColor.calendarWeekEndColor),
      ),
      rowHeight: 44,
      weekendDays: [DateTime.saturday, DateTime.sunday],
      startingDayOfWeek: StartingDayOfWeek.monday,
      rangeSelectionMode: RangeSelectionMode.disabled,
      availableGestures: AvailableGestures.horizontalSwipe,
      locale: 'in',
    );
  }
}
