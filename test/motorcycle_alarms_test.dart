import 'package:flutter_test/flutter_test.dart';
import 'package:moto_mecanico/models/distance.dart';
import 'package:moto_mecanico/models/motorcycle.dart';
import 'package:moto_mecanico/models/task.dart';
import 'package:moto_mecanico/motorcycle_alarms.dart';

void main() {
  group('getDistanceAlarmLevel', () {
    late Motorcycle motorcycle;

    setUp(() {
      motorcycle = Motorcycle(
        name: 'Test Bike',
        odometer: const Distance(1000, DistanceUnit.unitKm),
      );
    });

    test('returns none when task dueOdometer is not valid', () {
      final task = Task(
        name: 'Test Task',
        dueOdometer: const Distance(null), // Invalid distance
      );

      final result = motorcycle.getDistanceAlarmLevel(task);

      expect(result, equals(TaskAlarm.none));
    });

    test('returns none when task is closed', () {
      final task = Task(
        name: 'Test Task',
        dueOdometer: const Distance(900, DistanceUnit.unitKm),
        closed: true,
      );

      final result = motorcycle.getDistanceAlarmLevel(task);

      expect(result, equals(TaskAlarm.none));
    });

    test('returns none when motorcycle odometer is not valid', () {
      final motorcycleInvalid = Motorcycle(
        name: 'Test Bike',
        odometer: const Distance(null), // Invalid odometer
      );
      final task = Task(
        name: 'Test Task',
        dueOdometer: const Distance(900, DistanceUnit.unitKm),
      );

      final result = motorcycleInvalid.getDistanceAlarmLevel(task);

      expect(result, equals(TaskAlarm.none));
    });

    test('returns red when remaining distance is at red threshold', () {
      final task = Task(
        name: 'Test Task',
        dueOdometer: const Distance(
            1000, DistanceUnit.unitKm), // Exactly at current odometer
      );

      final result = motorcycle.getDistanceAlarmLevel(task);

      expect(result, equals(TaskAlarm.red));
    });

    test('returns red when remaining distance is below red threshold', () {
      final task = Task(
        name: 'Test Task',
        dueOdometer: const Distance(950, DistanceUnit.unitKm), // 50km overdue
      );

      final result = motorcycle.getDistanceAlarmLevel(task);

      expect(result, equals(TaskAlarm.red));
    });

    test('returns yellow when remaining distance is at yellow threshold', () {
      final task = Task(
        name: 'Test Task',
        dueOdometer:
            const Distance(1200, DistanceUnit.unitKm), // 200km remaining
      );

      final result = motorcycle.getDistanceAlarmLevel(task);

      expect(result, equals(TaskAlarm.yellow));
    });

    test('returns yellow when remaining distance is below yellow threshold',
        () {
      final task = Task(
        name: 'Test Task',
        dueOdometer:
            const Distance(1100, DistanceUnit.unitKm), // 100km remaining
      );

      final result = motorcycle.getDistanceAlarmLevel(task);

      expect(result, equals(TaskAlarm.yellow));
    });

    test('returns none when remaining distance is above yellow threshold', () {
      final task = Task(
        name: 'Test Task',
        dueOdometer:
            const Distance(1300, DistanceUnit.unitKm), // 300km remaining
      );

      final result = motorcycle.getDistanceAlarmLevel(task);

      expect(result, equals(TaskAlarm.none));
    });
  });

  group('getDurationAlarmLevel', () {
    late Motorcycle motorcycle;

    setUp(() {
      motorcycle = Motorcycle(name: 'Test Bike');
    });

    test('returns none when task dueDate is null', () {
      final task = Task(
        name: 'Test Task',
        dueDate: null,
      );

      final result = motorcycle.getDurationAlarmLevel(task);

      expect(result, equals(TaskAlarm.none));
    });

    test('returns none when task is closed', () {
      final task = Task(
        name: 'Test Task',
        dueDate: DateTime.now().add(const Duration(days: 5)),
        closed: true,
      );

      final result = motorcycle.getDurationAlarmLevel(task);

      expect(result, equals(TaskAlarm.none));
    });

    test('returns red when task is overdue', () {
      final task = Task(
        name: 'Test Task',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      );

      final result = motorcycle.getDurationAlarmLevel(task);

      expect(result, equals(TaskAlarm.red));
    });

    test('returns yellow when task is due today at end of day', () {
      final task = Task(
        name: 'Test Task',
        dueDate: DateTime.now(),
      );

      final result = motorcycle.getDurationAlarmLevel(task);

      // Should be yellow since we add 23:59 to the due date
      expect(result, equals(TaskAlarm.yellow));
    });

    test('returns yellow when task is due within 14 days', () {
      final task = Task(
        name: 'Test Task',
        dueDate: DateTime.now().add(const Duration(days: 10)),
      );

      final result = motorcycle.getDurationAlarmLevel(task);

      expect(result, equals(TaskAlarm.yellow));
    });

    test('returns yellow when task is due within yellow threshold', () {
      // The algorithm adds 23:59:59 to the due date, so we need to account for that.
      // For a task to be at the yellow threshold, the remaining time after adding
      // 23:59:59 should be exactly 14 days.
      final task = Task(
        name: 'Test Task',
        dueDate: DateTime.now()
            .add(const Duration(days: 13, hours: 0, minutes: 0, seconds: 1)),
      );

      final result = motorcycle.getDurationAlarmLevel(task);

      expect(result, equals(TaskAlarm.yellow));
    });

    test('returns none when task is due more than 14 days away', () {
      final task = Task(
        name: 'Test Task',
        dueDate: DateTime.now().add(const Duration(days: 20)),
      );

      final result = motorcycle.getDurationAlarmLevel(task);

      expect(result, equals(TaskAlarm.none));
    });
  });

  group('getAlarmLevel', () {
    late Motorcycle motorcycle;

    setUp(() {
      motorcycle = Motorcycle(
        name: 'Test Bike',
        odometer: const Distance(1000, DistanceUnit.unitKm),
      );
    });

    test('returns red when distance alarm is red', () {
      final task = Task(
        name: 'Test Task',
        dueOdometer: const Distance(900, DistanceUnit.unitKm), // Red distance
        dueDate: DateTime.now().add(const Duration(days: 30)), // Green duration
      );

      final result = motorcycle.getAlarmLevel(task);

      expect(result, equals(TaskAlarm.red));
    });

    test('returns red when duration alarm is red', () {
      final task = Task(
        name: 'Test Task',
        dueOdometer:
            const Distance(2000, DistanceUnit.unitKm), // Green distance
        dueDate:
            DateTime.now().subtract(const Duration(days: 1)), // Red duration
      );

      final result = motorcycle.getAlarmLevel(task);

      expect(result, equals(TaskAlarm.red));
    });

    test('returns red when both distance and duration alarms are red', () {
      final task = Task(
        name: 'Test Task',
        dueOdometer: const Distance(900, DistanceUnit.unitKm), // Red distance
        dueDate:
            DateTime.now().subtract(const Duration(days: 1)), // Red duration
      );

      final result = motorcycle.getAlarmLevel(task);

      expect(result, equals(TaskAlarm.red));
    });

    test('returns yellow when distance alarm is yellow and duration is none',
        () {
      final task = Task(
        name: 'Test Task',
        dueOdometer:
            const Distance(1100, DistanceUnit.unitKm), // Yellow distance
        dueDate: DateTime.now().add(const Duration(days: 30)), // Green duration
      );

      final result = motorcycle.getAlarmLevel(task);

      expect(result, equals(TaskAlarm.yellow));
    });

    test('returns yellow when duration alarm is yellow and distance is none',
        () {
      final task = Task(
        name: 'Test Task',
        dueOdometer:
            const Distance(2000, DistanceUnit.unitKm), // Green distance
        dueDate:
            DateTime.now().add(const Duration(days: 10)), // Yellow duration
      );

      final result = motorcycle.getAlarmLevel(task);

      expect(result, equals(TaskAlarm.yellow));
    });

    test('returns yellow when both alarms are yellow', () {
      final task = Task(
        name: 'Test Task',
        dueOdometer:
            const Distance(1100, DistanceUnit.unitKm), // Yellow distance
        dueDate:
            DateTime.now().add(const Duration(days: 10)), // Yellow duration
      );

      final result = motorcycle.getAlarmLevel(task);

      expect(result, equals(TaskAlarm.yellow));
    });

    test('returns none when both alarms are none', () {
      final task = Task(
        name: 'Test Task',
        dueOdometer:
            const Distance(2000, DistanceUnit.unitKm), // Green distance
        dueDate: DateTime.now().add(const Duration(days: 30)), // Green duration
      );

      final result = motorcycle.getAlarmLevel(task);

      expect(result, equals(TaskAlarm.none));
    });

    test('returns none when task has no due date or odometer', () {
      final task = Task(name: 'Test Task');

      final result = motorcycle.getAlarmLevel(task);

      expect(result, equals(TaskAlarm.none));
    });
  });
}
