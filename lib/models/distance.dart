import 'package:moto_mecanico/locale/formats.dart';

enum DistanceUnit {
  unitKm,
  unitMile,
}

class Distance implements Comparable<dynamic> {
  static const double kmToMiles = 0.621371;
  const Distance(this.distance, [this.unit = DistanceUnit.unitKm]);

  final int? distance;
  final DistanceUnit unit;

  bool get isValid => distance != null;

  Distance toUnit(DistanceUnit newUnit) {
    var newDistance = distance;
    if (distance != null && unit != newUnit) {
      if (newUnit == DistanceUnit.unitKm) {
        newDistance = (distance! / kmToMiles).round();
      } else {
        newDistance = (distance! * kmToMiles).round();
      }
    }
    return Distance(newDistance, newUnit);
  }

  @override
  String toString({bool compact = false}) {
    if (!isValid) return '';

    return (compact && distance!.abs() > 9999)
        ? '${(distance! ~/ 1000)}k'
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
    return Distance((distance ?? 0) + (other.toUnit(unit).distance ?? 0), unit);
  }

  // Returns the subtraction of other distance in the current unit.
  Distance operator -(Distance other) {
    return Distance((distance ?? 0) - (other.toUnit(unit).distance ?? 0), unit);
  }

  // Returns the multiplication of a distance with a constant.
  Distance operator *(int mul) {
    return Distance((distance ?? 0) * mul, unit);
  }

  bool operator >(Distance other) {
    return (distance ?? 0) > (other.toUnit(unit).distance ?? 0);
  }

  bool operator >=(Distance other) {
    return (distance ?? 0) >= (other.toUnit(unit).distance ?? 0);
  }

  bool operator <(Distance other) {
    return (distance ?? 0) < (other.toUnit(unit).distance ?? 0);
  }

  bool operator <=(Distance other) {
    return (distance ?? 0) <= (other.toUnit(unit).distance ?? 0);
  }

  @override
  bool operator ==(Object other) {
    return other is Distance && other.toUnit(unit).distance == distance;
  }

  @override
  int get hashCode => toUnit(DistanceUnit.unitKm).distance ?? 0;

  @override
  int compareTo(dynamic other) {
    assert(other != null);
    if (other is! Distance) {
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
    return Distance(
        json['distance'],
        json['unit'] != null && json['unit'] == 'mile'
            ? DistanceUnit.unitMile
            : DistanceUnit.unitKm);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['distance'] = distance;
    data['unit'] = unit == DistanceUnit.unitMile ? 'mile' : 'km';
    return data;
  }
}
