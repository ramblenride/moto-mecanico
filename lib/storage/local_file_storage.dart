import 'dart:async';
import 'dart:io';

import 'package:moto_mecanico/storage/storage.dart';
import 'package:moto_mecanico/storage/storage_utils.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Wraps storage access local files.
class LocalFileStorage extends Storage {
  final String _baseDir;

  LocalFileStorage({String baseDir}) : _baseDir = baseDir;

  static Future<String> getDefaultDir() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> getBaseDir() async => _baseDir ?? await getDefaultDir();

  @override
  Future<File> getFile(String filename) async {
    return File(await _localPath(filename));
  }

  @override
  Future<String> addExternalFile(String sourcePath) async {
    if (await createDir('', recursive: true) == null) return null;
    final destination = Uuid().v4() + getFileExtension(sourcePath);
    final output = await copyExternalFile(sourcePath, destination);
    return output != null ? destination : null;
  }

  @override
  Future<File> copyExternalFile(String input, String destination) async {
    final inputFile = File(input);
    return inputFile.copySync(await _localPath(destination));
  }

  @override
  Future deleteFile(String filename) async {
    final file = File(await _localPath(filename));
    if (await file.exists() == false) return true;
    await file.delete();
  }

  @override
  Future<Directory> createDir(String name, {bool recursive = false}) async {
    final fullPath = await _localPath(name);
    final dir = Directory(fullPath);
    if (await dir.exists() == false) {
      await dir.create(recursive: recursive);
    }
    return dir;
  }

  @override
  Future removeDir(String name) async {
    final fullPath = await _localPath(name);
    final dir = Directory(fullPath);
    if (await dir.exists() == true) {
      await dir.delete(recursive: true);
    }
  }

  Future<String> _localPath(String name) async {
    final baseDir = await getBaseDir();
    return join(baseDir, name);
  }
}
