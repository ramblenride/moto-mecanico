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

  factory MotorcycleTemplate.fromJson(Map<String, dynamic> json) {
    var tasks = <TaskTemplate>[];
    if (json['tasks'] != null) {
      json['tasks'].forEach((v) {
        try {
          final task = TaskTemplate.fromJson(v);
          if (task.name.isNotEmpty) {
            tasks.add(task);
          }
        } catch (e) {
          debugPrint('Failed to parse task template from JSON: $e');
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
    this.distance = const Distance(null, DistanceUnit.unitKm),
    this.intervalDistance = const Distance(null, DistanceUnit.unitKm),
    this.intervalMonths = 0,
    this.links = const [],
    this.months = 0,
    this.notes = '',
    this.technicalLevel = TechnicalLevel.none,
  });

  factory TaskTemplate.fromJson(Map<String, dynamic> json) {
    final links = <TaskLink>[];
    if (json['links'] != null) {
      json['links'].forEach((v) {
        try {
          final link = TaskLink.fromJson(v);
          if (link.name.isNotEmpty && link.url.isNotEmpty) {
            links.add(link);
          }
        } catch (e) {
          debugPrint('Failed to parse JSON link: $v');
          debugPrint(e.toString());
        }
      });
    }

    return TaskTemplate(
        description: json['description'] ?? '',
        distance: Distance(json['km'], DistanceUnit.unitKm),
        intervalDistance: Distance(json['intervalKm'], DistanceUnit.unitKm),
        intervalMonths: json['intervalMonths'] ?? 0,
        months: json['months'] ?? 0,
        name: json['name'],
        notes: json['notes'] ?? '',
        technicalLevel: _parseTechnicalLevel(json['technicalLevel'] ?? ''),
        links: links);
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

  factory TaskLink.fromJson(Map<String, dynamic> json) =>
      TaskLink(name: json['name'], url: json['url']);
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
          if (moto.name.isNotEmpty && (moto.description.isNotEmpty)) {
            templates.add(moto);
          }
        } catch (e) {
          debugPrint('Failed to parse motorcycle task template: $m ');
          debugPrint(e.toString());
        }
      });
    }
  }
}
