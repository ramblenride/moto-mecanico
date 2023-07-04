import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:moto_mecanico/locale/formats.dart';
import 'package:moto_mecanico/models/labels.dart';
import 'package:moto_mecanico/models/motorcycle.dart';
import 'package:moto_mecanico/models/task.dart';
import 'package:moto_mecanico/themes.dart';
import 'package:moto_mecanico/widgets/config_widget.dart';
import 'package:provider/provider.dart';

// FIXME: This code is fairly similar to the TaskCard but keeping them
// separate because we're playing around with the look a lot.
// Merge/reuse when happy with results.
class ClosedTaskCard extends StatelessWidget {
  const ClosedTaskCard({Key? key, required this.motorcycle, required this.task})
      : super(key: key);

  final Motorcycle motorcycle;
  final Task task;

  bool matches(String match) {
    return task.matches(match);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: RnrColors.darkBlue,
        border: Border(
          top: BorderSide(color: Colors.transparent),
          left: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
          bottom: BorderSide(color: Colors.white54),
        ),
      ),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(right: 9),
              width: 13,
              child: Consumer<LabelsModel>(
                builder: (context, labels_model, child) {
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: _buildIndicators(labels_model.labels));
                },
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    task.name,
                    style: Theme.of(context).textTheme.taskCardName,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _getTotalCostStr(context),
                    style: Theme.of(context).textTheme.taskCardDescription,
                  ),
                  Text(
                    _getWorkDoneByStr(context),
                    style: Theme.of(context).textTheme.taskCardDescription,
                  ),
                ],
              ),
            ),
            _buildReminderBox(context),
          ]),
    );
  }

  String _getTotalCostStr(context) {
    if (task.cost.value > 0) {
      final currencyFormat = NumberFormat.simpleCurrency(
        name: ConfigWidget.of(context).currencySymbol,
        decimalDigits: 0,
      );
      return AppLocalizations.of(context)!.closed_task_card_cost +
          ': ' +
          currencyFormat.format(task.cost.value);
    }
    return '';
  }

  String _getWorkDoneByStr(context) {
    if (task.executor.isNotEmpty == true) {
      return AppLocalizations.of(context)!.closed_task_card_executor +
          ': ' +
          '${task.executor}';
    }
    return '';
  }

  Widget _buildReminderBox(BuildContext context) {
    final distanceUnit = ConfigWidget.of(context).distanceUnit;

    final distanceElapsed = !task.closedOdometer.isValid
        ? null
        : (motorcycle.odometer - task.closedOdometer);
    final daysElapsed = task.closedDate == null
        ? null
        : DateTime.now().difference(task.closedDate!).inDays;

    final remaining = <Widget>[];
    var daysUnit;
    var daysStr;
    if (daysElapsed != null) {
      if (daysElapsed.abs() > 365) {
        final years = daysElapsed / 365;
        daysStr = years.toStringAsFixed(1);
        daysUnit =
            AppLocalizations.of(context)!.unit_years(years.abs().round());
      } else {
        daysStr = '$daysElapsed';
        daysUnit = AppLocalizations.of(context)!.unit_days(daysElapsed.abs());
      }
    }
    if (daysStr != null) {
      remaining.add(Text(daysUnit,
          style: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(color: Colors.blueGrey[200], fontSize: 13)));
      remaining.add(Text(daysStr,
          style: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(color: Colors.blueGrey[100], fontSize: 16)));
    }

    final distanceStr = distanceElapsed != null
        ? distanceElapsed.toUnit(distanceUnit).toString(compact: true)
        : null;

    if (distanceStr != null) {
      if (daysStr != null) {
        remaining.add(Divider(
          height: 2,
          thickness: 2,
          color: Colors.blueGrey[400],
          indent: 24,
          endIndent: 24,
        ));
      }

      remaining.add(Text(distanceStr,
          style: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(color: Colors.blueGrey[100], fontSize: 16)));
      remaining.add(Text(AppLocalSupport.distanceUnitsCompact[distanceUnit]!,
          style: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(color: Colors.blueGrey[200], fontSize: 13)));
    }

    return Container(
      height: 80,
      width: 76,
      padding: EdgeInsets.all(1),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [...remaining]),
    );
  }

  List<Widget> _buildIndicators(Map<int, Label> labels) {
    final num_labels = task.labels.length;
    if (num_labels == 0) return [];

    return task.labels.map((id) {
      return Container(
          width: 8, height: 65 / num_labels, color: labels[id]!.color);
    }).toList();
  }
}
