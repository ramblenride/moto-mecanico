import 'package:flutter_test/flutter_test.dart';
import 'package:moto_mecanico/models/garage_model.dart';
import 'package:moto_mecanico/models/motorcycle.dart';
import 'package:moto_mecanico/models/task.dart';
import 'package:moto_mecanico/storage/garage_storage.dart';
import 'package:moto_mecanico/storage/local_file_storage.dart';
import 'package:moto_mecanico/storage/motorcycle_local_storage.dart';

void main() {
  group('Storage Tests', () {
    void _removeStorageFiles() async {
      final storage =
          LocalFileStorage(baseDir: await GarageStorage.getBaseDir());
      await storage.removeDir('');
    }

    setUp(_removeStorageFiles);
    tearDown(_removeStorageFiles);

    test('garage storage can save and reload garage', () async {
      // Save garage
      final garage = GarageModel();
      garage.storage = GarageStorage();
      garage.storage.storage =
          LocalFileStorage(baseDir: await GarageStorage.getBaseDir());

      final motorcycle = Motorcycle(name: 'mine');
      motorcycle.storage = MotorcycleLocalStorage(motoId: motorcycle.id);
      await motorcycle.storage.connect();
      final task = Task(name: 'my task');
      motorcycle.addTask(task);
      await garage.add(motorcycle);

      // Create a new garage and load the data
      final garage2 = GarageModel();
      garage2.storage = GarageStorage();
      garage2.storage.storage =
          LocalFileStorage(baseDir: await GarageStorage.getBaseDir());

      await garage2.storage.loadGarage(garage2);
      expect(garage2.motos.length, equals(1));
      final moto2 = garage2.motos.first;
      expect(moto2.name, equals(motorcycle.name));

      expect(moto2.tasks.length, equals(1));
      final task2 = moto2.tasks.first;
      expect(task2.name, equals(task.name));
    });
  });
}
