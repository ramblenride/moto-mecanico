import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:moto_mecanico/assets.dart';
import 'package:moto_mecanico/models/motorcycle_template_index.dart';
import 'package:moto_mecanico/models/motorcycle_templates.dart';
import 'package:moto_mecanico/widgets/motorcycle_template_task_tile.dart';

class MotorcycleTemplateCard extends StatefulWidget {
  final MotorcycleTemplateIndexItem template;
  final List<TaskTemplate>? selectedTasks;

  const MotorcycleTemplateCard(
      {super.key, required this.template, this.selectedTasks});

  @override
  State<MotorcycleTemplateCard> createState() => _MotorcycleTemplateCardState();
}

class _MotorcycleTemplateCardState extends State<MotorcycleTemplateCard> {
  final List<MotorcycleTemplateTaskTile> _taskTiles = [];
  late Future<List<TaskTemplate>> _tasks;

  @override
  void initState() {
    super.initState();
    if (widget.template.tasks.isEmpty) {
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
          return _buildTaskList(snapshot.data!);
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!
                  .motorcycle_task_template_page_loading_templates),
              const SizedBox(height: 10),
              const CircularProgressIndicator(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskList(List<TaskTemplate> tasks) {
    return Column(children: _showSelected(tasks));
  }

  List<Widget> _showSelected(List<TaskTemplate> tasks) {
    _taskTiles.clear();
    final children = <Widget>[];
    children.add(
      Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 10),
        child: Text(
          AppLocalizations.of(context)!
              .motorcycle_task_template_page_select_task_header,
          textAlign: TextAlign.left,
        ),
      ),
    );

    var i = 0;
    for (final task in tasks) {
      children.add(_getTaskTile(task, i));
      i++;
    }

    return children;
  }

  Widget _getTaskTile(TaskTemplate task, int taskId) {
    final tile = MotorcycleTemplateTaskTile(
        key: UniqueKey(),
        task: task,
        toggleCb: (TaskTemplate t, bool value) {
          if (widget.selectedTasks != null) {
            if (value) {
              widget.selectedTasks!.add(t);
            } else {
              widget.selectedTasks!.remove(t);
            }
          }
        });
    _taskTiles.add(tile);
    return tile;
  }

  Future<String> _loadMotoIndexDocument() async {
    final response = await http
        .get(Uri.parse('$templatesBaseDbUrl/${widget.template.location}'));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      debugPrint(
          'Failed to download the motorcycle task template. Return code: ${response.statusCode}');

      throw Exception(mounted
          ? AppLocalizations.of(context)!
              .motorcycle_task_template_page_error_loading_motorcycle
          : "Failed to download the motorcycle task template.");
    }
  }

  Future<List<TaskTemplate>> _loadMotorcycleTasksFromTemplate() async {
    final jsonString = await _loadMotoIndexDocument();
    try {
      final moto = MotorcycleTemplates.fromJson(
              jsonDecode(jsonString) as Map<String, dynamic>)
          .templates
          .first;
      return moto.tasks;
    } catch (error) {
      debugPrint('Failed to parse the motorcycle task template file: $error');
      throw Exception(mounted
          ? AppLocalizations.of(context)!
              .motorcycle_task_template_page_error_loading_motorcycle
          : "Failed to parse the motorcycle task template file.");
    }
  }
}
