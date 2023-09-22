import 'package:flutter/material.dart';
import 'package:kalender/src/extensions.dart';
import 'package:kalender/src/models/calendar/calendar_event.dart';

/// The base MultiChildLayoutDelegate for [MultiDayEventGroupLayoutDelegate]'s
///
abstract class MultiDayEventGroupLayoutDelegate<T>
    extends MultiChildLayoutDelegate {
  MultiDayEventGroupLayoutDelegate({
    required this.events,
    required this.visibleDateRange,
    required this.multiDayTileHeight,
  });

  final List<CalendarEvent<T>> events;
  final DateTimeRange visibleDateRange;
  final double multiDayTileHeight;

  @override
  bool shouldRelayout(covariant MultiDayEventGroupLayoutDelegate oldDelegate) {
    return oldDelegate.events != events;
  }
}

class MultiDayEventGroupDefaultLayoutDelegate<T>
    extends MultiDayEventGroupLayoutDelegate<T> {
  MultiDayEventGroupDefaultLayoutDelegate({
    required super.events,
    required super.visibleDateRange,
    required super.multiDayTileHeight,
  });

  @override
  void performLayout(Size size) {
    final numChildren = events.length;
    final visibleDates = visibleDateRange.datesSpanned;
    final dayWidth = size.width / visibleDates.length;

    final tileSizes = <int, Size>{};
    final tileDx = <int, double>{};

    /// Loop through each event.
    for (var i = 0; i < numChildren; i++) {
      final id = i;
      final event = events[id];

      final eventDates = event.datesSpanned;

      // first visible date.
      final firstVisibleDate = eventDates.firstWhere(
        visibleDates.contains,
      );

      // last visible date.
      final lastVisibleDate = eventDates.lastWhere(
        visibleDates.contains,
      );

      final visibleEventDates = eventDates.getRange(
        eventDates.indexOf(firstVisibleDate),
        eventDates.indexOf(lastVisibleDate) + 1,
      );

      final dx = visibleDates.indexOf(visibleEventDates.first) * dayWidth;
      tileDx[id] = dx;

      // Calculate the width of the tile.
      final tileWidth = (visibleEventDates.length) * dayWidth;

      // Layout the tile.
      final childSize = layoutChild(
        id,
        BoxConstraints.tightFor(
          width: tileWidth,
          height: multiDayTileHeight,
        ),
      );

      tileSizes[id] = childSize;
    }

    final tilePositions = <int, Offset>{};
    for (var id = 0; id < numChildren; id++) {
      final event = events[id];

      // Find events that fill the same dates as the current event.
      final eventsAbove = tilePositions.keys.map((e) => events[e]).where(
        (eventAbove) {
          return eventAbove.datesSpanned.any(event.datesSpanned.contains);
        },
      ).toList();

      var dy = 0.0;
      if (eventsAbove.isNotEmpty) {
        final eventAboveID = events.indexOf(eventsAbove.last);
        dy = tilePositions[eventAboveID]!.dy + multiDayTileHeight;
      }

      tilePositions[id] = Offset(
        tileDx[id]!,
        dy,
      );
    }
    for (var id = 0; id < numChildren; id++) {
      positionChild(
        id,
        tilePositions[id]!,
      );
    }
  }
}
