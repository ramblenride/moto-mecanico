import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
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
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() {
  loadMotoMecanico();
}

void loadMotoMecanico() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _configureLocalTimeZone();

  await _initializeNotifications();

  await _deleteCacheDir();

  runApp(MotoLogApp());
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(currentTimeZone));
}

Future<void> _initializeNotifications() async {
  await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  const initSettingsAndroid = AndroidInitializationSettings('app_icon');

  final initSettings = InitializationSettings(
    android: initSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onSelectNotification: (String payload) async {
      if (payload != null) {
        debugPrint('notification payload: $payload');
        // FIXME: Show the task tied to the notification
        //selectNotificationSubject.add(payload);
      }
    },
  );

  // FIXME: Whatever creates notifications must check if enabled in config
  //await _createNotification();
  _showActiveNotifications();
  _showPendingNotifications();
}

/*
void _createNotification() async {
  return await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'scheduled title',
      'scheduled body',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      const NotificationDetails(
          android: AndroidNotificationDetails('your channel id',
              'your channel name', 'your channel description')),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime);
}
*/

void _showActiveNotifications() async {
  final activeNotifications = await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.getActiveNotifications();
  debugPrint('Active Notifications:');
  activeNotifications.forEach((element) => debugPrint(element.toString()));
}

void _showPendingNotifications() async {
  final pendingNotificationRequests =
      await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  debugPrint('Pending Notifications:');
  pendingNotificationRequests
      .forEach((element) => debugPrint(element.toString()));
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

    state.applyConfiguration();
  }
}

class _MotoLogAppState extends State<MotoLogApp> {
  Future _initialized;
  Configuration _config;
  LabelsModel _labels;
  GarageModel _garage;
  Locale _locale;

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
    await _labels.loadFromStorage();
  }

  Future<void> _setGarage() async {
    _garage = GarageModel();
    final garageStorage = GarageStorage();
    garageStorage.storage =
        LocalFileStorage(baseDir: await GarageStorage.getBaseDir());
    _garage.storage = garageStorage;
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
                  title: _config.packageInfo.appName,
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
              child: Text('Initialization Error: ' + snapshot.error),
            ));
          } else {
            return LoadingPage();
          }
        });
  }

  Locale _getLocale(Locale deviceLocale, Iterable<Locale> supportedLocales) {
    return supportedLocales.contains(deviceLocale)
        ? deviceLocale
        : supportedLocales.firstWhere(
            (element) =>
                element.languageCode.split(RegExp(r'[_-]'))[0] ==
                deviceLocale.languageCode.split(RegExp(r'[_-]'))[0],
            orElse: () => Locale('en'));
  }
}
