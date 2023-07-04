import 'package:flutter/foundation.dart';
import 'package:moto_mecanico/models/motorcycle_templates.dart';

class MotorcycleTemplateIndexItem {
  String description;
  String name;
  String location;
  List<TaskTemplate> tasks;

  MotorcycleTemplateIndexItem({
    required this.description,
    required this.name,
    required this.location,
    this.tasks = const [],
  });

  MotorcycleTemplateIndexItem.fromJson(Map<String, dynamic> json)
      : description = json['description'],
        location = json['location'],
        name = '',
        tasks = const [];
}

class MotorcycleTemplateIndex {
  List<MotorcycleTemplateIndexItem> templates = const [];

  MotorcycleTemplateIndex({
    this.templates = const [],
  });

  MotorcycleTemplateIndex.fromJson(Map<String, dynamic> json) {
    templates = <MotorcycleTemplateIndexItem>[];
    json.forEach((name, value) {
      try {
        final template = MotorcycleTemplateIndexItem.fromJson(value);
        if (template.location.isNotEmpty) {
          template.name = name;
          templates.add(template);
        }
      } catch (e) {
        debugPrint(
            'Failed to parse template info from motorcycle service index');
        debugPrint(e.toString());
      }
    });
  }
}
