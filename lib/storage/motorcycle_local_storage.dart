import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:moto_mecanico/models/motorcycle.dart';
import 'package:moto_mecanico/models/task.dart';
import 'package:moto_mecanico/storage/garage_storage.dart';
import 'package:moto_mecanico/storage/local_file_storage.dart';
import 'package:moto_mecanico/storage/motorcycle_storage.dart';
import 'package:moto_mecanico/storage/storage.dart';
import 'package:path/path.dart';

class MotorcycleLocalStorage extends MotorcycleStorage {
  late final Storage _storage;
  final String motoId;
  MotorcycleLocalStorage({required this.motoId});

  @override
  Future<bool> connect({String? baseDir}) async {
    // FIXME: Force passing the base dir in the constructor?
    // Not possible right now because of the MotorcycleAddEditPage
    final root = baseDir ?? await GarageStorage.getBaseDir();
    _storage = LocalFileStorage(baseDir: join(root, motoId));
    return true;
  }

  @override
  String get type => 'local';
  @override
  Map<String, dynamic> get storageInfo => {};

  @override
  Storage get storage => _storage;

  @override
  Future<bool> addMotorcycle(Motorcycle moto) async {
    try {
      await _storage.createDir('', recursive: true);
    } catch (error) {
      return false;
    }
    return await updateMotorcycle(moto);
  }

  @override
  Future<bool> updateMotorcycle(Motorcycle moto) async {
    await _storage.saveToJson(
        _getMotoFilename(motoId), moto.toJson(encodeTasks: false));
    final tasks = <String, dynamic>{};
    tasks['tasks'] = moto.tasks.map((v) => v.toJson()).toList();
    return await _storage.saveToJson(_getTasksFilename(motoId), tasks);
  }

  @override
  Future deleteMotorcycle() async {
    return await _storage.removeDir('');
  }

  @override
  Future<File?> getMotoFile(String id) async {
    return await _storage.getFile(id);
  }

  @override
  Future<String?> addMotoFile(String sourcePath) async {
    return await _storage.addExternalFile(sourcePath);
  }

  @override
  Future deleteMotoFile(String id) async {
    return await _storage.deleteFile(id);
  }

  // Throws an error if the motorcycle cannot be loaded
  Future<Motorcycle> loadMotorcycle(String id) async {
    final motoJson = await _storage.getFromJson(_getMotoFilename(id));
    final motorcycle = Motorcycle.fromJson(motoJson);

    final taskJson = await _storage.getFromJson(_getTasksFilename(id));
    if (taskJson['tasks'] != null) {
      taskJson['tasks'].forEach((t) {
        try {
          final task = Task.fromJson(t);
          motorcycle.addTask(task);
        } catch (e) {
          debugPrint("Ignoring invalid task JSON: $e");
        }
      });
    }

    return motorcycle;
  }

  String _getMotoFilename(String id) {
    return '$id.json';
  }

  String _getTasksFilename(String id) {
    return '$id-tasks.json';
  }
}
