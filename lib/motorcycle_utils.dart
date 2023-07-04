import 'package:flutter/material.dart';
import 'package:moto_mecanico/assets.dart';
import 'package:moto_mecanico/models/motorcycle.dart';

Future<ImageProvider> getMotoPicture(Motorcycle moto) async {
  ImageProvider? provider;
  if (moto.picture.isNotEmpty && moto.storage != null) {
    try {
      final imageFile = await moto.storage!.getMotoFile(moto.picture);
      if (imageFile != null) {
        provider = FileImage(imageFile);
      }
    } catch (e) {
      debugPrint('Failed to load motorcycle image file:\n$e');
    }
  }

  provider ??= AssetImage(IMG_MOTO_DEFAULT);
  return provider;
}
