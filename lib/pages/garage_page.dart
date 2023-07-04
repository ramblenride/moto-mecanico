import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:moto_mecanico/garage_import_export.dart';
import 'package:moto_mecanico/models/garage_model.dart';
import 'package:moto_mecanico/models/motorcycle.dart';
import 'package:moto_mecanico/pages/motorcycle_edit_page.dart';
import 'package:moto_mecanico/storage/motorcycle_local_storage.dart';
import 'package:moto_mecanico/widgets/app_bar_filter.dart';
import 'package:moto_mecanico/widgets/garage_drawer.dart';
import 'package:moto_mecanico/widgets/moto_cards_view.dart';
import 'package:provider/provider.dart';

/// This is the initial page shown when opening the application.
/// It displays a list of the motorcycles in the garage.
/// It's possible to filter the items to be shown and to sort
/// based on different criterias.
/// Clicking on a motorcycle opens the 'view motorcycle' page.
/// A floating button links to the 'add motorcycle' page.
/// A drawer contains links to settings, etc...
class GaragePage extends StatefulWidget {
  GaragePage({Key? key}) : super(key: key);

  @override
  _GaragePageState createState() => _GaragePageState();
}

class _GaragePageState extends State<GaragePage> {
  bool _isLoading = false;

  // FIXME: Cannot show snackbar cleanly in this widget because it creates the scaffold.
  // Create a loading widget that wraps the main page and shows errors
  Widget? _snackBarMsg;
  String _search = '';
  MotorcycleSort _sort = MotorcycleSort.alarms;

  String _getSortMethodStr(MotorcycleSort method) {
    switch (method) {
      case MotorcycleSort.alarms:
        return AppLocalizations.of(context)!.garage_page_sort_list_alarms;
      case MotorcycleSort.make:
        return AppLocalizations.of(context)!.garage_page_sort_list_make;
      case MotorcycleSort.name:
        return AppLocalizations.of(context)!.garage_page_sort_list_name;
      case MotorcycleSort.year:
        return AppLocalizations.of(context)!.garage_page_sort_list_year;
    }
  }

  void _addMotorcycle() {
    Navigator.push<Motorcycle>(
      context,
      MaterialPageRoute<Motorcycle>(
          builder: (context) => MotorcycleEditPage(motorcycle: null)),
    );
  }

  void _updateSearchQuery(String newQuery) {
    setState(() {
      _search = newQuery;
    });
  }

  void _updateSortMethod(MotorcycleSort newSort) {
    setState(() {
      _sort = newSort;
    });
  }

  List<Widget> _buildActions() {
    return <Widget>[
      PopupMenuButton<MotorcycleSort>(
        tooltip: AppLocalizations.of(context)!.garage_page_sort_button_tooltip,
        icon: const Icon(Icons.sort),
        onSelected: _updateSortMethod,
        itemBuilder: (context) {
          final list = <PopupMenuEntry<MotorcycleSort>>[
            PopupMenuItem(
              child: Text(
                AppLocalizations.of(context)!.garage_page_sort_list_header,
              ),
              value: null,
              enabled: false,
            ),
            PopupMenuDivider(),
          ];

          for (final sortValue in MotorcycleSort.values) {
            list.add(
              PopupMenuItem(
                value: sortValue,
                child: ListTile(
                  leading: Icon(_sort == sortValue
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked),
                  title: Text(_getSortMethodStr(sortValue)),
                ),
              ),
            );
          }

          return list;
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final msg = _snackBarMsg;
    _snackBarMsg = null;

    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBarFilter(
          title: Text(AppLocalizations.of(context)!.garage_page_title),
          hintText: AppLocalizations.of(context)!.appbar_filter_textfield_hint,
          updateSearchQueryCb: _updateSearchQuery,
          leadingActions: _buildActions(),
        ),
        drawer: GarageDrawer(
          onImport: _importGarage,
          onExport: _exportGarage,
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.library_add),
          tooltip:
              AppLocalizations.of(context)!.garage_page_add_motorcycle_button,
          onPressed: _addMotorcycle,
        ),
        body: Center(
          child: MotoCardsView(
            snackBarMsg: msg,
            search: _search,
            sortMethod: _sort,
          ),
        ),
      ),
    );
  }

  void _importGarage() async {
    setState(() => _isLoading = true);
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['zip']);
    if (result?.files.single.path != null) {
      final zipFile = File(result!.files.single.path!);
      final garage = Provider.of<GarageModel>(context, listen: false);
      try {
        final newGarage = await GarageImportExport.Import(zipFile);
        await _addToGarage(garage, newGarage);
      } catch (error) {
        debugPrint('Import error: ${error.toString()}');
        _snackBarMsg = Text(AppLocalizations.of(context)!.garage_import_error);
      }
      await zipFile.delete();
      GarageImportExport.RemoveTempDirectory();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _addToGarage(GarageModel garage, GarageModel newGarage) async {
    var nbIgnored = 0;
    for (final moto in newGarage.motos) {
      if (garage.motos.contains(moto)) {
        nbIgnored += 1;
      } else {
        final storage = MotorcycleLocalStorage(motoId: moto.id);
        await storage.connect();
        await garage.add(await Motorcycle.fromMotorcycle(moto, storage));
      }
    }
    if (nbIgnored > 0) {
      debugPrint('Garage import ignored ${nbIgnored} motos');
      _snackBarMsg =
          Text(AppLocalizations.of(context)!.garage_import_ignored(nbIgnored));
    }
  }

  void _exportGarage() async {
    final garage = Provider.of<GarageModel>(context, listen: false);
    try {
      setState(() => _isLoading = true);
      final zipFile = await GarageImportExport.Export(garage);
      if (zipFile == null) throw Exception('Failed to create zip file');
      /* FIXME!!!!!
      await Share.shareFiles([zipFile.path],
          subject: 'Moto Mecanico - ' +
              AppLocalizations.of(context)!.garage_page_title);
*/
      await zipFile.delete();
    } catch (error) {
      debugPrint('Export error: ${error.toString()}');
      _snackBarMsg = Text(AppLocalizations.of(context)!.garage_export_error);
    }

    GarageImportExport.RemoveTempDirectory();
    setState(() => _isLoading = false);
  }
}
