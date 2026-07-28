import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/app_color.dart';
import '../../helpers/helpers.dart';

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
    this.calendarStartDay = 1,
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
  final int calendarStartDay;

  @override
  Widget build(BuildContext context) {
    final startDay = calendarStartDay.clamp(1, 31);
    if (startDay != 1) return _buildCustomPeriodCalendar(startDay);

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

  Widget _buildCustomPeriodCalendar(int startDay) {
    final periodStart = _periodStartDate(startDay);
    final periodEnd = _monthStartDate(
      periodStart.year,
      periodStart.month + 1,
      startDay,
    ).subtract(1.days);
    final totalDays = periodEnd.difference(periodStart).inDays + 1;
    final rowCount = (totalDays / 7).ceil();
    final days = List.generate(totalDays, (i) => periodStart.add(i.days));

    return Column(
      children: [
        Row(
          children: List.generate(7, (i) {
            final day = periodStart.add(i.days);
            final isWeekend = day.weekday == DateTime.saturday ||
                day.weekday == DateTime.sunday;
            return Expanded(
              child: Text(
                _weekdayLabel(day.weekday),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isWeekend ? AppColor.calendarWeekEndColor : null,
                ),
              ),
            );
          }),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: rowCount * 7,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisExtent: 44,
          ),
          itemBuilder: (context, index) {
            if (index >= days.length) return SizedBox.shrink();
            return _buildDayCell(days[index]);
          },
        ),
      ],
    );
  }

  DateTime _periodStartDate(int startDay) {
    final effectiveStartDay =
        startDay.clamp(1, DateTime(focusedDay.year, focusedDay.month + 1, 0).day);

    if (focusedDay.day >= effectiveStartDay) {
      return _monthStartDate(focusedDay.year, focusedDay.month, startDay);
    }

    return _monthStartDate(focusedDay.year, focusedDay.month - 1, startDay);
  }

  DateTime _monthStartDate(int year, int month, int startDay) {
    final monthDays = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, startDay.clamp(1, monthDays));
  }

  Widget _buildDayCell(DateTime day) {
    final events = eventLoader?.call(day) ?? [];
    final selected = selectedDayPredicate?.call(day) ?? false;
    final today = isSameDay(day, DateTime.now());
    final isWeekend =
        day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;

    Color? fillColor;
    if (selected) {
      fillColor = AppColor.calendarSelectedColor;
    } else if (today) {
      fillColor = AppColor.calendarTodayColor;
    }

    return InkWell(
      onTap: () => onDaySelected?.call(day, day),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: fillColor,
                shape: BoxShape.rectangle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: selected ? 11 : 12,
                  color: isWeekend ? AppColor.calendarWeekEndColor : null,
                ),
              ),
            ),
          ),
          if (events.isNotEmpty)
            Icon(
              Icons.circle,
              size: 6,
              color: _eventFlagColor(events),
            ).positioned(top: 8, right: 8),
        ],
      ),
    );
  }

  Color _eventFlagColor(List<T> events) {
    var total = 0;
    for (final event in events) {
      total += event.toString().toInt() ?? 0;
    }
    return total.getFlagColor();
  }

  String _weekdayLabel(int weekday) {
    return switch (weekday) {
      DateTime.monday => 'Sen',
      DateTime.tuesday => 'Sel',
      DateTime.wednesday => 'Rab',
      DateTime.thursday => 'Kam',
      DateTime.friday => 'Jum',
      DateTime.saturday => 'Sab',
      DateTime.sunday => 'Min',
      _ => '',
    };
  }
}
