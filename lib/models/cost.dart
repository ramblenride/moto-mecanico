import 'package:flutter/foundation.dart';

enum CostType { part, labor, other }

// FIXME: Enable immutability when all usages are converted to use copyWith.
//@immutable
class Cost {
  String description;
  int value;
  CostType type;
  bool copyable;

  Cost(this.value, this.description,
      {this.type = CostType.other, this.copyable = false})
      : assert(value >= 0, 'Cost value cannot be negative');

  Cost.from(Cost cost)
      : description = cost.description,
        value = cost.value,
        type = cost.type,
        copyable = cost.copyable;

  Cost copyWith({
    String? description,
    int? value,
    CostType? type,
    bool? copyable,
  }) {
    return Cost(
      value ?? this.value,
      description ?? this.description,
      type: type ?? this.type,
      copyable: copyable ?? this.copyable,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cost &&
        other.description == description &&
        other.value == value &&
        other.type == type &&
        other.copyable == copyable;
  }

  @override
  int get hashCode {
    return Object.hash(description, value, type, copyable);
  }

  @override
  String toString() {
    return 'Cost(description: $description, value: $value, type: $type, copyable: $copyable)';
  }

  static Cost? fromJson(Map<String, dynamic> json) {
    try {
      var description = json['description'] ?? '';
      var value = json['value'] ?? 0;
      var type = CostType.values.byName(json['type'] ?? 'other');
      var copyable = json['copyable'] ?? false;

      return Cost(value, description, type: type, copyable: copyable);
    } catch (e) {
      debugPrint('Failed to parse cost:');
      debugPrint(e.toString());
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['description'] = description;
    data['value'] = value;

    switch (type) {
      case CostType.part:
        data['type'] = 'part';
        break;
      case CostType.labor:
        data['type'] = 'labor';
        break;
      case CostType.other:
        data['type'] = 'other';
        break;
    }

    data['copyable'] = copyable;
    return data;
  }

  static Cost total(List<Cost> costs, CostType? type) {
    final filteredCosts =
        type == null ? costs : costs.where((c) => c.type == type);

    final totalValue =
        filteredCosts.fold<int>(0, (sum, cost) => sum + cost.value);
    return Cost(totalValue, 'Total', type: type ?? CostType.other);
  }
}
