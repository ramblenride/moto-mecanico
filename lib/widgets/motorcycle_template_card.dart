import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:moto_mecanico/assets.dart';
import 'package:moto_mecanico/models/motorcycle_template_index.dart';
import 'package:moto_mecanico/models/motorcycle_templates.dart';
import 'package:moto_mecanico/widgets/motorcycle_template_task_tile.dart';

class MotorcycleTemplateCard extends StatefulWidget {
  final _MotorcycleTemplateCardState _state;
  final MotorcycleTemplateIndexItem template;

  MotorcycleTemplateCard({Key key, @required this.template})
      : assert(template != null),
        _state = _MotorcycleTemplateCardState(),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _state;

  List<TaskTemplate> getSelectedTasks() {
    return _state.getSelectedTasks();
  }
}

class _MotorcycleTemplateCardState extends State<MotorcycleTemplateCard> {
  final List<MotorcycleTemplateTaskTile> _taskTiles = [];
  Future<List<TaskTemplate>> _tasks;

  @override
  void initState() {
    super.initState();
    if (widget.template.tasks == null) {
      _tasks = _loadMotorcycleTasksFromTemplate();
    } else {
      _tasks = Future.value(widget.template.tasks);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TaskTemplate>>(
      future: _tasks,
      builder:
          (BuildContext context, AsyncSnapshot<List<TaskTemplate>> snapshot) {
        if (snapshot.hasError) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Text(
                snapshot.error.toString(),
                textAlign: TextAlign.center,
              ),
            ],
          );
        } else if (snapshot.hasData) {
          return _buildTaskList(snapshot.data);
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // FIXME Correct text
              Text(AppLocalizations.of(context)
                  .motorcycle_task_template_page_loading_templates),
              const SizedBox(height: 10),
              CircularProgressIndicator(),
            ],
          ),
        );
      },
    );
  }

  List<TaskTemplate> getSelectedTasks() {
    final tasks = <TaskTemplate>[];
    for (final tile in _taskTiles) {
      if (tile.isEnabled()) {
        tasks.add(tile.task);
      }
    }
    return tasks;
  }

  Widget _buildTaskList(List<TaskTemplate> tasks) {
    return Column(children: _showSelected());
  }

  List<Widget> _showSelected() {
    _taskTiles.clear();
    final children = <Widget>[];
    children.add(
      Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 10),
        child: Text(
          AppLocalizations.of(context)
              .motorcycle_task_template_page_select_task_header,
          textAlign: TextAlign.left,
        ),
      ),
    );

    if (widget.template.tasks != null) {
      var i = 0;
      for (final task in widget.template.tasks) {
        children.add(_getTaskTile(task, i));
        i++;
      }
    }

    return children;
  }

  Widget _getTaskTile(task, taskId) {
    final tile = MotorcycleTemplateTaskTile(
      key: UniqueKey(),
      task: task,
    );
    _taskTiles.add(tile);
    return tile;
  }

  Future<String> _loadMotoIndexDocument() async {
    final response = await http
        .get(Uri.parse('${TEMPLATES_BASE_DB_URL}/${widget.template.location}'));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      debugPrint(
          'Failed to download motorcycle task template. Return code: ${response.statusCode}');
      throw Exception(AppLocalizations.of(context)
          .motorcycle_task_template_page_error_loading_motorcycle);
    }
  }

  Future<List<TaskTemplate>> _loadMotorcycleTasksFromTemplate() async {
    final jsonString = await _loadMotoIndexDocument();
    try {
      final moto = MotorcycleTemplates.fromJson(
              jsonDecode(jsonString) as Map<String, dynamic>)
          .templates
          .first;
      widget.template.tasks = moto?.tasks; // Cache result
    } catch (error) {
      debugPrint('Failed to parse motorcycle task template file: ${error}');
      throw Exception(AppLocalizations.of(context)
          .motorcycle_task_template_page_error_loading_motorcycle);
    }

    return widget.template.tasks;
  }
}
