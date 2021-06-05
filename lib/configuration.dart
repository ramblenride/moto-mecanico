import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moto_mecanico/locale/formats.dart';
import 'package:moto_mecanico/models/distance.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

// This class stores the global configuration of the app.
// loadConfig() should be called once at startup.
// Sensible defaults (based on system locale) are returned if there is no
// saved value.
class Configuration {
  static const _DEFAULT_CURRENCY_SYMBOL = 'USD';
  static const _PROP_NAME_LOCALE = 'locale';
  static const _PROP_NAME_CURRENCY = 'currency';
  static const _PROP_NAME_DATE_FORMAT = 'date_format';
  static const _PROP_NAME_DISTANCE_UNIT = 'distance_unit';
  static const _PROP_VALUE_DISTANCE_UNIT_KM = 'km';
  static const _PROP_VALUE_DISTANCE_UNIT_MILE = 'mile';
  static const _PROP_NAME_NOTIFICATIONS = 'notifications';

  SharedPreferences _prefs;
  Locale _systemLocale;

  Locale _locale;

  String _currencySymbol;
  String _dateFormat;
  DistanceUnit _distanceUnit;

  bool _notifications;

  // Made available to the application here, but not store in the config.
  PackageInfo packageInfo;

  Configuration(String systemLocale) {
    _systemLocale = Locale(systemLocale ?? 'en');
  }

  String get currencySymbol {
    _currencySymbol ??=
        NumberFormat.currency(locale: _systemLocale.languageCode)
                .currencyName ??
            _DEFAULT_CURRENCY_SYMBOL;

    return _currencySymbol;
  }

  set currencySymbol(String symbol) {
    assert(_prefs != null);
    _currencySymbol = symbol;

    _prefs.setString(_PROP_NAME_CURRENCY, symbol);
  }

  String get dateFormat {
    if (_dateFormat == null) {
      final localeDateFormat =
          DateFormat.yMd(_systemLocale.languageCode).pattern;
      _dateFormat =
          AppLocalSupport.supportedDateFormats.contains(localeDateFormat)
              ? localeDateFormat
              : 'y/M/d';
    }
    return _dateFormat;
  }

  set dateFormat(String format) {
    assert(_prefs != null);
    _dateFormat = format;

    _prefs.setString(_PROP_NAME_DATE_FORMAT, format);
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
        _distanceUnit = DistanceUnit.UnitMile;
      } else {
        _distanceUnit = DistanceUnit.UnitKM;
      }
    }
    return _distanceUnit;
  }

  set distanceUnit(DistanceUnit unit) {
    assert(_prefs != null);
    _distanceUnit = unit;

    _prefs.setString(
        _PROP_NAME_DISTANCE_UNIT,
        unit == DistanceUnit.UnitMile
            ? _PROP_VALUE_DISTANCE_UNIT_MILE
            : _PROP_VALUE_DISTANCE_UNIT_KM);
  }

  Locale get locale => _locale;
  set locale(Locale locale) {
    assert(_prefs != null);
    _locale = locale;

    _prefs.setString(_PROP_NAME_LOCALE, locale.languageCode);
  }

  bool get notifications {
    return _notifications ?? true;
  }

  set notifications(bool enabled) {
    _notifications = enabled;

    _prefs.setBool(_PROP_NAME_NOTIFICATIONS, _notifications);
  }

  void loadConfig() async {
    _prefs = await SharedPreferences.getInstance();
    final localeStr = _prefs.getString(_PROP_NAME_LOCALE);
    _locale = localeStr != null ? Locale(localeStr) : null;

    final distance = _prefs.getString(_PROP_NAME_DISTANCE_UNIT);
    if (distance != null) {
      if (distance == _PROP_VALUE_DISTANCE_UNIT_KM) {
        _distanceUnit = DistanceUnit.UnitKM;
      } else if (distance == _PROP_VALUE_DISTANCE_UNIT_MILE) {
        _distanceUnit = DistanceUnit.UnitMile;
      }
    }

    _currencySymbol = _prefs.getString(_PROP_NAME_CURRENCY);
    _dateFormat = _prefs.getString(_PROP_NAME_DATE_FORMAT);
    _notifications = _prefs.getBool(_PROP_NAME_NOTIFICATIONS);
  }
}
