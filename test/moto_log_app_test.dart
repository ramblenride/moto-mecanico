import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moto_mecanico/models/garage_model.dart';
import 'package:moto_mecanico/models/labels.dart';
import 'package:moto_mecanico/moto_log_app.dart';
import 'package:moto_mecanico/pages/garage_page.dart';
import 'package:moto_mecanico/pages/loading_page.dart';
import 'package:moto_mecanico/storage/garage_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mocks/void_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MotoLogApp tests', () {
    late SharedPreferences mockPreferences;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      mockPreferences = await SharedPreferences.getInstance();
    });

    testWidgets('MotoLogApp shows LoadingPage initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(MotoLogApp(preferences: mockPreferences));

      expect(find.byType(LoadingPage), findsOneWidget);
    });

    testWidgets('MotoLogApp static applyConfiguration does not crash',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    // This should not crash even if not in proper context
                    MotoLogApp.applyConfiguration(context);
                  },
                  child: const Text('Test'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Should not crash
      expect(tester.takeException(), isNull);
    });

    group('Configuration loading', () {
      testWidgets('MotoLogApp handles different SharedPreferences values',
          (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({
          'locale': 'en_US',
          'currency': 'USD',
          'distance_unit': 'mile',
        });
        final prefs = await SharedPreferences.getInstance();

        final garage = GarageModel();
        garage.storage = GarageStorage();
        garage.storage!.storage = VoidStorage();

        var labels = LabelsModel();

        final app =
            MotoLogApp(preferences: prefs, garage: garage, labels: labels);
        await tester.pumpWidget(app);
        expect(find.byType(LoadingPage), findsOneWidget);

        await tester.pumpAndSettle();
        expect(find.byType(GaragePage), findsOneWidget);
      });

      testWidgets('MotoLogApp handles empty SharedPreferences',
          (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        final garage = GarageModel();
        garage.storage = GarageStorage();
        garage.storage!.storage = VoidStorage();

        var labels = LabelsModel();

        final app =
            MotoLogApp(preferences: prefs, garage: garage, labels: labels);
        await tester.pumpWidget(app);
        expect(find.byType(LoadingPage), findsOneWidget);

        await tester.pumpAndSettle();
        expect(find.byType(GaragePage), findsOneWidget);
      });
    });
  });
}
