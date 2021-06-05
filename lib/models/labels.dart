import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:moto_mecanico/storage/local_file_storage.dart';

const _STORAGE_FILE = 'labels.json';

class Label {
  final int id;
  final Color color;
  final String name;
  const Label({@required this.id, @required this.color, @required this.name});

  static Label fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final colorNum = json['color'] as int;
    if (id != null && colorNum != null) {
      final id = json['id'] as int;
      final color = Color(colorNum);
      final name = json['name'] as String;
      return Label(id: id, color: color, name: name ?? '');
    }
    debugPrint('Failed to parse label from JSON. Missing fields.');
    return null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['color'] = color.value;
    data['name'] = name;
    return data;
  }
}

class LabelsModel extends ChangeNotifier {
  Map<int, Label> _labels;

  final _DEFAULT_LABELS = {
    0: Label(id: 0, color: Colors.red, name: ''),
    1: Label(id: 1, color: Colors.orange, name: ''),
    2: Label(id: 2, color: Colors.green, name: ''),
    3: Label(id: 3, color: Colors.lightBlue, name: ''),
    4: Label(id: 4, color: Colors.purple, name: ''),
    5: Label(id: 5, color: Colors.indigo, name: ''),
    6: Label(id: 6, color: Colors.brown, name: ''),
  };

  LabelsModel() {
    _labels = _DEFAULT_LABELS;
  }

  UnmodifiableMapView<int, Label> get labels => UnmodifiableMapView(_labels);

  bool update(Label label) {
    assert(label != null);

    if (!_labels.containsKey(label.id)) return false;

    _labels[label.id] = label;
    notifyListeners();

    _saveToStorage();
    return true;
  }

  void loadFromStorage() async {
    final storage = LocalFileStorage();
    try {
      final json = await storage.getFromJson(_STORAGE_FILE);
      final labels = fromJson(json);
      if (labels != null && labels.isNotEmpty) {
        _labels = labels;
      }
    } catch (error) {
      debugPrint(error.toString());
    }

    notifyListeners();
  }

  Future<bool> _saveToStorage() async {
    final storage = LocalFileStorage();
    final json = toJson();
    final result = await storage.saveToJson(_STORAGE_FILE, json);
    return result;
  }

  Map<int, Label> fromJson(Map<String, dynamic> json) {
    if (json['labels'] != null) {
      final labels = <int, Label>{};
      json['labels'].forEach((dynamic v) {
        final label = Label.fromJson(v as Map<String, dynamic>);
        if (label != null) {
          labels[label.id] = label;
        }
      });
      return labels;
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (_labels != null) {
      data['labels'] = _labels.values.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
