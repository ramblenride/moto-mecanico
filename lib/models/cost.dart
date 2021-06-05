import 'package:flutter/foundation.dart';

enum CostType { part, labor, other }

class Cost {
  String description;
  int value;
  CostType type;
  bool copyable;

  Cost(this.value, this.description,
      {this.type = CostType.other, this.copyable = false}) {
    value ??= 0;
    description ??= '';
  }

  static Cost total(List<Cost> costs, CostType type) {
    const sumStr = 'Total';
    if (costs.isEmpty) return Cost(0, sumStr, type: type);
    return costs.reduce((Cost total, Cost cost) {
      if (type == null || type == cost.type) {
        return Cost(total.value + cost.value, sumStr, type: type);
      } else {
        return total;
      }
    });
  }

  Cost.from(Cost cost) {
    description = cost.description;
    value = cost.value;
    type = cost.type;
    copyable = cost.copyable;
  }

  Cost.fromJson(Map<String, dynamic> json) {
    try {
      description = json['description'] ?? '';
      value = json['value'] ?? 0;

      switch (json['type']) {
        case 'part':
          type = CostType.part;
          break;
        case 'labor':
          type = CostType.labor;
          break;
        default:
          type = CostType.other;
          break;
      }

      copyable = json['copyable'] ?? false;
    } catch (e) {
      debugPrint('Failed to parse cost:');
      debugPrint(e.toString());
      value = 0;
      description = '';
      type = CostType.other;
      copyable = false;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['description'] = description;
    data['value'] = value;

    if (type != null) {
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
    }

    data['copyable'] = copyable;
    return data;
  }
}
