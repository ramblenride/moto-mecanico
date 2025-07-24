import 'package:flutter/material.dart';
import 'package:moto_mecanico/moto_log_app.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  loadMotoMecanico();
}

Future<void> loadMotoMecanico() async {
  await _deleteCacheDir();

  runApp(MotoLogApp(
    preferences: await SharedPreferences.getInstance(),
  ));
}

Future<void> _deleteCacheDir() async {
  final cacheDir = await getTemporaryDirectory();
  try {
    await cacheDir.delete(recursive: true);
  } catch (error) {
    debugPrint(error.toString());
  }
}
