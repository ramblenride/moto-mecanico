import 'package:flutter/foundation.dart';
import 'package:moto_mecanico/models/distance.dart';
import 'package:moto_mecanico/models/task.dart';

class MotorcycleTemplate {
  String description;
  String name;
  List<TaskTemplate> tasks;

  MotorcycleTemplate({
    @required this.description,
    @required this.name,
    @required this.tasks,
  })  : assert(name != null),
        assert(description != null),
        assert(tasks != null);

  MotorcycleTemplate.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    name = json['name'];
    if (json['tasks'] != null) {
      tasks = <TaskTemplate>[];
      json['tasks'].forEach((v) {
        final task = TaskTemplate.fromJson(v);
        if (task != null &&
            (task.name?.isNotEmpty ?? false) &&
            (task.description?.isNotEmpty ?? false)) {
          tasks.add(task);
        }
      });
    }
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
    @required this.description,
    @required this.name,
    this.distance = const Distance(null, DistanceUnit.UnitKM),
    this.intervalDistance = const Distance(null, DistanceUnit.UnitKM),
    this.intervalMonths,
    this.links = const [],
    this.months,
    this.notes = '',
    this.technicalLevel,
  })  : assert(description != null),
        assert(name != null);

  TaskTemplate.fromJson(Map<String, dynamic> json) {
    try {
      description = json['description'];
      distance = Distance(json['km'], DistanceUnit.UnitKM);
      intervalDistance = Distance(json['intervalKm'], DistanceUnit.UnitKM);
      intervalMonths = json['intervalMonths'];
      months = json['months'];
      name = json['name'];
      notes = json['notes'] ?? '';
      technicalLevel = _parseTechnicalLevel(json['technicalLevel']);

      if (json['links'] != null) {
        links = <TaskLink>[];
        json['links'].forEach((v) {
          final link = TaskLink.fromJson(v);
          if (link != null && link.name != null && link.url != null) {
            links.add(link);
          }
        });
      }
    } catch (e) {
      debugPrint('Failed to parse task template from JSON');
      debugPrint(e.toString());
      name = null;
      description = null;
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
        return null;
    }
  }
}

class TaskLink {
  String name;
  String url;

  TaskLink({
    @required this.name,
    @required this.url,
  })  : assert(name != null),
        assert(url != null);

  TaskLink.fromJson(Map<String, dynamic> json) {
    try {
      name = json['name'];
      url = json['url'];
    } catch (e) {
      debugPrint('Failed to parse JSON link');
      debugPrint(e.toString());
    }
  }
}

class MotorcycleTemplates {
  List<MotorcycleTemplate> templates;

  MotorcycleTemplates({
    this.templates = const [],
  });

  MotorcycleTemplates.fromJson(Map<String, dynamic> json) {
    templates = <MotorcycleTemplate>[];
    if (json['motorcycles'] != null) {
      json['motorcycles'].forEach((m) {
        try {
          final moto = MotorcycleTemplate.fromJson(m);
          if (moto != null &&
              (moto.name?.isNotEmpty ?? false) &&
              (moto.description?.isNotEmpty ?? false)) {
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
