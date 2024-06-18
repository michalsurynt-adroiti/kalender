import 'package:flutter/material.dart';
import 'package:kalender/src/extensions.dart';
import 'package:kalender/src/models/calendar/calendar_controller.dart';
import 'package:kalender/src/providers/calendar_scope.dart';
import 'package:kalender/src/components/event_groups/multi_day_event_group_widget.dart';
import 'package:kalender/src/components/gesture_detectors/multi_day_header_gesture_detector.dart';
import 'package:kalender/src/models/event_group_controllers/multi_day_event_group.dart';
import 'package:kalender/src/models/view_configurations/month_configurations/month_view_configuration.dart';
import 'package:kalender/src/providers/calendar_style.dart';

class MonthViewPageContent<T> extends StatelessWidget {
  const MonthViewPageContent({
    super.key,
    required this.viewConfiguration,
    required this.visibleDateRange,
    required this.horizontalStep,
    required this.verticalStep,
    required this.controller,
  });

  final DateTimeRange visibleDateRange;
  final MonthViewConfiguration viewConfiguration;
  final double horizontalStep;
  final double verticalStep;
  final CalendarController<T> controller;

  @override
  Widget build(BuildContext context) {
    final scope = CalendarScope.of<T>(context);
    final components = CalendarStyleProvider.of(context).components;

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: <Widget>[
        ListenableBuilder(
          listenable: scope.eventsController,
          builder: (context, child) {
            return IntrinsicHeight(
              child: SizedBox(
                child: Stack(
                  children: [
                    components.monthGridBuilder(),
                    Column(
                      children: [
                        for (int c = 0; c < 6; c++)
                          Builder(
                            builder: (context) {
                              // Calculate the start date.
                              final isFirstWeek = c == 0;
                              //controller.visibleMonth

                              final start = visibleDateRange.start.add(
                                Duration(days: c * 7),
                              );

                              // Calculate the end date.
                              final end = visibleDateRange.start.add(
                                Duration(days: (c * 7) + 7),
                              );

                              // Create a date range from the start and end dates.
                              final weekDateRange = DateTimeRange(
                                start: start.startOfDay,
                                end: end.startOfDay,
                              );

                              // Get the events from the events controller.
                              final events = scope.eventsController.getEventsFromDateRange(
                                weekDateRange,
                              );

                              controller.visibleEvents = controller.visibleEvents.followedBy(events);

                              // Create a multi day event group from the events.
                              final multiDayEventGroup = MultiDayEventGroup.fromEvents(
                                events: events,
                              );

                              final selectedEvent = scope.eventsController.selectedEvent;
                              final horizontalStepDuration = viewConfiguration.horizontalStepDuration;
                              final verticalStepDuration = viewConfiguration.verticalStepDuration;
                              final multiDayTileHeight = viewConfiguration.multiDayTileHeight;

                              // Calculate the height of the multi day event group.
                              var height =
                                  multiDayTileHeight * (multiDayEventGroup.maxNumberOfStackedEvents + (viewConfiguration.createMultiDayEvents ? 1 : 0));
                              if (events.isEmpty) {
                                // No events in a given week.
                                height = 40;
                              }

                              final gestureDetector = MultiDayHeaderGestureDetector<T>(
                                createMultiDayEvents: viewConfiguration.createMultiDayEvents,
                                createEventTrigger: viewConfiguration.createEventTrigger,
                                visibleDateRange: weekDateRange,
                                horizontalStep: horizontalStep,
                                verticalStep: verticalStep,
                              );

                              final eventGroup = MultiDayEventGroupWidget<T>(
                                multiDayEventGroup: multiDayEventGroup,
                                visibleDateRange: weekDateRange,
                                horizontalStep: horizontalStep,
                                horizontalStepDuration: horizontalStepDuration,
                                verticalStep: verticalStep,
                                verticalStepDuration: verticalStepDuration,
                                isChanging: false,
                                multiDayTileHeight: multiDayTileHeight,
                                rescheduleDateRange: visibleDateRange,
                              );

                              final cellHeaders = Row(
                                children: <Widget>[
                                  for (int r = 0; r < 7; r++)
                                    Expanded(
                                      child: components.monthCellHeaderBuilder(
                                        visibleDateRange.start.add(
                                          Duration(days: (c * 7) + r),
                                        ),
                                        (date) => scope.functions.onDateTapped?.call(date),
                                      ),
                                    ),
                                ],
                              );

                              ListenableBuilder? changingEvent;
                              if (selectedEvent != null && scope.eventsController.hasChangingEvent) {
                                changingEvent = ListenableBuilder(
                                  listenable: scope.eventsController.selectedEvent!,
                                  builder: (context, child) {
                                    final occursDuring = selectedEvent.occursDuringDateTimeRange(weekDateRange);

                                    if (occursDuring) {
                                      final multiDayEventGroup = MultiDayEventGroup.fromEvents(
                                        events: [selectedEvent],
                                      );

                                      return MultiDayEventGroupWidget<T>(
                                        multiDayEventGroup: multiDayEventGroup,
                                        visibleDateRange: weekDateRange,
                                        horizontalStep: horizontalStep,
                                        horizontalStepDuration: horizontalStepDuration,
                                        verticalStep: verticalStep,
                                        verticalStepDuration: verticalStepDuration,
                                        isChanging: true,
                                        multiDayTileHeight: multiDayTileHeight,
                                        rescheduleDateRange: visibleDateRange,
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  },
                                );
                              }

                              final style = CalendarStyleProvider.of(context).style.monthGridStyle;
                              final color = style.color ?? Colors.white10;

                              return DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: isFirstWeek ? BorderSide(color: color) : BorderSide.none,
                                    bottom: BorderSide(color: color),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    cellHeaders,
                                    SizedBox(
                                      height: height,
                                      child: Stack(
                                        children: [
                                          gestureDetector,
                                          eventGroup,
                                          changingEvent ?? const SizedBox.shrink(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
