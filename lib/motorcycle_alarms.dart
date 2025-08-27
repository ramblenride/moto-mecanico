import 'package:moto_mecanico/models/distance.dart';
import 'package:moto_mecanico/models/motorcycle.dart';
import 'package:moto_mecanico/models/task.dart';

const alarmDistanceYellow = Distance(200);
const alarmDistanceRed = Distance(0);

const alarmDurationYellow = Duration(days: 14);
const alarmDurationRed = Duration(days: 0);

enum TaskAlarm { none, yellow, red }

extension MotoAlarmExt on Motorcycle {
  TaskAlarm getDistanceAlarmLevel(Task task) {
    if (!task.dueOdometer.isValid || task.closed || !odometer.isValid) {
      return TaskAlarm.none;
    }

    final remaining = task.dueOdometer - odometer;
    if (remaining <= alarmDistanceRed) {
      return TaskAlarm.red;
    } else if (remaining <= alarmDistanceYellow) {
      return TaskAlarm.yellow;
    }

    return TaskAlarm.none;
  }

  TaskAlarm getDurationAlarmLevel(Task task) {
    if (task.dueDate == null || task.closed) {
      return TaskAlarm.none;
    }
    final remaining = task.dueDate!
        // Use the end of day as due date
        .add(const Duration(hours: 23, minutes: 59, seconds: 59))
        .difference(DateTime.now());

    if (remaining <= alarmDurationRed) {
      return TaskAlarm.red;
    } else if (remaining <= alarmDurationYellow) {
      return TaskAlarm.yellow;
    }

    return TaskAlarm.none;
  }

  TaskAlarm getAlarmLevel(Task task) {
    final distance = getDistanceAlarmLevel(task);
    final duration = getDurationAlarmLevel(task);
    if (distance == TaskAlarm.red || duration == TaskAlarm.red) {
      return TaskAlarm.red;
    }
    if (distance == TaskAlarm.yellow || duration == TaskAlarm.yellow) {
      return TaskAlarm.yellow;
    }

    return TaskAlarm.none;
  }

  List<Task> getRedAlerts() {
    return tasks.where((task) => getAlarmLevel(task) == TaskAlarm.red).toList();
  }

  List<Task> getYellowAlerts() {
    return tasks
        .where((task) => getAlarmLevel(task) == TaskAlarm.yellow)
        .toList();
  }

  List<Task> getAlerts() {
    return tasks
        .where((task) => getAlarmLevel(task) != TaskAlarm.none)
        .toList();
  }
}
