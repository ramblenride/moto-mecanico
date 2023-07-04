import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:moto_mecanico/models/labels.dart';
import 'package:moto_mecanico/themes.dart';
import 'package:provider/provider.dart';

class LabelSelector extends StatefulWidget {
  LabelSelector({Key? key, required this.active_labels}) : super(key: key);

  final List<int> active_labels;

  @override
  State<StatefulWidget> createState() =>
      _LabelSelectorState(active_labels: active_labels);
}

class _LabelSelectorState extends State<LabelSelector> {
  _LabelSelectorState({required this.active_labels});

  List<int> active_labels;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<LabelsModel>(
      builder: (context, labelsModel, child) => Wrap(
        runSpacing: 4,
        children: [
          InkWell(
            onTap: () {
              setState(() => _expanded = !_expanded);
            },
            child: Row(
              children: [
                const SizedBox(height: 45), // Force uniform height
                Text(
                  AppLocalizations.of(context)!
                      .label_selector_title
                      .toUpperCase(),
                  style: Theme.of(context).textTheme.propEditorName,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 5,
                    runSpacing: 5,
                    children: _buildIndicators(labelsModel.labels),
                  ),
                ),
                Container(
                  width: 40,
                  child: Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
          ..._buildLabelList(labelsModel.labels)
        ],
      ),
    );
  }

  List<Widget> _buildIndicators(Map<int, Label> labels) {
    const indicatorHeight = 15.0;
    const indicatorWidth = 28.0;
    var indicators = <Widget>[];

    for (final id in active_labels) {
      indicators.add(
        Container(
          decoration: BoxDecoration(
            color: labels[id]!.color,
            border: Border.all(
              color: Colors.black,
              width: 1.0,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
          width: indicatorWidth,
          height: indicatorHeight,
        ),
      );
    }

    return indicators;
  }

  List<Widget> _buildLabelList(Map<int, Label> labels) {
    if (!_expanded) return [];

    return labels.entries.map((label) {
      var row = [
        Text(label.value.name, style: Theme.of(context).textTheme.labelName),
        Spacer(),
      ];

      if (active_labels.contains(label.key)) {
        row.add(Icon(Icons.check, color: Colors.white));
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: InkWell(
          onTap: () {
            setState(() {
              if (active_labels.contains(label.value.id)) {
                active_labels.remove(label.value.id);
              } else {
                active_labels.add(label.value.id);
              }
            });
          },
          child: Container(
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: label.value.color,
              border: Border.all(
                color: Colors.black,
                width: 1.0,
                style: BorderStyle.solid,
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: Row(
              children: row,
            ),
          ),
        ),
      );
    }).toList();
  }
}
