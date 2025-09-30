//import 'package:flutter/foundation.dart';

// FIXME: Make this class immutable when all uses are updated.
//@immutable
class Note {
  bool copyable;
  String _name;
  String _text;
  DateTime _lastUpdate;

  Note(
      {required name,
      required text,
      this.copyable = false,
      DateTime? lastUpdate})
      : _lastUpdate = lastUpdate ?? DateTime.now(),
        _name = name,
        _text = text;

  String get name => _name;
  String get text => _text;
  DateTime get lastUpdate => _lastUpdate;

  set name(String name) {
    if (name != _name) {
      _name = name;
      _lastUpdate = DateTime.now();
    }
  }

  set text(String text) {
    if (text != _text) {
      _text = text;
      _lastUpdate = DateTime.now();
    }
  }

  Note copyWith({
    String? name,
    String? text,
    bool? copyable,
    DateTime? lastUpdate,
  }) {
    final copy = Note(
        name: name ?? _name,
        text: text ?? _text,
        copyable: copyable ?? this.copyable,
        lastUpdate: lastUpdate ?? _lastUpdate);
    return copy;
  }

  @override
  bool operator ==(Object other) {
    return other is Note &&
        other._name == _name &&
        other._text == _text &&
        other.copyable == copyable &&
        other._lastUpdate == _lastUpdate;
  }

  @override
  int get hashCode => Object.hash(_name, _text, copyable, _lastUpdate);

  factory Note.fromJson(Map<String, dynamic> json) {
    DateTime? lastUpdate;
    if (json['lastUpdate'] != null) {
      lastUpdate = DateTime.tryParse(json['lastUpdate']);
    }
    var newNote = Note(
        name: json['name'] ?? '',
        text: json['text'] ?? '',
        copyable: json['copyable'] ?? false,
        lastUpdate: lastUpdate);

    return newNote;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = _name;
    data['text'] = _text;
    data['copyable'] = copyable;
    data['lastUpdate'] = _lastUpdate.toIso8601String();
    return data;
  }
}
