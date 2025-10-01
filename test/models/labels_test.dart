import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moto_mecanico/models/labels.dart';

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

const String kTemporaryPath = 'temporaryPath';
const String kApplicationSupportPath = 'applicationSupportPath';
const String kDownloadsPath = 'downloadsPath';
const String kLibraryPath = 'libraryPath';
const String kApplicationDocumentsPath = 'applicationDocumentsPath';
const String kExternalCachePath = 'externalCachePath';
const String kExternalStoragePath = 'externalStoragePath';

// Tests are forcing errors, so drop the error logs.
void debugHandler(message, {wrapWidth}) {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  debugPrint = debugHandler;

  group('Labels Model Tests', () {
    setUp(() async {
      PathProviderPlatform.instance = FakePathProviderPlatform();
    });

    test('default labels are not empty', () {
      final model = LabelsModel();
      final labels = model.labels;
      expect(labels, isNotEmpty);
    });

    test('LabelsModel.labels returns UnmodifiableMapView', () {
      final model = LabelsModel();
      final labels = model.labels;

      expect(labels, isA<UnmodifiableMapView<int, Label>>());
      expect(() => labels[0] = Label(id: 0, color: Colors.black, name: 'test'),
          throwsUnsupportedError);
    });

    test('updating unknown label does nothing', () async {
      final model = LabelsModel();
      final length = model.labels.length;

      final result = await model.update(Label(
        id: 17,
        color: const Color(0x00034222),
        name: '',
      ));
      expect(result, isFalse);
      expect(model.labels.length, equals(length));
    });

    test('updating a valid label', () async {
      final model = LabelsModel();
      final length = model.labels.length;

      final result = await model.update(Label(
        id: 2,
        color: const Color(0x00121212),
        name: 'Mine',
      ));
      expect(result, isTrue);

      final labels = model.labels;
      expect(labels.length, equals(length));
      final label = labels[2];
      expect(label!.id, equals(2));
      expect(label.color.value, equals(const Color(0x00121212).value));
      expect(label.name, equals('Mine'));
    });

    test('update returns false for non-existent label ID', () async {
      final model = LabelsModel();

      final result = await model.update(Label(
        id: 999,
        color: Colors.black,
        name: 'Non-existent',
      ));

      expect(result, isFalse);
      expect(model.labels.containsKey(999), isFalse);
    });

    test('update returns true and updates existing label', () async {
      final model = LabelsModel();
      final newLabel = Label(id: 3, color: Colors.cyan, name: 'Updated');

      final result = await model.update(newLabel);

      expect(result, isTrue);
      final updatedLabel = model.labels[3];
      expect(updatedLabel!.color, equals(Colors.cyan));
      expect(updatedLabel.name, equals('Updated'));
    });

    test('update preserves other labels when updating one', () async {
      final model = LabelsModel();
      final originalLabels = Map.from(model.labels);

      await model.update(Label(id: 2, color: Colors.black, name: 'Changed'));

      // All other labels should remain unchanged
      for (int i = 0; i < 7; i++) {
        if (i != 2) {
          expect(model.labels[i]!.color, equals(originalLabels[i]!.color));
          expect(model.labels[i]!.name, equals(originalLabels[i]!.name));
        }
      }

      // Only label 2 should be different
      expect(model.labels[2]!.color, equals(Colors.black));
      expect(model.labels[2]!.name, equals('Changed'));
    });

    test('JSON round trip', () async {
      final model = LabelsModel();
      await model.update(Label(
        id: 2,
        color: const Color(0x00121212),
        name: 'Mine',
      ));
      final labels = model.labels;

      final modelParsed = LabelsModel();
      final labelsParsed =
          modelParsed.fromJson(jsonDecode(jsonEncode(model.toJson())));

      expect(labelsParsed.length, equals(labels.length));
      expect(labelsParsed[1]!.id, equals(labels[1]!.id));
      expect(labelsParsed[1]!.color.value, equals(labels[1]!.color.value));
      expect(labelsParsed[1]!.name, equals(labels[1]!.name));
      expect(labelsParsed[2]!.id, equals(2));
      expect(labelsParsed[2]!.name, equals('Mine'));
      expect(
          labelsParsed[2]!.color.value, equals(const Color(0x00121212).value));
    });

    test('JSON parse missing fields', () {
      final model = LabelsModel();
      var parsedLabels = model.fromJson(jsonDecode('{}'));
      expect(parsedLabels, isEmpty);

      parsedLabels = model.fromJson(jsonDecode('{\n"labels": []}'));
      expect(parsedLabels, isNotNull);
      expect(parsedLabels.length, equals(0));

      // A valid ID and a valid color are required for a label to be parsed
      parsedLabels = model.fromJson(jsonDecode('{\n"labels": [{"id": 0}]}'));
      expect(parsedLabels, isNotNull);
      expect(parsedLabels.length, equals(0));

      parsedLabels = model
          .fromJson(jsonDecode('{\n"labels": [{"id": 0, "color": 121212}]}'));
      expect(parsedLabels, isNotNull);
      expect(parsedLabels.length, equals(1));
      final label = parsedLabels[0];
      expect(label, isNotNull);
      expect(label!.id, equals(0));
      expect(label.color.value, equals(121212));
      expect(label.name, '');
    });

    test('JSON parsing trims name length', () {
      // Name that exceeds 20 character should be trimmed
      final model = LabelsModel();
      final tooLongName = 'A' * 21;
      var parsedLabels = model.fromJson(jsonDecode("""{
        "labels": [{"id": 1, "color": 121212, "name": "$tooLongName"}]
      }"""));

      expect(parsedLabels, isNotNull);
      expect(parsedLabels.length, equals(1));
      final label = parsedLabels[1];
      expect(label, isNotNull);
      expect(label!.id, equals(1));
      expect(label.color.value, equals(121212));
      expect(label.name, equals('A' * 20));
    });
  });

  group('Label Class Tests', () {
    test('Label constructor creates valid label', () {
      final label = Label(
        id: 1,
        color: Colors.red,
        name: 'Test Label',
      );

      expect(label.id, equals(1));
      expect(label.color, equals(Colors.red));
      expect(label.name, equals('Test Label'));
    });

    test('Label constructor handles edge cases', () {
      // Empty name
      final labelEmptyName = Label(id: 0, color: Colors.blue, name: '');
      expect(labelEmptyName.name, equals(''));

      // Special characters in name
      final labelSpecialChars = Label(
        id: 2,
        color: Colors.green,
        name: '🔧 Maint & Repair!',
      );
      expect(labelSpecialChars.name, equals('🔧 Maint & Repair!'));

      // Long name (within 20 char limit)
      const longName = 'Under the limit';
      final labelLongName = Label(id: 3, color: Colors.yellow, name: longName);
      expect(labelLongName.name, equals(longName));
    });

    test('Label constructor validates name length', () {
      // Name that exceeds 20 character limit should throw
      final tooLongName = 'A' * 21;
      expect(() => Label(id: 1, color: Colors.red, name: tooLongName),
          throwsA(isA<ArgumentError>()));
    });

    test('Label.fromJson creates valid label from correct JSON', () {
      final json = {
        'id': 5,
        'color': Colors.purple.value,
        'name': 'Purple Label',
      };

      final label = Label.fromJson(json);

      expect(label.id, equals(5));
      expect(label.color.value, equals(Colors.purple.value));
      expect(label.name, equals('Purple Label'));
    });

    test('Label.fromJson handles missing name field', () {
      final json = {
        'id': 1,
        'color': Colors.red.value,
        // Missing 'name' field
      };

      final label = Label.fromJson(json);

      expect(label.id, equals(1));
      expect(label.name, equals('')); // Should default to empty string
    });

    test('Label.fromJson throws for missing required fields', () {
      // Missing id
      final jsonMissingId = {
        'color': Colors.red.value,
        'name': 'Test',
      };
      expect(() => Label.fromJson(jsonMissingId), throwsArgumentError);

      // Missing color
      final jsonMissingColor = {
        'id': 1,
        'name': 'Test',
      };
      expect(() => Label.fromJson(jsonMissingColor), throwsArgumentError);

      // Both missing
      final jsonEmpty = <String, dynamic>{};
      expect(() => Label.fromJson(jsonEmpty), throwsArgumentError);
    });

    test('Label.fromJson handles invalid data types', () {
      // String id instead of int
      final jsonStringId = {
        'id': '5',
        'color': Colors.red.value,
        'name': 'Test',
      };
      expect(() => Label.fromJson(jsonStringId), throwsArgumentError);

      // String color instead of int
      final jsonStringColor = {
        'id': 5,
        'color': 'red',
        'name': 'Test',
      };
      expect(() => Label.fromJson(jsonStringColor), throwsArgumentError);

      // Non-string name (should default to empty string)
      final jsonIntName = {
        'id': 5,
        'color': Colors.red.value,
        'name': 123,
      };
      final labelWithIntName = Label.fromJson(jsonIntName);
      expect(labelWithIntName.name, equals(''));
    });

    test('Label.fromJson handles null values', () {
      final jsonNullValues = {
        'id': null,
        'color': null,
        'name': null,
      };
      expect(() => Label.fromJson(jsonNullValues), throwsArgumentError);
    });

    test('Label.toJson creates correct JSON representation', () {
      final label = Label(
        id: 7,
        color: const Color(0xFF123456),
        name: 'Test Export',
      );

      final json = label.toJson();

      expect(json['id'], equals(7));
      expect(json['color'], equals(0xFF123456));
      expect(json['name'], equals('Test Export'));
      expect(json.length, equals(3)); // Should have exactly 3 keys
    });

    test('Label JSON round trip preserves data', () {
      final originalLabel = Label(
        id: 9,
        color: const Color(0xFFABCDEF),
        name: 'Round Trip Test 🚀',
      );

      final json = originalLabel.toJson();
      final parsedLabel = Label.fromJson(json);

      expect(parsedLabel.id, equals(originalLabel.id));
      expect(parsedLabel.color.value, equals(originalLabel.color.value));
      expect(parsedLabel.name, equals(originalLabel.name));
    });

    test('copyWith id only', () {
      final original = Label(id: 1, color: Colors.red, name: 'Test');
      final copied = original.copyWith(id: 5);

      expect(copied.id, equals(5));
      expect(copied.color, equals(Colors.red));
      expect(copied.name, equals('Test'));
    });

    test('copyWith color only', () {
      final original = Label(id: 1, color: Colors.red, name: 'Test');
      final copied = original.copyWith(color: Colors.blue);

      expect(copied.id, equals(1));
      expect(copied.color, equals(Colors.blue));
      expect(copied.name, equals('Test'));
    });

    test('copyWith name only', () {
      final original = Label(id: 1, color: Colors.red, name: 'Test');
      final copied = original.copyWith(name: 'Updated');

      expect(copied.id, equals(1));
      expect(copied.color, equals(Colors.red));
      expect(copied.name, equals('Updated'));
    });

    test('copyWith all parameters', () {
      final original = Label(id: 1, color: Colors.red, name: 'Test');
      final copied = original.copyWith(
        id: 3,
        color: Colors.green,
        name: 'New',
      );

      expect(copied.id, equals(3));
      expect(copied.color, equals(Colors.green));
      expect(copied.name, equals('New'));
    });

    test('copyWith no parameters returns equivalent', () {
      final original = Label(id: 2, color: Colors.orange, name: 'Original');
      final copied = original.copyWith();

      expect(copied.id, equals(original.id));
      expect(copied.color, equals(original.color));
      expect(copied.name, equals(original.name));
    });

    test('copyWith validates name length', () {
      final original = Label(id: 1, color: Colors.red, name: 'Test');
      final tooLongName = 'A' * 21;

      expect(
        () => original.copyWith(name: tooLongName),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('copyWith empty name', () {
      final original = Label(id: 1, color: Colors.red, name: 'Test');
      final copied = original.copyWith(name: '');

      expect(copied.name, equals(''));
      expect(copied.id, equals(1));
      expect(copied.color, equals(Colors.red));
    });
  });
}

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return "/tmp";
  }
}
