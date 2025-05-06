import 'package:flutter/material.dart';
import 'package:intl/intl_standalone.dart';
import 'package:moto_mecanico/configuration.dart';
import 'package:moto_mecanico/models/labels.dart';
import 'package:moto_mecanico/moto_log_app.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  loadMotoMecanico();
}

Future<void> loadMotoMecanico() async {
  await _deleteCacheDir();
  final config = await _loadConfig();
  final locale = config.locale;
  final labels = await _loadLabels();

  runApp(MotoLogApp(
      preferences: await SharedPreferences.getInstance(),
      config: config,
      locale: locale,
      labels: labels));
}

Future<void> _deleteCacheDir() async {
  final cacheDir = await getTemporaryDirectory();
  if (cacheDir.existsSync()) {
    try {
      cacheDir.deleteSync(recursive: true);
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}

Future<Configuration> _loadConfig() async {
  final config = Configuration(await findSystemLocale());
  await config.loadConfig();
  // FIXME: Putting this inside loadConfig breaks the unit tests
  config.packageInfo = await PackageInfo.fromPlatform();
  return config;
}

Future<LabelsModel> _loadLabels() async {
  final labels = LabelsModel();
  await labels.loadFromStorage();
  return labels;
}
