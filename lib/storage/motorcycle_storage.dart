import 'dart:io';

import 'package:moto_mecanico/models/motorcycle.dart';
import 'package:moto_mecanico/storage/storage.dart';

abstract class MotorcycleStorage {
  /// Return a string representation of the type of storage.
  String get type;

  /// Return additional information required to access storage.
  Map<String, dynamic> get storageInfo;

  /// Return the backend storage used for this object
  Storage get storage;

  /// Connect to the repository. Must be called exactly once before calling other methods.
  Future<bool> connect();

  /// Add a motorcycle repository.
  Future<bool> addMotorcycle(Motorcycle moto);

  /// Update the motorcycle repository.
  Future<bool> updateMotorcycle(Motorcycle moto);

  /// Remove the motorcycle repository.
  Future deleteMotorcycle();

  /// Return a file from a motorcycle repository (picture, attachment, etc).
  Future<File> getMotoFile(String id);

  /// Copy a file to a motorcycle repository and return the new file id.
  Future<String> addMotoFile(String sourcePath);

  /// Delete a file from the motorcycle repository.
  Future deleteMotoFile(String id);
}
