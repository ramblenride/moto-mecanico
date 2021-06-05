import 'dart:async';
import 'dart:io';

import 'package:moto_mecanico/storage/storage.dart';

class VoidStorage extends Storage {
  static Future<String> getDefaultDir() async {
    return '/tmp';
  }

  Future<String> getBaseDir() async => '/tmp';

  @override
  Future<File> getFile(String filename) async {
    return null;
  }

  @override
  Future<String> addExternalFile(String sourcePath) async {
    return null;
  }

  @override
  Future<File> copyExternalFile(String input, String destination) async {
    return null;
  }

  @override
  Future deleteFile(String filename) async {
    return;
  }

  @override
  Future<Directory> createDir(String name, {bool recursive = false}) async {
    return null;
  }

  @override
  Future removeDir(String name) async {
    return;
  }
}
