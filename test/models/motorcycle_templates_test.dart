import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moto_mecanico/models/motorcycle_templates.dart';

// Tests are forcing errors, so drop the error logs.
void debugHandler(message, {wrapWidth}) {}

void main() {
  debugPrint = debugHandler;

  test('JSON parse MotorcycleTemplates', () {
    var parsed = MotorcycleTemplates.fromJson(jsonDecode(
        '{"motorcycles": [{"name": "name", "description": "description"}]}'));
    expect(parsed, isNotNull);
    expect(parsed.templates.length, equals(1));
    expect(parsed.templates.first.name, equals('name'));
    expect(parsed.templates.first.description, equals('description'));
  });

  test('JSON parse invalid MotorcycleTemplates', () {
    var parsed = MotorcycleTemplates.fromJson(
        jsonDecode('{"motorcycles": [{"name": "name", "description": 17}]}'));
    expect(parsed, isNotNull);
    expect(parsed.templates.length, equals(0));
  });
}
