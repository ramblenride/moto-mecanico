import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:moto_mecanico/dialogs/add_cost_dialog.dart';
import 'package:moto_mecanico/models/cost.dart';
import 'package:moto_mecanico/themes.dart';
import 'package:moto_mecanico/widgets/cost_selector_row.dart';

class CostSelector extends StatefulWidget {
  CostSelector({Key key, @required this.costs, @required this.currencySymbol})
      : assert(costs != null),
        assert(currencySymbol != null),
        super(key: key);

  final List<Cost> costs;
  final String currencySymbol;

  @override
  State<StatefulWidget> createState() => _CostSelectorState();
}

class _CostSelectorState extends State<CostSelector> {
  Map<Key, CostSelectorRow> _costRows;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _buildRows();
  }

  @override
  Widget build(BuildContext context) {
    final smallCurrencyFormat = NumberFormat.simpleCurrency(
      name: widget.currencySymbol,
      decimalDigits: 0,
    );
    smallCurrencyFormat.turnOffGrouping();

    final largeCurrencyFormat = NumberFormat.compactSimpleCurrency(
      name: widget.currencySymbol,
      decimalDigits: 0,
    );
    largeCurrencyFormat.turnOffGrouping();

    final topLineFont = Theme.of(context).textTheme.selectorWidgetHeader;
    final costTotal = Cost.total(widget.costs, null).value;

    return Wrap(
      children: [
        InkWell(
          onTap: () {
            setState(() => _expanded = !_expanded);
          },
          child: ConstrainedBox(
            // Force a uniform height
            constraints: BoxConstraints(minHeight: 35),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context).cost_selector_title,
                  style: Theme.of(context).textTheme.propEditorHeader,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    costTotal > 99999
                        ? '${largeCurrencyFormat.format(costTotal)}'
                        : '${smallCurrencyFormat.format(costTotal)}',
                    style: topLineFont,
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  width: 26,
                  height: 26,
                  child: _expanded
                      ? IconButton(
                          icon: Icon(Icons.add_circle_outline),
                          visualDensity: VisualDensity.compact,
                          alignment: Alignment.bottomCenter,
                          padding: EdgeInsets.zero,
                          color: Colors.blueGrey[100],
                          tooltip: AppLocalizations.of(context)
                              .cost_selector_add_cost,
                          onPressed: _addCost,
                        )
                      : Container(),
                ),
                Container(
                  // Force a specific width so that it aligns with other selectors.
                  alignment: Alignment.bottomRight,
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  width: 42,
                  child: Text(
                    '(${widget.costs.length})',
                    style: topLineFont.copyWith(fontSize: 18),
                    textAlign: TextAlign.right,
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  width: 26,
                  height: 26,
                  child: Icon(
                    _expanded ? Icons.expand_more : Icons.chevron_left,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [..._buildCostList()],
          ),
        ),
      ],
    );
  }

  void _addCost() async {
    final result = await showDialog<Cost>(
      context: context,
      builder: (BuildContext context) {
        return AddCostDialog(
          onResult: (result) {
            Navigator.of(context).pop(result);
          },
        );
      },
    );
    if (result != null) {
      widget.costs.add(result);
      setState(() {
        _expanded = true;
        _buildRows();
      });
    }
  }

  void _buildRows() {
    _costRows = {};
    for (final cost in widget.costs) {
      final key = UniqueKey();
      _costRows[key] = CostSelectorRow(
        key: key,
        cost: cost,
        onRemove: (cost) => setState(() {
          widget.costs.remove(cost);
          _buildRows();
        }),
        onUpdate: () => setState(() {}),
      );
    }
  }

  List<Widget> _buildCostList() {
    if (!_expanded) return [];
    if (_costRows.isEmpty) {
      return [
        Text(
          AppLocalizations.of(context).cost_selector_empty_list,
          style: Theme.of(context).textTheme.propEditorHint,
        )
      ];
    }
    return _costRows.values.toList();
  }
}
