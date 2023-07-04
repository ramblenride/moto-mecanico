import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl_standalone.dart';
import 'package:moto_mecanico/configuration.dart';
import 'package:moto_mecanico/models/garage_model.dart';
import 'package:moto_mecanico/models/labels.dart';
import 'package:moto_mecanico/pages/garage_page.dart';
import 'package:moto_mecanico/pages/loading_page.dart';
import 'package:moto_mecanico/storage/garage_storage.dart';
import 'package:moto_mecanico/storage/local_file_storage.dart';
import 'package:moto_mecanico/themes.dart';
import 'package:moto_mecanico/widgets/config_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

void main() {
  loadMotoMecanico();
}

Future<void> loadMotoMecanico() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _deleteCacheDir();

  runApp(MotoLogApp());
}

Future<void> _deleteCacheDir() async {
  final cacheDir = await getTemporaryDirectory();
  if (cacheDir.existsSync()) {
    try {
      await cacheDir.delete(recursive: true);
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}

class MotoLogApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MotoLogAppState();

  static void applyConfiguration(BuildContext context) {
    final state = context.findAncestorStateOfType<_MotoLogAppState>();

    state?.applyConfiguration();
  }
}

class _MotoLogAppState extends State<MotoLogApp> {
  Configuration _config = Configuration('');
  Future? _initialized;
  LabelsModel? _labels;
  GarageModel? _garage;
  Locale? _locale;

  void applyConfiguration() {
    setState(() {
      _locale = _config.locale;
    });
  }

  Future<void> _loadConfig() async {
    _config = Configuration(await findSystemLocale());
    await _config.loadConfig();
    _config.packageInfo = await PackageInfo.fromPlatform();
    _locale = _config.locale;
  }

  Future<void> _loadLabels() async {
    _labels = LabelsModel();
    await _labels?.loadFromStorage();
  }

  Future<void> _setGarage() async {
    _garage = GarageModel();
    final garageStorage = GarageStorage();
    garageStorage.storage =
        LocalFileStorage(baseDir: await GarageStorage.getBaseDir());
    _garage?.storage = garageStorage;
  }

  Future<bool> _initConfiguration() async {
    await _loadConfig();
    await _loadLabels();
    await _setGarage();
    return true;
  }

  @override
  void initState() {
    super.initState();
    _initialized = _initConfiguration();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialized,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return ConfigWidget(
              config: _config,
              child: MultiProvider(
                providers: [
                  ChangeNotifierProvider.value(
                    value: _garage,
                  ),
                  ChangeNotifierProvider.value(
                    value: _labels,
                  ),
                ],
                child: MaterialApp(
                  title: _config.packageInfo?.appName ?? '',
                  darkTheme: Theme.of(context).RnrDarkTheme,
                  themeMode: ThemeMode.dark,
                  home: GaragePage(),
                  locale: _locale,
                  localeResolutionCallback: _getLocale,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text('Initialization Error: ' +
                  (snapshot.error?.toString() ?? '')),
            ));
          } else {
            return LoadingPage();
          }
        });
  }

  Locale? _getLocale(Locale? deviceLocale, Iterable<Locale> supportedLocales) {
    if (deviceLocale == null) return null;
    return supportedLocales.contains(deviceLocale)
        ? deviceLocale
        : supportedLocales.firstWhere(
            (element) =>
                element.languageCode.split(RegExp(r'[_-]'))[0] ==
                deviceLocale.languageCode.split(RegExp(r'[_-]'))[0],
            orElse: () => Locale('en'));
  }
}
