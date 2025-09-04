import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:moto_mecanico/locale/formats.dart';
import 'package:moto_mecanico/models/labels.dart';
import 'package:moto_mecanico/models/motorcycle.dart';
import 'package:moto_mecanico/models/task.dart';
import 'package:moto_mecanico/motorcycle_alarms.dart';
import 'package:moto_mecanico/themes.dart';
import 'package:moto_mecanico/widgets/config_widget.dart';
import 'package:provider/provider.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.motorcycle,
    required this.task,
  });

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
              padding: const EdgeInsets.only(right: 9),
              width: 13,
              child: Consumer<LabelsModel>(
                builder: (context, labelsModel, child) {
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: _buildIndicators(labelsModel.labels));
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
                    task.description,
                    softWrap: true,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.taskCardDescription,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
                task.recurring
                    ? /*Icons.cached */ Icons.autorenew
                    : Icons.schedule,
                size: 22,
                color: task.recurring ||
                        task.dueDate != null ||
                        task.dueOdometer.isValid
                    ? Colors.blueGrey[100]
                    : Colors.transparent),
            _buildReminderBox(context),
          ]),
    );
  }

  Color _getAlarmColor(TaskAlarm alarm) {
    return alarm == TaskAlarm.red
        ? RnrColors.mediumRed
        : alarm == TaskAlarm.yellow
            ? Colors.orange
            : Colors.blueGrey[100]!;
  }

  Widget _buildReminderBox(BuildContext context) {
    final distanceUnit = ConfigWidget.of(context).distanceUnit;

    final distanceRemaining = !task.dueOdometer.isValid
        ? null
        : task.dueOdometer - motorcycle.odometer;
    final daysRemaining = task.dueDate
        ?.add(const Duration(hours: 23, minutes: 59))
        .difference(DateTime.now())
        .inDays
        .abs();

    final distanceColor =
        _getAlarmColor(motorcycle.getDistanceAlarmLevel(task));
    final durationColor =
        _getAlarmColor(motorcycle.getDurationAlarmLevel(task));

    final remaining = <Widget>[];
    String daysUnit = '';
    String daysStr = '';
    if (daysRemaining != null) {
      if (daysRemaining > 365) {
        final years = daysRemaining / 365;
        daysStr = years.toStringAsFixed(1);
        daysUnit = AppLocalizations.of(context)!.unit_years(years.round());
      } else {
        daysStr = '$daysRemaining';
        daysUnit = AppLocalizations.of(context)!.unit_days(daysRemaining);
      }
    }
    remaining.add(Text(
      daysUnit,
      style: Theme.of(context)
          .textTheme
          .titleSmall!
          .copyWith(color: Colors.blueGrey[200], fontSize: 13),
    ));
    remaining.add(Text(
      daysStr,
      style: Theme.of(context)
          .textTheme
          .titleSmall!
          .copyWith(color: durationColor, fontSize: 16),
    ));

    final distanceStr =
        distanceRemaining?.toUnit(distanceUnit).toString(compact: true);
    if (distanceStr != null) {
      remaining.add(
        Divider(
          height: 2,
          thickness: 2,
          color: Colors.blueGrey[400],
          indent: 24,
          endIndent: 24,
        ),
      );
      remaining.add(Text(
        distanceStr,
        style: Theme.of(context)
            .textTheme
            .titleSmall!
            .copyWith(color: distanceColor, fontSize: 16),
      ));
      remaining.add(Text(
        DistanceSupport.getUnitSymbol(distanceUnit),
        style: Theme.of(context)
            .textTheme
            .titleSmall!
            .copyWith(color: Colors.blueGrey[200], fontSize: 13),
      ));
    }
    return Container(
      height: 80,
      width: 76,
      padding: const EdgeInsets.all(1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [...remaining],
      ),
    );
  }

  List<Widget> _buildIndicators(Map<int, Label> labels) {
    final numLabels = task.labels.length;
    if (numLabels == 0) return [];

    return task.labels.map((id) {
      return Container(
          width: 8, height: 65 / numLabels, color: labels[id]!.color);
    }).toList();
  }
}
