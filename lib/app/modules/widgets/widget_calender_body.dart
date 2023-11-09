import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MyCalenderBody<T> extends StatelessWidget {
  const MyCalenderBody({
    super.key,
    required this.focusedDay,
    required this.minimumDate,
    required this.maximumDate,
    required this.onCalendarCreated,
    required this.onPageChanged,
    required this.onDaySelected,
    required this.selectedDayPredicate,
    required this.eventLoader,
    this.calendarBuilders = const CalendarBuilders(),
  });

  /// basic
  final DateTime focusedDay;
  final DateTime minimumDate;
  final DateTime maximumDate;

  /// event
  final void Function(PageController pageController) onCalendarCreated;
  final void Function(DateTime focusedDay) onPageChanged;
  final OnDaySelected onDaySelected;
  final bool Function(DateTime day) selectedDayPredicate;
  final List<T> Function(DateTime day) eventLoader;

  /// raw
  final CalendarBuilders<T> calendarBuilders;

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
      calendarBuilders: calendarBuilders,

      /// config
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,

        // textstyle
        defaultTextStyle: TextStyle(fontSize: 11),
        todayTextStyle: TextStyle(fontSize: 12),
        selectedTextStyle: TextStyle(fontSize: 11),
        outsideTextStyle: TextStyle(fontSize: 11, color: Vx.neutral500),
        weekendTextStyle: TextStyle(fontSize: 11, color: Vx.white),
        todayDecoration: BoxDecoration(color: Vx.neutral700, shape: BoxShape.rectangle),
        selectedDecoration: BoxDecoration(color: Vx.green800, shape: BoxShape.rectangle),
        // tableBorder: TableBorder.all(color: Vx.neutral900, borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(fontSize: 12),
        weekendStyle: TextStyle(fontSize: 12, color: Vx.white),
      ),
      rowHeight: 44,
      weekendDays: [DateTime.saturday, DateTime.sunday],
      startingDayOfWeek: StartingDayOfWeek.monday,
      rangeSelectionMode: RangeSelectionMode.disabled,
      availableGestures: AvailableGestures.none,
      locale: 'in',
    );
  }
}
