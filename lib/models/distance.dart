import 'package:flutter/foundation.dart';
import 'package:moto_mecanico/locale/formats.dart';

enum DistanceUnit {
  UnitKM,
  UnitMile,
}

class Distance implements Comparable<dynamic> {
  static const double KM_TO_MILES = 0.621371;
  const Distance(this.distance, [this.unit = DistanceUnit.UnitKM]);

  final int distance;
  final DistanceUnit unit;

  bool get isValid => distance != null;

  Distance toUnit(DistanceUnit newUnit) {
    var newDistance = distance;
    if (distance != null && unit != newUnit) {
      if (newUnit == DistanceUnit.UnitKM) {
        newDistance = (distance / KM_TO_MILES).round();
      } else {
        newDistance = (distance * KM_TO_MILES).round();
      }
    }
    return Distance(newDistance, newUnit);
  }

  @override
  String toString({bool compact = false}) {
    if (!isValid) return '';

    return (compact && distance.abs() > 9999)
        ? '${(distance ~/ 1000)}k'
        : distance.toString();
  }

  String toFullString({bool compact = false}) {
    final distanceStr = toString(compact: compact);
    if (distanceStr.isNotEmpty) {
      final unitStr = compact
          ? AppLocalSupport.distanceUnitsCompact[unit]
          : AppLocalSupport.distanceUnits[unit];
      return '$distanceStr $unitStr';
    }
    return distanceStr;
  }

  // Returns the addition of two distances in the current unit.
  Distance operator +(Distance other) {
    assert(other != null);
    return Distance((distance ?? 0) + (other.toUnit(unit).distance ?? 0), unit);
  }

  // Returns the subtraction of other distance in the current unit.
  Distance operator -(Distance other) {
    assert(other != null);
    return Distance((distance ?? 0) - (other.toUnit(unit).distance ?? 0), unit);
  }

  // Returns the multiplication of a distance with a constant.
  Distance operator *(int other) {
    assert(other != null);
    return Distance((distance ?? 0) * other, unit);
  }

  bool operator >(Distance other) {
    assert(other != null);
    return (distance ?? 0) > (other.toUnit(unit).distance ?? 0);
  }

  bool operator >=(Distance other) {
    assert(other != null);
    return (distance ?? 0) >= (other.toUnit(unit).distance ?? 0);
  }

  bool operator <(Distance other) {
    assert(other != null);
    return (distance ?? 0) < (other.toUnit(unit).distance ?? 0);
  }

  bool operator <=(Distance other) {
    assert(other != null);
    return (distance ?? 0) <= (other.toUnit(unit).distance ?? 0);
  }

  @override
  bool operator ==(dynamic other) {
    return other is Distance && other.toUnit(unit).distance == distance;
  }

  @override
  int get hashCode => toUnit(DistanceUnit.UnitKM).distance;

  @override
  int compareTo(dynamic other) {
    assert(other != null);
    if (!(other is Distance)) {
      return 0;
    }

    if (this < other) {
      return -1;
    }
    if (this > other) {
      return 1;
    }
    return 0;
  }

  factory Distance.fromJson(Map<String, dynamic> json) {
    if (json != null && json.containsKey('distance') && json['unit'] != null) {
      return Distance(json['distance'],
          json['unit'] == 'mile' ? DistanceUnit.UnitMile : DistanceUnit.UnitKM);
    }
    debugPrint('Failed to parse distance from JSON. Missing fields.');
    return Distance(null);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['distance'] = distance;
    data['unit'] = unit == DistanceUnit.UnitMile ? 'mile' : 'km';
    return data;
  }
}
