import 'dart:convert';
import 'dart:io';

abstract class Storage {
  Future<File?> getFile(String filename);

  // Copy a file with an absolute path to a local file with a unique name.
  Future<String?> addExternalFile(String sourcePath);

  // Copy a file with an absolute path to a local destination
  Future<File?> copyExternalFile(String input, String destination);

  Future deleteFile(String filename);

  Future<Directory?> createDir(String name, {bool recursive = false});

  Future removeDir(String name);

  Future<Map<String, dynamic>> getFromJson(String name) async {
    final file = await getFile(name);
    if (file != null && file.existsSync() == false ||
        await file!.lengthSync() == 0) {
      return {};
    }

    final contents = await file.readAsString();
    return jsonDecode(contents);
  }

  Future<bool> saveToJson(String filename, Map<String, dynamic> json) async {
    final file = await getFile(filename);
    final content = jsonEncode(json);
    if (file != null && content.isNotEmpty) {
      await file.writeAsString(content);
    }
    return true;
  }
}
