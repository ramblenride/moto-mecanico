import 'dart:async';
import 'dart:io';

import 'package:moto_mecanico/models/motorcycle.dart';
import 'package:moto_mecanico/storage/motorcycle_storage.dart';
import 'package:moto_mecanico/storage/storage.dart';

import 'void_storage.dart';

class MotorcycleVoidStorage extends MotorcycleStorage {
  MotorcycleVoidStorage();

  @override
  Future<bool> connect({String baseDir}) async {
    return true;
  }

  @override
  String get type => 'void';
  @override
  Map<String, dynamic> get storageInfo => {};

  @override
  Storage get storage => VoidStorage();

  @override
  Future<bool> addMotorcycle(Motorcycle moto) async {
    return true;
  }

  @override
  Future<bool> updateMotorcycle(Motorcycle moto) async {
    return true;
  }

  @override
  Future deleteMotorcycle() async {
    return;
  }

  @override
  Future<File> getMotoFile(String id) async {
    return null;
  }

  @override
  Future<String> addMotoFile(String sourcePath) async {
    return '';
  }

  @override
  Future deleteMotoFile(String id) async {
    return;
  }

  Future<Motorcycle> loadMotorcycle(String id) async {
    return null;
  }
}
