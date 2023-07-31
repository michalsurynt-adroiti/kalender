import 'package:flutter/material.dart';
import 'package:kalender/src/extentions.dart';
import 'package:kalender/src/models/calendar/calendar_model_export.dart';
import 'package:kalender/src/providers/calendar_internals.dart';

class DayTileGestureDetector<T extends Object?> extends StatefulWidget {
  const DayTileGestureDetector({
    super.key,
    required this.child,
    required this.event,
    required this.visibleDateTimeRange,
    required this.verticalDurationStep,
    required this.verticalStep,
    required this.horizontalDurationStep,
    required this.horizontalStep,
    required this.snapPoints,
    required this.eventSnapping,
  });
  final Widget child;

  final DateTimeRange visibleDateTimeRange;

  final CalendarEvent<T> event;

  /// The duration of the vertical step when dragging/resizing an event.
  final Duration verticalDurationStep;
  final double verticalStep;

  /// The duration of the horizontal step when dragging an event.
  final Duration? horizontalDurationStep;
  final double? horizontalStep;

  final List<DateTime> snapPoints;
  final bool eventSnapping;

  @override
  State<DayTileGestureDetector<T>> createState() => _DayTileGestureDetectorState<T>();
}

class _DayTileGestureDetectorState<T> extends State<DayTileGestureDetector<T>> {
  late CalendarEvent<T> event;
  late DateTimeRange initialDateTimeRange;
  late List<DateTime> snapPoints;
  late bool eventSnapping;

  Offset cursorOffset = Offset.zero;
  int currentVerticalSteps = 0;
  int currentHorizontalSteps = 0;

  @override
  void initState() {
    super.initState();
    event = widget.event;
    initialDateTimeRange = event.dateTimeRange;
    snapPoints = widget.snapPoints;
  }

  @override
  void didUpdateWidget(covariant DayTileGestureDetector<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    snapPoints = widget.snapPoints;
    eventSnapping = widget.eventSnapping;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onPanStart: isMobileDevice ? null : _onPanStart,
        onPanUpdate: isMobileDevice ? null : _onPanUpdate,
        onPanEnd: isMobileDevice ? null : _onPanEnd,
        onLongPressStart: isMobileDevice ? _onLongPressStart : null,
        onLongPressMoveUpdate: isMobileDevice ? _onLongPressMoveUpdate : null,
        onLongPressEnd: isMobileDevice ? _onLongPressEnd : null,
        onTap: _onTap,
        child: widget.child,
      ),
    );
  }

  void _onTap() {
    // Set the changing event.
    controller.chaningEvent = event;
    controller.isMoving = true;

    // Call the onEventTapped function.
    functions.onEventTapped?.call(controller.chaningEvent!);

    // Reset the changing event.
    controller.isMoving = false;
    controller.chaningEvent = null;
  }

  void _onPanStart(DragStartDetails details) {
    _onRescheduleStart();
    controller.isMoving = true;
    controller.chaningEvent = event;
    initialDateTimeRange = event.dateTimeRange;
  }

  void _onPanEnd(DragEndDetails details) {
    _onRescheduleEnd();
    functions.onEventChanged?.call(initialDateTimeRange, controller.chaningEvent!);
    controller.chaningEvent = null;
    controller.isMoving = false;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _onReschedule(cursorOffset += details.delta);
  }

  void _onLongPressStart(LongPressStartDetails details) {
    _onRescheduleStart();
    controller.isMoving = true;
    controller.chaningEvent = event;
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    _onRescheduleEnd();
    functions.onEventChanged?.call(initialDateTimeRange, controller.chaningEvent!);
    controller.chaningEvent = null;
    controller.isMoving = false;
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    _onReschedule(details.offsetFromOrigin);
  }

  void _onRescheduleStart() {
    initialDateTimeRange = widget.visibleDateTimeRange;
    cursorOffset = Offset.zero;
    currentVerticalSteps = 0;
    currentHorizontalSteps = 0;
  }

  void _onRescheduleEnd() {
    cursorOffset = Offset.zero;
    currentVerticalSteps = 0;
    currentHorizontalSteps = 0;
  }

  void _onReschedule(Offset cursorOffset) {
    int verticalSteps = (cursorOffset.dy / widget.verticalStep).round();
    if (verticalSteps != currentVerticalSteps) {
      currentVerticalSteps = verticalSteps;
    }

    int horizontalSteps = 0;
    Duration horizontalDurationDelta = const Duration();
    if (widget.horizontalStep != null) {
      horizontalSteps = (cursorOffset.dx / widget.horizontalStep!).round();
      if (horizontalSteps != currentHorizontalSteps) {
        currentHorizontalSteps = horizontalSteps;
      }
      horizontalDurationDelta = widget.horizontalDurationStep! * horizontalSteps;
    }

    DateTime newStart = initialDateTimeRange.start
        .add(horizontalDurationDelta)
        .add(widget.verticalDurationStep * verticalSteps);

    DateTime newEnd = initialDateTimeRange.end
        .add(horizontalDurationDelta)
        .add(widget.verticalDurationStep * verticalSteps);

    int startIndex = snapPoints.indexWhere(
      (DateTime element) => element.difference(newStart).abs() <= const Duration(minutes: 15),
    );

    int endIndex = snapPoints.indexWhere(
      (DateTime element) => element.difference(newEnd).abs() <= const Duration(minutes: 15),
    );

    if (startIndex != -1) {
      newStart = snapPoints[startIndex];
      newEnd = newStart.add(initialDateTimeRange.duration);
    } else if (endIndex != -1) {
      newEnd = snapPoints[endIndex];
      newStart = newEnd.subtract(initialDateTimeRange.duration);
    }

    DateTimeRange newDateTimeRange = DateTimeRange(
      start: newStart,
      end: newEnd,
    );

    if (newDateTimeRange.start.isWithin(widget.visibleDateTimeRange) ||
        newDateTimeRange.end.isWithin(widget.visibleDateTimeRange)) {
      controller.chaningEvent!.dateTimeRange = newDateTimeRange;
    }
  }

  bool get isMobileDevice => CalendarInternals.of<T>(context).configuration.isMobileDevice;

  CalendarInternals<T> get internals => CalendarInternals.of<T>(context);
  CalendarController<T> get controller => internals.controller;
  CalendarFunctions<T> get functions => internals.functions;
}