import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:moto_mecanico/models/cost.dart';
import 'package:moto_mecanico/models/distance.dart';
import 'package:moto_mecanico/models/motorcycle.dart';
import 'package:moto_mecanico/motorcycle_utils.dart';
import 'package:moto_mecanico/themes.dart';
import 'package:moto_mecanico/widgets/config_widget.dart';
import 'package:provider/provider.dart';

class MotorcycleInfoTab extends StatelessWidget {
  const MotorcycleInfoTab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const imageHeight = 250.0;
    final theme = Theme.of(context);
    final descriptionStyle =
        theme.textTheme.propEditorValue.copyWith(fontSize: 16);
    final propNameStyle = theme.textTheme.propEditorName.copyWith(fontSize: 14);
    final distanceUnit = ConfigWidget.of(context).distanceUnit;

    final smallCurrencyFormat = NumberFormat.simpleCurrency(
      name: ConfigWidget.of(context).currencySymbol,
      decimalDigits: 0,
    );
    smallCurrencyFormat.turnOffGrouping();

    final largeCurrencyFormat = NumberFormat.compactSimpleCurrency(
      name: ConfigWidget.of(context).currencySymbol,
      decimalDigits: 0,
    );
    largeCurrencyFormat.turnOffGrouping();

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Consumer<Motorcycle>(
          builder: (context, motorcycle, child) {
            // FIXME: Use Futures for these. It could take a while if there are many tasks.
            final costs = _buildCostList(context, motorcycle);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: imageHeight),
                  child: FutureBuilder(
                    future: getMotoPicture(motorcycle),
                    builder: (BuildContext context,
                        AsyncSnapshot<ImageProvider> imageProvider) {
                      if (imageProvider.hasData) {
                        return Image(
                          image: imageProvider.data,
                          fit: BoxFit.contain,
                        );
                      } else if (imageProvider.hasError) {
                        return Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.redAccent,
                                size: 48,
                              ),
                              Text(AppLocalizations.of(context)
                                  .motorcycle_image_load_failed),
                            ],
                          ),
                        );
                      } else {
                        return Icon(Icons.image_search);
                      }
                    },
                  ),
                ),

                // Complete details
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0),
                  child: DefaultTextStyle(
                    softWrap: true,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: descriptionStyle,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                          child: Text(
                            motorcycle.description,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            style: descriptionStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        RnrDivider,
                        Center(
                          child: Text(
                            _getCaredFor(context, distanceUnit, motorcycle),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ),
                        RnrDivider,
                        const SizedBox(height: 5),
                        _getInfoRow(
                          context,
                          AppLocalizations.of(context)
                              .motorcycle_edit_page_name_prop_vin,
                          motorcycle.vin,
                          AppLocalizations.of(context)
                              .motorcycle_edit_page_name_prop_licence_plate,
                          motorcycle.immatriculation,
                          propNameStyle,
                        ),
                        const SizedBox(height: 10),
                        _getInfoRow(
                          context,
                          AppLocalizations.of(context)
                              .motorcycle_edit_page_name_prop_color,
                          motorcycle.color,
                          AppLocalizations.of(context)
                              .motorcycle_edit_page_name_prop_odometer,
                          motorcycle.odometer
                              .toUnit(distanceUnit)
                              .toFullString(),
                          propNameStyle,
                        ),
                        const SizedBox(height: 10),
                        _getInfoRow(
                          context,
                          AppLocalizations.of(context)
                              .motorcycle_edit_page_name_prop_purchase_date,
                          _getPurchaseDateStr(context, motorcycle),
                          AppLocalizations.of(context)
                              .motorcycle_edit_page_name_prop_purchase_odometer,
                          motorcycle.purchaseOdometer
                              .toUnit(distanceUnit)
                              .toFullString(),
                          propNameStyle,
                        ),
                        const SizedBox(height: 5),
                        RnrDivider,
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context).cost_total,
                              textAlign: TextAlign.start,
                              style:
                                  Theme.of(context).textTheme.propEditorHeader,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${_formatCurrency(_getSpendingCost(motorcycle), smallCurrencyFormat, largeCurrencyFormat)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .selectorWidgetHeader
                                  .copyWith(
                                    color: Colors.blueGrey[100],
                                  ),
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _getInfoRow(
                          context,
                          costs[0].description.toUpperCase(),
                          _formatCurrency(costs[0].value, smallCurrencyFormat,
                              largeCurrencyFormat),
                          costs[1].description.toUpperCase(),
                          _formatCurrency(costs[1].value, smallCurrencyFormat,
                              largeCurrencyFormat),
                          propNameStyle,
                        ),
                        const SizedBox(height: 10),
                        _getInfoRow(
                          context,
                          costs[2].description.toUpperCase(),
                          _formatCurrency(costs[2].value, smallCurrencyFormat,
                              largeCurrencyFormat),
                          costs[3].description.toUpperCase(),
                          _formatCurrency(costs[3].value, smallCurrencyFormat,
                              largeCurrencyFormat),
                          propNameStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatCurrency(value, NumberFormat smallCurrencyFormat,
      NumberFormat largeCurrencyFormat) {
    return value > 99999
        ? largeCurrencyFormat.format(value)
        : smallCurrencyFormat.format(value);
  }

  Widget _getInfoRow(BuildContext context, String propName1, String propValue1,
      String propName2, String propValue2, TextStyle propNameStyle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _getInfoProp(context, propName1, propValue1, propNameStyle),
        ),
        const SizedBox(width: 4),
        Expanded(
          flex: 2,
          child: _getInfoProp(context, propName2, propValue2, propNameStyle),
        ),
      ],
    );
  }

  Widget _getInfoProp(BuildContext context, String propName, String propValue,
      TextStyle propNameStyle) {
    final value =
        (propValue != null && propValue.isNotEmpty) ? propValue : '---';
    return InkWell(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: value)).then((result) {
          final snackBar = SnackBar(
            content: Text(
                AppLocalizations.of(context).snackbar_copy_to_clipboard(value)),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
          ),
          Text(
            propName,
            maxLines: 2,
            style: propNameStyle,
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }

  String _getPurchaseDateStr(BuildContext context, Motorcycle motorcycle) {
    if (motorcycle.purchaseDate != null) {
      return '${DateFormat(ConfigWidget.of(context).dateFormat).format(motorcycle.purchaseDate)}';
    }
    return '---';
  }

  String _getCaredFor(
      BuildContext context, DistanceUnit distanceUnit, Motorcycle motorcycle) {
    var caredFor = '';
    if (motorcycle.purchaseDate != null) {
      final difference =
          DateTime.now().difference(motorcycle.purchaseDate).inDays.abs();
      if (difference > 365) {
        final years = difference / 365;
        caredFor +=
            ' ${years.toStringAsFixed(1)} ${AppLocalizations.of(context).unit_years(years.round())}';

        AppLocalizations.of(context).unit_years(years.round());
      } else {
        caredFor +=
            ' ${difference.toString()} ${AppLocalizations.of(context).unit_days(difference)}';
      }
    }

    if (motorcycle.odometer.distance != null &&
        motorcycle.odometer.distance > 0) {
      if (caredFor.isNotEmpty) {
        caredFor += ' ${AppLocalizations.of(context).info_tab_over}';
      }
      caredFor +=
          ' ${(motorcycle.odometer - motorcycle.purchaseOdometer).toUnit(distanceUnit).toFullString()}';
    }

    if (caredFor.isNotEmpty) {
      return '${AppLocalizations.of(context).info_tab_enjoyed_for}${caredFor}.';
    }

    return '';
  }

  List<Cost> _buildCostList(BuildContext context, Motorcycle motorcycle) {
    final purchase = Cost(
        motorcycle.purchasePrice ?? 0, AppLocalizations.of(context).motorcycle,
        type: CostType.other);
    var totalParts = Cost(0, AppLocalizations.of(context).cost_type_parts,
        type: CostType.part);
    var totalLabor = Cost(0, AppLocalizations.of(context).cost_type_labor,
        type: CostType.labor);
    var totalOther = Cost(0, AppLocalizations.of(context).cost_type_other,
        type: CostType.other);

    motorcycle.closedTasks.forEach((task) {
      totalParts.value =
          Cost.total([totalParts, ...task.costs], CostType.part).value;
      totalLabor.value =
          Cost.total([totalLabor, ...task.costs], CostType.labor).value;
      totalOther.value =
          Cost.total([totalOther, ...task.costs], CostType.other).value;
    });

    return [purchase, totalParts, totalLabor, totalOther];
  }

  int _getSpendingCost(Motorcycle motorcycle) {
    // FIXME: Reuse the totals for each type instead of going through all the
    // tasks again.
    var spending = motorcycle.purchasePrice ?? 0;
    motorcycle.closedTasks.forEach((task) => spending += (task.cost.value));
    return spending;
  }
}
