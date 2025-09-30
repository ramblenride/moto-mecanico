import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:moto_mecanico/models/note.dart';

void main() {
  group('Note Model Tests', () {
    test('constructor creates valid note', () {
      final note = Note(name: 'Test', text: 'Content');

      expect(note.name, equals('Test'));
      expect(note.text, equals('Content'));
      expect(note.copyable, equals(false));
      expect(note.lastUpdate, isNotNull);
    });

    test('constructor with all parameters', () {
      final timestamp = DateTime(2024, 1, 15, 10, 30);
      final note = Note(
        name: 'Test',
        text: 'Content',
        copyable: true,
        lastUpdate: timestamp,
      );

      expect(note.name, equals('Test'));
      expect(note.text, equals('Content'));
      expect(note.copyable, equals(true));
      expect(note.lastUpdate, equals(timestamp));
    });

    test('name setter updates name and lastUpdate', () async {
      final note = Note(name: 'Initial', text: 'Text');
      final initialUpdate = note.lastUpdate;

      await Future.delayed(const Duration(milliseconds: 10));
      note.name = 'Updated';

      expect(note.name, equals('Updated'));
      expect(note.lastUpdate.isAfter(initialUpdate), isTrue);
    });

    test('name setter does not update lastUpdate if name unchanged', () {
      final note = Note(name: 'Same', text: 'Text');
      final initialUpdate = note.lastUpdate;

      note.name = 'Same';

      expect(note.name, equals('Same'));
      expect(note.lastUpdate, equals(initialUpdate));
    });

    test('text setter updates text and lastUpdate', () async {
      final note = Note(name: 'Name', text: 'Initial');
      final initialUpdate = note.lastUpdate;

      await Future.delayed(const Duration(milliseconds: 10));
      note.text = 'Updated';

      expect(note.text, equals('Updated'));
      expect(note.lastUpdate.isAfter(initialUpdate), isTrue);
    });

    test('text setter does not update lastUpdate if text unchanged', () {
      final note = Note(name: 'Name', text: 'Same');
      final initialUpdate = note.lastUpdate;

      note.text = 'Same';

      expect(note.text, equals('Same'));
      expect(note.lastUpdate, equals(initialUpdate));
    });

    test('copyWith name only', () {
      final original = Note(name: 'Original', text: 'Text');
      final copied = original.copyWith(name: 'New Name');

      expect(copied.name, equals('New Name'));
      expect(copied.text, equals(original.text));
      expect(copied.copyable, equals(original.copyable));
      expect(copied.lastUpdate, equals(original.lastUpdate));
    });

    test('copyWith text only', () {
      final original = Note(name: 'Name', text: 'Original');
      final copied = original.copyWith(text: 'New Text');

      expect(copied.name, equals(original.name));
      expect(copied.text, equals('New Text'));
      expect(copied.copyable, equals(original.copyable));
      expect(copied.lastUpdate, equals(original.lastUpdate));
    });

    test('copyWith copyable only', () {
      final original = Note(name: 'Name', text: 'Text', copyable: false);
      final copied = original.copyWith(copyable: true);

      expect(copied.name, equals(original.name));
      expect(copied.text, equals(original.text));
      expect(copied.copyable, equals(true));
      expect(copied.lastUpdate, equals(original.lastUpdate));
    });

    test('copyWith lastUpdate only', () {
      final original = Note(name: 'Name', text: 'Text');
      final newTimestamp = DateTime(2024, 6, 15);
      final copied = original.copyWith(lastUpdate: newTimestamp);

      expect(copied.name, equals(original.name));
      expect(copied.text, equals(original.text));
      expect(copied.copyable, equals(original.copyable));
      expect(copied.lastUpdate, equals(newTimestamp));
    });

    test('copyWith all parameters', () {
      final original = Note(name: 'Old', text: 'Old Text');
      final newTimestamp = DateTime(2024, 12, 25);
      final copied = original.copyWith(
        name: 'New',
        text: 'New Text',
        copyable: true,
        lastUpdate: newTimestamp,
      );

      expect(copied.name, equals('New'));
      expect(copied.text, equals('New Text'));
      expect(copied.copyable, equals(true));
      expect(copied.lastUpdate, equals(newTimestamp));
    });

    test('copyWith no parameters returns equivalent', () {
      final original = Note(name: 'Name', text: 'Text');
      final copied = original.copyWith();

      expect(copied.name, equals(original.name));
      expect(copied.text, equals(original.text));
      expect(copied.copyable, equals(original.copyable));
      expect(copied.lastUpdate, equals(original.lastUpdate));
    });

    test('equality operator returns true for identical notes', () {
      final timestamp = DateTime(2024, 5, 10);
      final note1 = Note(
        name: 'Test',
        text: 'Content',
        copyable: true,
        lastUpdate: timestamp,
      );
      final note2 = Note(
        name: 'Test',
        text: 'Content',
        copyable: true,
        lastUpdate: timestamp,
      );

      expect(note1 == note2, isTrue);
      expect(note1.hashCode, equals(note2.hashCode));
    });

    test('equality operator returns false for different names', () {
      final timestamp = DateTime(2024, 5, 10);
      final note1 = Note(name: 'Name1', text: 'Text', lastUpdate: timestamp);
      final note2 = Note(name: 'Name2', text: 'Text', lastUpdate: timestamp);

      expect(note1 == note2, isFalse);
    });

    test('equality operator returns false for different text', () {
      final timestamp = DateTime(2024, 5, 10);
      final note1 = Note(name: 'Name', text: 'Text1', lastUpdate: timestamp);
      final note2 = Note(name: 'Name', text: 'Text2', lastUpdate: timestamp);

      expect(note1 == note2, isFalse);
    });

    test('equality operator returns false for different copyable', () {
      final timestamp = DateTime(2024, 5, 10);
      final note1 = Note(
          name: 'Name', text: 'Text', copyable: true, lastUpdate: timestamp);
      final note2 = Note(
          name: 'Name', text: 'Text', copyable: false, lastUpdate: timestamp);

      expect(note1 == note2, isFalse);
    });

    test('equality operator returns false for different lastUpdate', () {
      final note1 =
          Note(name: 'Name', text: 'Text', lastUpdate: DateTime(2024, 1, 1));
      final note2 =
          Note(name: 'Name', text: 'Text', lastUpdate: DateTime(2024, 1, 2));

      expect(note1 == note2, isFalse);
    });

    test('hashCode is consistent', () {
      final timestamp = DateTime(2024, 5, 10);
      final note = Note(name: 'Test', text: 'Content', lastUpdate: timestamp);

      expect(note.hashCode, equals(note.hashCode));
    });

    test('JSON round trip', () {
      const text = 'this is a note';
      const name = 'this is a name';
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

    test('toJson includes all fields', () {
      final timestamp = DateTime(2024, 5, 10, 14, 30);
      final note = Note(
        name: 'Test',
        text: 'Content',
        copyable: true,
        lastUpdate: timestamp,
      );

      final json = note.toJson();

      expect(json['name'], equals('Test'));
      expect(json['text'], equals('Content'));
      expect(json['copyable'], equals(true));
      expect(json['lastUpdate'], equals(timestamp.toIso8601String()));
    });

    test('fromJson handles copyable field', () {
      final json = {
        'name': 'Test',
        'text': 'Content',
        'copyable': true,
        'lastUpdate': '2024-05-10T14:30:00.000',
      };

      final note = Note.fromJson(json);

      expect(note.copyable, equals(true));
    });

    test('fromJson handles invalid lastUpdate gracefully', () {
      final json = {
        'name': 'Test',
        'text': 'Content',
        'lastUpdate': 'invalid-date',
      };

      final note = Note.fromJson(json);

      expect(note.name, equals('Test'));
      expect(note.text, equals('Content'));
      expect(note.lastUpdate, isNotNull);
    });
  });
}
