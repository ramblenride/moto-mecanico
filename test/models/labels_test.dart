import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moto_mecanico/models/labels.dart';

import 'package:path_provider/path_provider.dart';
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
    test('default labels are not empty', () {
      final model = LabelsModel();
      final labels = model.labels;
      expect(labels, isNotEmpty);
    });

    test('updating unknown label does nothing', () async {
      final model = LabelsModel();
      final length = model.labels.length;

      final result = await model.update(const Label(
        id: 17,
        color: Color(0x00034222),
        name: '',
      ));
      expect(result, isFalse);
      expect(model.labels.length, equals(length));
    });

    test('updating a valid label', () async {
      final model = LabelsModel();
      final length = model.labels.length;

      final result = await model.update(const Label(
        id: 2,
        color: Color(0x00121212),
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

    test('JSON round trip', () async {
      final model = LabelsModel();
      await model.update(const Label(
        id: 2,
        color: Color(0x00121212),
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
      expect(label!.id, equals(0));
      expect(label.color.value, equals(121212));
      expect(label.name, '');
    });
  });
}

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async {
    return kTemporaryPath;
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    return kApplicationSupportPath;
  }

  @override
  Future<String?> getLibraryPath() async {
    return kLibraryPath;
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return kApplicationDocumentsPath;
  }

  @override
  Future<String?> getExternalStoragePath() async {
    return kExternalStoragePath;
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    return <String>[kExternalCachePath];
  }

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    return <String>[kExternalStoragePath];
  }

  @override
  Future<String?> getDownloadsPath() async {
    return kDownloadsPath;
  }
}
