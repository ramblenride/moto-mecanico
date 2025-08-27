import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moto_mecanico/locale/formats.dart';
import 'package:moto_mecanico/models/distance.dart';
import 'package:shared_preferences/shared_preferences.dart';

// This class stores the global configuration of the app.
// loadConfig() should be called once at startup.
// Sensible defaults (based on system locale) are returned if there is no
// saved value.
class Configuration {
  static const defaultCurrencySymbol = 'USD';
  static const propNameLocale = 'locale';
  static const propNameCurrency = 'currency';
  static const propNameDateFormat = 'date_format';
  static const propNameDistanceUnit = 'distance_unit';
  static const propValueDistanceUnitKm = 'km';
  static const propValueDistanceUnitMile = 'mile';
  static const propNameNotifications = 'notifications';

  final Locale _systemLocale;

  String _currencySymbol;
  bool _notifications;
  Locale _locale;

  SharedPreferences? _prefs;
  String? _dateFormat;
  DistanceUnit? _distanceUnit;

  Configuration(String systemLocale)
      : _systemLocale = Locale(systemLocale),
        _currencySymbol = defaultCurrencySymbol,
        _notifications = false,
        _locale = Locale(systemLocale);

  String get currencySymbol => _currencySymbol;

  set currencySymbol(String symbol) {
    assert(_prefs != null);
    _currencySymbol = symbol;

    _prefs?.setString(propNameCurrency, symbol);
  }

  String get dateFormat {
    if (_dateFormat == null) {
      final localeDateFormat =
          DateFormat.yMd(_systemLocale.languageCode).pattern;
      _dateFormat = (localeDateFormat != null &&
              AppLocalSupport.supportedDateFormats.contains(localeDateFormat))
          ? localeDateFormat
          : AppLocalSupport.supportedDateFormats.first;
    }
    return _dateFormat!;
  }

  set dateFormat(String format) {
    assert(_prefs != null);
    _dateFormat = format;

    _prefs?.setString(propNameDateFormat, format);
  }

  DistanceUnit get distanceUnit {
    if (_distanceUnit == null) {
      const countriesUsingMiles = ['US', 'GB', 'LR', 'MM'];
      var countryCode = _systemLocale.countryCode;
      if (countryCode == null) {
        final splitLocale = _systemLocale.languageCode.split(RegExp(r'[_-]'));
        if (splitLocale.length > 1) {
          countryCode = splitLocale[1];
        }
      }
      if (countryCode != null &&
          countriesUsingMiles.contains(countryCode.toUpperCase())) {
        _distanceUnit = DistanceUnit.unitMile;
      } else {
        _distanceUnit = DistanceUnit.unitKm;
      }
    }
    return _distanceUnit!;
  }

  set distanceUnit(DistanceUnit unit) {
    assert(_prefs != null);
    _distanceUnit = unit;

    _prefs?.setString(
        propNameDistanceUnit,
        unit == DistanceUnit.unitMile
            ? propValueDistanceUnitMile
            : propValueDistanceUnitKm);
  }

  Locale get locale => _locale;
  set locale(Locale locale) {
    assert(_prefs != null);
    _locale = locale;

    _prefs?.setString(propNameLocale, locale.languageCode);
  }

  bool get notifications {
    return _notifications;
  }

  set notifications(bool enabled) {
    _notifications = enabled;

    _prefs?.setBool(propNameNotifications, _notifications);
  }

  Future<void> loadConfig() async {
    _prefs = await SharedPreferences.getInstance();
    final localeStr = _prefs?.getString(propNameLocale);
    _locale = localeStr != null && localeStr.isNotEmpty
        ? Locale(localeStr)
        : _systemLocale;

    final distance = _prefs?.getString(propNameDistanceUnit);
    if (distance != null) {
      if (distance == propValueDistanceUnitKm) {
        _distanceUnit = DistanceUnit.unitKm;
      } else if (distance == propValueDistanceUnitMile) {
        _distanceUnit = DistanceUnit.unitMile;
      }
    }

    _currencySymbol = _prefs?.getString(propNameCurrency) ??
        NumberFormat.currency(locale: _systemLocale.languageCode)
            .currencyName ??
        defaultCurrencySymbol;
    _dateFormat = _prefs?.getString(propNameDateFormat) ??
        AppLocalSupport.supportedDateFormats
            .first; // FIXME: Get the default for the locale
    _notifications = _prefs?.getBool(propNameNotifications) ?? true;
  }
}
