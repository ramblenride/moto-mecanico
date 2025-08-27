import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:moto_mecanico/configuration.dart';
import 'package:moto_mecanico/locale/formats.dart';
import 'package:moto_mecanico/models/distance.dart';
import 'package:moto_mecanico/moto_log_app.dart';
import 'package:moto_mecanico/widgets/config_widget.dart';
import 'package:moto_mecanico/widgets/dissmiss_keyboard_ontap.dart';
import 'package:moto_mecanico/widgets/label_editor.dart';
import 'package:moto_mecanico/widgets/property_editor_card.dart';
import 'package:moto_mecanico/widgets/property_editor_row.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final config = ConfigWidget.of(context);

    return PopScope(
      canPop: true,
      onPopInvoked: (bool didPop) {
        if (!didPop) return;
        // Reload the app with the new language
        MotoLogApp.applyConfiguration(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.settings_page_title),
        ),
        body: DismissKeyboardOnTap(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: SingleChildScrollView(
              child: Wrap(
                runSpacing: 10,
                children: [
                  PropertyEditorCard(
                    title: AppLocalizations.of(context)!
                        .settings_page_localization_header,
                    children: [
                      _getLanguageRow(config),
                      _getDateRow(config),
                      _getCurrencyRow(config),
                      _getDistanceRow(config),
                      // FIXME: Disabled for now
                      //_getNotificationsRow(config),
                    ],
                  ),
                  PropertyEditorCard(
                    title: AppLocalizations.of(context)!
                        .settings_page_labels_header,
                    children: const [
                      SizedBox(height: 10),
                      LabelEditor(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getLanguageRow(Configuration config) {
    return PropertyEditorRow(
      name: AppLocalizations.of(context)!.settings_page_language_prop_name,
      inputField: Align(
        alignment: Alignment.centerRight,
        child: DropdownButton<String>(
          value: _getLanguageCode(config),
          items: AppLocalSupport.supportedLanguages.keys.map((key) {
            return DropdownMenuItem<String>(
              value: key,
              child: Text(AppLocalSupport.supportedLanguages[key]!),
            );
          }).toList(),
          onChanged: (newLocale) {
            if (newLocale != null && newLocale.isNotEmpty) {
              setState(() => config.locale = Locale(newLocale));
            }
          },
        ),
      ),
    );
  }

  Widget _getDateRow(Configuration config) {
    final date = DateTime(2020, 1, 31);
    var dateFormats = AppLocalSupport.supportedDateFormats;
    if (!dateFormats.contains(config.dateFormat)) {
      if (config.dateFormat.isNotEmpty) {
        dateFormats.add(config.dateFormat);
      } else {
        config.dateFormat = dateFormats.first;
      }
    }
    return PropertyEditorRow(
      name: AppLocalizations.of(context)!.settings_page_date_format_prop_name,
      inputField: Align(
        alignment: Alignment.centerRight,
        child: DropdownButton<String>(
          value: config.dateFormat,
          items: dateFormats.map((item) {
            final widget = DropdownMenuItem<String>(
                value: item,
                child: Text(
                  DateFormat(item).format(date),
                ));
            return widget;
          }).toList(),
          onChanged: (newFormat) {
            if (newFormat != null) {
              setState(() => config.dateFormat = newFormat);
            }
          },
        ),
      ),
    );
  }

  Widget _getCurrencyRow(Configuration config) {
    return PropertyEditorRow(
      name: AppLocalizations.of(context)!.settings_page_currency_prop_name,
      inputField: Align(
        alignment: Alignment.centerRight,
        child: DropdownButton<String>(
          value: config.currencySymbol,
          items: AppLocalSupport.currencySymbols.keys.map((item) {
            // FIXME: The list is long. A searchable dropdown would be very useful here.
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
              ),
            );
          }).toList(),
          onChanged: (newCurrency) {
            if (newCurrency != null) {
              setState(() {
                setState(() => config.currencySymbol = newCurrency);
              });
            }
          },
        ),
      ),
    );
  }

  Widget _getDistanceRow(Configuration config) {
    return PropertyEditorRow(
      name: AppLocalizations.of(context)!.settings_page_distance_prop_name,
      inputField: Align(
        alignment: Alignment.centerRight,
        child: DropdownButton<DistanceUnit>(
          value: config.distanceUnit,
          items: [
            DropdownMenuItem(
              value: DistanceUnit.unitKm,
              child: Text(AppLocalSupport.distanceUnits[DistanceUnit.unitKm]!),
            ),
            DropdownMenuItem(
              value: DistanceUnit.unitMile,
              child:
                  Text(AppLocalSupport.distanceUnits[DistanceUnit.unitMile]!),
            ),
          ],
          onChanged: (newUnit) {
            if (newUnit != null) {
              setState(() => config.distanceUnit = newUnit);
            }
          },
        ),
      ),
    );
  }

  String _getLanguageCode(Configuration config) {
    return AppLocalSupport.supportedLanguages
            .containsKey(config.locale.languageCode)
        ? config.locale.languageCode
        : AppLocalSupport.supportedLanguages.keys.first;
  }
}
