import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:moto_mecanico/models/motorcycle.dart';
import 'package:moto_mecanico/motorcycle_alarms.dart';
import 'package:moto_mecanico/storage/garage_storage.dart';

enum MotorcycleSort {
  alarms,
  name,
  make,
  year,
}

class GarageModel extends ChangeNotifier {
  final List<Motorcycle> _motos = [];
  final Map<String, VoidCallback> _listeners = {};
  GarageStorage _storage;
  Function(Error) _onErrorCb; // FIXME: Use a event stream instead?
  bool _loading = false;

  GarageStorage get storage => _storage;
  set storage(GarageStorage storage) => _storage = storage;
  set onErrorCb(Function(Error) onErrorCb) => _onErrorCb = onErrorCb;

  /// Returns the complete unsorted list of motorcycles in the garage
  UnmodifiableListView<Motorcycle> get motos => UnmodifiableListView(_motos);

  /// Returns the sorted list of motorcycles matching the current filter
  List<Motorcycle> getFilteredMotos(String filter, MotorcycleSort sortMethod) {
    return _motos.where((moto) {
      return (filter == null || moto.matches(filter));
    }).toList()
      ..sort((a, b) {
        switch (sortMethod) {
          case MotorcycleSort.alarms:
            {
              // Reverse sort alarms (higher alarms go first)
              var red =
                  b.getRedAlerts().length.compareTo(a.getRedAlerts().length);
              if (red != 0) return red;

              return b
                  .getYellowAlerts()
                  .length
                  .compareTo(a.getYellowAlerts().length);
            }
          case MotorcycleSort.name:
            {
              return a.name.compareTo(b.name);
            }
          case MotorcycleSort.make:
            {
              return (a.make ?? '').compareTo(b.make ?? '');
            }
          case MotorcycleSort.year:
            {
              return (a.year ?? 0).compareTo(b.year ?? 0);
            }
        }

        // FIXME: Needed because of the analyzer.
        return 0;
      });
  }

  void _motoEventListener(Motorcycle moto) {
    try {
      moto.storage.updateMotorcycle(moto);
    } catch (error) {
      _handleError(error, 'Failed to save motorcycle to storage.');
    }
  }

  /// Adds a motorcycle to the garage and notifies listeners.
  Future<void> add(Motorcycle moto) async {
    if (_motos.contains(moto) == false) {
      _motos.add(moto);

      final listener = () => _motoEventListener(moto);
      _listeners[moto.id] = listener;
      moto.addListener(listener);

      notifyListeners();
      if (_loading == false && _storage != null) {
        try {
          await _storage.addMotorcycle(this, moto);
        } catch (error) {
          _handleError(error, 'Failed to save motorcycle to storage.');
        }
      }
    }
  }

  /// Removes a specific motorcycle from the garage and notifies listeners.
  void remove(Motorcycle moto) {
    _motos.remove(moto);

    notifyListeners();
    if (_storage != null) {
      moto.removeListener(_listeners[moto.id]);
      _listeners.remove(moto.id);
      try {
        _storage.deleteMotorcycle(this, moto);
      } catch (error) {
        _handleError(error, 'Failed to remove motorcycle from storage.');
      }
    }
  }

  Future<void> loadFromIndex() async {
    if (_storage != null) {
      _loading = true;
      try {
        await _storage.loadGarage(this);
      } catch (error) {
        _handleError(error, 'Failed to load garage.');
      }
      _loading = false;
    }
  }

  void _handleError(Error error, String message) {
    debugPrint('Error: $message}');
    debugPrint('Exception: ${error.toString()}');
    if (_onErrorCb != null) {
      _onErrorCb(error);
    }
  }
}
