import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:moto_mecanico/models/attachment.dart';
import 'package:moto_mecanico/models/cost.dart';
import 'package:moto_mecanico/models/distance.dart';
import 'package:moto_mecanico/models/note.dart';
import 'package:moto_mecanico/storage/storage.dart';
import 'package:uuid/uuid.dart';

enum TechnicalLevel { none, easy, intermediate, pro }
enum EffortLevel { none, small, medium, large }

// Defines a motorcycle task. All objects are optional except for the name.
class Task implements Comparable<dynamic> {
  Task({
    @required this.name,
    this.description = '',
    this.effortLevel,
    this.technicalLevel,
    this.notes,
    this.labels,
    this.dueDate,
    this.dueOdometer = const Distance(null),
    this.recurringMonths,
    this.recurringOdometer = const Distance(null),
    this.closed = false,
    this.closedDate,
    this.closedOdometer = const Distance(null),
    this.costs,
    this.executor = '',
    this.attachments,
  }) : assert(name != null) {
    notes ??= [];
    labels ??= [];
    costs ??= [];
    attachments ??= [];
  }

  // Clones a task ignoring (or not) the costs/attachments marked as non-copyable
  // Copied attachments are not transfered to the local storage.
  Task.from(Task task, {bool ignoreCopyable = false}) {
    name = task.name;
    description = task.description;
    effortLevel = task.effortLevel;
    technicalLevel = task.technicalLevel;
    notes = [];
    labels = List<int>.from(task.labels);
    dueDate = task.dueDate;
    dueOdometer = task.dueOdometer;
    recurringMonths = task.recurringMonths;
    recurringOdometer = task.recurringOdometer;
    closed = task.closed;
    closedDate = task.closedDate;
    closedOdometer = task.closedOdometer;
    executor = task.executor;
    costs = [];
    attachments = [];

    for (final note in task.notes) {
      if (note.copyable || ignoreCopyable) {
        notes.add(Note.from(note));
      }
    }

    for (final cost in task.costs) {
      if (cost.copyable || ignoreCopyable) {
        costs.add(Cost.from(cost));
      }
    }

    for (final attachment in task.attachments) {
      if (attachment.copyable || ignoreCopyable) {
        attachments.add(Attachment.from(attachment));
      }
    }
  }

  String name; // Name / title / theme / part.
  final String id = Uuid().v4(); // Unique id
  String description; // Short description
  // The duration of the effort required.
  EffortLevel effortLevel;
  // The level of technical expertise or tools required
  TechnicalLevel technicalLevel;

  List<Note> notes;
  List<int> labels;

  DateTime dueDate;
  Distance dueOdometer;

  int recurringMonths;
  Distance recurringOdometer;

  bool closed;
  DateTime closedDate;
  Distance closedOdometer;

  List<Cost> costs;
  String executor; // Who did the work?
  List<Attachment> attachments;

  Cost get cost => Cost.total(costs, null);
  bool get recurring =>
      (recurringOdometer.isValid && recurringOdometer.distance > 0) ||
      (recurringMonths != null && recurringMonths > 0);

  @override
  int compareTo(dynamic other, {Distance odometer}) {
    assert(other != null);
    if (!(other is Task)) {
      return 0;
    }

    Task otherTask = other;

    // FIXME: Find a better way to determine this value. Based on history?
    const _DISTANCE_PER_DAY = Distance(33, DistanceUnit.UnitKM);

    var distanceThis =
        dueOdometer.toUnit(DistanceUnit.UnitKM).distance ?? 999999;
    if (odometer?.distance != null) {
      distanceThis -= odometer.toUnit(DistanceUnit.UnitKM).distance ?? 0;
    }
    final distanceDateThis = dueDate != null
        ? _DISTANCE_PER_DAY.distance *
            (dueDate.difference(DateTime.now()).inDays)
        : 999999;

    var distanceOther =
        otherTask.dueOdometer.toUnit(DistanceUnit.UnitKM).distance ?? 999999;
    if (odometer?.distance != null) {
      distanceOther -= odometer.toUnit(DistanceUnit.UnitKM).distance ?? 0;
    }
    final distanceDateOther = otherTask.dueDate != null
        ? _DISTANCE_PER_DAY.distance *
            (otherTask.dueDate.difference(DateTime.now()).inDays)
        : 999999;

    final minThis = min(distanceThis, distanceDateThis);
    final minOther = min(distanceOther, distanceDateOther);
    if (minThis < minOther) return -1;
    if (minThis == minOther) return 0;
    return 1;
  }

  bool matches(String desc) {
    assert(desc != null);
    if (desc.isEmpty) return true;

    final upperDesc = desc.toUpperCase();
    if ([
          name,
          description,
          executor,
          ...attachments.map((a) => a.name),
          ...costs.map((c) => c.description),
        ].any((item) {
          return item?.toUpperCase()?.contains(upperDesc) ?? false;
        }) ==
        true) return true;

    return notes.any((note) {
      return note.text.toUpperCase().contains(upperDesc) ||
          note.name.toUpperCase().contains(upperDesc);
    });
  }

  // Return a new task based on the information of the old task
  // Reset fields that should not be part of a new task
  factory Task.fromRenew(Task task) {
    if (task.recurring == false) return null;

    final newTask = Task.from(task);
    newTask.dueDate = null;
    newTask.dueOdometer = Distance(null);
    newTask.closed = false;
    newTask.closedDate = null;
    newTask.closedOdometer = Distance(null);

    if ((task.recurringMonths ?? 0) > 0) {
      final closedDate = task.closedDate ?? DateTime.now();
      newTask.dueDate =
          closedDate.add(Duration(days: task.recurringMonths * 30));
    }
    if (task.recurringOdometer.isValid && task.recurringOdometer.distance > 0) {
      newTask.dueOdometer = task.closedOdometer + task.recurringOdometer;
    }

    return newTask;
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    if (json != null && json['name'] != null) {
      final task = Task(
        name: json['name'],
        description: json['description'],
      );

      task.effortLevel = task._parseEffortLevel(json['effortLevel']);
      task.technicalLevel = task._parseTechnicalLevel(json['technicalLevel']);

      if (json['notes'] != null) {
        json['notes'].forEach((n) {
          final note = Note.fromJson(n);
          if (note != null) task.notes.add(note);
        });
      }
      if (json['labels'] != null) {
        json['labels'].forEach((label) => task.labels.add(label));
      }

      if (json['dueDate'] != null) {
        task.dueDate = DateTime.tryParse(json['dueDate']);
      }
      task.dueOdometer = Distance.fromJson(json['dueOdometer']);

      task.recurringOdometer = Distance.fromJson(json['recurringOdometer']);
      task.recurringMonths = json['recurringMonths'] as int;

      task.closed = json['closed'];
      if (json['closedDate'] != null) {
        task.closedDate = DateTime.tryParse(json['closedDate']);
      }
      task.closedOdometer = Distance.fromJson(json['closedOdometer']);

      if (json['costs'] != null) {
        json['costs'].forEach((cost) => task.costs.add(Cost.fromJson(cost)));
      }

      task.executor = json['executor'];

      if (json['attachments'] != null) {
        json['attachments'].forEach((attachment) =>
            task.attachments.add(Attachment.fromJson(attachment)));
      }

      return task;
    }

    return null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['description'] = description;

    if (effortLevel != null) {
      switch (effortLevel) {
        case EffortLevel.none:
          {
            break;
          }
        case EffortLevel.small:
          data['effortLevel'] = 'small';
          break;
        case EffortLevel.medium:
          data['effortLevel'] = 'medium';
          break;
        case EffortLevel.large:
          data['effortLevel'] = 'large';
          break;
      }
    }

    if (technicalLevel != null) {
      switch (technicalLevel) {
        case TechnicalLevel.none:
          {
            break;
          }
        case TechnicalLevel.easy:
          data['technicalLevel'] = 'easy';
          break;
        case TechnicalLevel.intermediate:
          data['technicalLevel'] = 'intermediate';
          break;
        case TechnicalLevel.pro:
          data['technicalLevel'] = 'pro';
          break;
      }
    }

    data['notes'] = notes.map((note) => note.toJson()).toList();
    data['labels'] = labels;

    if (dueDate != null) {
      data['dueDate'] = dueDate.toIso8601String();
    }
    data['dueOdometer'] = dueOdometer.toJson();

    data['recurringMonths'] = recurringMonths;
    data['recurringOdometer'] = recurringOdometer.toJson();

    data['closed'] = closed;
    if (closedDate != null) {
      data['closedDate'] = closedDate?.toIso8601String();
    }
    data['closedOdometer'] = closedOdometer.toJson();

    data['costs'] = costs.map((cost) => cost.toJson()).toList();
    data['executor'] = executor;
    data['attachments'] =
        attachments.map((attachment) => attachment.toJson()).toList();

    return data;
  }

  EffortLevel _parseEffortLevel(String levelStr) {
    switch (levelStr) {
      case 'small':
        return EffortLevel.small;
      case 'medium':
        return EffortLevel.medium;
      case 'large':
        return EffortLevel.large;
      default:
        return EffortLevel.none;
    }
  }

  TechnicalLevel _parseTechnicalLevel(String levelStr) {
    switch (levelStr) {
      case 'easy':
        return TechnicalLevel.easy;
      case 'intermediate':
        return TechnicalLevel.intermediate;
      case 'pro':
        return TechnicalLevel.pro;
      default:
        return TechnicalLevel.none;
    }
  }

  // Copy file/picture attachments from one storage area to another.
  static Future<void> transferAttachments(
      Task task, Storage oldStorage, Storage newStorage) async {
    final toRemove = <Attachment>[];
    final toAdd = <Attachment>[];

    for (final attachment in task.attachments) {
      if (attachment.type == AttachmentType.file ||
          attachment.type == AttachmentType.picture) {
        final origFile = await oldStorage.getFile(attachment.url);
        final url = await newStorage.addExternalFile(origFile.path);

        toAdd.add(Attachment(
          name: attachment.name,
          type: attachment.type,
          url: url,
          copyable: attachment.copyable,
        ));

        toRemove.add(attachment);
      }
    }
    toRemove.forEach(task.attachments.remove);
    toAdd.forEach(task.attachments.add);
  }
}
