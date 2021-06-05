import 'package:flutter/foundation.dart';

class Note {
  String _name;
  String _text;
  bool _copyable;
  DateTime _lastUpdate;

  Note({@required name, @required text, copyable = false})
      : assert(name != null),
        assert(text != null),
        _lastUpdate = DateTime.now() {
    _name = name;
    _text = text;
    _copyable = copyable;
  }

  String get name => _name;
  String get text => _text;
  bool get copyable => _copyable;
  DateTime get lastUpdate => _lastUpdate;

  set name(String name) {
    if ((name ?? '') != (_name ?? '')) {
      _name = name ?? '';
      _lastUpdate = DateTime.now();
    }
  }

  set text(String text) {
    if ((text ?? '') != (_text ?? '')) {
      _text = text ?? '';
      _lastUpdate = DateTime.now();
    }
  }

  set copyable(bool copyable) {
    _copyable = copyable;
  }

  Note.from(Note note) {
    _name = note.name;
    _text = note.text;
    _copyable = note.copyable;
    _lastUpdate = note.lastUpdate;
  }

  Note.fromJson(Map<String, dynamic> json) {
    _name = json['name'] ?? '';
    _text = json['text'] ?? '';
    _copyable = json['copyable'] ?? false;

    if (json['lastUpdate'] != null) {
      _lastUpdate = DateTime.tryParse(json['lastUpdate']);
    }
    _lastUpdate ??= DateTime.now();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = _name;
    data['text'] = _text;
    data['copyable'] = _copyable;
    data['lastUpdate'] = _lastUpdate.toIso8601String();
    return data;
  }
}
