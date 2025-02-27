import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:intl/intl.dart' as intl;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalender Example',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CalendarController<Event> controller = CalendarController(
    calendarDateTimeRange: DateTimeRange(
      start: DateTime(DateTime.now().year - 1),
      end: DateTime(DateTime.now().year + 1),
    ),
  );
  final CalendarEventsController<Event> eventController = CalendarEventsController<Event>();

  late ViewConfiguration currentConfiguration = viewConfigurations[0];
  List<ViewConfiguration> viewConfigurations = [
    CustomMultiDayConfiguration(
      name: 'Day',
      numberOfDays: 1,
      startHour: 6,
      endHour: 18,
    ),
    CustomMultiDayConfiguration(
      name: 'Custom',
      numberOfDays: 1,
    ),
    WeekConfiguration(),
    WorkWeekConfiguration(),
    MonthConfiguration(
      createMultiDayEvents: false,
      enableRescheduling: false,
      enableResizing: false,
      createEventTrigger: null,
      multiDayTileHeight: 100,
      firstDayOfWeek: 7,
    ),
    ScheduleConfiguration(),
    MultiWeekConfiguration(
      numberOfWeeks: 3,
    ),
  ];

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();

    // Current events with existing dates
    eventController.addEvents([
      CalendarEvent(
        dateTimeRange: DateTimeRange(
          start: now,
          end: now.add(const Duration(hours: 1)),
        ),
        eventData: Event(title: 'Event 1'),
      ),
      CalendarEvent(
        dateTimeRange: DateTimeRange(
          start: now.add(const Duration(hours: 2)),
          end: now.add(const Duration(hours: 5)),
        ),
        eventData: Event(title: 'Event 2'),
      ),
      CalendarEvent(
        dateTimeRange: DateTimeRange(
          start: DateTime(now.year, now.month, now.day),
          end: DateTime(now.year, now.month, now.day).add(const Duration(days: 2)),
        ),
        eventData: Event(title: 'Event 3'),
      ),

      // March 2025 test events - Monday
      CalendarEvent(
        dateTimeRange: DateTimeRange(
          start: DateTime(2025, 3, 10, 9, 0), // Monday 9:00 AM
          end: DateTime(2025, 3, 10, 11, 0), // Monday 11:00 AM
        ),
        eventData: Event(title: 'Monday Morning Meeting', color: Colors.red),
      ),
      CalendarEvent(
        dateTimeRange: DateTimeRange(
          start: DateTime(2025, 3, 10, 14, 0), // Monday 2:00 PM
          end: DateTime(2025, 3, 10, 16, 30), // Monday 4:30 PM
        ),
        eventData: Event(title: 'Monday Afternoon Workshop', color: Colors.orange),
      ),

      // Tuesday events
      CalendarEvent(
        dateTimeRange: DateTimeRange(
          start: DateTime(2025, 3, 11, 10, 0), // Tuesday 10:00 AM
          end: DateTime(2025, 3, 11, 15, 0), // Tuesday 3:00 PM
        ),
        eventData: Event(title: 'All-day Conference', color: Colors.purple),
      ),

      // Wednesday events - overlapping events to test rendering
      CalendarEvent(
        dateTimeRange: DateTimeRange(
          start: DateTime(2025, 3, 12, 13, 0), // Wednesday 1:00 PM
          end: DateTime(2025, 3, 12, 14, 0), // Wednesday 2:00 PM
        ),
        eventData: Event(title: 'Lunch Meeting', color: Colors.green),
      ),
      CalendarEvent(
        dateTimeRange: DateTimeRange(
          start: DateTime(2025, 3, 12, 13, 30), // Wednesday 1:30 PM
          end: DateTime(2025, 3, 12, 15, 0), // Wednesday 3:00 PM
        ),
        eventData: Event(title: 'Client Call', color: Colors.teal),
      ),

      // Thursday - multi-day event
      CalendarEvent(
        dateTimeRange: DateTimeRange(
          start: DateTime(2025, 3, 13, 0, 0), // Thursday 12:00 AM
          end: DateTime(2025, 3, 15, 0, 0), // Saturday 12:00 AM
        ),
        eventData: Event(title: 'Business Trip', color: Colors.indigo),
      ),

      // Friday - short events
      CalendarEvent(
        dateTimeRange: DateTimeRange(
          start: DateTime(2025, 3, 14, 9, 0), // Friday 9:00 AM
          end: DateTime(2025, 3, 14, 9, 30), // Friday 9:30 AM
        ),
        eventData: Event(title: 'Quick Standup', color: Colors.amber),
      ),
      CalendarEvent(
        dateTimeRange: DateTimeRange(
          start: DateTime(2025, 3, 14, 16, 0), // Friday 4:00 PM
          end: DateTime(2025, 3, 14, 17, 0), // Friday 5:00 PM
        ),
        eventData: Event(title: 'Weekly Review', color: Colors.blue),
      ),

      // Weekend events
      CalendarEvent(
        dateTimeRange: DateTimeRange(
          start: DateTime(2025, 3, 15, 10, 0), // Saturday 10:00 AM
          end: DateTime(2025, 3, 15, 12, 0), // Saturday 12:00 PM
        ),
        eventData: Event(title: 'Weekend Workshop', color: Colors.deepOrange),
      ),
      CalendarEvent(
        dateTimeRange: DateTimeRange(
          start: DateTime(2025, 3, 16, 15, 0), // Sunday 3:00 PM
          end: DateTime(2025, 3, 16, 18, 0), // Sunday 6:00 PM
        ),
        eventData: Event(title: 'Planning Session', color: Colors.pink),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final calendar = CalendarView<Event>(
      controller: controller,
      eventsController: eventController,
      viewConfiguration: currentConfiguration,
      tileBuilder: (event, configuration) => const SizedBox(),
      style: const CalendarStyle(
        backgroundColor: Colors.pink,
      ),
      multiDayTileBuilder: _multiDayTileBuilder,
      scheduleTileBuilder: _scheduleTileBuilder,
      components: CalendarComponents(
        calendarHeaderBuilder: (range) => _calendarHeader(range, controller.visibleMonth!),
        monthCellHeaderBuilder: (date, onTapped) {
          if (controller.visibleMonth case final month?) {
            if (month.month == date.month && month.year == date.year) {
              return Row(
                children: [
                  const Spacer(),
                  Text(
                    date.day.toString(),
                    style: const TextStyle(color: Colors.yellow),
                  ),
                ],
              );
            }
          }
          return Text(
            date.day.toString(),
            style: TextStyle(color: Colors.pink.shade100),
          );
        },
      ),
      eventHandlers: const CalendarEventHandlers(
          // onEventTapped: _onEventTapped,
          ),
    );

    return SafeArea(
      child: Scaffold(
        body: calendar,
      ),
    );
  }

  CalendarEvent<Event> _onCreateEvent(DateTimeRange dateTimeRange) {
    return CalendarEvent(
      dateTimeRange: dateTimeRange,
      eventData: Event(
        title: 'New Event',
      ),
    );
  }

  Future<void> _onEventCreated(CalendarEvent<Event> event) async {
    // Add the event to the events controller.
    eventController.addEvent(event);

    // Deselect the event.
    eventController.deselectEvent();
  }

  Future<void> _onEventTapped(
    CalendarEvent<Event> event,
  ) async {
    if (isMobile) {
      eventController.selectedEvent == event ? eventController.deselectEvent() : eventController.selectEvent(event);
    }
  }

  Future<void> _onEventChanged(
    DateTimeRange initialDateTimeRange,
    CalendarEvent<Event> event,
  ) async {
    if (isMobile) {
      eventController.deselectEvent();
    }
  }

  Widget _multiDayTileBuilder(
    CalendarEvent<Event> event,
    MultiDayTileConfiguration configuration,
  ) {
    final color = event.eventData?.color ?? Colors.blue;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      elevation: configuration.tileType == TileType.selected ? 8 : 0,
      color: configuration.tileType == TileType.ghost ? color.withAlpha(100) : color,
      child: Center(
        child: configuration.tileType != TileType.ghost ? Text((event.eventData?.title?.replaceAll('e', 'dupa')) ?? 'New Event') : null,
      ),
    );
  }

  Widget _scheduleTileBuilder(CalendarEvent<Event> event, DateTime date) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: event.eventData?.color ?? Colors.blue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(event.eventData?.title ?? 'New Event'),
    );
  }

  Widget _calendarHeader(DateTimeRange dateTimeRange, DateTime visibleMonth) {
    return Row(
      children: [
        Text(
          intl.DateFormat('yyyy - MMMM').format(visibleMonth),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Spacer(),
        DropdownMenu(
          onSelected: (value) {
            if (value == null) return;
            setState(() {
              currentConfiguration = value;
            });
          },
          initialSelection: currentConfiguration,
          dropdownMenuEntries: viewConfigurations.map((e) => DropdownMenuEntry(value: e, label: e.name)).toList(),
        ),
        IconButton.filledTonal(
          onPressed: () {
            controller.animateToPreviousPage().then((_) {
              setState(() {});
            });
          },
          icon: const Icon(Icons.navigate_before_rounded),
        ),
        IconButton.filledTonal(
          onPressed: () {
            controller.animateToNextPage().then((_) {
              setState(() {});
            });
          },
          icon: const Icon(Icons.navigate_next_rounded),
        ),
        IconButton.filledTonal(
          onPressed: () {
            setState(() {
              controller.animateToDate(DateTime.now());
            });
          },
          icon: const Icon(Icons.today),
        ),
      ],
    );
  }

  bool get isMobile {
    return kIsWeb ? false : Platform.isAndroid || Platform.isIOS;
  }
}

class Event {
  Event({
    required this.title,
    this.description,
    this.color,
  });

  /// The title of the [Event].
  final String title;

  /// The description of the [Event].
  final String? description;

  /// The color of the [Event] tile.
  final Color? color;
}
