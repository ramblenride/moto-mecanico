class Note {
  String _name;
  String _text;
  bool _copyable;
  DateTime _lastUpdate;

  Note({required name, required text, copyable = false})
      : _lastUpdate = DateTime.now(),
        _name = name,
        _text = text,
        _copyable = copyable;

  String get name => _name;
  String get text => _text;
  bool get copyable => _copyable;
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

  set copyable(bool copyable) {
    _copyable = copyable;
  }

  Note.from(Note note)
      : _name = note.name,
        _text = note.text,
        _copyable = note.copyable,
        _lastUpdate = note.lastUpdate;

  factory Note.fromJson(Map<String, dynamic> json) {
    var newNote = Note(
        name: json['name'] ?? '',
        text: json['text'] ?? '',
        copyable: json['copyable'] ?? false);

    DateTime? lastUpdate;
    if (json['lastUpdate'] != null) {
      lastUpdate = DateTime.tryParse(json['lastUpdate']);
    }

    newNote._lastUpdate = lastUpdate ?? DateTime.now();

    return newNote;
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
