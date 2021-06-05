import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:moto_mecanico/configuration.dart';
import 'package:moto_mecanico/locale/formats.dart';
import 'package:moto_mecanico/main.dart';
import 'package:moto_mecanico/models/distance.dart';
import 'package:moto_mecanico/widgets/config_widget.dart';
import 'package:moto_mecanico/widgets/dissmiss_keyboard_ontap.dart';
import 'package:moto_mecanico/widgets/label_editor.dart';
import 'package:moto_mecanico/widgets/property_editor_card.dart';
import 'package:moto_mecanico/widgets/property_editor_row.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final config = ConfigWidget.of(context);

    return WillPopScope(
      onWillPop: () async {
        // Reload the app with the new language
        MotoLogApp.applyConfiguration(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).settings_page_title),
        ),
        body: DismissKeyboardOnTap(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: SingleChildScrollView(
              child: Wrap(
                runSpacing: 10,
                children: [
                  PropertyEditorCard(
                    title: AppLocalizations.of(context)
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
                    title: AppLocalizations.of(context)
                        .settings_page_labels_header,
                    children: [
                      const SizedBox(height: 10),
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
    assert(config != null);
    return PropertyEditorRow(
      name: AppLocalizations.of(context).settings_page_language_prop_name,
      inputField: Align(
        alignment: Alignment.centerRight,
        child: DropdownButton<String>(
          value: config.locale?.languageCode ??
              Localizations.localeOf(context)
                  .languageCode
                  .split(RegExp(r'[_-]'))[0],
          items: AppLocalSupport.supportedLanguages.keys.map((key) {
            return DropdownMenuItem<String>(
              child: Text(AppLocalSupport.supportedLanguages[key]),
              value: key,
            );
          }).toList(),
          onChanged: (newLocale) {
            setState(() => config.locale = Locale(newLocale));
          },
        ),
      ),
    );
  }

  Widget _getDateRow(Configuration config) {
    assert(config != null);
    return PropertyEditorRow(
      name: AppLocalizations.of(context).settings_page_date_format_prop_name,
      inputField: Align(
        alignment: Alignment.centerRight,
        child: DropdownButton<String>(
          value: config.dateFormat,
          items: AppLocalSupport.supportedDateFormats.map((item) {
            final date = DateTime(2020, 1, 31);
            final widget = DropdownMenuItem<String>(
                child: Text(
                  DateFormat(item).format(date),
                ),
                value: item);
            return widget;
          }).toList(),
          onChanged: (newFormat) =>
              setState(() => config.dateFormat = newFormat),
        ),
      ),
    );
  }

  Widget _getCurrencyRow(Configuration config) {
    assert(config != null);
    return PropertyEditorRow(
      name: AppLocalizations.of(context).settings_page_currency_prop_name,
      inputField: Align(
        alignment: Alignment.centerRight,
        child: DropdownButton<String>(
          value: config.currencySymbol,
          items: AppLocalSupport.currencySymbols.keys.map((item) {
            // FIXME: The list is long. A searchable dropdown would be very useful here.
            return DropdownMenuItem<String>(
              child: Text(
                item,
              ),
              value: item,
            );
          }).toList(),
          onChanged: (newCurrency) => setState(() {
            setState(() => config.currencySymbol = newCurrency);
          }),
        ),
      ),
    );
  }

  Widget _getDistanceRow(Configuration config) {
    assert(config != null);
    return PropertyEditorRow(
      name: AppLocalizations.of(context).settings_page_distance_prop_name,
      inputField: Align(
        alignment: Alignment.centerRight,
        child: DropdownButton<DistanceUnit>(
          value: config.distanceUnit,
          items: [
            DropdownMenuItem(
              value: DistanceUnit.UnitKM,
              child: Text(
                AppLocalSupport.distanceUnits[DistanceUnit.UnitKM],
              ),
            ),
            DropdownMenuItem(
              value: DistanceUnit.UnitMile,
              child: Text(AppLocalSupport.distanceUnits[DistanceUnit.UnitMile]),
            ),
          ],
          onChanged: (newUnit) => setState(() => config.distanceUnit = newUnit),
        ),
      ),
    );
  }

/*
  Widget _getNotificationsRow(Configuration config) {
    assert(config != null);
    return PropertyEditorRow(
      name: AppLocalizations.of(context).settings_page_notifications_prop_name,
      inputField: Switch(
        activeColor: RnrColors.orange,
        activeTrackColor: RnrColors.darkOrange,
        inactiveTrackColor: Colors.grey[700],
        inactiveThumbColor: Colors.grey[500],
        value: config.notifications,
        onChanged: (enabled) => setState(() => config.notifications = enabled),
      ),
    );
  }
  */
}
