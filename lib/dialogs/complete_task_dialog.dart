import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:moto_mecanico/locale/formats.dart';
import 'package:moto_mecanico/models/distance.dart';
import 'package:moto_mecanico/models/motorcycle.dart';
import 'package:moto_mecanico/models/note.dart';
import 'package:moto_mecanico/models/task.dart';
import 'package:moto_mecanico/themes.dart';
import 'package:moto_mecanico/widgets/config_widget.dart';
import 'package:moto_mecanico/widgets/dissmiss_keyboard_ontap.dart';
import 'package:moto_mecanico/widgets/note_selector_row.dart';
import 'package:moto_mecanico/widgets/property_editor_card.dart';
import 'package:moto_mecanico/widgets/property_editor_row.dart';
import 'package:moto_mecanico/widgets/textformfield_date_picker.dart';

class CompleteTaskDialog extends StatefulWidget {
  CompleteTaskDialog({
    @required this.motorcycle,
    @required this.tasks,
    @required this.onResult,
  });

  final Motorcycle motorcycle;
  final List<Task> tasks;
  final Function(bool) onResult;

  @override
  State<StatefulWidget> createState() => _CompleteTaskDialogState(tasks: tasks);
}

class _CompleteTaskDialogState extends State<CompleteTaskDialog> {
  _CompleteTaskDialogState({@required this.tasks});

  final List<Task> tasks;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final propValueStyle = Theme.of(context).textTheme.propEditorValue;
    final distanceUnit = ConfigWidget.of(context).distanceUnit;
    final dateFormat = DateFormat(ConfigWidget.of(context).dateFormat);

    return Dialog(
      child: DismissKeyboardOnTap(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  AppLocalizations.of(context)
                      .complete_task_dialog_title(tasks.length),
                  style: Theme.of(context).textTheme.dialogHeader,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5),
                child: Form(
                  key: _formKey,
                  child: Wrap(
                    children: [
                      PropertyEditorCard(
                        isDialog: true,
                        children: [
                          PropertyEditorRow(
                            name: AppLocalizations.of(context)
                                .complete_task_dialog_date_prop_name,
                            inputField: TextFormFieldDatePicker(
                              decoration: _valueFieldDecoration(
                                  AppLocalizations.of(context)
                                      .complete_task_dialog_date_prop_hint),
                              textAlign: TextAlign.end,
                              style: propValueStyle,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                              lastDate: DateTime(2099, 12, 31),
                              dateFormat: dateFormat,
                              onSaved: (selectedDate) {
                                for (final task in tasks) {
                                  task.closedDate = selectedDate;
                                }
                              },
                            ),
                          ),
                          PropertyEditorRow(
                            name: AppLocalizations.of(context)
                                .motorcycle_edit_page_name_prop_odometer,
                            inputField: TextFormField(
                              decoration: _valueFieldDecoration(
                                  AppLocalizations.of(context)
                                      .motorcycle_edit_page_hint_prop_odometer),
                              textAlign: TextAlign.end,
                              style: propValueStyle,
                              initialValue: widget.motorcycle.odometer
                                  .toUnit(distanceUnit)
                                  .toString(),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(7),
                              ],
                              onSaved: (value) {
                                final closedValue = Distance(
                                    value.isNotEmpty ? int.parse(value) : null,
                                    distanceUnit);
                                for (final task in tasks) {
                                  task.closedOdometer = closedValue;
                                }
                              },
                            ),
                            trailer: Text(
                              '${AppLocalSupport.distanceUnits[distanceUnit]}',
                              style: propValueStyle,
                            ),
                          ),
                          PropertyEditorRow(
                            name: AppLocalizations.of(context)
                                .task_edit_page_name_prop_executor,
                            inputField: TextFormField(
                              decoration: _valueFieldDecoration(
                                  AppLocalizations.of(context)
                                      .task_edit_page_hint_prop_executor),
                              textAlign: TextAlign.end,
                              style: propValueStyle,
                              initialValue:
                                  tasks.first?.executor?.toString() ?? '',
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(32),
                              ],
                              onSaved: (value) {
                                for (final task in tasks) {
                                  task.executor = value;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      PropertyEditorCard(
                        title: AppLocalizations.of(context)
                            .motorcycle_edit_page_section_header_notes,
                        children: [
                          NoteSelectorRow(
                            header: false,
                            minLines: 3,
                            maxLines: 5,
                            onSaved: (value) {
                              if (value != null) {
                                for (final task in tasks) {
                                  task.notes.add(Note.from(value));
                                }
                              }
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          TextButton(
                            child: Text(
                                AppLocalizations.of(context)
                                    .dialog_cancel_button,
                                style:
                                    Theme.of(context).textTheme.dialogButton),
                            onPressed: () => widget.onResult(false),
                          ),
                          TextButton(
                            child: Text(
                                AppLocalizations.of(context)
                                    .dialog_complete_button,
                                style:
                                    Theme.of(context).textTheme.dialogButton),
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                for (final task in tasks) {
                                  task.closed = true;
                                }
                                _formKey.currentState.save();
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
}
