import 'package:flutter/foundation.dart';
import 'package:moto_mecanico/models/motorcycle_templates.dart';

class MotorcycleTemplateIndexItem {
  String description;
  String name;
  String location;
  List<TaskTemplate> tasks;

  MotorcycleTemplateIndexItem({
    @required this.description,
    @required this.name,
    @required this.location,
    this.tasks = const [],
  })  : assert(name != null),
        assert(description != null),
        assert(location != null);

  MotorcycleTemplateIndexItem.fromJson(Map<String, dynamic> json) {
    if (json != null) {
      description = json['description'];
      location = json['location'];
      name = '';
    } else {
      debugPrint('Empty motorcycle service interval template index');
    }
  }
}

class MotorcycleTemplateIndex {
  List<MotorcycleTemplateIndexItem> templates = const [];

  MotorcycleTemplateIndex({
    this.templates = const [],
  });

  MotorcycleTemplateIndex.fromJson(Map<String, dynamic> json) {
    templates = <MotorcycleTemplateIndexItem>[];
    if (json != null) {
      json.forEach((name, value) {
        try {
          final template = MotorcycleTemplateIndexItem.fromJson(value);
          if (template != null && (template.location?.isNotEmpty ?? false)) {
            template.name = name;
            templates.add(template);
          }
        } catch (e) {
          debugPrint(
              'Failed to parse template info from motorcycle service index');
          debugPrint(e.toString());
        }
      });
    } else {
      debugPrint('Empty motorcycle service intervalindex.');
    }
  }
}
