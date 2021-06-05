import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:moto_mecanico/assets.dart';
import 'package:moto_mecanico/models/cost.dart';
import 'package:moto_mecanico/themes.dart';

enum CostAction { delete, edit, copyable }

class CostSelectorRow extends StatefulWidget {
  CostSelectorRow(
      {Key key, @required this.cost, @required this.onRemove, this.onUpdate})
      : assert(cost != null),
        assert(onRemove != null),
        super(key: key);

  final Cost cost;
  final Function onRemove;
  final Function onUpdate;

  @override
  State<StatefulWidget> createState() => _CostSelectorRowState(cost: cost);
}

class _CostSelectorRowState extends State<CostSelectorRow> {
  _CostSelectorRowState({@required this.cost}) : assert(cost != null);

  final Cost cost;
  final _formKey = GlobalKey<FormState>();
  bool _edit = false;
  TextStyle _textStyle;
  TextStyle _hintStyle;

  @override
  Widget build(BuildContext context) {
    _textStyle =
        Theme.of(context).textTheme.propEditorValue.copyWith(fontSize: 18);
    _hintStyle = Theme.of(context).textTheme.propEditorHint;

    return Form(
      key: _formKey,
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(right: 5),
            width: 30,
            child: _getCostIcon(),
          ),
          Expanded(
            flex: 70,
            child: _getNameTextOrEditor(),
          ),
          //const SizedBox(width: 10),
          // FIXME: Allow value to expand more if not editing...
          Expanded(
            flex: 30,
            child: _getValueTextOrEditor(),
          ),
          Container(
            height: 30,
            width: 35, // FIXME: Cost / Note / Attachment
            child: PopupMenuButton<CostAction>(
              padding: EdgeInsets.zero,
              icon: const Align(
                // Align with the icons above
                alignment: Alignment.centerRight,
                child: Icon(Icons.more_vert),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: !_edit,
                  value: CostAction.edit,
                  child: Text(
                      AppLocalizations.of(context).cost_selector_action_edit),
                ),
                PopupMenuItem(
                  value: CostAction.delete,
                  child: Text(AppLocalizations.of(context)
                      .attachment_selector_action_delete),
                ),
                PopupMenuItem(
                  value: CostAction.copyable,
                  child: Tooltip(
                    message: AppLocalizations.of(context).renewable_tooltip,
                    child: Row(
                      children: [
                        Text(AppLocalizations.of(context).renewable),
                        const SizedBox(width: 10),
                        Icon(
                          cost.copyable
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              onSelected: (value) async {
                switch (value) {
                  case CostAction.edit:
                    {
                      setState(() => _edit = true);
                      break;
                    }
                  case CostAction.delete:
                    {
                      setState(() => _edit = false);
                      widget.onRemove(cost);
                      break;
                    }
                  case CostAction.copyable:
                    {
                      setState(() => cost.copyable = !cost.copyable);
                      break;
                    }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Image _getCostIcon() {
    switch (widget.cost.type) {
      case CostType.labor:
        return Image.asset(IMG_COST_LABOR);
      case CostType.part:
        return Image.asset(IMG_COST_PART);
      case CostType.other:
        return Image.asset(IMG_COST_OTHER);
    }
    return null;
  }

  Widget _getNameTextOrEditor() {
    if (!_edit) {
      return Text(
        cost.description,
        style: _textStyle,
      );
    } else {
      return TextFormField(
        autofocus: true,
        initialValue: cost.description,
        decoration: InputDecoration(
          hintText:
              AppLocalizations.of(context).cost_selector_row_hint_description,
          hintStyle: _hintStyle,
        ),
        inputFormatters: [
          LengthLimitingTextInputFormatter(24),
        ],
        style: _textStyle,
        onFieldSubmitted: (value) => _saveCost(),
        onSaved: (value) {
          if (value.isNotEmpty) {
            cost.description = value;
          }
        },
      );
    }
  }

  Widget _getValueTextOrEditor() {
    if (!_edit) {
      final formatter = NumberFormat.compact();

      return Text(
        cost.value > 9999
            ? formatter.format(cost.value)
            : cost.value.toString(),
        textAlign: TextAlign.right,
        style: _textStyle,
      );
    } else {
      return TextFormField(
        initialValue: cost.value != 0 ? cost.value.toString() : '',
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).cost_selector_row_hint_cost,
          hintStyle: _hintStyle,
        ),
        textAlign: TextAlign.end,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        keyboardType: TextInputType.number,
        style: _textStyle,
        onFieldSubmitted: (value) => _saveCost(),
        onSaved: (value) {
          if (value.isNotEmpty) {
            cost.value = int.parse(value);
          }
        },
      );
    }
  }

  void _saveCost() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() => _edit = false);
      if (widget.onUpdate != null) widget.onUpdate();
    }
  }
}
