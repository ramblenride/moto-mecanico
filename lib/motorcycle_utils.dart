import 'package:flutter/material.dart';
import 'package:moto_mecanico/assets.dart';
import 'package:moto_mecanico/models/motorcycle.dart';

Future<ImageProvider> getMotoPicture(Motorcycle moto) async {
  assert(moto != null);

  ImageProvider provider;
  if (moto.picture != null) {
    try {
      provider = FileImage(await moto.storage.getMotoFile(moto.picture));
    } catch (e) {
      debugPrint('Failed to load motorcycle image file:\n$e');
    }
  }

  provider ??= AssetImage(IMG_MOTO_DEFAULT);
  return provider;
}
