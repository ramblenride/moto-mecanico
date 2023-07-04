import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:moto_mecanico/configuration.dart';
import 'package:moto_mecanico/models/distance.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('configuration has default values (en_US)', () async {
    SharedPreferences.setMockInitialValues({});
    final config = Configuration('en_US');
    await config.loadConfig();

    expect(config.locale, equals(null));
    expect(config.currencySymbol, equals('USD'));
    expect(config.dateFormat, isNot(null));
    expect(
      DateFormat(config.dateFormat).format(DateTime(2020, 12, 30)),
      equals('12/30/2020'),
    );
    expect(config.distanceUnit, equals(DistanceUnit.UnitMile));
  });

  test('configuration has default values (fr_FR)', () async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting();
    final config = Configuration('fr_FR');
    await config.loadConfig();

    expect(config.locale, equals(null));
    expect(config.currencySymbol, equals('EUR'));
    expect(config.dateFormat, isNot(null));
    expect(
      DateFormat(config.dateFormat).format(DateTime(2020, 12, 30)),
      equals('30/12/2020'),
    );
    expect(config.distanceUnit, equals(DistanceUnit.UnitKM));
  });

  test('configuration can read saved values from storage', () async {
    SharedPreferences.setMockInitialValues({
      'locale': 'fr_CA',
      'currency': 'BRP',
      'distance_unit': 'km',
      'date_format': 'y/M/d'
    });

    await initializeDateFormatting();
    final config = Configuration('en');
    await config.loadConfig();

    expect(config.locale, equals(const Locale('fr_CA')));
    expect(config.currencySymbol, equals('BRP'));
    expect(config.dateFormat, isNot(null));
    expect(
      DateFormat(config.dateFormat).format(DateTime(2020, 12, 30)),
      equals('2020/12/30'),
    );
    expect(config.distanceUnit, equals(DistanceUnit.UnitKM));
  });
}
