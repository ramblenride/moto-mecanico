class Note {
  bool copyable;
  String _name;
  String _text;
  DateTime _lastUpdate;

  Note({required name, required text, this.copyable = false})
      : _lastUpdate = DateTime.now(),
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

  Note.from(Note note)
      : copyable = note.copyable,
        _name = note.name,
        _text = note.text,
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
    data['copyable'] = copyable;
    data['lastUpdate'] = _lastUpdate.toIso8601String();
    return data;
  }
}
