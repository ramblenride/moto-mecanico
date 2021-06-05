import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moto_mecanico/models/cost.dart';

// Tests are forcing errors, so drop the error logs.
void debugHandler(message, {wrapWidth}) {}

void main() {
  debugPrint = debugHandler;

  test('empty cost isValid', () {
    final empty = Cost(null, null);

    expect(empty.value, equals(0));
    expect(empty.description, equals(''));
  });

  test('JSON round trip', () {
    final description = 'this is a cost';
    final cost = Cost(32, description);
    final costParsed = Cost.fromJson(jsonDecode(jsonEncode(cost.toJson())));
    expect(costParsed, isNotNull);
    expect(costParsed.description, equals(description));
    expect(costParsed.value, equals(32));
  });

  test('JSON parse missing fields', () {
    var parsedCost = Cost.fromJson(jsonDecode('{}'));
    expect(parsedCost, isNotNull);
    expect(parsedCost.value, equals(0));
    expect(parsedCost.description, equals(''));

    parsedCost = Cost.fromJson(jsonDecode('{\n"value": 17}'));
    expect(parsedCost.value, equals(17));

    parsedCost =
        Cost.fromJson(jsonDecode('{"value": 17, "description": "clutch"}'));
    expect(parsedCost.value, equals(17));
    expect(parsedCost.description, equals('clutch'));
  });

  test('JSON parse fields wrong type', () {
    var parsedCost = Cost.fromJson(jsonDecode('{\n"value": "17"}'));
    expect(parsedCost.value, equals(0));
    expect(parsedCost.description, equals(''));

    parsedCost = Cost.fromJson(jsonDecode('{"value": 17, "description": 17}'));
    expect(parsedCost.value, equals(0));
    expect(parsedCost.description, equals(''));
  });
}
