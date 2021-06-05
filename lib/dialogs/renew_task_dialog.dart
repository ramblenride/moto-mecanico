import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:moto_mecanico/locale/formats.dart';
import 'package:moto_mecanico/models/distance.dart';
import 'package:moto_mecanico/models/task.dart';
import 'package:moto_mecanico/themes.dart';
import 'package:moto_mecanico/widgets/config_widget.dart';
import 'package:moto_mecanico/widgets/dissmiss_keyboard_ontap.dart';
import 'package:moto_mecanico/widgets/property_editor_card.dart';
import 'package:moto_mecanico/widgets/property_editor_row.dart';
import 'package:moto_mecanico/widgets/textformfield_date_picker.dart';

class RenewTaskDialog extends StatefulWidget {
  RenewTaskDialog({
    @required this.task,
    @required this.onResult,
  });

  final Task task;
  final Function(Task) onResult;

  @override
  State<StatefulWidget> createState() => _RenewTaskDialogState(task: task);
}

class _RenewTaskDialogState extends State<RenewTaskDialog> {
  _RenewTaskDialogState({@required task}) {
    newTask = Task.fromRenew(task);
  }

  var _distanceUnit;
  Task newTask;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _distanceUnit = ConfigWidget.of(context).distanceUnit;
    final propValueStyle = Theme.of(context).textTheme.propEditorValue;
    final dateFormat = DateFormat(ConfigWidget.of(context).dateFormat);

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
                padding: const EdgeInsets.only(top: 15, bottom: 10),
                decoration: BoxDecoration(
                  color: RnrColors.blue[800],
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                ),
                child: Text(
                  AppLocalizations.of(context).renew_task_dialog_title,
                  style: Theme.of(context).textTheme.dialogHeader,
                  textAlign: TextAlign.center,
                ),
              ),
              PropertyEditorCard(
                isDialog: true,
                children: [
                  PropertyEditorRow(
                    name: AppLocalizations.of(context)
                        .renew_task_dialog_date_prop_name,
                    inputField: TextFormFieldDatePicker(
                      decoration: _valueFieldDecoration(
                          AppLocalizations.of(context)
                              .renew_task_dialog_date_prop_hint),
                      textAlign: TextAlign.end,
                      style: propValueStyle,
                      initialDate: _getInitialDate(),
                      firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                      lastDate: DateTime(2099, 12, 31),
                      dateFormat: dateFormat,
                      onSaved: (selectedDate) {
                        newTask.dueDate = selectedDate;
                      },
                    ),
                  ),
                  PropertyEditorRow(
                    name: AppLocalizations.of(context)
                        .renew_task_dialog_odometer_prop_name,
                    inputField: TextFormField(
                      decoration: _valueFieldDecoration(
                          AppLocalizations.of(context)
                              .renew_task_dialog_odometer_prop_hint),
                      textAlign: TextAlign.end,
                      style: propValueStyle,
                      initialValue: _getInitialOdometer(),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                      ],
                      onSaved: (value) {
                        newTask.dueOdometer = Distance(
                            value.isNotEmpty ? int.parse(value) : null,
                            _distanceUnit);
                      },
                    ),
                    trailer: Text(
                      '${AppLocalSupport.distanceUnits[_distanceUnit]}',
                      style: propValueStyle,
                    ),
                  ),
                  // FIXME: It would be helpful if the user could select which attachments to keep
                  // Or maybe use a regular task editor instead of this dialog?
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: Text(
                        AppLocalizations.of(context).dialog_cancel_button,
                        style: Theme.of(context).textTheme.dialogButton),
                    onPressed: () => widget.onResult(null),
                  ),
                  TextButton(
                    child: Text(AppLocalizations.of(context).dialog_add_button,
                        style: Theme.of(context).textTheme.dialogButton),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        widget.onResult(newTask);
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

  InputDecoration _valueFieldDecoration(String hint) {
    return InputDecoration.collapsed(
      hintText: hint,
      hintStyle: Theme.of(context).textTheme.propEditorHint,
    );
  }

  String _getInitialOdometer() {
    if (!newTask.dueOdometer.isValid || newTask.dueOdometer.distance == 0) {
      return '';
    }

    return newTask.dueOdometer.toUnit(_distanceUnit).toString();
  }

  DateTime _getInitialDate() {
    return newTask.dueDate;
  }
}
