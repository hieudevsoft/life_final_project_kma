// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:uvid/domain/models/event.dart';

@immutable
class CalendarEventDataModel<T extends Object?> {
  /// Specifies date on which all these events are.
  final DateTime date;

  /// Defines the start time of the event.
  /// [endTime] and [startTime] will defines time on same day.
  /// This is required when you are using [CalendarEventData] for [DayView]
  final DateTime? startTime;

  /// Defines the end time of the event.
  /// [endTime] and [startTime] defines time on same day.
  /// This is required when you are using [CalendarEventData] for [DayView]
  final DateTime? endTime;

  /// Title of the event.
  final String title;

  /// Description of the event.
  final String description;

  /// Defines color of event.
  /// This color will be used in default widgets provided by plugin.
  final Color color;

  /// Event on [date].
  final T? event;

  final DateTime? _endDate;

  /// Stores all the events on [date]
  const CalendarEventDataModel({
    required this.title,
    this.description = "",
    this.event,
    this.color = Colors.blue,
    this.startTime,
    this.endTime,
    DateTime? endDate,
    required this.date,
  }) : _endDate = endDate;

  DateTime get endDate => _endDate ?? date;

  @override
  String toString() => toJson().toString();

  @override
  bool operator ==(Object other) {
    return other is CalendarEventDataModel<T> &&
        date.compareWithoutTime(other.date) &&
        endDate.compareWithoutTime(other.endDate) &&
        ((event == null && other.event == null) || (event != null && other.event != null && event == other.event)) &&
        ((startTime == null && other.startTime == null) ||
            (startTime != null && other.startTime != null && startTime!.hasSameTimeAs(other.startTime!))) &&
        ((endTime == null && other.endTime == null) ||
            (endTime != null && other.endTime != null && endTime!.hasSameTimeAs(other.endTime!))) &&
        title == other.title &&
        color == other.color &&
        description == other.description;
  }

  @override
  int get hashCode => super.hashCode;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'date': date.millisecondsSinceEpoch,
      'startTime': startTime?.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
      'title': title,
      'description': description,
      'color': color.value,
      'event': event,
      '_endDate': _endDate?.millisecondsSinceEpoch,
    };
  }

  factory CalendarEventDataModel.fromMap(Map<String, dynamic> map) {
    return CalendarEventDataModel<T>(
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      startTime: map['startTime'] != null ? DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int) : null,
      endTime: map['endTime'] != null ? DateTime.fromMillisecondsSinceEpoch(map['endTime'] as int) : null,
      title: map['title'] as String,
      description: map['description'] as String,
      color: Color(map['color'] as int),
      event: map['event'],
    );
  }

  String toJson() => json.encode(toMap());

  factory CalendarEventDataModel.fromJson(String source) =>
      CalendarEventDataModel.fromMap(json.decode(source) as Map<String, dynamic>);

  CalendarEventData<Event?> toCalendarEventData() {
    return CalendarEventData(
      title: title,
      date: date,
      startTime: startTime,
      endTime: endTime,
      color: color,
      description: description,
      endDate: endDate,
      event: Event.fromJson(event.toString()),
    );
  }
}
