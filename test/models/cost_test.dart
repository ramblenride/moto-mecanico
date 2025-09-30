import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moto_mecanico/models/cost.dart';

// Tests are forcing errors, so drop the error logs.
void debugHandler(message, {wrapWidth}) {}

void main() {
  debugPrint = debugHandler;

  test('JSON round trip', () {
    const description = 'this is a cost';
    final cost = Cost(32, description);
    final costParsed = Cost.fromJson(jsonDecode(jsonEncode(cost.toJson())));
    expect(costParsed, isNotNull);
    expect(costParsed!.description, equals(description));
    expect(costParsed.value, equals(32));
  });

  test('JSON parse missing fields', () {
    var parsedCost = Cost.fromJson(jsonDecode('{}'));
    expect(parsedCost, isNotNull);
    expect(parsedCost!.value, equals(0));
    expect(parsedCost.description, equals(''));

    parsedCost = Cost.fromJson(jsonDecode('{\n"value": 17}'));
    expect(parsedCost, isNotNull);
    expect(parsedCost!.value, equals(17));

    parsedCost =
        Cost.fromJson(jsonDecode('{"value": 17, "description": "clutch"}'));
    expect(parsedCost, isNotNull);
    expect(parsedCost!.value, equals(17));
    expect(parsedCost.description, equals('clutch'));
  });

  test('JSON parse fields wrong type', () {
    var parsedCost = Cost.fromJson(jsonDecode('{\n"value": "17"}'));
    expect(parsedCost, isNull);

    parsedCost = Cost.fromJson(jsonDecode('{"value": 17, "description": 17}'));
    expect(parsedCost, isNull);
  });

  test('copyWith creates new instance with updated fields', () {
    final original =
        Cost(100, 'Oil change', type: CostType.part, copyable: true);

    final withNewValue = original.copyWith(value: 150);
    expect(withNewValue.value, equals(150));
    expect(withNewValue.description, equals('Oil change'));
    expect(withNewValue.type, equals(CostType.part));
    expect(withNewValue.copyable, equals(true));

    final withNewDescription = original.copyWith(description: 'Filter change');
    expect(withNewDescription.value, equals(100));
    expect(withNewDescription.description, equals('Filter change'));

    final withNewType = original.copyWith(type: CostType.labor);
    expect(withNewType.type, equals(CostType.labor));

    final withNewCopyable = original.copyWith(copyable: false);
    expect(withNewCopyable.copyable, equals(false));

    final withMultiple =
        original.copyWith(value: 200, description: 'New description');
    expect(withMultiple.value, equals(200));
    expect(withMultiple.description, equals('New description'));
  });

  test('copyWith with no parameters returns equivalent instance', () {
    final original =
        Cost(100, 'Oil change', type: CostType.part, copyable: true);
    final copy = original.copyWith();

    expect(copy.value, equals(original.value));
    expect(copy.description, equals(original.description));
    expect(copy.type, equals(original.type));
    expect(copy.copyable, equals(original.copyable));
  });

  test('equality operator works correctly', () {
    final cost1 = Cost(100, 'Oil change', type: CostType.part, copyable: true);
    final cost2 = Cost(100, 'Oil change', type: CostType.part, copyable: true);
    final cost3 = Cost(150, 'Oil change', type: CostType.part, copyable: true);
    final cost4 = Cost(100, 'Different', type: CostType.part, copyable: true);
    final cost5 = Cost(100, 'Oil change', type: CostType.labor, copyable: true);
    final cost6 = Cost(100, 'Oil change', type: CostType.part, copyable: false);

    expect(cost1 == cost2, isTrue);
    expect(cost1 == cost3, isFalse);
    expect(cost1 == cost4, isFalse);
    expect(cost1 == cost5, isFalse);
    expect(cost1 == cost6, isFalse);
    expect(cost1 == cost1, isTrue); // identity
  });

  test('hashCode is consistent with equality', () {
    final cost1 = Cost(100, 'Oil change', type: CostType.part, copyable: true);
    final cost2 = Cost(100, 'Oil change', type: CostType.part, copyable: true);
    final cost3 = Cost(150, 'Oil change', type: CostType.part, copyable: true);

    expect(cost1.hashCode, equals(cost2.hashCode));
    expect(cost1.hashCode, isNot(equals(cost3.hashCode)));
  });

  test('toString returns readable representation', () {
    final cost = Cost(100, 'Oil change', type: CostType.part, copyable: true);
    final str = cost.toString();

    expect(str, contains('Cost('));
    expect(str, contains('description: Oil change'));
    expect(str, contains('value: 100'));
    expect(str, contains('type: CostType.part'));
    expect(str, contains('copyable: true'));
  });

  test('Cost.total with no type filter', () {
    final costs = [
      Cost(100, 'Part 1', type: CostType.part),
      Cost(50, 'Labor 1', type: CostType.labor),
      Cost(25, 'Other 1', type: CostType.other),
    ];

    final total = Cost.total(costs, null);
    expect(total.value, equals(175));
    expect(total.description, equals('Total'));
  });

  test('Cost.total with type filter', () {
    final costs = [
      Cost(100, 'Part 1', type: CostType.part),
      Cost(50, 'Part 2', type: CostType.part),
      Cost(25, 'Labor 1', type: CostType.labor),
    ];

    final partTotal = Cost.total(costs, CostType.part);
    expect(partTotal.value, equals(150));
    expect(partTotal.type, equals(CostType.part));

    final laborTotal = Cost.total(costs, CostType.labor);
    expect(laborTotal.value, equals(25));
    expect(laborTotal.type, equals(CostType.labor));
  });

  test('Cost.total with empty list', () {
    final total = Cost.total([], null);
    expect(total.value, equals(0));
    expect(total.description, equals('Total'));
  });

  test('Cost.total with type filter matching no costs', () {
    final costs = [
      Cost(100, 'Part 1', type: CostType.part),
      Cost(50, 'Part 2', type: CostType.part),
    ];

    final laborTotal = Cost.total(costs, CostType.labor);
    expect(laborTotal.value, equals(0));
  });

  test('Cost.from creates copy', () {
    final original =
        Cost(100, 'Oil change', type: CostType.part, copyable: true);
    final copy = Cost.from(original);

    expect(copy.value, equals(original.value));
    expect(copy.description, equals(original.description));
    expect(copy.type, equals(original.type));
    expect(copy.copyable, equals(original.copyable));
  });

  test('JSON serialization preserves all CostType values', () {
    final partCost = Cost(100, 'Part', type: CostType.part);
    final laborCost = Cost(100, 'Labor', type: CostType.labor);
    final otherCost = Cost(100, 'Other', type: CostType.other);

    final partParsed = Cost.fromJson(jsonDecode(jsonEncode(partCost.toJson())));
    final laborParsed =
        Cost.fromJson(jsonDecode(jsonEncode(laborCost.toJson())));
    final otherParsed =
        Cost.fromJson(jsonDecode(jsonEncode(otherCost.toJson())));

    expect(partParsed!.type, equals(CostType.part));
    expect(laborParsed!.type, equals(CostType.labor));
    expect(otherParsed!.type, equals(CostType.other));
  });

  test('JSON serialization preserves copyable field', () {
    final copyableCost = Cost(100, 'Test', copyable: true);
    final nonCopyableCost = Cost(100, 'Test', copyable: false);

    final copyableParsed =
        Cost.fromJson(jsonDecode(jsonEncode(copyableCost.toJson())));
    final nonCopyableParsed =
        Cost.fromJson(jsonDecode(jsonEncode(nonCopyableCost.toJson())));

    expect(copyableParsed!.copyable, isTrue);
    expect(nonCopyableParsed!.copyable, isFalse);
  });
}
