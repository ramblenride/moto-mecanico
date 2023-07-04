import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:moto_mecanico/assets.dart';
import 'package:moto_mecanico/dialogs/complete_task_dialog.dart';
import 'package:moto_mecanico/dialogs/delete_dialog.dart';
import 'package:moto_mecanico/locale/formats.dart';
import 'package:moto_mecanico/models/attachment.dart';
import 'package:moto_mecanico/models/distance.dart';
import 'package:moto_mecanico/models/labels.dart';
import 'package:moto_mecanico/models/motorcycle.dart';
import 'package:moto_mecanico/models/task.dart';
import 'package:moto_mecanico/pages/motorcycle_edit_page.dart';
import 'package:moto_mecanico/pages/motorcycle_task_templates_page.dart';
import 'package:moto_mecanico/pages/task_edit_page.dart';
import 'package:moto_mecanico/themes.dart';
import 'package:moto_mecanico/widgets/app_bar_filter.dart';
import 'package:moto_mecanico/widgets/closed_task_card.dart';
import 'package:moto_mecanico/widgets/config_widget.dart';
import 'package:moto_mecanico/widgets/motorcycle_info_tab.dart';
import 'package:moto_mecanico/widgets/task_card.dart';
import 'package:provider/provider.dart';

enum MotorcycleAction {
  edit,
  add_template_tasks,
}

enum PopupEditAction {
  odometer,
  hours,
}

/// This page is shown when the user clicks on a motorcycle and contains 3 tabs:
/// - The open tasks
/// - The closed/completed tasks
/// - Motorcycle info
/// A button in the app bar allows updating the motorycle odometer.
class MotorcycleViewPage extends StatefulWidget {
  MotorcycleViewPage({Key? key}) : super(key: key);

  @override
  _MotorcycleViewPageState createState() => _MotorcycleViewPageState();
}

class _MotorcycleViewPageState extends State<MotorcycleViewPage>
    with SingleTickerProviderStateMixin {
  _MotorcycleViewPageState();

  late final TabController _tabController;
  late final DistanceUnit _distanceUnit;

  final List<Task> _selectedTasks = [];

  String? _taskFilter;
  List<TaskCard> _activeTaskCards = [];
  List<ClosedTaskCard> _closedTaskCards = [];
  int _currentTab = 0;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: _currentTab,
    );
    _tabController.animation?.addListener(() {
      final value = _tabController.animation!.value.round();
      if (value != _currentTab) {
        setState(() => _currentTab = value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _distanceUnit = ConfigWidget.of(context).distanceUnit;

    return PopScope(
      onPopInvoked: (bool didPop) async {
        if (!didPop) return;

        if (_selectedTasks.isNotEmpty) {
          setState(() => _selectedTasks.clear());
        }
      },
      child: Consumer<Motorcycle>(
        builder: (context, motorcycle, child) {
          _buildActiveTaskCards(motorcycle);
          _buildClosedTaskCards(motorcycle);
          return Scaffold(
            appBar: _buildAppBar(motorcycle),
            body: TabBarView(
              controller: _tabController,
              children: [
                _getActiveTasks(motorcycle),
                _getClosedTasks(motorcycle),
                MotorcycleInfoTab(),
              ],
            ),
            floatingActionButton: _currentTab != 2
                ? FloatingActionButton(
                    child: Icon(Icons.library_add),
                    tooltip: AppLocalizations.of(context)!
                        .motorcycle_view_task_button_add_task_tooltip,
                    onPressed: () => _showAddEditTask(null, motorcycle),
                  )
                : null,
          );
        },
      ),
    );
  }

  void _updateSearchQuery(String newQuery) {
    setState(() => _taskFilter = newQuery);
  }

  Future<void> _renewTasks(
      Motorcycle motorcycle, List<Task> selectedTasks) async {
    for (final task in selectedTasks) {
      final newTask = Task.fromRenew(task);
      if (newTask != null) {
        final storage = motorcycle.storage!.storage;
        await Task.transferAttachments(newTask, storage, storage);
        motorcycle.addTask(newTask);
      }
    }
  }

  PreferredSizeWidget _buildAppBar(Motorcycle motorcycle) {
    if (_selectedTasks.isNotEmpty) {
      return AppBar(
        title: Text(AppLocalizations.of(context)!
            .motorcycle_view_page_appbar_title_tasks_selected(
                _selectedTasks.length)),
        actions: [
          Container(
            width: 40,
            child: IconButton(
              icon: Icon(Icons.delete_outline),
              tooltip: AppLocalizations.of(context)!
                  .motorcycle_view_page_appbar_tooltip_icon_delete,
              onPressed: () => _showTaskDeleteDialog(motorcycle),
            ),
          ),
          Container(
            width: 45,
            child: IconButton(
              iconSize: 30,
              icon: Icon(Icons.archive),
              tooltip: AppLocalizations.of(context)!
                  .motorcycle_view_page_appbar_tooltip_icon_close,
              onPressed: () => _showTaskCompleteDialog(motorcycle),
            ),
          ),
        ],
      );
    }

    return PreferredSize(
      preferredSize: Size.fromHeight(80.0),
      child: AppBarFilter(
        hintText: AppLocalizations.of(context)!
            .motorcycle_view_page_appbar_filter_hint,
        title: Text(motorcycle.name),
        updateSearchQueryCb: _updateSearchQuery,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Text(AppLocalizations.of(context)!
                .motorcycle_view_page_appbar_tab_tasks),
            Text(AppLocalizations.of(context)!
                .motorcycle_view_page_appbar_tab_history),
            Text(AppLocalizations.of(context)!
                .motorcycle_view_page_appbar_tab_info),
          ],
        ),
        leadingActions: <Widget>[
          PopupMenuButton<PopupEditAction>(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: RnrColors.orange,
                  width: 2,
                )),
            color: RnrColors.lightBlue[700],
            padding: EdgeInsets.zero,
            tooltip: AppLocalizations.of(context)!
                .motorcycle_view_page_appbar_icon_odometer,
            icon: Icon(Icons.speed),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: PopupEditAction.odometer,
                child: TextFormField(
                  autofocus: true,
                  textAlign: TextAlign.end,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixText: AppLocalizations.of(context)!
                        .motorcycle_view_page_appbar_odometer_textfield_prefix,
                    suffixText: AppLocalSupport.distanceUnits[_distanceUnit],
                  ),
                  initialValue:
                      motorcycle.odometer.toUnit(_distanceUnit).toString(),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(7),
                  ],
                  onFieldSubmitted: (value) {
                    motorcycle.odometer = Distance(
                        value.isNotEmpty ? int.parse(value) : null,
                        _distanceUnit);
                    motorcycle.saveChanges();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ],
        trailingActions: [
          PopupMenuButton<MotorcycleAction>(
            padding: EdgeInsets.zero,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: MotorcycleAction.add_template_tasks,
                child: Text(AppLocalizations.of(context)!
                    .motorcycle_view_appbar_popop_add_tasks),
              ),
              PopupMenuItem(
                value: MotorcycleAction.edit,
                child: Text(AppLocalizations.of(context)!
                    .motorcycle_view_appbar_popop_edit_moto),
              ),
            ],
            onSelected: (value) async {
              switch (value) {
                case MotorcycleAction.add_template_tasks:
                  {
                    final result = await Navigator.push<Motorcycle>(
                      context,
                      MaterialPageRoute<Motorcycle>(
                        builder: (context) =>
                            MotorcycleTaskTemplatePage(motorcycle: motorcycle),
                      ),
                    );
                    if (result != null) {
                      motorcycle.saveChanges();
                    }
                    break;
                  }
                case MotorcycleAction.edit:
                  {
                    await Navigator.push<Motorcycle>(
                      context,
                      MaterialPageRoute<Motorcycle>(
                        builder: (context) =>
                            MotorcycleEditPage(motorcycle: motorcycle),
                      ),
                    );
                    break;
                  }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showTaskCompleteDialog(Motorcycle motorcycle) async {
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CompleteTaskDialog(
          motorcycle: motorcycle,
          tasks: _selectedTasks,
          onResult: (result) async {
            if (result) {
              await _renewTasks(motorcycle, _selectedTasks);
              _selectedTasks.clear();
              motorcycle.saveChanges();
            }
            Navigator.of(context).pop(result);
          },
        );
      },
    );
  }

  void _showTaskDeleteDialog(Motorcycle motorcycle) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return DeleteDialog(
          title: AppLocalizations.of(context)!
              .motorcycle_view_page_appbar_tooltip_icon_delete,
          content: AppLocalizations.of(context)!
              .motorcycle_view_page_delete_tasks_dialog_text(
                  _selectedTasks.length),
          onResult: (result) {
            Navigator.of(context).pop(result);
          },
        );
      },
    );
    if (result != null && result) {
      _selectedTasks.forEach((task) {
        motorcycle.removeTask(task);
        task.attachments.forEach((attachment) {
          // FIXME: This should be centralized
          if (attachment.type == AttachmentType.file ||
              attachment.type == AttachmentType.picture) {
            motorcycle.storage!.storage.deleteFile(attachment.url);
          }
        });
      });
      _selectedTasks.clear();
      motorcycle.saveChanges();
    }
  }

  Widget _noTaskWidget() {
    return Tooltip(
      message:
          AppLocalizations.of(context)!.motorcycle_view_page_tooltip_no_task,
      child: Center(
        child: Image.asset(IMG_ROADSIGN_RESERVED_PARKING, width: 120),
      ),
    );
  }

  Widget _noClosedTaskWidget() {
    return Tooltip(
      message:
          AppLocalizations.of(context)!.motorcycle_view_page_tooltip_no_task,
      child: Center(
        child: Image.asset(IMG_ROADSIGN_COMPLETED_TASKS, width: 120),
      ),
    );
  }

  // FUTURE: Currently we rebuild the full list everytime something changes.
  // We could optimize by rebuilding only the cards for the tasks that have
  // changed.
  void _buildActiveTaskCards(Motorcycle motorcycle) {
    _activeTaskCards = motorcycle.activeTasks.map((task) {
      return TaskCard(
        motorcycle: motorcycle,
        task: task,
      );
    }).toList();
  }

  void _buildClosedTaskCards(Motorcycle motorcycle) {
    _closedTaskCards = motorcycle.closedTasks.map((task) {
      return ClosedTaskCard(
        motorcycle: motorcycle,
        task: task,
      );
    }).toList();
  }

  void _select(TaskCard card) {
    setState(() {
      if (_selectedTasks.contains(card.task)) {
        _selectedTasks.remove(card.task);
      } else {
        _selectedTasks.add(card.task);
      }
    });
  }

  bool _labelsMatch(
      Map<int, Label> labels, List<int> taskLabels, String criteria) {
    return taskLabels.any((id) =>
        labels.containsKey(id) &&
        labels[id]!.name.toUpperCase().contains(criteria.toUpperCase()));
  }

  Widget _getActiveTasks(Motorcycle motorcycle) {
    var activeCards = List<TaskCard>.from(_activeTaskCards);
    if (_taskFilter != null && _taskFilter!.isNotEmpty) {
      final labels = Provider.of<LabelsModel>(context, listen: false).labels;
      activeCards = activeCards.where(
        (card) {
          if (card.matches(_taskFilter!)) return true;
          return _labelsMatch(labels, card.task.labels, _taskFilter!);
        },
      ).toList();
    }

    if (activeCards.isEmpty) {
      return _noTaskWidget();
    }

    activeCards.sort(
      (a, b) {
        return a.task.compareTo(b.task, odometer: motorcycle.odometer);
      },
    );

    return ListView(
      padding: EdgeInsets.fromLTRB(4, 6, 4, 64),
      children: activeCards.map((card) {
        final isSelected = _selectedTasks.contains(card.task);
        return InkWell(
          onTap: () {
            _selectedTasks.isEmpty
                ? _showAddEditTask(card.task, motorcycle)
                : _select(card);
          },
          onLongPress: () => _select(card),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
                Colors.white38, isSelected ? BlendMode.srcATop : BlendMode.dst),
            child: card,
          ),
        );
      }).toList(),
    );
  }

  Widget _getClosedTasks(Motorcycle motorcycle) {
    var closedTaskCards = List<ClosedTaskCard>.from(_closedTaskCards);
    if (_taskFilter != null && _taskFilter!.isNotEmpty) {
      final labels = Provider.of<LabelsModel>(context, listen: false).labels;
      closedTaskCards = closedTaskCards.where((card) {
        if (card.matches(_taskFilter!)) return true;
        return _labelsMatch(labels, card.task.labels, _taskFilter!);
      }).toList();
    }

    if (closedTaskCards.isEmpty) {
      return _noClosedTaskWidget();
    }

    closedTaskCards.sort(
      (a, b) {
        return (b.task.closedDate ?? DateTime.now())
            .compareTo(a.task.closedDate ?? DateTime.now());
      },
    );

    return ListView(
      padding: EdgeInsets.fromLTRB(4, 6, 4, 64),
      children: closedTaskCards.map((card) {
        return InkWell(
          onTap: () => _showAddEditTask(card.task, motorcycle),
          child: card,
        );
      }).toList(),
    );
  }

  void _showAddEditTask(Task? task, Motorcycle motorcycle) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (context) => TaskEditPage(motorcycle: motorcycle, task: task),
      ),
    );
  }
}
