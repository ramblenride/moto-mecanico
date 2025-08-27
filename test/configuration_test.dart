import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:moto_mecanico/configuration.dart';
import 'package:moto_mecanico/locale/formats.dart';
import 'package:moto_mecanico/models/distance.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Configuration - Default Values', () {
    test('has correct defaults for US locale (en_US)', () async {
      SharedPreferences.setMockInitialValues({});
      final config = Configuration('en_US');
      await config.loadConfig();

      expect(config.locale, equals(const Locale('en_US')));
      expect(config.currencySymbol, equals('USD'));
      expect(config.dateFormat, isNotNull);
      expect(
        DateFormat(config.dateFormat).format(DateTime(2020, 12, 30)),
        equals('12/30/2020'),
      );
      expect(config.distanceUnit, equals(DistanceUnit.unitMile));
      expect(config.notifications, isTrue);
    });

    test('has correct defaults for French locale (fr_FR)', () async {
      SharedPreferences.setMockInitialValues({});
      await initializeDateFormatting();
      final config = Configuration('fr_FR');
      await config.loadConfig();

      expect(config.locale, equals(const Locale('fr_FR')));
      expect(config.currencySymbol, equals('EUR'));
      expect(config.dateFormat, isNotNull);
      expect(
        DateFormat(config.dateFormat).format(DateTime(2020, 12, 30)),
        equals('12/30/2020'),
      );
      expect(config.distanceUnit, equals(DistanceUnit.unitKm));
      expect(config.notifications, isTrue);
    });

    test('has correct defaults for GB locale (en_GB)', () async {
      SharedPreferences.setMockInitialValues({});
      final config = Configuration('en_GB');
      await config.loadConfig();

      expect(config.locale, equals(const Locale('en_GB')));
      expect(config.distanceUnit, equals(DistanceUnit.unitMile));
    });

    test('has correct defaults for German locale (de_DE)', () async {
      SharedPreferences.setMockInitialValues({});
      final config = Configuration('de_DE');
      await config.loadConfig();

      expect(config.locale, equals(const Locale('de_DE')));
      expect(config.distanceUnit, equals(DistanceUnit.unitKm));
    });

    test('handles valid but uncommon locale gracefully', () async {
      SharedPreferences.setMockInitialValues({});
      final config = Configuration('es_ES');
      await config.loadConfig();

      expect(config.locale, equals(const Locale('es_ES')));
      expect(config.distanceUnit, equals(DistanceUnit.unitKm)); // Spain uses km
      expect(config.currencySymbol, isNotEmpty);
    });
  });

  group('Configuration - Loading Saved Values', () {
    test('can read saved values from storage', () async {
      SharedPreferences.setMockInitialValues({
        'locale': 'fr_CA',
        'currency': 'BRP',
        'distance_unit': 'km',
        'date_format': 'y/M/d',
        'notifications': false,
      });

      await initializeDateFormatting();
      final config = Configuration('en');
      await config.loadConfig();

      expect(config.locale, equals(const Locale('fr_CA')));
      expect(config.currencySymbol, equals('BRP'));
      expect(config.dateFormat, equals('y/M/d'));
      expect(
        DateFormat(config.dateFormat).format(DateTime(2020, 12, 30)),
        equals('2020/12/30'),
      );
      expect(config.distanceUnit, equals(DistanceUnit.unitKm));
      expect(config.notifications, isFalse);
    });

    test('handles partial saved configuration', () async {
      SharedPreferences.setMockInitialValues({
        'currency': 'EUR',
        'distance_unit': 'mile',
      });

      final config = Configuration('en_US');
      await config.loadConfig();

      expect(
          config.locale, equals(const Locale('en_US'))); // Uses system locale
      expect(config.currencySymbol, equals('EUR')); // Uses saved value
      expect(config.distanceUnit,
          equals(DistanceUnit.unitMile)); // Uses saved value
      expect(config.notifications, isTrue); // Uses default
    });

    test('handles invalid distance unit in storage', () async {
      SharedPreferences.setMockInitialValues({
        'distance_unit': 'invalid_unit',
      });

      final config = Configuration('en_US');
      await config.loadConfig();

      expect(config.distanceUnit,
          equals(DistanceUnit.unitMile)); // Falls back to locale-based default
    });

    test('handles empty string values in storage', () async {
      SharedPreferences.setMockInitialValues({
        'locale': '',
        'date_format': '',
      });

      final config = Configuration('fr_FR');
      await config.loadConfig();

      expect(config.locale,
          equals(const Locale('fr_FR'))); // Uses system locale for empty string
      expect(config.currencySymbol, isNotEmpty); // Should have some default
    });
  });

  group('Configuration - Setters and Persistence', () {
    late Configuration config;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      config = Configuration('en_US');
      await config.loadConfig();
    });

    test('currency setter updates value and saves to storage', () async {
      const newCurrency = 'EUR';
      config.currencySymbol = newCurrency;

      expect(config.currencySymbol, equals(newCurrency));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('currency'), equals(newCurrency));
    });

    test('locale setter updates value and saves to storage', () async {
      const newLocale = Locale('es');
      config.locale = newLocale;

      expect(config.locale, equals(newLocale));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('locale'), equals('es'));
    });

    test('distance unit setter updates value and saves to storage', () async {
      config.distanceUnit = DistanceUnit.unitKm;

      expect(config.distanceUnit, equals(DistanceUnit.unitKm));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('distance_unit'), equals('km'));

      config.distanceUnit = DistanceUnit.unitMile;
      expect(prefs.getString('distance_unit'), equals('mile'));
    });

    test('date format setter updates value and saves to storage', () async {
      const newFormat = 'dd/MM/y';
      config.dateFormat = newFormat;

      expect(config.dateFormat, equals(newFormat));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('date_format'), equals(newFormat));
    });

    test('notifications setter updates value and saves to storage', () async {
      config.notifications = false;

      expect(config.notifications, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notifications'), isFalse);

      config.notifications = true;
      expect(config.notifications, isTrue);
      expect(prefs.getBool('notifications'), isTrue);
    });
  });

  group('Configuration - Distance Unit Detection', () {
    test('detects miles for US locale', () async {
      SharedPreferences.setMockInitialValues({});
      final config = Configuration('en_US');
      await config.loadConfig();

      expect(config.distanceUnit, equals(DistanceUnit.unitMile));
    });

    test('detects miles for GB locale', () async {
      SharedPreferences.setMockInitialValues({});
      final config = Configuration('en_GB');
      await config.loadConfig();

      expect(config.distanceUnit, equals(DistanceUnit.unitMile));
    });

    test('detects miles for Liberia (LR)', () async {
      SharedPreferences.setMockInitialValues({});
      final config = Configuration('en_LR');
      await config.loadConfig();

      expect(config.distanceUnit, equals(DistanceUnit.unitMile));
    });

    test('detects miles for Myanmar (MM)', () async {
      SharedPreferences.setMockInitialValues({});
      final config = Configuration('my_MM');
      await config.loadConfig();

      expect(config.distanceUnit, equals(DistanceUnit.unitMile));
    });

    test('detects km for most other countries', () async {
      final testLocales = [
        'fr_FR',
        'de_DE',
        'it_IT',
        'es_ES',
        'ja_JP',
        'zh_CN'
      ];

      for (final locale in testLocales) {
        SharedPreferences.setMockInitialValues({});
        final config = Configuration(locale);
        await config.loadConfig();

        expect(config.distanceUnit, equals(DistanceUnit.unitKm),
            reason: 'Locale $locale should use km');
      }
    });

    test('handles locale with underscore in language code', () async {
      SharedPreferences.setMockInitialValues({});
      final config = Configuration('en_US');
      await config.loadConfig();

      expect(config.distanceUnit, equals(DistanceUnit.unitMile));
    });

    test('handles locale with dash separator', () async {
      SharedPreferences.setMockInitialValues({});
      final config = Configuration('en-GB');
      await config.loadConfig();

      expect(config.distanceUnit, equals(DistanceUnit.unitMile));
    });
  });

  group('Configuration - Date Format', () {
    test('returns supported date format for system locale', () async {
      SharedPreferences.setMockInitialValues({});
      final config = Configuration('en_US');
      await config.loadConfig();

      expect(AppLocalSupport.supportedDateFormats.contains(config.dateFormat),
          isTrue);
    });

    test('falls back to first supported format for unsupported locale format',
        () async {
      SharedPreferences.setMockInitialValues({});
      final config = Configuration('ru_RU'); // Locale with different format
      await config.loadConfig();

      expect(AppLocalSupport.supportedDateFormats.contains(config.dateFormat),
          isTrue);
    });

    test('uses saved date format when available', () async {
      const savedFormat = 'dd/MM/y';
      SharedPreferences.setMockInitialValues({
        'date_format': savedFormat,
      });

      final config = Configuration('en_US');
      await config.loadConfig();

      expect(config.dateFormat, equals(savedFormat));
    });
  });

  group('Configuration - Edge Cases', () {
    test('handles null country code gracefully', () async {
      SharedPreferences.setMockInitialValues({});
      final config = Configuration('en'); // No country code
      await config.loadConfig();

      expect(config.distanceUnit,
          equals(DistanceUnit.unitKm)); // Default when no country
    });

    test('handles case insensitive country codes', () async {
      SharedPreferences.setMockInitialValues({});
      final config = Configuration('en_us'); // lowercase
      await config.loadConfig();

      expect(config.distanceUnit, equals(DistanceUnit.unitMile));
    });

    test('multiple calls to loadConfig do not cause issues', () async {
      SharedPreferences.setMockInitialValues({
        'currency': 'EUR',
        'distance_unit': 'km',
      });

      final config = Configuration('en_US');
      await config.loadConfig();
      final firstCurrency = config.currencySymbol;
      final firstDistance = config.distanceUnit;

      await config.loadConfig(); // Second load

      expect(config.currencySymbol, equals(firstCurrency));
      expect(config.distanceUnit, equals(firstDistance));
    });

    test('getter calls before loadConfig return correct defaults', () {
      final config = Configuration('en_US');

      // These should not throw and should return sensible defaults
      expect(config.locale, equals(const Locale('en_US')));
      expect(
          config.currencySymbol, equals(Configuration.defaultCurrencySymbol));
      expect(config.notifications, isFalse); // Constructor default
      expect(() => config.dateFormat, returnsNormally);
      expect(() => config.distanceUnit, returnsNormally);
    });
  });

  group('Configuration - Error Handling & Robustness', () {
    test('setters throw assertions without SharedPreferences initialized', () {
      final config = Configuration('en_US');

      // These should throw assertion errors since _prefs is null
      expect(
          () => config.currencySymbol = 'EUR', throwsA(isA<AssertionError>()));
      expect(() => config.locale = const Locale('fr'),
          throwsA(isA<AssertionError>()));
      expect(() => config.distanceUnit = DistanceUnit.unitKm,
          throwsA(isA<AssertionError>()));
      expect(
          () => config.dateFormat = 'dd/MM/y', throwsA(isA<AssertionError>()));

      // Notifications setter doesn't have assertion, so it should work
      expect(() => config.notifications = true, returnsNormally);
      expect(config.notifications, isTrue);
    });

    test('handles missing values in SharedPreferences gracefully', () async {
      // Use empty map to simulate missing values
      SharedPreferences.setMockInitialValues({});

      final config = Configuration('de_DE');
      await config.loadConfig();

      // Should use defaults when values are missing
      expect(config.locale, equals(const Locale('de_DE')));
      expect(config.currencySymbol, isNotEmpty);
      expect(config.distanceUnit, equals(DistanceUnit.unitKm));
      expect(config.dateFormat, isNotEmpty);
      expect(config.notifications, isTrue); // Default
    });

    test('uses default currency for unsaved configuration', () async {
      SharedPreferences.setMockInitialValues({});
      final config = Configuration('ja_JP');
      await config.loadConfig();

      // Should have some currency (JPY or default)
      expect(config.currencySymbol, isNotEmpty);
    });

    test('date format validation ensures valid formats', () async {
      SharedPreferences.setMockInitialValues({});
      final config = Configuration('en_US');
      await config.loadConfig();

      final dateFormat = config.dateFormat;
      expect(AppLocalSupport.supportedDateFormats.contains(dateFormat), isTrue,
          reason: 'Date format should be from supported formats list');

      // Test that the format actually works
      expect(
          () => DateFormat(dateFormat).format(DateTime.now()), returnsNormally);
    });

    test('distance unit detection handles valid edge case locales', () async {
      final testCases = [
        'en_US_POSIX', // Valid format with variant
        'en', // No country code
      ];

      for (final locale in testCases) {
        SharedPreferences.setMockInitialValues({});
        final config = Configuration(locale);
        await config.loadConfig();

        // Should not throw and should return a valid distance unit
        expect(() => config.distanceUnit, returnsNormally,
            reason: 'Locale "$locale" should not cause distanceUnit to throw');
        expect(
            [DistanceUnit.unitKm, DistanceUnit.unitMile]
                .contains(config.distanceUnit),
            isTrue,
            reason: 'Should return a valid distance unit for locale "$locale"');
      }
    });

    test('persistent storage works correctly after multiple setter calls',
        () async {
      SharedPreferences.setMockInitialValues({});
      final config = Configuration('en_US');
      await config.loadConfig();

      // Make multiple rapid changes
      config.currencySymbol = 'EUR';
      config.currencySymbol = 'GBP';
      config.currencySymbol = 'JPY';

      config.distanceUnit = DistanceUnit.unitKm;
      config.distanceUnit = DistanceUnit.unitMile;

      config.notifications = false;
      config.notifications = true;

      // Verify final state is persisted
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('currency'), equals('JPY'));
      expect(prefs.getString('distance_unit'), equals('mile'));
      expect(prefs.getBool('notifications'), isTrue);
    });

    test('configuration handles very long locale strings', () async {
      const longLocale = 'en_VERYLONGCOUNTRYCODE'; // Long but valid format
      SharedPreferences.setMockInitialValues({});
      final config = Configuration(longLocale);

      expect(() async => await config.loadConfig(), returnsNormally);
      expect(config.locale.toString(), equals(longLocale));
    });

    test('date format getter is consistent on multiple calls', () async {
      SharedPreferences.setMockInitialValues({});
      final config = Configuration('en_US');
      await config.loadConfig();

      final format1 = config.dateFormat;
      final format2 = config.dateFormat;
      final format3 = config.dateFormat;

      expect(format1, equals(format2));
      expect(format2, equals(format3));
    });

    test('distance unit getter is consistent on multiple calls', () async {
      SharedPreferences.setMockInitialValues({});
      final config = Configuration('fr_FR');
      await config.loadConfig();

      final unit1 = config.distanceUnit;
      final unit2 = config.distanceUnit;
      final unit3 = config.distanceUnit;

      expect(unit1, equals(unit2));
      expect(unit2, equals(unit3));
      expect(unit1, equals(DistanceUnit.unitKm));
    });
  });
}
