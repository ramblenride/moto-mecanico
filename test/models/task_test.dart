import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:moto_mecanico/models/attachment.dart';
import 'package:moto_mecanico/models/cost.dart';
import 'package:moto_mecanico/models/distance.dart';
import 'package:moto_mecanico/models/note.dart';
import 'package:moto_mecanico/models/task.dart';

void main() {
  group('Task Construction', () {
    test('constructor creates valid task with required name', () {
      final task = Task(name: 'Oil Change');

      expect(task.name, equals('Oil Change'));
      expect(task.description, equals(''));
      expect(task.closed, equals(false));
      expect(task.effortLevel, equals(EffortLevel.none));
      expect(task.technicalLevel, equals(TechnicalLevel.none));
      expect(task.attachments, isEmpty);
      expect(task.costs, isEmpty);
      expect(task.labels, isEmpty);
      expect(task.notes, isEmpty);
      expect(task.id, isNotEmpty);
    });

    test('constructor with all parameters', () {
      final dueDate = DateTime(2025, 12, 31);
      final closedDate = DateTime(2025, 1, 15);
      final task = Task(
        name: 'Brake Service',
        description: 'Replace brake pads',
        closed: true,
        closedDate: closedDate,
        closedOdometer: const Distance(10000),
        dueDate: dueDate,
        dueOdometer: const Distance(15000),
        effortLevel: EffortLevel.medium,
        technicalLevel: TechnicalLevel.intermediate,
        executor: 'John Doe',
        recurringMonths: 12,
        recurringOdometer: const Distance(5000),
        labels: [1, 2, 3],
      );

      expect(task.name, equals('Brake Service'));
      expect(task.description, equals('Replace brake pads'));
      expect(task.closed, isTrue);
      expect(task.closedDate, equals(closedDate));
      expect(task.closedOdometer.distance, equals(10000));
      expect(task.dueDate, equals(dueDate));
      expect(task.dueOdometer.distance, equals(15000));
      expect(task.effortLevel, equals(EffortLevel.medium));
      expect(task.technicalLevel, equals(TechnicalLevel.intermediate));
      expect(task.executor, equals('John Doe'));
      expect(task.recurringMonths, equals(12));
      expect(task.recurringOdometer.distance, equals(5000));
      expect(task.labels, equals([1, 2, 3]));
    });

    test('each task has unique id', () {
      final task1 = Task(name: 'Task 1');
      final task2 = Task(name: 'Task 2');

      expect(task1.id, isNot(equals(task2.id)));
      expect(task1.id, isNotEmpty);
      expect(task2.id, isNotEmpty);
    });
  });

  group('Task.from Factory', () {
    test('creates copy with basic fields', () {
      final original = Task(
        name: 'Original Task',
        description: 'Description',
        effortLevel: EffortLevel.large,
        technicalLevel: TechnicalLevel.pro,
        executor: 'Jane',
        labels: [1, 2],
      );

      final copy = Task.from(original);

      expect(copy.name, equals(original.name));
      expect(copy.description, equals(original.description));
      expect(copy.effortLevel, equals(original.effortLevel));
      expect(copy.technicalLevel, equals(original.technicalLevel));
      expect(copy.executor, equals(original.executor));
      expect(copy.labels, equals([1, 2]));
      expect(copy.id, isNot(equals(original.id))); // New ID
    });

    test('copies notes, costs, attachments with copyable=true', () {
      final original = Task(
        name: 'Task',
        notes: [
          Note(name: 'Note 1', text: 'Text 1', copyable: true),
          Note(name: 'Note 2', text: 'Text 2', copyable: false),
        ],
        costs: [
          Cost(100, 'Cost 1', copyable: true),
          Cost(200, 'Cost 2', copyable: false),
        ],
        attachments: [
          Attachment(
              type: AttachmentType.link,
              url: 'http://example.com',
              name: 'Link 1',
              copyable: true),
          Attachment(
              type: AttachmentType.link,
              url: 'http://test.com',
              name: 'Link 2',
              copyable: false),
        ],
      );

      final copy = Task.from(original);

      expect(copy.notes.length, equals(1));
      expect(copy.notes[0].name, equals('Note 1'));
      expect(copy.costs.length, equals(1));
      expect(copy.costs[0].value, equals(100));
      expect(copy.attachments.length, equals(1));
      expect(copy.attachments[0].name, equals('Link 1'));
    });

    test('copies all items when ignoreCopyable is true', () {
      final original = Task(
        name: 'Task',
        notes: [
          Note(name: 'Note 1', text: 'Text 1', copyable: false),
          Note(name: 'Note 2', text: 'Text 2', copyable: false),
        ],
        costs: [
          Cost(100, 'Cost 1', copyable: false),
          Cost(200, 'Cost 2', copyable: false),
        ],
      );

      final copy = Task.from(original, ignoreCopyable: true);

      expect(copy.notes.length, equals(2));
      expect(copy.costs.length, equals(2));
    });
  });

  group('Task.fromRenew', () {
    test('returns null for non-recurring task', () {
      final task = Task(
        name: 'Non-recurring',
        recurringMonths: 0,
        recurringOdometer: const Distance(null),
      );

      final renewed = Task.fromRenew(task);
      expect(renewed, isNull);
    });

    test('renews task with recurring months', () {
      final closedDate = DateTime(2025, 1, 1);
      final task = Task(
        name: 'Oil Change',
        description: 'Change oil',
        closed: true,
        closedDate: closedDate,
        closedOdometer: const Distance(10000),
        recurringMonths: 6,
        labels: [1],
        costs: [Cost(50, 'Oil', copyable: true)],
      );

      final renewed = Task.fromRenew(task)!;

      expect(renewed.name, equals('Oil Change'));
      expect(renewed.closed, isFalse);
      expect(renewed.closedDate, isNull);
      expect(renewed.closedOdometer.distance, isNull);
      expect(renewed.dueDate, equals(DateTime(2025, 7, 1)));
      expect(renewed.costs.length, equals(1));
    });

    test('renews task with large recurring months', () {
      final closedDate = DateTime(2025, 1, 1);
      final task = Task(
        name: 'Oil Change',
        description: 'Change oil',
        closed: true,
        closedDate: closedDate,
        closedOdometer: const Distance(10000),
        recurringMonths: 18,
        labels: [1],
        costs: [Cost(50, 'Oil', copyable: true)],
      );

      final renewed = Task.fromRenew(task)!;

      expect(renewed.name, equals('Oil Change'));
      expect(renewed.closed, isFalse);
      expect(renewed.closedDate, isNull);
      expect(renewed.closedOdometer.distance, isNull);
      expect(renewed.dueDate, equals(DateTime(2026, 7, 1)));
      expect(renewed.costs.length, equals(1));
    });

    test('renews task with recurring odometer', () {
      final task = Task(
        name: 'Tire Rotation',
        closed: true,
        closedOdometer: const Distance(10000),
        recurringOdometer: const Distance(5000),
      );

      final renewed = Task.fromRenew(task)!;

      expect(renewed.closed, isFalse);
      expect(renewed.dueOdometer.distance, equals(15000));
      expect(renewed.closedOdometer.distance, isNull);
    });

    test('renews task with both time and distance recurrence', () {
      final closedDate = DateTime(2025, 1, 1);
      final task = Task(
        name: 'Service',
        closed: true,
        closedDate: closedDate,
        closedOdometer: const Distance(8000),
        recurringMonths: 12,
        recurringOdometer: const Distance(10000),
      );

      final renewed = Task.fromRenew(task)!;

      expect(renewed.dueDate, equals(DateTime(2026, 1, 1)));
      expect(renewed.dueOdometer.distance, equals(18000));
    });
  });

  group('Task Properties', () {
    test('cost returns total of all costs', () {
      final task = Task(
        name: 'Task',
        costs: [
          Cost(100, 'Part 1'),
          Cost(50, 'Part 2'),
          Cost(25, 'Labor'),
        ],
      );

      expect(task.cost.value, equals(175));
    });

    test('recurring returns true when has recurring months', () {
      final task = Task(name: 'Task', recurringMonths: 6);
      expect(task.recurring, isTrue);
    });

    test('recurring returns true when has recurring odometer', () {
      final task = Task(
        name: 'Task',
        recurringOdometer: const Distance(5000),
      );
      expect(task.recurring, isTrue);
    });

    test('recurring returns false when no recurrence', () {
      final task = Task(name: 'Task');
      expect(task.recurring, isFalse);
    });
  });

  group('Task Sorting', () {
    test('sorting tasks by odometer, null goes last', () {
      final task1 = Task(name: '1', dueOdometer: const Distance(100));
      final task2 = Task(name: '2', dueOdometer: const Distance(null));
      final task3 =
          Task(name: '3', dueOdometer: const Distance(2, DistanceUnit.unitKm));
      final task4 = Task(
          name: '4', dueOdometer: const Distance(2, DistanceUnit.unitMile));

      final tasks = [task1, task2, task3, task4];
      tasks.sort();
      expect(tasks, equals([task3, task4, task1, task2]));
    });

    test('sorting tasks by date, null goes last', () {
      final task1 =
          Task(name: '1', dueDate: DateTime.now().add(const Duration(days: 5)));
      final task2 = Task(name: '2', dueDate: null);
      final task3 = Task(name: '3', dueDate: DateTime.now());

      final tasks = [task1, task2, task3];
      tasks.sort();
      expect(tasks, equals([task3, task1, task2]));
    });

    test('sorting tasks with distance and date', () {
      const odometer = Distance(1200);
      final task1 = Task(
          name: '1',
          dueDate: DateTime.now().add(const Duration(days: 365))); // Far future
      final task2 = Task(name: '2'); // Not scheduled
      final task3 = Task(name: '3', dueDate: DateTime.now()); // Today
      final task4 = Task(
          name: '4', dueOdometer: odometer + const Distance(5)); // Near future
      final task5 = Task(
          name: '5', dueOdometer: const Distance(100)); // The past (odometer)
      final task6 = Task(
          name: '6',
          dueDate: DateTime.now()
              .subtract(const Duration(days: 100))); // The past (date)

      final tasks = [task1, task2, task3, task4, task5, task6];
      tasks.sort((a, b) {
        return a.compareTimeAndDistance(b, odometer: const Distance(1200));
      });

      expect(tasks, equals([task6, task5, task3, task4, task1, task2]));
    });

    test('compareTo uses compareTimeAndDistance', () {
      final task1 = Task(name: '1', dueDate: DateTime.now());
      final task2 =
          Task(name: '2', dueDate: DateTime.now().add(const Duration(days: 5)));

      expect(task1.compareTo(task2), equals(-1));
      expect(task2.compareTo(task1), equals(1));
      expect(task1.compareTo(task1), equals(0));
    });
  });

  group('Task.matches', () {
    test('returns true for empty search string', () {
      final task = Task(name: 'Task');
      expect(task.matches(''), isTrue);
    });

    test('matches task name', () {
      final task = Task(name: 'Oil Change');
      expect(task.matches('oil'), isTrue);
      expect(task.matches('OIL'), isTrue);
      expect(task.matches('change'), isTrue);
      expect(task.matches('brake'), isFalse);
    });

    test('matches task description', () {
      final task = Task(name: 'Task', description: 'Replace brake pads');
      expect(task.matches('brake'), isTrue);
      expect(task.matches('PADS'), isTrue);
      expect(task.matches('oil'), isFalse);
    });

    test('matches executor', () {
      final task = Task(name: 'Task', executor: 'John Doe');
      expect(task.matches('john'), isTrue);
      expect(task.matches('DOE'), isTrue);
      expect(task.matches('jane'), isFalse);
    });

    test('matches attachment names', () {
      final task = Task(
        name: 'Task',
        attachments: [
          Attachment(
              type: AttachmentType.link,
              url: 'http://example.com',
              name: 'Manual'),
        ],
      );
      expect(task.matches('manual'), isTrue);
      expect(task.matches('guide'), isFalse);
    });

    test('matches cost descriptions', () {
      final task = Task(
        name: 'Task',
        costs: [Cost(100, 'Brake fluid')],
      );
      expect(task.matches('fluid'), isTrue);
      expect(task.matches('oil'), isFalse);
    });

    test('matches note text', () {
      final task = Task(
        name: 'Task',
        notes: [Note(name: 'Note', text: 'Important reminder')],
      );
      expect(task.matches('reminder'), isTrue);
      expect(task.matches('IMPORTANT'), isTrue);
      expect(task.matches('urgent'), isFalse);
    });

    test('matches note name', () {
      final task = Task(
        name: 'Task',
        notes: [Note(name: 'Service History', text: 'Details')],
      );
      expect(task.matches('history'), isTrue);
      expect(task.matches('details'), isTrue);
    });
  });

  group('Task JSON Serialization', () {
    test('JSON round trip with minimal fields', () {
      final task = Task(name: 'Simple Task');
      final json = task.toJson();
      final parsed = Task.fromJson(json);

      expect(parsed.name, equals('Simple Task'));
      expect(parsed.description, equals(''));
      expect(parsed.closed, equals(false));
    });

    test('JSON round trip with all fields', () {
      final dueDate = DateTime(2025, 12, 31);
      final closedDate = DateTime(2025, 1, 15);
      final task = Task(
        name: 'Complete Task',
        description: 'Full description',
        closed: true,
        closedDate: closedDate,
        closedOdometer: const Distance(10000),
        dueDate: dueDate,
        dueOdometer: const Distance(15000),
        effortLevel: EffortLevel.large,
        technicalLevel: TechnicalLevel.pro,
        executor: 'Technician',
        recurringMonths: 12,
        recurringOdometer: const Distance(5000),
        labels: [1, 2, 3],
        notes: [Note(name: 'Note', text: 'Text')],
        costs: [Cost(100, 'Cost')],
        attachments: [
          Attachment(type: AttachmentType.link, url: 'http://example.com'),
        ],
      );

      final json = jsonDecode(jsonEncode(task.toJson()));
      final parsed = Task.fromJson(json);

      expect(parsed.name, equals('Complete Task'));
      expect(parsed.description, equals('Full description'));
      expect(parsed.closed, isTrue);
      expect(parsed.closedDate, equals(closedDate));
      expect(parsed.closedOdometer.distance, equals(10000));
      expect(parsed.dueDate, equals(dueDate));
      expect(parsed.dueOdometer.distance, equals(15000));
      expect(parsed.effortLevel, equals(EffortLevel.large));
      expect(parsed.technicalLevel, equals(TechnicalLevel.pro));
      expect(parsed.executor, equals('Technician'));
      expect(parsed.recurringMonths, equals(12));
      expect(parsed.recurringOdometer.distance, equals(5000));
      expect(parsed.labels, equals([1, 2, 3]));
      expect(parsed.notes.length, equals(1));
      expect(parsed.costs.length, equals(1));
      expect(parsed.attachments.length, equals(1));
    });

    test('fromJson throws for invalid JSON', () {
      expect(() => Task.fromJson({}), throwsArgumentError);
    });

    test('toJson handles all EffortLevel values', () {
      final tasks = [
        Task(name: 'None', effortLevel: EffortLevel.none),
        Task(name: 'Small', effortLevel: EffortLevel.small),
        Task(name: 'Medium', effortLevel: EffortLevel.medium),
        Task(name: 'Large', effortLevel: EffortLevel.large),
      ];

      final json0 = tasks[0].toJson();
      final json1 = tasks[1].toJson();
      final json2 = tasks[2].toJson();
      final json3 = tasks[3].toJson();

      expect(json0.containsKey('effortLevel'), isFalse);
      expect(json1['effortLevel'], equals('small'));
      expect(json2['effortLevel'], equals('medium'));
      expect(json3['effortLevel'], equals('large'));

      expect(Task.fromJson(json1).effortLevel, equals(EffortLevel.small));
      expect(Task.fromJson(json2).effortLevel, equals(EffortLevel.medium));
      expect(Task.fromJson(json3).effortLevel, equals(EffortLevel.large));
    });

    test('toJson handles all TechnicalLevel values', () {
      final tasks = [
        Task(name: 'None', technicalLevel: TechnicalLevel.none),
        Task(name: 'Easy', technicalLevel: TechnicalLevel.easy),
        Task(name: 'Intermediate', technicalLevel: TechnicalLevel.intermediate),
        Task(name: 'Pro', technicalLevel: TechnicalLevel.pro),
      ];

      final json0 = tasks[0].toJson();
      final json1 = tasks[1].toJson();
      final json2 = tasks[2].toJson();
      final json3 = tasks[3].toJson();

      expect(json0.containsKey('technicalLevel'), isFalse);
      expect(json1['technicalLevel'], equals('easy'));
      expect(json2['technicalLevel'], equals('intermediate'));
      expect(json3['technicalLevel'], equals('pro'));

      expect(Task.fromJson(json1).technicalLevel, equals(TechnicalLevel.easy));
      expect(Task.fromJson(json2).technicalLevel,
          equals(TechnicalLevel.intermediate));
      expect(Task.fromJson(json3).technicalLevel, equals(TechnicalLevel.pro));
    });

    test('fromJson handles invalid enum values', () {
      final json = {
        'name': 'Task',
        'effortLevel': 'invalid',
        'technicalLevel': 'unknown',
      };

      final task = Task.fromJson(json);

      expect(task.effortLevel, equals(EffortLevel.none));
      expect(task.technicalLevel, equals(TechnicalLevel.none));
    });

    test('fromJson handles null dates gracefully', () {
      final json = {
        'name': 'Task',
        'dueDate': null,
        'closedDate': null,
      };

      final task = Task.fromJson(json);

      expect(task.dueDate, isNull);
      expect(task.closedDate, isNull);
    });

    test('JSON serialization preserves empty lists', () {
      final task = Task(
        name: 'Task',
        notes: [],
        costs: [],
        attachments: [],
        labels: [],
      );

      final json = task.toJson();
      final parsed = Task.fromJson(json);

      expect(parsed.notes, isEmpty);
      expect(parsed.costs, isEmpty);
      expect(parsed.attachments, isEmpty);
      expect(parsed.labels, isEmpty);
    });
  });
}
