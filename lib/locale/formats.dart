import 'package:moto_mecanico/models/distance.dart';

/// Support for locale-specific language configurations
class LocaleSupport {
  static const Map<String, String> _supportedLanguages = {
    'en': 'English (US)',
    'es': 'Español',
    'fr': 'Français',
  };

  /// Returns the display name for a language code
  static String getLanguageName(String code) =>
      _supportedLanguages[code] ?? 'Unknown';

  /// Checks if a language code is supported
  static bool isValidLanguage(String code) =>
      _supportedLanguages.containsKey(code);

  /// Returns all supported language codes
  static List<String> getSupportedLanguages() =>
      _supportedLanguages.keys.toList();

  /// Returns all language code to name mappings
  static Map<String, String> getAllLanguages() =>
      Map.unmodifiable(_supportedLanguages);
}

/// Support for date format configurations
class DateFormatSupport {
  static const List<String> _supportedDateFormats = [
    'M/d/y',
    'MM/dd/y',
    'd/M/y',
    'dd/MM/y',
    'y/M/d',
    'y/MM/dd'
  ];

  /// Checks if a date format is supported
  static bool isValidFormat(String format) =>
      _supportedDateFormats.contains(format);

  /// Returns the default date format
  static String getDefaultFormat() => _supportedDateFormats.first;

  /// Returns all supported date formats
  static List<String> getSupportedFormats() =>
      List.unmodifiable(_supportedDateFormats);
}

/// Support for currency configurations
class CurrencySupport {
  // Currency full names from openexchangerates.org (updated list)
  static const Map<String, String> _currencyNames = {
    'AED': 'United Arab Emirates Dirham',
    'AFN': 'Afghan Afghani',
    'ALL': 'Albanian Lek',
    'AMD': 'Armenian Dram',
    'ANG': 'Netherlands Antillean Guilder',
    'AOA': 'Angolan Kwanza',
    'ARS': 'Argentine Peso',
    'AUD': 'Australian Dollar',
    'AWG': 'Aruban Florin',
    'AZN': 'Azerbaijani Manat',
    'BAM': 'Bosnia-Herzegovina Convertible Mark',
    'BBD': 'Barbadian Dollar',
    'BDT': 'Bangladeshi Taka',
    'BGN': 'Bulgarian Lev',
    'BHD': 'Bahraini Dinar',
    'BIF': 'Burundian Franc',
    'BMD': 'Bermudan Dollar',
    'BND': 'Brunei Dollar',
    'BOB': 'Bolivian Boliviano',
    'BRL': 'Brazilian Real',
    'BSD': 'Bahamian Dollar',
    'BTC': 'Bitcoin',
    'BTN': 'Bhutanese Ngultrum',
    'BWP': 'Botswanan Pula',
    'BYN': 'Belarusian Ruble',
    'BZD': 'Belize Dollar',
    'CAD': 'Canadian Dollar',
    'CDF': 'Congolese Franc',
    'CHF': 'Swiss Franc',
    'CLF': 'Chilean Unit of Account (UF)',
    'CLP': 'Chilean Peso',
    'CNH': 'Chinese Yuan (Offshore)',
    'CNY': 'Chinese Yuan',
    'COP': 'Colombian Peso',
    'CRC': 'Costa Rican Colón',
    'CUC': 'Cuban Convertible Peso',
    'CUP': 'Cuban Peso',
    'CVE': 'Cape Verdean Escudo',
    'CZK': 'Czech Republic Koruna',
    'DJF': 'Djiboutian Franc',
    'DKK': 'Danish Krone',
    'DOP': 'Dominican Peso',
    'DZD': 'Algerian Dinar',
    'EGP': 'Egyptian Pound',
    'ERN': 'Eritrean Nakfa',
    'ETB': 'Ethiopian Birr',
    'EUR': 'Euro',
    'FJD': 'Fijian Dollar',
    'FKP': 'Falkland Islands Pound',
    'GBP': 'British Pound Sterling',
    'GEL': 'Georgian Lari',
    'GGP': 'Guernsey Pound',
    'GHS': 'Ghanaian Cedi',
    'GIP': 'Gibraltar Pound',
    'GMD': 'Gambian Dalasi',
    'GNF': 'Guinean Franc',
    'GTQ': 'Guatemalan Quetzal',
    'GYD': 'Guyanaese Dollar',
    'HKD': 'Hong Kong Dollar',
    'HNL': 'Honduran Lempira',
    'HRK': 'Croatian Kuna',
    'HTG': 'Haitian Gourde',
    'HUF': 'Hungarian Forint',
    'IDR': 'Indonesian Rupiah',
    'ILS': 'Israeli New Sheqel',
    'IMP': 'Manx pound',
    'INR': 'Indian Rupee',
    'IQD': 'Iraqi Dinar',
    'IRR': 'Iranian Rial',
    'ISK': 'Icelandic Króna',
    'JEP': 'Jersey Pound',
    'JMD': 'Jamaican Dollar',
    'JOD': 'Jordanian Dinar',
    'JPY': 'Japanese Yen',
    'KES': 'Kenyan Shilling',
    'KGS': 'Kyrgystani Som',
    'KHR': 'Cambodian Riel',
    'KMF': 'Comorian Franc',
    'KPW': 'North Korean Won',
    'KRW': 'South Korean Won',
    'KWD': 'Kuwaiti Dinar',
    'KYD': 'Cayman Islands Dollar',
    'KZT': 'Kazakhstani Tenge',
    'LAK': 'Laotian Kip',
    'LBP': 'Lebanese Pound',
    'LKR': 'Sri Lankan Rupee',
    'LRD': 'Liberian Dollar',
    'LSL': 'Lesotho Loti',
    'LYD': 'Libyan Dinar',
    'MAD': 'Moroccan Dirham',
    'MDL': 'Moldovan Leu',
    'MGA': 'Malagasy Ariary',
    'MKD': 'Macedonian Denar',
    'MMK': 'Myanma Kyat',
    'MNT': 'Mongolian Tugrik',
    'MOP': 'Macanese Pataca',
    'MRU': 'Mauritanian Ouguiya',
    'MUR': 'Mauritian Rupee',
    'MVR': 'Maldivian Rufiyaa',
    'MWK': 'Malawian Kwacha',
    'MXN': 'Mexican Peso',
    'MYR': 'Malaysian Ringgit',
    'MZN': 'Mozambican Metical',
    'NAD': 'Namibian Dollar',
    'NGN': 'Nigerian Naira',
    'NIO': 'Nicaraguan Córdoba',
    'NOK': 'Norwegian Krone',
    'NPR': 'Nepalese Rupee',
    'NZD': 'New Zealand Dollar',
    'OMR': 'Omani Rial',
    'PAB': 'Panamanian Balboa',
    'PEN': 'Peruvian Nuevo Sol',
    'PGK': 'Papua New Guinean Kina',
    'PHP': 'Philippine Peso',
    'PKR': 'Pakistani Rupee',
    'PLN': 'Polish Zloty',
    'PYG': 'Paraguayan Guarani',
    'QAR': 'Qatari Rial',
    'RON': 'Romanian Leu',
    'RSD': 'Serbian Dinar',
    'RUB': 'Russian Ruble',
    'RWF': 'Rwandan Franc',
    'SAR': 'Saudi Riyal',
    'SBD': 'Solomon Islands Dollar',
    'SCR': 'Seychellois Rupee',
    'SDG': 'Sudanese Pound',
    'SEK': 'Swedish Krona',
    'SGD': 'Singapore Dollar',
    'SHP': 'Saint Helena Pound',
    'SLE': 'Sierra Leonean Leone',
    'SOS': 'Somali Shilling',
    'SRD': 'Surinamese Dollar',
    'SSP': 'South Sudanese Pound',
    'STN': 'São Tomé and Príncipe Dobra',
    'SVC': 'Salvadoran Colón',
    'SYP': 'Syrian Pound',
    'SZL': 'Swazi Lilangeni',
    'THB': 'Thai Baht',
    'TJS': 'Tajikistani Somoni',
    'TMT': 'Turkmenistani Manat',
    'TND': 'Tunisian Dinar',
    'TOP': 'Tongan Pa\'anga',
    'TRY': 'Turkish Lira',
    'TTD': 'Trinidad and Tobago Dollar',
    'TWD': 'New Taiwan Dollar',
    'TZS': 'Tanzanian Shilling',
    'UAH': 'Ukrainian Hryvnia',
    'UGX': 'Ugandan Shilling',
    'USD': 'United States Dollar',
    'UYU': 'Uruguayan Peso',
    'UZS': 'Uzbekistan Som',
    'VES': 'Venezuelan Bolívar Soberano',
    'VND': 'Vietnamese Dong',
    'VUV': 'Vanuatu Vatu',
    'WST': 'Samoan Tala',
    'XAF': 'CFA Franc BEAC',
    'XAG': 'Silver Ounce',
    'XAU': 'Gold Ounce',
    'XCD': 'East Caribbean Dollar',
    'XDR': 'Special Drawing Rights',
    'XOF': 'CFA Franc BCEAO',
    'XPD': 'Palladium Ounce',
    'XPF': 'CFP Franc',
    'XPT': 'Platinum Ounce',
    'YER': 'Yemeni Rial',
    'ZAR': 'South African Rand',
    'ZMW': 'Zambian Kwacha',
    'ZWL': 'Zimbabwean Dollar'
  };

  /// Returns the full currency name for a currency code
  static String getCurrencyName(String code) =>
      _currencyNames[code] ?? 'Unknown Currency';

  /// Checks if a currency code is valid
  static bool isValidCurrency(String code) => _currencyNames.containsKey(code);

  /// Returns all supported currency codes
  static List<String> getSupportedCurrencies() => _currencyNames.keys.toList();

  /// Returns all currency code to name mappings
  static Map<String, String> getAllCurrencies() =>
      Map.unmodifiable(_currencyNames);
}

/// Support for distance unit configurations
class DistanceSupport {
  static const Map<DistanceUnit, String> _distanceUnits = {
    DistanceUnit.unitKm: 'km',
    DistanceUnit.unitMile: 'miles'
  };

  static const Map<DistanceUnit, String> _distanceUnitsCompact = {
    DistanceUnit.unitKm: 'km',
    DistanceUnit.unitMile: 'mi'
  };

  /// Returns the unit name for a distance unit
  static String getUnitName(DistanceUnit unit, {bool compact = false}) {
    final units = compact ? _distanceUnitsCompact : _distanceUnits;
    return units[unit] ?? 'unknown';
  }

  /// Returns the unit symbol for a distance unit (same as compact name)
  static String getUnitSymbol(DistanceUnit unit) =>
      _distanceUnitsCompact[unit] ?? 'unknown';

  /// Returns all distance units mapping
  static Map<DistanceUnit, String> getAllUnits({bool compact = false}) {
    final units = compact ? _distanceUnitsCompact : _distanceUnits;
    return Map.unmodifiable(units);
  }
}
