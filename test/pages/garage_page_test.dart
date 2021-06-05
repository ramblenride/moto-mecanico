import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moto_mecanico/configuration.dart';
import 'package:moto_mecanico/models/garage_model.dart';
import 'package:moto_mecanico/models/motorcycle.dart';
import 'package:moto_mecanico/pages/garage_page.dart';
import 'package:moto_mecanico/storage/garage_storage.dart';
import 'package:moto_mecanico/widgets/config_widget.dart';
import 'package:moto_mecanico/widgets/motorcycle_card.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mocks/motorcycle_void_storage.dart';
import '../mocks/void_storage.dart';

Future<Widget> createGaragePage(GarageModel garage) async {
  SharedPreferences.setMockInitialValues({});

  final config = Configuration('en');
  await config.loadConfig();

  return ConfigWidget(
    config: config,
    child: ChangeNotifierProvider<GarageModel>.value(
      value: garage,
      child: MaterialApp(
        locale: config.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: GaragePage(),
      ),
    ),
  );
}

void addMotos(GarageModel garage, int n, bool reverseSort) async {
  final motos = [];
  await Iterable<int>.generate(n).forEach((i) async {
    final moto = Motorcycle(
      name: reverseSort ? 'Moto-${n - 1 - i}' : 'Moto-$i',
    );
    moto.storage = MotorcycleVoidStorage();
    motos.add(moto);
  });
  motos.forEach((moto) => garage.add(moto));
}

void main() async {
  testWidgets('empty garage contains one image', (WidgetTester tester) async {
    final garage = GarageModel();
    await tester.pumpWidget(await createGaragePage(garage));
    await tester.pumpAndSettle();

    // An empty garage should contain only one image with a tooltip
    expect(find.byType(Image), findsOneWidget);

    // ...and no motorcycle card
    expect(find.byType(MotorcycleCard, skipOffstage: false), findsNothing);
  });

  testWidgets('a garage with one motorcycle creates one card',
      (WidgetTester tester) async {
    final garage = GarageModel();
    await garage.add(Motorcycle(name: 'Test'));
    await tester.pumpWidget(await createGaragePage(garage));
    await tester.pumpAndSettle();
    expect(find.byType(MotorcycleCard), findsOneWidget);
  });

  testWidgets('adding a motorcycle to the garage creates one card',
      (WidgetTester tester) async {
    final garage = GarageModel();
    await tester.pumpWidget(await createGaragePage(garage));

    await garage.add(Motorcycle(name: 'Test'));
    await tester.pumpAndSettle();
    expect(find.byType(MotorcycleCard), findsOneWidget);
  });

  testWidgets('large garage can scroll', (WidgetTester tester) async {
    final garage = GarageModel();
    await addMotos(garage, 5, false);

    await tester.pumpWidget(await createGaragePage(garage));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(MotorcycleCard, 'Moto-0'), findsOneWidget);
    await tester.fling(find.byType(ListView), Offset(0, -200), 3000);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(MotorcycleCard, 'Moto-0'), findsNothing);
    expect(find.text('Moto-3'), findsOneWidget);
  });

  testWidgets('tapping card opens motorcycle view page',
      (WidgetTester tester) async {
    final garage = GarageModel();
    await addMotos(garage, 1, false);

    await tester.pumpWidget(await createGaragePage(garage));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(MotorcycleCard).first);
    await tester.pumpAndSettle();

    // An empty motorcycle should contain no tasks (represented by an image)
    expect(find.byType(Image), findsOneWidget);

    // The view page should contain the motorcycle name in the appbar
    expect(find.widgetWithText(AppBar, 'Moto-0'), findsOneWidget);

    // New page has button to go back to garage
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('long press on card opens motorcycle edit page',
      (WidgetTester tester) async {
    final garage = GarageModel();
    garage.storage = GarageStorage();
    garage.storage.storage = VoidStorage();
    await addMotos(garage, 1, false);

    await tester.pumpWidget(await createGaragePage(garage));
    await tester.pumpAndSettle();

    await tester.longPress(find.byType(MotorcycleCard).first);
    await tester.pumpAndSettle();

    // Check page title
    expect(find.widgetWithText(AppBar, 'Edit Motorcycle'), findsOneWidget);

    // New page has button to go back to garage
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('sorting moto cards by name', (WidgetTester tester) async {
    final garage = GarageModel();
    await addMotos(garage, 5, true);

    await tester.pumpWidget(await createGaragePage(garage));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(MotorcycleCard, 'Moto-0'), findsNothing);
    await tester.tap(find.byTooltip('Sort the motorcycle list'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Name'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(MotorcycleCard, 'Moto-0'), findsOneWidget);
  });

  testWidgets('filtering moto cards', (WidgetTester tester) async {
    final garage = GarageModel();
    await addMotos(garage, 6, false);

    await tester.pumpWidget(await createGaragePage(garage));
    await tester.pumpAndSettle();

    // Many motorcycles initially
    expect(
        tester.widgetList(find.byType(MotorcycleCard)).length, greaterThan(1));
    expect(find.widgetWithText(MotorcycleCard, 'Moto-5'), findsNothing);
    await tester.tap(find.byTooltip('Filter the motorcycle list'));
    await tester.pumpAndSettle();

    // Filtering on a broad name has many hits
    await tester.enterText(find.byType(TextField), 'Moto');
    await tester.pumpAndSettle();
    expect(
        tester.widgetList(find.byType(MotorcycleCard)).length, greaterThan(1));

    // Filter on a specific motorcycle name has only one hit
    await tester.enterText(find.byType(TextField), 'Moto-5');
    await tester.pumpAndSettle();
    expect(find.byType(MotorcycleCard), findsNWidgets(1));
    expect(find.widgetWithText(MotorcycleCard, 'Moto-5'), findsOneWidget);
  });
}
