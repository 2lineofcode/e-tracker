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

      /// event
      onCalendarCreated: onCalendarCreated,
      onPageChanged: onPageChanged,
      onDaySelected: onDaySelected,
      selectedDayPredicate: selectedDayPredicate,
      eventLoader: eventLoader,
      calendarBuilders: calendarBuilders,

      /// config
      headerVisible: false,
      calendarStyle: CalendarStyle(
        defaultTextStyle: TextStyle(fontSize: 11),
        todayTextStyle: TextStyle(fontSize: 12),
        selectedTextStyle: TextStyle(fontSize: 11),
        outsideTextStyle: TextStyle(fontSize: 11, color: Vx.neutral500),
        weekendTextStyle: TextStyle(fontSize: 11, color: Vx.red300),
        todayDecoration: BoxDecoration(color: Colors.orange.withAlpha(100), shape: BoxShape.rectangle),
        selectedDecoration: BoxDecoration(color: Colors.blue[800], shape: BoxShape.rectangle),
        outsideDaysVisible: false,

        /// marker
        markerDecoration: BoxDecoration(color: Vx.orange300, shape: BoxShape.circle),
        markersMaxCount: 1,
        markersOffset: PositionedOffset(top: 8, end: 8),
        markersAutoAligned: false,
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(fontSize: 12),
        weekendStyle: TextStyle(fontSize: 12, color: Vx.red300),
      ),
      rowHeight: 44,
      weekendDays: [DateTime.saturday, DateTime.sunday],
      startingDayOfWeek: StartingDayOfWeek.monday,
      rangeSelectionMode: RangeSelectionMode.disabled,
    );
  }
}
