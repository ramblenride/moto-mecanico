import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moto_mecanico/assets.dart';
import 'package:moto_mecanico/dialogs/edit_cost_dialog.dart';
import 'package:moto_mecanico/models/cost.dart';
import 'package:moto_mecanico/themes.dart';

class AddCostDialog extends StatefulWidget {
  AddCostDialog({@required this.onResult});

  final Function(Cost) onResult;

  @override
  State<StatefulWidget> createState() => _AddCostDialogState();
}

class _AddCostDialogState extends State<AddCostDialog> {
  _AddCostDialogState();

  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Dialog(
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
              AppLocalizations.of(context).add_cost_type_dialog_title,
              style: theme.dialogHeader,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _CostItem(
                  Image.asset(IMG_COST_PART),
                  AppLocalizations.of(context).cost_type_parts,
                  () => _addCost(CostType.part),
                ),
                _CostItem(
                  Image.asset(IMG_COST_LABOR),
                  AppLocalizations.of(context).cost_type_labor,
                  () => _addCost(CostType.labor),
                ),
                _CostItem(
                  Image.asset(IMG_COST_OTHER),
                  AppLocalizations.of(context).cost_type_other,
                  () => _addCost(CostType.other),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child: Text(
                  AppLocalizations.of(context).dialog_cancel_button,
                  style: theme.dialogButton,
                ),
                onPressed: () => widget.onResult(null),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addCost(CostType type) async {
    final result = await showDialog<Cost>(
      context: context,
      builder: (BuildContext context) {
        return EditCostDialog(
          cost: Cost(0, '', type: type),
          onResult: (result) {
            Navigator.of(context).pop(result);
          },
        );
      },
    );
    widget.onResult(result);
  }

  Widget _CostItem(Image icon, String title, Function action) {
    return InkWell(
      onTap: action,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(right: 5),
            width: 45,
            height: 45,
            child: icon,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .propEditorValue
                .copyWith(fontSize: 20),
          ),
        ],
      ),
    );
  }
}
