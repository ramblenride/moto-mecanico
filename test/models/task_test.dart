import 'package:flutter_test/flutter_test.dart';
import 'package:moto_mecanico/models/distance.dart';
import 'package:moto_mecanico/models/task.dart';

void main() {
  test('sorting tasks by odometer, null goes last', () {
    final task1 = Task(name: '1', dueOdometer: Distance(100));
    final task2 = Task(name: '2', dueOdometer: Distance(null));
    final task3 =
        Task(name: '3', dueOdometer: Distance(2, DistanceUnit.UnitKM));
    final task4 =
        Task(name: '4', dueOdometer: Distance(2, DistanceUnit.UnitMile));

    final tasks = [task1, task2, task3, task4];
    tasks.sort();
    expect(tasks, equals([task3, task4, task1, task2]));
  });

  test('sorting tasks by date, null goes last', () {
    final task1 =
        Task(name: '1', dueDate: DateTime.now().add(Duration(days: 5)));
    final task2 = Task(name: '2', dueDate: null);
    final task3 = Task(name: '3', dueDate: DateTime.now());

    final tasks = [task1, task2, task3];
    tasks.sort();
    expect(tasks, equals([task3, task1, task2]));
  });

  test('sorting tasks with distance and date', () {
    final odometer = Distance(1200);
    final task1 = Task(
        name: '1',
        dueDate: DateTime.now().add(Duration(days: 365))); // Far future
    final task2 = Task(name: '2'); // Not scheduled
    final task3 = Task(name: '3', dueDate: DateTime.now()); // Today
    final task4 =
        Task(name: '4', dueOdometer: odometer + Distance(5)); // Near future
    final task5 =
        Task(name: '5', dueOdometer: Distance(100)); // The past (odometer)
    final task6 = Task(
        name: '6',
        dueDate:
            DateTime.now().subtract(Duration(days: 100))); // The past (date)

    final tasks = [task1, task2, task3, task4, task5, task6];
    tasks.sort((a, b) {
      return a.compareTo(b, odometer: Distance(1200));
    });

    expect(tasks, equals([task6, task5, task3, task4, task1, task2]));
  });
}
