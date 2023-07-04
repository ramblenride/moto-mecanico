import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:moto_mecanico/assets.dart';
import 'package:moto_mecanico/models/cost.dart';
import 'package:moto_mecanico/themes.dart';
import 'package:moto_mecanico/widgets/dissmiss_keyboard_ontap.dart';
import 'package:moto_mecanico/widgets/property_editor_row.dart';

class EditCostDialog extends StatefulWidget {
  EditCostDialog({
    required this.onResult,
    required this.cost,
  });

  final Function(Cost?) onResult;
  final Cost cost;

  @override
  State<StatefulWidget> createState() => _EditCostDialogState();
}

class _EditCostDialogState extends State<EditCostDialog> {
  _EditCostDialogState();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final propHintStyle = theme.propEditorHint;
    final propValueStyle = theme.propEditorValue;

    return DismissKeyboardOnTap(
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
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Text(
                widget.cost.value != 0
                    ? AppLocalizations.of(context)!.add_cost_edit_dialog_title
                    : AppLocalizations.of(context)!.add_cost_dialog_title,
                style: theme.dialogHeader,
                textAlign: TextAlign.center,
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 64,
                            child: _getCostIcon(widget.cost.type),
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!
                              .cost_selector_row_hint_description
                              .toUpperCase(),
                          style: theme.propEditorName,
                        ),
                        TextFormField(
                          decoration: InputDecoration.collapsed(
                            hintText: AppLocalizations.of(context)!
                                .add_cost_dialog_hint_description,
                            hintStyle: propHintStyle,
                          ),
                          textAlign: TextAlign.right,
                          style: propValueStyle,
                          initialValue: widget.cost.description,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(24),
                          ],
                          onSaved: (value) {
                            widget.cost.description = value ?? '';
                          },
                        ),
                        const SizedBox(height: 10),
                        PropertyEditorRow(
                          name: AppLocalizations.of(context)!
                              .cost_selector_row_hint_cost
                              .toUpperCase(),
                          inputField: TextFormField(
                            decoration: InputDecoration.collapsed(
                              hintText: AppLocalizations.of(context)!
                                  .add_cost_dialog_hint_value,
                              hintStyle: propHintStyle,
                            ),
                            textAlign: TextAlign.right,
                            style: propValueStyle,
                            initialValue: widget.cost.value == 0
                                ? ''
                                : widget.cost.value.toString(),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            onSaved: (value) {
                              widget.cost.value =
                                  (value != null && value.isNotEmpty)
                                      ? int.parse(value)
                                      : 0;
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        _getButtonRow(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Image _getCostIcon(CostType type) {
    switch (type) {
      case CostType.labor:
        return Image.asset(IMG_COST_LABOR);
      case CostType.part:
        return Image.asset(IMG_COST_PART);
      case CostType.other:
        return Image.asset(IMG_COST_OTHER);
    }
  }

  Widget _getButtonRow() {
    final buttonTheme = Theme.of(context).textTheme.dialogButton;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          child: Text(
            AppLocalizations.of(context)!.dialog_cancel_button,
            style: buttonTheme,
          ),
          onPressed: () => widget.onResult(null),
        ),
        TextButton(
          child: Text(
            AppLocalizations.of(context)!.dialog_add_button,
            style: buttonTheme,
          ),
          onPressed: () {
            final cost = _getCost();
            if (cost != null) {
              widget.onResult(cost);
            }
          },
        ),
      ],
    );
  }

  Cost? _getCost() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      return widget.cost;
    }
    return null;
  }
}
