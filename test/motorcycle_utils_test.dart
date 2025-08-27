import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moto_mecanico/assets.dart';
import 'package:moto_mecanico/models/motorcycle.dart';
import 'package:moto_mecanico/motorcycle_utils.dart';

import 'mocks/motorcycle_void_storage.dart';

void main() {
  group('getMotoPicture', () {
    late Motorcycle testMotorcycle;
    late MotorcycleVoidStorage mockStorage;

    setUp(() {
      mockStorage = MotorcycleVoidStorage();
      testMotorcycle = Motorcycle(name: 'test-moto');
      testMotorcycle.storage = mockStorage;
    });

    test('returns default asset image when picture is empty', () async {
      // Arrange
      testMotorcycle.picture = '';

      // Act
      final result = await getMotoPicture(testMotorcycle);

      // Assert
      expect(result, isA<AssetImage>());
      expect((result as AssetImage).assetName, equals(imgMotoDefault));
    });

    test('returns default asset image when storage is null', () async {
      // Arrange
      testMotorcycle.picture = 'some-picture.jpg';
      testMotorcycle.storage = null;

      // Act
      final result = await getMotoPicture(testMotorcycle);

      // Assert
      expect(result, isA<AssetImage>());
      expect((result as AssetImage).assetName, equals(imgMotoDefault));
    });

    test('returns default asset image when getMotoFile returns null', () async {
      // Arrange
      testMotorcycle.picture = 'nonexistent-picture.jpg';
      // MotorcycleVoidStorage.getMotoFile always returns null

      // Act
      final result = await getMotoPicture(testMotorcycle);

      // Assert
      expect(result, isA<AssetImage>());
      expect((result as AssetImage).assetName, equals(imgMotoDefault));
    });

    test('returns default asset image when getMotoFile throws exception',
        () async {
      // Arrange
      final mockStorageWithException = _MockStorageWithException();
      testMotorcycle.picture = 'error-picture.jpg';
      testMotorcycle.storage = mockStorageWithException;

      // Act
      final result = await getMotoPicture(testMotorcycle);

      // Assert
      expect(result, isA<AssetImage>());
      expect((result as AssetImage).assetName, equals(imgMotoDefault));
    });

    test('returns FileImage when valid file is found', () async {
      // Arrange
      final mockStorageWithFile = _MockStorageWithFile();
      testMotorcycle.picture = 'valid-picture.jpg';
      testMotorcycle.storage = mockStorageWithFile;

      // Act
      final result = await getMotoPicture(testMotorcycle);

      // Assert
      expect(result, isA<FileImage>());
      expect((result as FileImage).file.path, equals('/fake/path/picture.jpg'));
    });
  });
}

/// Mock storage that throws exception when getMotoFile is called
class _MockStorageWithException extends MotorcycleVoidStorage {
  @override
  Future<File?> getMotoFile(String id) async {
    throw Exception('Mock storage error for testing');
  }
}

/// Mock storage that returns a valid File when getMotoFile is called
class _MockStorageWithFile extends MotorcycleVoidStorage {
  @override
  Future<File?> getMotoFile(String id) async {
    return File('/fake/path/picture.jpg');
  }
}
