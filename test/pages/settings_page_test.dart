import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moto_mecanico/configuration.dart';
import 'package:moto_mecanico/models/distance.dart';
import 'package:moto_mecanico/models/labels.dart';
import 'package:moto_mecanico/pages/settings_page.dart';
import 'package:moto_mecanico/widgets/config_widget.dart';
import 'package:moto_mecanico/widgets/label_editor.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  testWidgets('settings page load with default config',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final config = Configuration('en_US');
    await config.loadConfig();

    final app = ConfigWidget(
      config: config,
      child: ChangeNotifierProvider(
        create: (context) => LabelsModel(),
        lazy: false,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsPage(),
        ),
      ),
    );
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    final dropdownStringType = DropdownButton<String>(
        onChanged: (_) {},
        items: const <DropdownMenuItem<String>>[]).runtimeType;

    final dropdownDistanceType = DropdownButton<DistanceUnit>(
        onChanged: (_) {},
        items: const <DropdownMenuItem<DistanceUnit>>[]).runtimeType;

    // 4 properties
    expect(find.byType(dropdownStringType), findsNWidgets(3));
    expect(find.byType(dropdownDistanceType), findsOneWidget);

    // FIXME: This doesn't really test that the right value has been selected.
    expect(find.text('English (US)'), findsOneWidget);
    expect(find.text('USD'), findsOneWidget);
    expect(find.text('km'), findsOneWidget);

    // Settings page always contain a label editor
    expect(find.byType(LabelEditor), findsOneWidget);
  });
}
