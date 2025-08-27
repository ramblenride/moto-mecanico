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
import 'package:moto_mecanico/assets.dart';
import 'package:moto_mecanico/themes.dart';
import 'package:moto_mecanico/widgets/config_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MotoLogApp extends StatefulWidget {
  final SharedPreferences preferences;
  final LabelsModel? labels;
  final GarageModel? garage;

  const MotoLogApp(
      {super.key, required this.preferences, this.labels, this.garage});

  @override
  State<StatefulWidget> createState() => _MotoLogAppState();

  static void applyConfiguration(BuildContext context) {
    final state = context.findAncestorStateOfType<_MotoLogAppState>();

    state?.applyConfiguration();
  }
}

class _MotoLogAppState extends State<MotoLogApp> {
  Configuration? _config;
  Locale? _locale;

  void applyConfiguration() {
    if (_config != null) {
      setState(() {
        _locale = _config!.locale;
      });
    }
  }

  Future<Configuration> _loadConfig() async {
    _config = Configuration(await findSystemLocale());
    await _config!.loadConfig();
    _locale = _config!.locale;
    return _config!;
  }

  Future<LabelsModel> _loadLabels() async {
    if (widget.labels != null) return widget.labels!;

    var labels = LabelsModel();
    await labels.loadFromStorage();
    return labels;
  }

  Future<GarageModel> _setGarage() async {
    if (widget.garage != null) return widget.garage!;

    var garage = GarageModel();
    final garageStorage = GarageStorage();
    garageStorage.storage =
        LocalFileStorage(baseDir: await GarageStorage.getBaseDir());
    garage.storage = garageStorage;
    return garage;
  }

  Future<(LabelsModel, GarageModel)> _initConfiguration() async {
    await _loadConfig();
    final labels = await _loadLabels();
    final garage = await _setGarage();
    return (labels, garage);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initConfiguration(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            final labels = snapshot.data.$1 as LabelsModel;
            final garage = snapshot.data.$2 as GarageModel;
            return ConfigWidget(
              config: _config!,
              child: MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                      create: (_) => garage,
                    ),
                    ChangeNotifierProvider(
                      create: (_) => labels,
                    ),
                  ],
                  builder: (context, widget) {
                    return MaterialApp(
                      title: appTitle,
                      darkTheme: Theme.of(context).rnrDarkTheme,
                      themeMode: ThemeMode.dark,
                      home: const GaragePage(),
                      locale: _locale,
                      localizationsDelegates:
                          AppLocalizations.localizationsDelegates,
                      supportedLocales: AppLocalizations.supportedLocales,
                    );
                  }),
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                  'Initialization Error: ${snapshot.error?.toString() ?? ''}'),
            ));
          } else {
            return const LoadingPage();
          }
        });
  }
}
