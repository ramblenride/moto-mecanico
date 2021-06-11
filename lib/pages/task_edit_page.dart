import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:moto_mecanico/assets.dart';
import 'package:moto_mecanico/dialogs/complete_task_dialog.dart';
import 'package:moto_mecanico/dialogs/delete_dialog.dart';
import 'package:moto_mecanico/dialogs/recurring_task_dialog.dart';
import 'package:moto_mecanico/locale/formats.dart';
import 'package:moto_mecanico/models/attachment.dart';
import 'package:moto_mecanico/models/distance.dart';
import 'package:moto_mecanico/models/motorcycle.dart';
import 'package:moto_mecanico/models/task.dart';
import 'package:moto_mecanico/themes.dart';
import 'package:moto_mecanico/widgets/attachment_selector.dart';
import 'package:moto_mecanico/widgets/config_widget.dart';
import 'package:moto_mecanico/widgets/cost_selector.dart';
import 'package:moto_mecanico/widgets/dissmiss_keyboard_ontap.dart';
import 'package:moto_mecanico/widgets/label_selector.dart';
import 'package:moto_mecanico/widgets/note_selector.dart';
import 'package:moto_mecanico/widgets/popup_buttons_button.dart';
import 'package:moto_mecanico/widgets/property_editor_card.dart';
import 'package:moto_mecanico/widgets/property_editor_row.dart';
import 'package:moto_mecanico/widgets/textformfield_date_picker.dart';

enum TaskAction { close, delete, reopen }

/// This page allows to add a new task or edit an existing one.
/// It contains all informations about the task.
/// A button allows to delete or close (complete) the task.
/// The changes are saved when the 'back' button is pressed.
class TaskEditPage extends StatefulWidget {
  TaskEditPage({Key key, @required this.motorcycle, this.task})
      : super(key: key);
  final Motorcycle motorcycle;
  final Task task;

  @override
  _TaskEditPageState createState() => _TaskEditPageState(task: task);
}

class _TaskEditPageState extends State<TaskEditPage> {
  _TaskEditPageState({this.task}) {
    _isNew = false;
    if (task == null) {
      _isNew = true;

      // Correctly create the task to track images/attachments
      // The task will be removed if the user leaves the page without adding it.
      task = Task(name: '');
    }
  }

  final _formKey = GlobalKey<FormState>();
  ScrollController _scrollController;
  Task task;
  bool _isNew;
  String _currencySymbol;
  DistanceUnit _distanceUnit;
  DateFormat _dateFormat;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _validateAndSaveTask() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      _saveTask();
      return true;
    }
    return false;
  }

  InputDecoration _valueFieldDecoration(String hint) {
    return InputDecoration.collapsed(
      hintText: hint,
      hintStyle: Theme.of(context).textTheme.propEditorHint,
    );
  }

  List<PopupButtonsItem> _technicalLevels() {
    const imgWidth = 32.0;
    return [
      PopupButtonsItem(
        icon: Icon(
          Icons.close,
          color: Colors.blueGrey[100],
        ),
        selectedIcon: Icon(
          Icons.more_horiz,
          color: Colors.blueGrey,
        ),
        value: TechnicalLevel.none,
        tooltip: AppLocalizations.of(context)
            .task_edit_page_tooltip_button_tech_level_none,
      ),
      PopupButtonsItem(
        icon: Image(
          image: AssetImage(IMG_TASK_SMALL),
          width: imgWidth,
        ),
        value: TechnicalLevel.easy,
        tooltip: AppLocalizations.of(context)
            .task_edit_page_tooltip_button_tech_level_easy,
      ),
      PopupButtonsItem(
        icon: Image(
          image: AssetImage(IMG_TASK_MEDIUM),
          width: imgWidth,
        ),
        value: TechnicalLevel.intermediate,
        tooltip: AppLocalizations.of(context)
            .task_edit_page_tooltip_button_tech_level_intermediate,
      ),
      PopupButtonsItem(
        icon: Image(
          image: AssetImage(IMG_TASK_LARGE),
          width: imgWidth,
        ),
        value: TechnicalLevel.pro,
        tooltip: AppLocalizations.of(context)
            .task_edit_page_tooltip_button_tech_level_difficult,
      ),
    ];
  }

  List<PopupButtonsItem> _effortLevels() {
    const imgWidth = 28.0;
    return [
      PopupButtonsItem(
        icon: Icon(
          Icons.close,
          color: Colors.blueGrey[100],
        ),
        selectedIcon: Icon(
          Icons.more_horiz,
          color: Colors.blueGrey,
        ),
        value: EffortLevel.none,
        tooltip: AppLocalizations.of(context)
            .task_edit_page_tooltip_button_effort_level_none,
      ),
      PopupButtonsItem(
        icon: Image(
          image: AssetImage(IMG_EFFORT_SMALL),
          width: imgWidth,
        ),
        value: EffortLevel.small,
        tooltip: AppLocalizations.of(context)
            .task_edit_page_tooltip_button_effort_level_small,
      ),
      PopupButtonsItem(
        icon: Image(
          image: AssetImage(IMG_EFFORT_MEDIUM),
          width: imgWidth,
        ),
        value: EffortLevel.medium,
        tooltip: AppLocalizations.of(context)
            .task_edit_page_tooltip_button_effort_level_medium,
      ),
      PopupButtonsItem(
        icon: Image(
          image: AssetImage(IMG_EFFORT_LARGE),
          width: imgWidth,
        ),
        value: EffortLevel.large,
        tooltip: AppLocalizations.of(context)
            .task_edit_page_tooltip_button_effort_level_large,
      ),
    ];
  }

  List<Widget> _buildFormFields() {
    final propValueStyle = Theme.of(context).textTheme.propEditorValue;
    final propLargeValueStyle =
        Theme.of(context).textTheme.propEditorLargeValue;

    return [
      PropertyEditorCard(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: _valueFieldDecoration(AppLocalizations.of(context)
                      .task_edit_page_hint_prop_name),
                  style: propValueStyle,
                  textAlign: TextAlign.center,
                  initialValue: task.name,
                  inputFormatters: [LengthLimitingTextInputFormatter(32)],
                  validator: (value) {
                    if (value.isEmpty) {
                      return AppLocalizations.of(context)
                          .property_name_missing_error;
                    }
                    return null;
                  },
                  onSaved: (value) {
                    task.name = value;
                  },
                ),
              ),
            ],
          ),
          RnrDivider,
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: _valueFieldDecoration(AppLocalizations.of(context)
                      .task_edit_page_hint_prop_description),
                  style: propLargeValueStyle,
                  textAlign: TextAlign.center,
                  minLines: 1,
                  maxLines: 3,
                  initialValue: task.description,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(96),
                  ],
                  textInputAction: TextInputAction.done,
                  onSaved: (value) {
                    task.description = value;
                  },
                ),
              ),
            ],
          ),
          RnrDivider,
          PropertyEditorRow(
            name: AppLocalizations.of(context)
                .motorcycle_edit_page_name_prop_tech_level,
            inputField: PopupButtonsButton(
              tooltip: AppLocalizations.of(context)
                  .task_edit_page_hint_prop_tech_level,
              items: _technicalLevels(),
              initialValue: task.technicalLevel ?? TechnicalLevel.none,
              onSelected: (level) => task.technicalLevel = level,
            ),
          ),
          PropertyEditorRow(
            name: AppLocalizations.of(context)
                .motorcycle_edit_page_name_prop_effort_level,
            inputField: PopupButtonsButton(
              tooltip: AppLocalizations.of(context)
                  .task_edit_page_hint_prop_effort_level,
              items: _effortLevels(),
              initialValue: task.effortLevel ?? EffortLevel.none,
              onSelected: (level) => task.effortLevel = level,
            ),
          ),
          LabelSelector(active_labels: task.labels),
        ],
      ),
      RnrDivider,
      task.closed ? _closedTaskSchedule() : _openTaskSchedule(),
      RnrDivider,
      PropertyEditorCard(
        children: [
          CostSelector(
            costs: task.costs,
            currencySymbol: _currencySymbol,
          ),
          const SizedBox(height: 8),
          AttachmentSelector(
            attachments: task.attachments,
            storage: widget.motorcycle.storage.storage,
          ),
        ],
      ),
      RnrDivider,
      PropertyEditorCard(
        children: [_buildNoteSelector()],
      ),
    ];
  }

  // FIXME: Move to its own widget
  Widget _openTaskSchedule() {
    final propValueStyle = Theme.of(context).textTheme.propEditorValue;
    return PropertyEditorCard(
      title: AppLocalizations.of(context).task_edit_page_header_schedule,
      icons: [
        Container(
          width: 40,
          height: 35,
          child: IconButton(
            padding: EdgeInsets.zero,
            alignment: Alignment.topCenter,
            visualDensity: VisualDensity.compact,
            iconSize: 30,
            tooltip: AppLocalizations.of(context)
                .task_edit_page_tooltip_add_to_calendar,
            icon: const Icon(
              Icons.insert_invitation,
            ),
            color: Colors.white70,
            onPressed: () async {
              final date = task.dueDate != null &&
                      task.dueDate.compareTo(DateTime.now()) > 0
                  ? task.dueDate
                  : DateTime.now();
              final event = Event(
                title: task.name,
                description: task.description,
                startDate: DateTime(date.year, date.month, date.day, 0, 0),
                endDate: DateTime(date.year, date.month, date.day, 23, 59),
                allDay: true,
              );

              await Add2Calendar.addEvent2Cal(event);
            },
          ),
        ),
        Container(
          width: 40,
          height: 35,
          child: IconButton(
            padding: EdgeInsets.zero,
            alignment: Alignment.topCenter,
            visualDensity: VisualDensity.compact,
            iconSize: 30,
            icon: const Icon(
              Icons.autorenew,
            ),
            color: !task.recurring ? Colors.white70 : Colors.green,
            tooltip: AppLocalizations.of(context)
                .task_edit_page_tooltip_recurring_button,
            onPressed: () async {
              final result = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return RecurringTaskDialog(
                      task: task,
                      onResult: (result) {
                        Navigator.of(context).pop(result);
                      },
                    );
                  });
              if (result == true) {
                setState(() => widget.motorcycle.saveChanges());
              }
            },
          ),
        ),
      ],
      children: [
        PropertyEditorRow(
          name:
              AppLocalizations.of(context).motorcycle_edit_page_name_prop_date,
          inputField: TextFormFieldDatePicker(
            decoration: _valueFieldDecoration(
                AppLocalizations.of(context).task_edit_page_hint_prop_date),
            textAlign: TextAlign.end,
            style: propValueStyle,
            initialDate: task.dueDate,
            firstDate: DateTime.fromMillisecondsSinceEpoch(0),
            lastDate: DateTime(2099, 12, 31),
            dateFormat: _dateFormat,
            onDateChanged: (date) {
              // Update the date immediately so that add2calender uses the correct date
              setState(() => task.dueDate = date);
            },
            onSaved: (selectedDate) {
              task.dueDate = selectedDate;
            },
          ),
        ),
        PropertyEditorRow(
          name: AppLocalizations.of(context)
              .motorcycle_edit_page_name_prop_odometer,
          inputField: TextFormField(
            decoration: _valueFieldDecoration(AppLocalizations.of(context)
                .motorcycle_edit_page_hint_prop_odometer),
            style: propValueStyle,
            textAlign: TextAlign.end,
            initialValue:
                task.dueOdometer?.toUnit(_distanceUnit).toString() ?? '',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(7),
            ],
            onSaved: (value) {
              task.dueOdometer = Distance(
                  value.isNotEmpty ? int.parse(value) : null, _distanceUnit);
            },
          ),
          trailer: Text(
            '${AppLocalSupport.distanceUnits[_distanceUnit]}',
            style: propValueStyle,
          ),
        ),
        PropertyEditorRow(
          name: AppLocalizations.of(context).task_edit_page_name_prop_executor,
          inputField: TextFormField(
            decoration: _valueFieldDecoration(
                AppLocalizations.of(context).task_edit_page_hint_prop_executor),
            textAlign: TextAlign.end,
            style: propValueStyle,
            initialValue: task.executor?.toString() ?? '',
            inputFormatters: [
              LengthLimitingTextInputFormatter(32),
            ],
            onSaved: (value) {
              task.executor = value;
            },
          ),
        ),
      ],
    );
  }

  // FIXME: Move to its own widget
  Widget _closedTaskSchedule() {
    // FIXME: This is the same as what's inside the CompleteTaskDialog
    final propValueStyle = Theme.of(context).textTheme.propEditorValue;
    return PropertyEditorCard(
      title: AppLocalizations.of(context).task_edit_page_header_closed_schedule,
      children: [
        PropertyEditorRow(
          name:
              AppLocalizations.of(context).complete_task_dialog_date_prop_name,
          inputField: TextFormFieldDatePicker(
            decoration: _valueFieldDecoration(AppLocalizations.of(context)
                .complete_task_dialog_date_prop_hint),
            textAlign: TextAlign.end,
            style: propValueStyle,
            initialDate: task.closedDate,
            firstDate: DateTime.fromMillisecondsSinceEpoch(0),
            lastDate: DateTime(2099, 12, 31),
            dateFormat: _dateFormat,
            onSaved: (selectedDate) {
              task.closedDate = selectedDate;
            },
          ),
        ),
        PropertyEditorRow(
          name: AppLocalizations.of(context)
              .motorcycle_edit_page_name_prop_odometer,
          inputField: TextFormField(
            decoration: _valueFieldDecoration(AppLocalizations.of(context)
                .motorcycle_edit_page_hint_prop_odometer),
            textAlign: TextAlign.end,
            style: propValueStyle,
            initialValue: task.closedOdometer.toUnit(_distanceUnit).toString(),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(7),
            ],
            onSaved: (value) {
              task.closedOdometer = Distance(
                  value.isNotEmpty ? int.parse(value) : null, _distanceUnit);
            },
          ),
          trailer: Text(
            '${AppLocalSupport.distanceUnits[_distanceUnit]}',
            style: propValueStyle,
          ),
        ),
        PropertyEditorRow(
          name: AppLocalizations.of(context).task_edit_page_name_prop_executor,
          inputField: TextFormField(
            decoration: _valueFieldDecoration(
                AppLocalizations.of(context).task_edit_page_hint_prop_executor),
            textAlign: TextAlign.end,
            style: propValueStyle,
            initialValue: task.executor?.toString() ?? '',
            inputFormatters: [
              LengthLimitingTextInputFormatter(32),
            ],
            onSaved: (value) {
              task.executor = value;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoteSelector() {
    final key = GlobalKey();

    return NoteSelector(
      key: key,
      onExpansionChanged: (isExpanded) async {
        if (isExpanded) {
          _scrollDown(key);
        }
      },
      notes: task.notes,
    );
  }

  void _scrollDown(GlobalKey myKey) {
    final keyContext = myKey.currentContext;

    if (keyContext != null) {
      // FIXME: Scroll to show the first note and the beginning of the next one
      //final box = keyContext.findRenderObject() as RenderBox;
      _scrollController.animateTo(
          _scrollController.position.pixels + 200 /*box.size.height*/,
          duration: Duration(milliseconds: 200),
          curve: Curves.linear);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ConfigWidget.of(context);
    _distanceUnit = config.distanceUnit;
    _currencySymbol = config.currencySymbol;
    _dateFormat = DateFormat(config.dateFormat);

    return WillPopScope(
      onWillPop: () async {
        if (_isNew) {
          _deleteTask();
          return true;
        } else {
          return _validateAndSaveTask();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isNew
                ? AppLocalizations.of(context).task_edit_page_title_add
                : (task.closed
                    ? AppLocalizations.of(context)
                        .task_edit_page_title_edit_closed
                    : AppLocalizations.of(context).task_edit_page_title_edit),
          ),
          actions: [
            _isNew
                ? Container(
                    width: 45,
                    child: IconButton(
                      iconSize: 30,
                      icon: Icon(Icons.add_circle_outline),
                      tooltip: AppLocalizations.of(context).appbar_add_button,
                      onPressed: _addTask,
                    ),
                  )
                : Container(
                    width: 40,
                    child: IconButton(
                      icon: Icon(Icons.delete_outline),
                      tooltip: AppLocalizations.of(context)
                          .task_edit_page_action_delete,
                      onPressed: _deleteTaskDialog,
                    ),
                  ),
            Container(
              width: 45,
              child: task.closed
                  ? IconButton(
                      iconSize: 30,
                      icon: Icon(Icons.unarchive),
                      tooltip: AppLocalizations.of(context)
                          .task_edit_page_action_reopen,
                      onPressed: _reopenTask,
                    )
                  : IconButton(
                      iconSize: 30,
                      icon: Icon(Icons.archive),
                      tooltip: AppLocalizations.of(context)
                          .task_edit_page_action_close,
                      onPressed: _closeTask,
                    ),
            ),
          ],
        ),
        body: DismissKeyboardOnTap(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Wrap(
                  runSpacing: 10,
                  children: _buildFormFields(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showTaskCompleteDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CompleteTaskDialog(
          motorcycle: widget.motorcycle,
          tasks: [task],
          onResult: (result) {
            Navigator.of(context).pop(result);
          },
        );
      },
    );
  }

  void _addTask() {
    if (_validateAndSaveTask()) {
      Navigator.pop(context);
    }
  }

  Future<void> _closeTask() async {
    if (_validateAndSaveTask()) {
      final result = await _showTaskCompleteDialog();
      if (result != null && result) {
        if (task.recurring) {
          final newTask = Task.fromRenew(task);
          if (newTask != null) {
            final storage = widget.motorcycle.storage.storage;
            await Task.transferAttachments(newTask, storage, storage);
            widget.motorcycle.addTask(newTask);
          }
        }
        widget.motorcycle.saveChanges();
        Navigator.pop(context, true);
      }
    }
  }

  void _reopenTask() {
    if (_validateAndSaveTask()) {
      task.closed = false;
      widget.motorcycle.saveChanges();
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteTaskDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return DeleteDialog(
          title: AppLocalizations.of(context).task_edit_page_action_delete,
          content:
              AppLocalizations.of(context).task_delete_dialog_text(task.name),
          onResult: (result) {
            Navigator.of(context).pop(result);
          },
        );
      },
    );
    if (result) {
      _deleteTask();
      Navigator.pop(context, true);
    }
  }

  void _deleteTask() {
    widget.motorcycle.removeTask(task);
    task.attachments.forEach((attachment) {
      // FIXME: This should be centralized
      if (attachment.type == AttachmentType.file ||
          attachment.type == AttachmentType.picture) {
        widget.motorcycle.storage.storage.deleteFile(attachment.url);
      }
    });
    widget.motorcycle.saveChanges();
  }

  void _saveTask() {
    widget.motorcycle.addTask(task);
    widget.motorcycle.saveChanges();
  }
}
