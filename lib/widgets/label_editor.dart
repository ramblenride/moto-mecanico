import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:moto_mecanico/models/labels.dart';
import 'package:moto_mecanico/themes.dart';
import 'package:provider/provider.dart';

class LabelEditor extends StatefulWidget {
  LabelEditor({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LabelEditorState();
}

class _LabelEditorState extends State<LabelEditor> {
  _LabelEditorState();

  final _formKey = GlobalKey<FormState>();
  List<String> _initialHints;
  List<Color> _labelColors = <Color>[];
  TextStyle _hintFont;
  TextStyle _textFont;

  @override
  Widget build(BuildContext context) {
    _initialHints = [
      AppLocalizations.of(context).label_editor_name_initial_hint_1,
      AppLocalizations.of(context).label_editor_name_initial_hint_2,
      AppLocalizations.of(context).label_editor_name_initial_hint_3,
      AppLocalizations.of(context).label_editor_name_initial_hint_4,
      AppLocalizations.of(context).label_editor_name_initial_hint_5,
      AppLocalizations.of(context).label_editor_name_initial_hint_6,
      AppLocalizations.of(context).label_editor_name_initial_hint_7
    ];

    _hintFont = Theme.of(context).textTheme.propEditorHint.copyWith(
          color: Colors.white70,
          fontStyle: FontStyle.italic,
          fontSize: 18,
        );
    _textFont = Theme.of(context).textTheme.labelName;

    return _buildLabelList();
  }

  void _save() {
    _formKey.currentState.save();
  }

  Widget _buildLabelList() {
    final labels = Provider.of<LabelsModel>(context, listen: false).labels;
    final firstEdit = labels.values.every((element) => element.name.isEmpty);

    var i = 0;
    return Form(
      key: _formKey,
      onWillPop: () {
        _save();
        return Future.value(true);
      },
      child: Wrap(
        runSpacing: 5,
        children: labels.entries.map(
          (label) {
            final index = i;
            if (_labelColors.length < i + 1) {
              _labelColors.add(label.value.color);
            }
            final widget = Padding(
              padding: EdgeInsets.only(left: 15, right: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      height: 45,
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: _labelColors[index],
                        border: Border.all(
                            color: Colors.black,
                            width: 1.0,
                            style: BorderStyle.solid),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      child: _getTextField(
                        label.value,
                        i,
                        firstEdit,
                        (name) {
                          Provider.of<LabelsModel>(context, listen: false)
                              .update(Label(
                                  id: label.value.id,
                                  color: _labelColors[index],
                                  name: name));
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.color_lens,
                      color: Colors.blueGrey[100],
                    ),
                    onPressed: () async {
                      _labelColors[index] =
                          await _changeColor(_labelColors[index]);
                      setState(() => _labelColors = List.from(_labelColors));
                    },
                  ),
                ],
              ),
            );
            i++;
            return widget;
          },
        ).toList(),
      ),
    );
  }

  Widget _getTextField(
      Label label, int i, bool firstEdit, Function(String) onSaved) {
    return TextFormField(
      cursorColor: Colors.white,
      decoration: InputDecoration.collapsed(
        hintText: firstEdit ? _initialHints[i] : '',
        hintStyle: _hintFont,
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(20)],
      initialValue: label.name,
      style: _textFont,
      onSaved: onSaved,
    );
  }

  Future<Color> _changeColor(Color color) async {
    var newColor = color;
    await showDialog(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        title: Text(AppLocalizations.of(context).settings_page_select_color),
        children: [
          SingleChildScrollView(
            child: BlockPicker(
                pickerColor: color,
                onColorChanged: (c) {
                  newColor = c;
                  Navigator.of(context).pop();
                }),
          ),
        ],
      ),
    );
    return newColor;
  }
}
