import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:moto_mecanico/locale/formats.dart';
import 'package:moto_mecanico/models/distance.dart';
import 'package:moto_mecanico/models/task.dart';
import 'package:moto_mecanico/themes.dart';
import 'package:moto_mecanico/widgets/config_widget.dart';
import 'package:moto_mecanico/widgets/dissmiss_keyboard_ontap.dart';
import 'package:moto_mecanico/widgets/property_editor_card.dart';
import 'package:moto_mecanico/widgets/property_editor_row.dart';

class RecurringTaskDialog extends StatefulWidget {
  RecurringTaskDialog({required this.task, required this.onResult});

  final Task task;
  final Function(bool) onResult;

  @override
  State<StatefulWidget> createState() => _RecurringTaskDialogState(task: task);
}

class _RecurringTaskDialogState extends State<RecurringTaskDialog> {
  _RecurringTaskDialogState({required this.task});

  var _distanceUnit;
  final Task task;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final propValueStyle = Theme.of(context).textTheme.propEditorValue;
    _distanceUnit = ConfigWidget.of(context).distanceUnit;

    return DismissKeyboardOnTap(
      child: Form(
        key: _formKey,
        child: Dialog(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.only(top: 15, bottom: 10),
                decoration: BoxDecoration(
                  color: RnrColors.blue[800],
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                ),
                child: Text(
                  AppLocalizations.of(context)!.recurring_task_dialog_title,
                  style: Theme.of(context).textTheme.dialogHeader,
                  textAlign: TextAlign.center,
                ),
              ),
              PropertyEditorCard(
                isDialog: true,
                children: [
                  PropertyEditorRow(
                    name: AppLocalizations.of(context)!
                        .recurring_task_dialog_duration_prop_name,
                    inputField: TextFormField(
                      decoration: _valueFieldDecoration(
                          context,
                          AppLocalizations.of(context)!
                              .recurring_task_dialog_duration_prop_hint),
                      textAlign: TextAlign.end,
                      style: propValueStyle,
                      initialValue: task.recurringMonths > 0
                          ? task.recurringMonths.toString()
                          : '',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                      ],
                      onSaved: (value) {
                        task.recurringMonths =
                            (value != null && value.isNotEmpty)
                                ? int.parse(value)
                                : 0;
                      },
                    ),
                    trailer: Text(
                      AppLocalizations.of(context)!
                          .recurring_task_dialog_duration_months,
                      style: propValueStyle,
                    ),
                  ),
                  PropertyEditorRow(
                    name: AppLocalizations.of(context)!
                        .recurring_task_dialog_distance_prop_name,
                    inputField: TextFormField(
                      decoration: _valueFieldDecoration(
                          context,
                          AppLocalizations.of(context)!
                              .recurring_task_dialog_distance_prop_hint),
                      textAlign: TextAlign.end,
                      style: propValueStyle,
                      initialValue: task.recurringOdometer
                          .toUnit(_distanceUnit)
                          .toString(),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                      ],
                      onSaved: (value) {
                        task.recurringOdometer = Distance(
                            (value != null && value.isNotEmpty)
                                ? int.parse(value)
                                : null,
                            _distanceUnit);
                      },
                    ),
                    trailer: Text(
                      '${AppLocalSupport.distanceUnits[_distanceUnit]}',
                      style: propValueStyle,
                    ),
                  ),
                ],
              ),
              const Flexible(
                child: SizedBox(height: 10),
              ),
              Wrap(
                runAlignment: WrapAlignment.end,
                alignment: WrapAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: Text(
                      AppLocalizations.of(context)!.dialog_cancel_button,
                      style: Theme.of(context).textTheme.dialogButton,
                    ),
                    onPressed: () => widget.onResult(false),
                  ),
                  TextButton(
                    child: Text(
                      AppLocalizations.of(context)!.dialog_save_button,
                      style: Theme.of(context).textTheme.dialogButton,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        widget.onResult(true);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _valueFieldDecoration(BuildContext context, String hint) {
    return InputDecoration.collapsed(
      hintText: hint,
      hintStyle: Theme.of(context).textTheme.propEditorHint,
    );
  }
}
