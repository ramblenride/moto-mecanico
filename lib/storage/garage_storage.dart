import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:moto_mecanico/models/garage.dart';
import 'package:moto_mecanico/models/motorcycle.dart';
import 'package:moto_mecanico/storage/local_file_storage.dart';
import 'package:moto_mecanico/storage/motorcycle_local_storage.dart';
import 'package:path/path.dart';

const _indexFile = 'garageIndex.json';
const _garageDir = 'db';

class GarageStorage {
  LocalFileStorage? storage;

  static Future<String> getBaseDir() async =>
      join(await LocalFileStorage.getDefaultDir(), _garageDir);

  Future<bool> addMotorcycle(GarageModel garage, Motorcycle moto) async {
    await saveGarage(garage);
    if (moto.storage != null) {
      return await moto.storage!.addMotorcycle(moto);
    }
    return true;
  }

  Future<bool> updateMotorcycle(GarageModel garage, Motorcycle moto) async {
    if (moto.storage != null) {
      return await moto.storage!.updateMotorcycle(moto);
    }
    return true;
  }

  Future deleteMotorcycle(GarageModel garage, Motorcycle moto) async {
    await saveGarage(garage);
    if (moto.storage != null) {
      return await moto.storage!.deleteMotorcycle();
    }
    return true;
  }

  Future loadGarage(GarageModel garage) async {
    if (storage == null) return;

    final json = await storage!.getFromJson(_getIndexFilename());
    return await _loadGarageIndexMap(garage, json);
  }

  Future<bool> saveGarage(GarageModel garage) async {
    if (storage == null) return false;

    await storage!.createDir('');
    return await storage!.saveToJson(_getIndexFilename(), _toIndexMap(garage));
  }

  Map<String, dynamic> _toIndexMap(GarageModel garage) {
    final data = <String, dynamic>{};

    data['motorcycles'] =
        garage.motos.where((moto) => moto.storage != null).map((moto) {
      return {
        'id': moto.id,
        'storage': moto.storage!.type,
        'storageInfo': moto.storage!.storageInfo,
      };
    }).toList();

    return data;
  }

  Future<void> _loadGarageIndexMap(
      GarageModel garage, Map<String, dynamic> json) async {
    if (json['motorcycles'] != null) {
      for (dynamic v in json['motorcycles']) {
        await _loadMotorcycle(garage, v);
      }
    }
  }

  Future<void> _loadMotorcycle(
      GarageModel garage, Map<String, dynamic> v) async {
    try {
      final id = v['id'];
      final storageType = v['storage'];
      if (id != null &&
          storageType != null &&
          garage.storage?.storage != null) {
        // FIXME: Use different storage object if not local
        final motoStorage = MotorcycleLocalStorage(motoId: id);
        await motoStorage.connect(
            baseDir: await garage.storage!.storage!.getBaseDir());
        try {
          final moto = await motoStorage.loadMotorcycle(id);
          moto.storage = motoStorage;
          await garage.add(moto);
        } catch (e) {
          debugPrint('Failed to load motorcycle $id from storage: $e');
        }
      } else {
        debugPrint('Failed to find motorcycle info in index file');
      }
    } catch (e) {
      debugPrint('Failed to parse a motorcycle from JSON storage: $e');
    }
  }

  String _getIndexFilename() {
    return _indexFile;
  }
}
