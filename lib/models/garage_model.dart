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

class GarageModel with ChangeNotifier {
  final List<Motorcycle> _motos = [];
  final Map<String, VoidCallback> _listeners = {};
  GarageStorage? storage;
  Function(Error)? _onErrorCb; // FIXME: Use a event stream instead?
  bool _loading = false;

  set onErrorCb(Function(Error) onErrorCb) => _onErrorCb = onErrorCb;

  /// Returns the complete unsorted list of motorcycles in the garage
  UnmodifiableListView<Motorcycle> get motos => UnmodifiableListView(_motos);

  /// Returns the sorted list of motorcycles matching the current filter
  List<Motorcycle> getFilteredMotos(String? filter, MotorcycleSort sortMethod) {
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
              return (a.make).compareTo(b.make);
            }
          case MotorcycleSort.year:
            {
              return (a.year ?? 0).compareTo(b.year ?? 0);
            }
        }
      });
  }

  void _motoEventListener(Motorcycle moto) {
    if (moto.storage != null) {
      moto.storage!.updateMotorcycle(moto).catchError((error) {
        _handleError(error, 'Failed to save motorcycle to storage.');
        return true;
      });
    }
  }

  /// Adds a motorcycle to the garage and notifies listeners.
  Future<void> add(Motorcycle moto) async {
    if (_motos.contains(moto) == false) {
      _motos.add(moto);

      void listener() => _motoEventListener(moto);
      _listeners[moto.id] = listener;
      moto.addListener(listener);

      notifyListeners();
      if (_loading == false && storage != null) {
        try {
          await storage!.addMotorcycle(this, moto);
        } on Error catch (error) {
          _handleError(error, 'Failed to save motorcycle to storage.');
        }
      }
    }
  }

  /// Removes a specific motorcycle from the garage and notifies listeners.
  void remove(Motorcycle moto) {
    _motos.remove(moto);

    notifyListeners();
    if (storage != null) {
      var listener = _listeners[moto.id];
      if (listener != null) {
        moto.removeListener(listener);
        _listeners.remove(moto.id);
      }
      try {
        storage!.deleteMotorcycle(this, moto);
      } on Error catch (error) {
        _handleError(error, 'Failed to remove motorcycle from storage.');
      }
    }
  }

  Future<void> loadFromIndex() async {
    if (storage != null) {
      _loading = true;
      try {
        await storage!.loadGarage(this);
      } on Error catch (error) {
        _handleError(error, 'Failed to load garage.');
      }
      _loading = false;
    }
  }

  void _handleError(Error error, String message) {
    debugPrint('Error: $message}');
    debugPrint('Exception: ${error.toString()}');
    if (_onErrorCb != null) {
      _onErrorCb!(error);
    }
  }
}
