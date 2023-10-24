import 'package:flutter/material.dart';
import 'package:kalender/src/models/calendar/calendar_event.dart';

/// The [CalendarEventHandlers] class contains the functions that are called by the calendar view.
///  * an event is changed, tapped, or created
///  * when a date is tapped.
class CalendarEventHandlers<T> {
  const CalendarEventHandlers({
    this.onEventChanged,
    this.onEventTapped,
    this.onCreateEvent,
    this.onDateTapped,
    this.onEventChangeStart,
    this.onPageChanged,
    this.onEventCreate,
    this.onEventCreated,
  });

  /// The [Function] called before the event is changed.
  final void Function(CalendarEvent<T> event)? onEventChangeStart;

  /// The [Function] called after the event is changed.
  ///
  /// The [Function] must return a [Future] so the UI can update on completion.
  final Future<void> Function(
    DateTimeRange initialDateTimeRange,
    CalendarEvent<T> event,
  )? onEventChanged;

  /// The [Function] called when the event is tapped.
  ///
  /// The [Function] must return a [Future] so the UI can update on completion.
  final Future<void> Function(
    CalendarEvent<T> event,
  )? onEventTapped;

  /// The [Function] called when an event is created.
  ///
  /// The [Function] must return a [Future] so the UI can update on completion.
  final Future<void> Function(
    CalendarEvent<T> newEvent,
  )? onCreateEvent;

  final CalendarEvent<T> Function(
    DateTimeRange initialDateTimeRange,
  )? onEventCreate;

  final Future<void> Function(
    CalendarEvent<T> newEvent,
  )? onEventCreated;

  /// The [Function] called when the event is tapped.
  final void Function(
    DateTime date,
  )? onDateTapped;

  /// The [Function] called when the page has changed.
  final void Function(
    DateTimeRange visibleDateTimeRange,
  )? onPageChanged;

  @override
  operator ==(Object other) {
    return other is CalendarEventHandlers<T> &&
        other.onEventChanged == onEventChanged &&
        other.onEventTapped == onEventTapped &&
        other.onCreateEvent == onCreateEvent &&
        other.onDateTapped == onDateTapped;
  }

  @override
  int get hashCode => Object.hash(
        onEventChanged,
        onEventTapped,
        onCreateEvent,
        onDateTapped,
      );
}
