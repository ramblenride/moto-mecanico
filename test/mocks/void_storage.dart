import 'dart:async';
import 'dart:io';

import 'package:moto_mecanico/storage/local_file_storage.dart';

class VoidStorage extends LocalFileStorage {
  static Future<String> getDefaultDir() async {
    return '/tmp';
  }

  @override
  Future<String> getBaseDir() async => '/tmp';

  @override
  Future<File> getFile(String filename) async {
    return File('');
  }

  @override
  Future<String> addExternalFile(String sourcePath) async {
    return '';
  }

  @override
  Future<File> copyExternalFile(String input, String destination) async {
    return File('');
  }

  @override
  Future deleteFile(String filename) async {
    return;
  }

  @override
  Future<Directory> createDir(String name, {bool recursive = false}) async {
    return Directory('');
  }

  @override
  Future removeDir(String name) async {
    return;
  }
}
