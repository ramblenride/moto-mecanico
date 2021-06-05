import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:moto_mecanico/models/garage_model.dart';
import 'package:moto_mecanico/models/motorcycle.dart';
import 'package:moto_mecanico/storage/local_file_storage.dart';
import 'package:moto_mecanico/storage/motorcycle_local_storage.dart';
import 'package:moto_mecanico/storage/storage.dart';
import 'package:path/path.dart';

const _INDEX_FILE = 'garageIndex.json';
const _GARAGE_DIR = 'db';

class GarageStorage {
  Storage _storage;

  static Future<String> getBaseDir() async =>
      join(await LocalFileStorage.getDefaultDir(), _GARAGE_DIR);

  LocalFileStorage get storage => _storage;
  set storage(Storage storage) => _storage = storage;

  Future<bool> addMotorcycle(GarageModel garage, Motorcycle moto) async {
    await saveGarage(garage);
    if (moto.storage != null) {
      return await moto.storage.addMotorcycle(moto);
    }
    return true;
  }

  Future<bool> updateMotorcycle(GarageModel garage, Motorcycle moto) async {
    if (moto.storage != null) {
      return await moto.storage.updateMotorcycle(moto);
    }
    return true;
  }

  Future deleteMotorcycle(GarageModel garage, Motorcycle moto) async {
    await saveGarage(garage);
    if (moto.storage != null) {
      return await moto.storage.deleteMotorcycle();
    }
    return true;
  }

  Future loadGarage(GarageModel garage) async {
    final json = await _storage.getFromJson(_getIndexFilename());
    return await _loadGarageIndexMap(garage, json);
  }

  Future<bool> saveGarage(GarageModel garage) async {
    if (await _storage.createDir('') == null) return false;
    return await _storage.saveToJson(_getIndexFilename(), _toIndexMap(garage));
  }

  Map<String, dynamic> _toIndexMap(GarageModel garage) {
    final data = <String, dynamic>{};
    data['motorcycles'] =
        garage.motos.where((moto) => moto.storage != null).map((moto) {
      return {
        'id': moto.id,
        'storage': moto.storage.type,
        'storageInfo': moto.storage.storageInfo,
      };
    }).toList();
    return data;
  }

  Future<void> _loadGarageIndexMap(
      GarageModel garage, Map<String, dynamic> json) async {
    if (json != null && json['motorcycles'] != null) {
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
      //final storageInfo = v['storageInfo'];
      if (id != null && storageType != null) {
        // FIXME: Use different storage object if not local
        final motoStorage = MotorcycleLocalStorage(motoId: id);
        await motoStorage.connect(
            baseDir: await garage.storage.storage.getBaseDir());
        final moto = await motoStorage.loadMotorcycle(id);
        if (moto != null) {
          moto.storage = motoStorage;
          await garage.add(moto);
        } else {
          debugPrint('Failed to load motorcycle ${id} from storage');
        }
      } else {
        debugPrint('Failed to find motorcycle info in index file');
      }
    } catch (e) {
      debugPrint('Failed to parse a motorcycle from JSON storage:');
      debugPrint(e.toString());
    }
  }

  String _getIndexFilename() {
    return _INDEX_FILE;
  }
}
