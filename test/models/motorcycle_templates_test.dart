import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moto_mecanico/models/distance.dart';
import 'package:moto_mecanico/models/motorcycle_templates.dart';
import 'package:moto_mecanico/models/task.dart';

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
    /* The description is an integer instead of a string */
    var parsed = MotorcycleTemplates.fromJson(
        jsonDecode('{"motorcycles": [{"name": "name", "description": 17}]}'));
    expect(parsed, isNotNull);
    expect(parsed.templates.length, equals(0));
  });

  test('JSON parse empty motorcycles list', () {
    var parsed =
        MotorcycleTemplates.fromJson(jsonDecode('{"motorcycles": []}'));
    expect(parsed, isNotNull);
    expect(parsed.templates.length, equals(0));
  });

  test('JSON parse missing motorcycles key', () {
    var parsed = MotorcycleTemplates.fromJson(jsonDecode('{}'));
    expect(parsed, isNotNull);
    expect(parsed.templates.length, equals(0));
  });

  test('JSON parse motorcycles with missing name', () {
    var parsed = MotorcycleTemplates.fromJson(
        jsonDecode('{"motorcycles": [{"description": "desc"}]}'));
    expect(parsed, isNotNull);
    expect(parsed.templates.length, equals(0));
  });

  test('JSON parse motorcycles with extra fields', () {
    var parsed = MotorcycleTemplates.fromJson(jsonDecode(
        '{"motorcycles": [{"name": "n", "description": "d", "extra": 123}]}'));
    expect(parsed, isNotNull);
    expect(parsed.templates.length, equals(1));
    expect(parsed.templates.first.name, equals('n'));
    expect(parsed.templates.first.description, equals('d'));
  });

  test('JSON parse motorcycles tasks', () {
    var parsed = MotorcycleTemplates.fromJson(jsonDecode(
        """{"motorcycles": [{"name": "n", "description": "d", "tasks": [
        {"name": "T1", "description": "D1", "km": 1000, "intervalKm": 100, "technicalLevel": "pro", "months": 12, "intervalMonths": 1, "notes": "Note1"},
        {"name": "T2", "description": "D2", "links": [{"name": "L1", "url": "http://test.com"}]}
        ]}]}"""));
    expect(parsed, isNotNull);
    expect(parsed.templates.length, equals(1));
    expect(parsed.templates.first.tasks.length, equals(2));

    var first = parsed.templates.first.tasks.first;
    expect(first, isNotNull);
    expect(first.name, equals("T1"));
    expect(first.description, equals("D1"));
    expect(first.distance, equals(const Distance(1000, DistanceUnit.unitKm)));
    expect(first.intervalDistance,
        equals(const Distance(100, DistanceUnit.unitKm)));
    expect(first.technicalLevel, equals(TechnicalLevel.pro));
    expect(first.months, equals(12));
    expect(first.intervalMonths, equals(1));
    expect(first.notes, equals("Note1"));
    expect(first.links, isEmpty);

    var second = parsed.templates.first.tasks[1];
    expect(second, isNotNull);
    expect(second.name, equals("T2"));
    expect(second.description, equals("D2"));
    expect(second.distance.isValid, isFalse);
    expect(second.intervalDistance.isValid, isFalse);
    expect(second.technicalLevel, equals(TechnicalLevel.none));
    expect(second.months, equals(0));
    expect(second.intervalMonths, equals(0));
    expect(second.notes, isEmpty);
    expect(second.links.length, equals(1));
    expect(second.links.first.name, equals("L1"));
    expect(second.links.first.url, equals("http://test.com"));
  });
}
