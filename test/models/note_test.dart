import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:moto_mecanico/models/note.dart';

void main() {
  test('JSON round trip', () {
    final text = 'this is a note';
    final name = 'this is a name';
    final note = Note(name: name, text: text);
    final noteParsed = Note.fromJson(jsonDecode(jsonEncode(note.toJson())));
    expect(noteParsed, isNotNull);
    expect(noteParsed.name, equals(name));
    expect(noteParsed.text, equals(text));
    expect(noteParsed.lastUpdate, equals(note.lastUpdate));
  });

  test('JSON parse missing fields', () {
    var parsed = Note.fromJson(jsonDecode('{}'));
    expect(parsed, isNotNull);
    expect(parsed.name, equals(''));
    expect(parsed.text, equals(''));
    expect(parsed.lastUpdate, isNotNull);
  });
}
