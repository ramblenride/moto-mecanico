import 'package:flutter/foundation.dart';
import 'package:moto_mecanico/models/distance.dart';
import 'package:moto_mecanico/models/task.dart';

class MotorcycleTemplate {
  String description;
  String name;
  List<TaskTemplate> tasks;

  MotorcycleTemplate({
    required this.description,
    required this.name,
    required this.tasks,
  });

  static MotorcycleTemplate? fromJson(Map<String, dynamic> json) {
    var tasks = <TaskTemplate>[];
    if (json['tasks'] != null) {
      json['tasks'].forEach((v) {
        final task = TaskTemplate.fromJson(v);
        if (task != null &&
            (task.name.isNotEmpty) &&
            (task.description.isNotEmpty)) {
          tasks.add(task);
        }
      });
    }

    return MotorcycleTemplate(
        description: json['description'], name: json['name'], tasks: tasks);
  }
}

class TaskTemplate {
  String description;
  Distance distance;
  Distance intervalDistance;
  int intervalMonths;
  List<TaskLink> links;
  int months;
  String name;
  String notes;
  TechnicalLevel technicalLevel;

  TaskTemplate({
    required this.description,
    required this.name,
    this.distance = const Distance(null, DistanceUnit.UnitKM),
    this.intervalDistance = const Distance(null, DistanceUnit.UnitKM),
    this.intervalMonths = 0,
    this.links = const [],
    this.months = 0,
    this.notes = '',
    this.technicalLevel = TechnicalLevel.none,
  });

  static TaskTemplate? fromJson(Map<String, dynamic> json) {
    try {
      var links = <TaskLink>[];
      if (json['links'] != null) {
        json['links'].forEach((v) {
          final link = TaskLink.fromJson(v);
          if (link != null && link.name.isNotEmpty && link.url.isNotEmpty) {
            links.add(link);
          }
        });

        return TaskTemplate(
            description: json['description'],
            distance: Distance(json['km'], DistanceUnit.UnitKM),
            intervalDistance: Distance(json['interalKm'], DistanceUnit.UnitKM),
            intervalMonths: json['intervalMonths'],
            months: json['months'],
            name: json['name'],
            notes: json['notes'] ?? '',
            technicalLevel: _parseTechnicalLevel(json['technicalLevel']),
            links: links);
      }
    } catch (e) {
      debugPrint('Failed to parse task template from JSON');
      debugPrint(e.toString());
    }
    return null;
  }

  static TechnicalLevel _parseTechnicalLevel(String levelStr) {
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
}

class TaskLink {
  String name;
  String url;

  TaskLink({
    required this.name,
    required this.url,
  });

  static TaskLink? fromJson(Map<String, dynamic> json) {
    try {
      return TaskLink(name: json['name'], url: json['url']);
    } catch (e) {
      debugPrint('Failed to parse JSON link');
      debugPrint(e.toString());
      return null;
    }
  }
}

class MotorcycleTemplates {
  List<MotorcycleTemplate> templates;

  MotorcycleTemplates({
    this.templates = const [],
  });

  MotorcycleTemplates.fromJson(Map<String, dynamic> json)
      : templates = <MotorcycleTemplate>[] {
    if (json['motorcycles'] != null) {
      json['motorcycles'].forEach((m) {
        try {
          final moto = MotorcycleTemplate.fromJson(m);
          if (moto != null &&
              (moto.name.isNotEmpty) &&
              (moto.description.isNotEmpty)) {
            templates.add(moto);
          }
        } catch (e) {
          debugPrint('Failed to parse motorcycle task template');
          debugPrint(e.toString());
        }
      });
    }
  }
}
