import 'package:flutter/material.dart';
import 'package:moto_mecanico/models/motorcycle.dart';
import 'package:moto_mecanico/motorcycle_alarms.dart';
import 'package:moto_mecanico/themes.dart';

class AlarmsIndicator extends StatelessWidget {
  AlarmsIndicator({required this.motorcycle});

  final Motorcycle motorcycle;

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: _getAlarmIcons(context));
  }

  List<Widget> _getAlarmIcons(BuildContext context) {
    final redAlerts = motorcycle.getRedAlerts();
    final yellowAlerts = motorcycle.getYellowAlerts();

    final alarmIcons = <Widget>[];
    if (redAlerts.isNotEmpty) {
      alarmIcons.add(
        Tooltip(
          message: 'Alerts', // FIXME: Translate
          child: _buildAlarm(context, RnrColors.red, redAlerts.length),
        ),
      );
    }

    if (yellowAlerts.isNotEmpty) {
      alarmIcons.add(
        Tooltip(
          message: 'Warnings', // FIXME: Translate
          child: _buildAlarm(context, Colors.orange, yellowAlerts.length),
        ),
      );
    }

    return alarmIcons;
  }

  Widget _buildAlarm(BuildContext context, Color color, int number) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.check_box_outline_blank,
          size: 36,
          color: color,
        ),
        Text(
          number.toString(),
          style: Theme.of(context).textTheme.taskCardName.copyWith(
                fontSize: 15,
                color: color,
              ),
        ),
      ],
    );
  }
}
