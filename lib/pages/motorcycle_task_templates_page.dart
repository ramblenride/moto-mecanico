import 'dart:convert' show jsonDecode;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:moto_mecanico/assets.dart';
import 'package:moto_mecanico/models/attachment.dart';
import 'package:moto_mecanico/models/distance.dart';
import 'package:moto_mecanico/models/motorcycle.dart';
import 'package:moto_mecanico/models/motorcycle_template_index.dart';
import 'package:moto_mecanico/models/motorcycle_templates.dart';
import 'package:moto_mecanico/models/note.dart';
import 'package:moto_mecanico/models/task.dart';
import 'package:moto_mecanico/themes.dart';
import 'package:moto_mecanico/widgets/motorcycle_template_card.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:url_launcher/url_launcher.dart';

/// This page allows to populate a motorcycle task list using tasks
/// imported from templates. The templates are downloaded from the internet
/// when the page is opened.
/// It's possible to select which task from a given template will be imported.
/// Templates are added to the motorcycle as tasks when the 'add' button is pressed.
class MotorcycleTaskTemplatePage extends StatefulWidget {
  MotorcycleTaskTemplatePage({Key? key, required this.motorcycle})
      : super(key: key);
  final Motorcycle motorcycle;

  @override
  _MotorcycleTaskTemplatePageState createState() =>
      _MotorcycleTaskTemplatePageState();
}

class _MotorcycleTaskTemplatePageState
    extends State<MotorcycleTaskTemplatePage> {
  _MotorcycleTaskTemplatePageState() : _clearSelected = false;

  bool _clearSelected;
  late final Future<MotorcycleTemplateIndex> _templateIndex;
  MotorcycleTemplateIndexItem? _selected;
  MotorcycleTemplateCard? _motoCard;

  @override
  void initState() {
    super.initState();
    _templateIndex = _loadMotorcycleTemplateIndex();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            AppLocalizations.of(context)!.motorcycle_task_template_page_title),
        actions: [
          TextButton(
              child: Text(
                AppLocalizations.of(context)!
                    .motorcycle_task_template_page_add_button,
                style: Theme.of(context).textTheme.appbarButton,
              ),
              onPressed: () {
                _addSelectedTasks();
                Navigator.pop(context, widget.motorcycle);
              }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        child: FutureBuilder<MotorcycleTemplateIndex>(
          future: _templateIndex,
          builder: (BuildContext context,
              AsyncSnapshot<MotorcycleTemplateIndex> snapshot) {
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
              return _buildTemplateSelector(snapshot.data!.templates);
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!
                        .motorcycle_task_template_page_loading_templates,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  const CircularProgressIndicator(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTemplateSelector(List<MotorcycleTemplateIndexItem> templates) {
    final items = <String>[];

    for (final template in templates) {
      items.add(template.name);
      //items.add(DropdownMenuItem(
      //  child: Text(template.name),
      //  value: template,
      //));
    }

    final children = <Widget>[
      const Padding(padding: EdgeInsets.only(top: 8)),
      DropdownSearch<String>(
        items: items,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            hintText: AppLocalizations.of(context)!
                .motorcycle_task_template_page_search_hint,
          ),
        ),
        //selectedItem: _getInitialSelection(templates),
        onChanged: (value) {
          setState(() {
            if (value == null) _clearSelected = true;
            //_setSelection(value);
          });
        },
        /*
        searchFn: (String keyword,
            List<DropdownMenuItem<MotorcycleTemplateIndexItem>> items) {
          var result = <int>[];
          if (keyword != null && items != null && keyword.isNotEmpty) {
            var i = 0;
            for (final template in items) {
              if (template.value.name
                  .toLowerCase()
                  .contains(keyword.toLowerCase())) {
                result.add(i);
              }
              i++;
            }
          } else {
            result = Iterable<int>.generate(items.length).toList();
          }
          return result;
        }*/
      ),
    ];
    if (_selected != null) {
      _motoCard = MotorcycleTemplateCard(
        key: UniqueKey(),
        template: _selected!,
      );
      children.add(
        Text(
          _selected!.description,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.taskCardDescription,
        ),
      );
      children.add(_motoCard!);
    }
    children.add(const SizedBox(height: 16));
    children.add(
      Text(
        AppLocalizations.of(context)!.motorcycle_task_template_page_disclaimer,
        textAlign: TextAlign.center,
        style:
            Theme.of(context).textTheme.propEditorHint.copyWith(fontSize: 13),
      ),
    );
    children.add(
      Container(
        width: 40,
        child: IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: _showHelpDialog,
        ),
      ),
    );

    return SingleChildScrollView(
      child: Scrollbar(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }

  void _addSelectedTasks() {
    if (_selected?.tasks == null || _motoCard == null) return;
    for (final template in _motoCard!.getSelectedTasks()) {
      _addTemplateTaskToMoto(widget.motorcycle, template);
    }
  }

  void _addTemplateTaskToMoto(Motorcycle moto, TaskTemplate templateTask) {
    final motoTask = Task(
      name: templateTask.name,
      description: templateTask.description,
      technicalLevel: templateTask.technicalLevel,
      notes: templateTask.notes.isNotEmpty
          ? [
              Note(
                name: AppLocalizations.of(context)!
                    .motorcycle_task_template_page_note_name,
                text: templateTask.notes,
                copyable: true,
              )
            ]
          : [],
      dueOdometer: _getDueOdometer(moto, templateTask),
      dueDate: _getDueDate(moto, templateTask),
      recurringMonths: templateTask.intervalMonths,
      recurringOdometer: templateTask.intervalDistance,
    );

    for (final link in templateTask.links) {
      motoTask.attachments.add(
        Attachment(
          type: AttachmentType.link,
          name: link.name,
          url: link.url,
          copyable: true,
        ),
      );
    }

    moto.addTask(motoTask);
  }

  void _setSelection(MotorcycleTemplateIndexItem template) {
    _selected = template;
  }

  String _getInitialSelection(List<MotorcycleTemplateIndexItem> templates) {
    if (_clearSelected == false &&
        _selected == null &&
        templates.isNotEmpty == true &&
        widget.motorcycle.make.isNotEmpty == true &&
        widget.motorcycle.model.isNotEmpty == true) {
      _selected = templates.firstWhere(
        (template) =>
            template.name
                .toLowerCase()
                .contains(widget.motorcycle.make.toLowerCase()) &&
            template.name
                .toLowerCase()
                .contains(widget.motorcycle.model.toLowerCase()),
        //orElse: () => null);
      );
      _setSelection(_selected!);
    }
    return _selected!.name;
  }

  // Returns the next scheduled service based on distance.
  // Use the first interval if it's not passed yet.
  // Otherwise add the recurring interval (if any) to the current odometer
  // If not, return the first interval even if it has passed.
  Distance _getDueOdometer(Motorcycle motorcycle, TaskTemplate templateTask) {
    if (templateTask.distance.distance != null &&
        motorcycle.odometer < templateTask.distance) {
      return templateTask.distance;
    }

    if (templateTask.intervalDistance.distance != null) {
      return templateTask.intervalDistance + motorcycle.odometer;
    }

    return templateTask.distance;
  }

  // Returns the next scheduled service based on time.
  // Use the first interval if it's not passed yet.
  // Otherwise add the recurring interval (if any) to the current odometer
  // If not, return the first interval even if it has passed.
  DateTime? _getDueDate(Motorcycle motorcycle, TaskTemplate templateTask) {
    const daysPerMonth = 30; // Precision is not so important here

    // Use the time for the first service if it hasn't passed yet.
    if (motorcycle.purchaseDate != null) {
      if (templateTask.months > 0) {
        final templateDuration =
            Duration(days: templateTask.months * daysPerMonth);
        if (DateTime.now().difference(motorcycle.purchaseDate!) <
            templateDuration) {
          return motorcycle.purchaseDate!.add(templateDuration);
        }
      }
    }

    // Otherwise add the time interval to the current date if available
    // (given that we don't know the last service date)
    if (templateTask.intervalMonths > 0) {
      return DateTime.now()
          .add(Duration(days: templateTask.intervalMonths * daysPerMonth));
    }

    return null;
  }

  Future<String> _loadMotoIndexDocument() async {
    final response = await http
        .get(Uri.parse('${TEMPLATES_BASE_DB_URL}/${TEMPLATES_INDEX_FILE}'));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(AppLocalizations.of(context)!
          .motorcycle_task_template_page_error_loading_index);
    }
  }

  Future<MotorcycleTemplateIndex> _loadMotorcycleTemplateIndex() async {
    final jsonString = await _loadMotoIndexDocument();
    try {
      return MotorcycleTemplateIndex.fromJson(
          jsonDecode(jsonString) as Map<String, dynamic>);
    } catch (error) {
      debugPrint('Failed to parse motorcycle index: ${error}');
      throw Exception(AppLocalizations.of(context)!
          .motorcycle_task_template_page_error_loading_index);
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.fromLTRB(8, 12, 8, 16),
          title: Text(
            AppLocalizations.of(context)!
                .motorcycle_task_template_page_help_dialog_title,
            textAlign: TextAlign.center,
          ),
          children: [
            Text(
              AppLocalizations.of(context)!
                  .motorcycle_task_template_page_help_dialog,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: Colors.blueGrey[200]!),
            ),
            IconButton(
              icon: Icon(Icons.open_in_browser),
              onPressed: _openMotoServiceDbUrl,
            ),
          ],
        );
      },
    );
  }

  void _openMotoServiceDbUrl() {
    launchUrl(Uri.parse(MOTO_SERVICE_DB_WEB));
  }
}
