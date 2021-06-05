import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:moto_mecanico/assets.dart';
import 'package:moto_mecanico/models/garage_model.dart';
import 'package:moto_mecanico/models/motorcycle.dart';
import 'package:moto_mecanico/pages/motorcycle_edit_page.dart';
import 'package:moto_mecanico/pages/motorcycle_view_page.dart';
import 'package:moto_mecanico/widgets/motorcycle_card.dart';
import 'package:provider/provider.dart';

/// This widget displays a list of motorcycle card, or a icon with text if the garage is empty
class MotoCardsView extends StatefulWidget {
  final String search;
  final MotorcycleSort sortMethod;
  final Widget snackBarMsg;

  MotoCardsView({
    Key key,
    this.search = '',
    this.sortMethod = MotorcycleSort.alarms,
    this.snackBarMsg,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MotoCardsViewState();
}

class _MotoCardsViewState extends State<MotoCardsView> {
  bool _garageLoaded = false;
  bool _initialized = false;

  void _loadGarage(BuildContext context, GarageModel garage) async {
    garage.onErrorCb = ((error) {
      final snackBar = SnackBar(
        content: Text(
          AppLocalizations.of(context).snackbar_storage_error +
              ': ${error.toString()}',
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });

    // FIXME: Ideally we would load the garage when the app starts, but there is no
    // way to display errors at that point.
    await garage.loadFromIndex();
    setState(() => _garageLoaded = true);
  }

  Widget _createEmptyGarage() {
    return Tooltip(
        message: AppLocalizations.of(context).garage_page_empty_garage,
        child: Image.asset(IMG_ROADSIGN_MOTO_PARKING, width: 140));
  }

  Widget _showGarageLoading(BuildContext context, GarageModel garage) {
    if (_initialized == false) {
      _initialized = true;
      _loadGarage(context, garage);
    }
    // FIXME: We should probably overlay the indicator on top of a grayed moto list
    // ...see the bikes appear as they are loaded
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context).garage_page_loading,
          style: Theme.of(context).textTheme.bodyText2,
        ),
        const SizedBox(height: 10),
        const CircularProgressIndicator(),
      ],
    );
  }

  Widget _createCards(BuildContext context, GarageModel garage) {
    if (_garageLoaded == false) {
      return _showGarageLoading(context, garage);
    }

    final motos = garage.getFilteredMotos(widget.search, widget.sortMethod);
    if (motos.isEmpty) return _createEmptyGarage();

    return Scrollbar(
      child: ListView(
        padding: const EdgeInsets.only(
            top: 8.0, left: 8.0, right: 8.0, bottom: 64.0),
        children: motos.map<Widget>((Motorcycle motorcycle) {
          return _createMotoCard(motorcycle);
        }).toList(),
      ),
    );
  }

  Widget _createMotoCard(Motorcycle motorcycle) {
    return ChangeNotifierProvider.value(
      value: motorcycle,
      child: Container(
        key:
            UniqueKey(), // FIXME: Isn't it the provider key that should be unique?
        margin: const EdgeInsets.only(bottom: 8.0),
        child: InkWell(
          child: MotorcycleCard(),
          onTap: () async {
            await Navigator.push<Motorcycle>(
              context,
              MaterialPageRoute<Motorcycle>(
                builder: (context) => ChangeNotifierProvider.value(
                  value: motorcycle,
                  child: MotorcycleViewPage(),
                ),
              ),
            );
          },
          onLongPress: () async {
            await Navigator.push<Motorcycle>(
              context,
              MaterialPageRoute<Motorcycle>(
                builder: (context) =>
                    MotorcycleEditPage(motorcycle: motorcycle),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.snackBarMsg != null) {
      // FIXME: This is terrible
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final snackBar = SnackBar(content: widget.snackBarMsg);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    }
    return Consumer<GarageModel>(
      builder: (context, garage, child) => _createCards(context, garage),
    );
  }
}
