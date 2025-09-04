import 'package:flutter_test/flutter_test.dart';
import 'package:moto_mecanico/locale/formats.dart';
import 'package:moto_mecanico/models/distance.dart';

void main() {
  group('LocaleSupport', () {
    test('getLanguageName returns correct display name for supported languages',
        () {
      expect(LocaleSupport.getLanguageName('en'), equals('English (US)'));
      expect(LocaleSupport.getLanguageName('es'), equals('Español'));
      expect(LocaleSupport.getLanguageName('fr'), equals('Français'));
    });

    test('getLanguageName returns "Unknown" for unsupported language codes',
        () {
      expect(LocaleSupport.getLanguageName('de'), equals('Unknown'));
      expect(LocaleSupport.getLanguageName('invalid'), equals('Unknown'));
      expect(LocaleSupport.getLanguageName(''), equals('Unknown'));
    });

    test('isValidLanguage returns true for supported languages', () {
      expect(LocaleSupport.isValidLanguage('en'), isTrue);
      expect(LocaleSupport.isValidLanguage('es'), isTrue);
      expect(LocaleSupport.isValidLanguage('fr'), isTrue);
    });

    test('isValidLanguage returns false for unsupported languages', () {
      expect(LocaleSupport.isValidLanguage('de'), isFalse);
      expect(LocaleSupport.isValidLanguage('invalid'), isFalse);
      expect(LocaleSupport.isValidLanguage(''), isFalse);
    });

    test('getSupportedLanguages returns all language codes', () {
      final languages = LocaleSupport.getSupportedLanguages();
      expect(languages, contains('en'));
      expect(languages, contains('es'));
      expect(languages, contains('fr'));
      expect(languages.length, equals(3));
    });

    test('getAllLanguages returns unmodifiable map', () {
      final languages = LocaleSupport.getAllLanguages();
      expect(languages['en'], equals('English (US)'));
      expect(languages['es'], equals('Español'));
      expect(languages['fr'], equals('Français'));

      // Test that map is unmodifiable
      expect(() => languages['de'] = 'German', throwsUnsupportedError);
    });
  });

  group('DateFormatSupport', () {
    test('isValidFormat returns true for supported formats', () {
      expect(DateFormatSupport.isValidFormat('M/d/y'), isTrue);
      expect(DateFormatSupport.isValidFormat('MM/dd/y'), isTrue);
      expect(DateFormatSupport.isValidFormat('d/M/y'), isTrue);
      expect(DateFormatSupport.isValidFormat('dd/MM/y'), isTrue);
      expect(DateFormatSupport.isValidFormat('y/M/d'), isTrue);
      expect(DateFormatSupport.isValidFormat('y/MM/dd'), isTrue);
    });

    test('isValidFormat returns false for unsupported formats', () {
      expect(DateFormatSupport.isValidFormat('yyyy-MM-dd'), isFalse);
      expect(DateFormatSupport.isValidFormat('invalid'), isFalse);
      expect(DateFormatSupport.isValidFormat(''), isFalse);
    });

    test('getDefaultFormat returns first supported format', () {
      final defaultFormat = DateFormatSupport.getDefaultFormat();
      expect(defaultFormat, equals('M/d/y'));
    });

    test('getSupportedFormats returns all date formats', () {
      final formats = DateFormatSupport.getSupportedFormats();
      expect(formats.length, equals(6));
      expect(formats, contains('M/d/y'));
      expect(formats, contains('MM/dd/y'));
      expect(formats, contains('d/M/y'));
      expect(formats, contains('dd/MM/y'));
      expect(formats, contains('y/M/d'));
      expect(formats, contains('y/MM/dd'));
    });

    test('getSupportedFormats returns unmodifiable list', () {
      final formats = DateFormatSupport.getSupportedFormats();
      expect(() => formats.add('new format'), throwsUnsupportedError);
    });
  });

  group('CurrencySupport', () {
    test('getCurrencyName returns correct names for valid currencies', () {
      expect(CurrencySupport.getCurrencyName('USD'),
          equals('United States Dollar'));
      expect(CurrencySupport.getCurrencyName('EUR'), equals('Euro'));
      expect(CurrencySupport.getCurrencyName('GBP'),
          equals('British Pound Sterling'));
      expect(CurrencySupport.getCurrencyName('JPY'), equals('Japanese Yen'));
    });

    test('getCurrencyName returns "Unknown Currency" for invalid currencies',
        () {
      expect(CurrencySupport.getCurrencyName('INVALID'),
          equals('Unknown Currency'));
      expect(
          CurrencySupport.getCurrencyName('XYZ'), equals('Unknown Currency'));
      expect(CurrencySupport.getCurrencyName(''), equals('Unknown Currency'));
    });

    test('isValidCurrency returns true for supported currencies', () {
      expect(CurrencySupport.isValidCurrency('USD'), isTrue);
      expect(CurrencySupport.isValidCurrency('EUR'), isTrue);
      expect(CurrencySupport.isValidCurrency('GBP'), isTrue);
      expect(CurrencySupport.isValidCurrency('JPY'), isTrue);
    });

    test('isValidCurrency returns false for unsupported currencies', () {
      expect(CurrencySupport.isValidCurrency('INVALID'), isFalse);
      expect(CurrencySupport.isValidCurrency('XYZ'), isFalse);
      expect(CurrencySupport.isValidCurrency(''), isFalse);
    });

    test('getSupportedCurrencies returns list of currency codes', () {
      final currencies = CurrencySupport.getSupportedCurrencies();
      expect(currencies, contains('USD'));
      expect(currencies, contains('EUR'));
      expect(currencies, contains('GBP'));
      expect(
          currencies.length, greaterThan(100)); // Should have many currencies
    });

    test('getAllCurrencies returns unmodifiable map', () {
      final currencies = CurrencySupport.getAllCurrencies();
      expect(currencies['USD'], equals('United States Dollar'));
      expect(currencies['EUR'], equals('Euro'));

      // Test that map is unmodifiable
      expect(
          () => currencies['TEST'] = 'Test Currency', throwsUnsupportedError);
    });

    test('currency symbols are consistent with currency names', () {
      // Test that currencies with symbols also have names
      expect(CurrencySupport.isValidCurrency('USD'), isTrue);
      expect(CurrencySupport.isValidCurrency('EUR'), isTrue);
      expect(CurrencySupport.isValidCurrency('GBP'), isTrue);
      expect(CurrencySupport.isValidCurrency('JPY'), isTrue);
      expect(CurrencySupport.isValidCurrency('INR'), isTrue);
    });
  });

  group('DistanceSupport', () {
    test('getUnitName returns correct unit names', () {
      expect(DistanceSupport.getUnitName(DistanceUnit.unitKm), equals('km'));
      expect(
          DistanceSupport.getUnitName(DistanceUnit.unitMile), equals('miles'));
    });

    test('getUnitName returns compact names when requested', () {
      expect(DistanceSupport.getUnitName(DistanceUnit.unitKm, compact: true),
          equals('km'));
      expect(DistanceSupport.getUnitName(DistanceUnit.unitMile, compact: true),
          equals('mi'));
    });

    test('getUnitSymbol returns compact unit symbols', () {
      expect(DistanceSupport.getUnitSymbol(DistanceUnit.unitKm), equals('km'));
      expect(
          DistanceSupport.getUnitSymbol(DistanceUnit.unitMile), equals('mi'));
    });

    test('getAllUnits returns full unit names by default', () {
      final units = DistanceSupport.getAllUnits();
      expect(units[DistanceUnit.unitKm], equals('km'));
      expect(units[DistanceUnit.unitMile], equals('miles'));
    });

    test('getAllUnits returns compact names when requested', () {
      final units = DistanceSupport.getAllUnits(compact: true);
      expect(units[DistanceUnit.unitKm], equals('km'));
      expect(units[DistanceUnit.unitMile], equals('mi'));
    });

    test('getAllUnits returns unmodifiable map', () {
      final units = DistanceSupport.getAllUnits();
      expect(() => units[DistanceUnit.unitKm] = 'kilometers',
          throwsUnsupportedError);
    });
  });

  group('Integration Tests', () {
    test('all supported languages have valid names', () {
      for (final code in LocaleSupport.getSupportedLanguages()) {
        final name = LocaleSupport.getLanguageName(code);
        expect(name, isNot(equals('Unknown')));
        expect(name.isNotEmpty, isTrue);
      }
    });

    test('all supported date formats are non-empty strings', () {
      for (final format in DateFormatSupport.getSupportedFormats()) {
        expect(format.isNotEmpty, isTrue);
        expect(DateFormatSupport.isValidFormat(format), isTrue);
      }
    });

    test('all supported currencies have valid names', () {
      final currencies = CurrencySupport.getSupportedCurrencies();
      expect(currencies.isNotEmpty, isTrue);

      // Test a sample of currencies
      for (final code in currencies.take(10)) {
        final name = CurrencySupport.getCurrencyName(code);
        expect(name, isNot(equals('Unknown Currency')));
        expect(name.isNotEmpty, isTrue);
        expect(CurrencySupport.isValidCurrency(code), isTrue);
      }
    });

    test('distance unit enums are properly mapped', () {
      for (final unit in DistanceUnit.values) {
        final name = DistanceSupport.getUnitName(unit);
        final compactName = DistanceSupport.getUnitName(unit, compact: true);
        final symbol = DistanceSupport.getUnitSymbol(unit);

        expect(name, isNot(equals('unknown')));
        expect(compactName, isNot(equals('unknown')));
        expect(symbol, isNot(equals('unknown')));
        expect(name.isNotEmpty, isTrue);
        expect(compactName.isNotEmpty, isTrue);
        expect(symbol.isNotEmpty, isTrue);
      }
    });
  });
}
