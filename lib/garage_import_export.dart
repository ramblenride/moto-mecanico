import 'dart:io';

import 'package:flutter_archive/flutter_archive.dart';
import 'package:moto_mecanico/models/garage_model.dart';
import 'package:moto_mecanico/storage/garage_storage.dart';
import 'package:moto_mecanico/storage/local_file_storage.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

const ARCHIVE_NAME = 'moto_mechanico_archive.zip';

class GarageImportExport {
  // NOTE: This will get more complex once the app supports remote repositories.
  static Future<File> Export(GarageModel garage) async {
    final storage = garage.storage;
    if (storage == null) return null;

    final dataDir = Directory(await storage.storage.getBaseDir());
    final archiveDir = await getTemporaryDirectory();

    final zipFile = File(join(archiveDir.path, ARCHIVE_NAME));
    if (await zipFile.exists() == true) {
      await zipFile.delete(recursive: true);
    }
    await ZipFile.createFromDirectory(
        sourceDir: dataDir, zipFile: zipFile, recurseSubDirs: true);
    return zipFile;
  }

  static Future<GarageModel> Import(File archive) async {
    final tempDir = (await getTemporaryDirectory()).path;
    final archiveDir = Directory(join(tempDir, 'import'));

    if (await archiveDir.exists()) {
      await archiveDir.delete(recursive: true);
    }
    await ZipFile.extractToDirectory(
        zipFile: archive, destinationDir: archiveDir);
    final garage = GarageModel();
    garage.storage = GarageStorage();
    garage.storage.storage = LocalFileStorage(baseDir: archiveDir.path);
    await garage.storage.loadGarage(garage);
    return garage;
  }

  static void RemoveTempDirectory() async {
    final tempDir = (await getTemporaryDirectory()).path;
    final archiveDir = Directory(join(tempDir, 'import'));

    if (await archiveDir.exists()) {
      await archiveDir.delete(recursive: true);
    }
  }
}
