import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:moto_mecanico/models/motorcycle_templates.dart';
import 'package:moto_mecanico/themes.dart';

class MotorcycleTemplateTaskTile extends StatefulWidget {
  final TaskTemplate task;
  final bool _renew;
  final bool _fixedTime;
  final _MotorcycleTemplateTaskTileState _state;

  MotorcycleTemplateTaskTile({Key key, @required this.task})
      : assert(task != null),
        _renew = (task.intervalDistance.distance ?? 0) > 0 ||
            (task.intervalMonths ?? 0) > 0,
        _fixedTime =
            (task.distance.distance ?? 0) > 0 || (task.months ?? 0) > 0,
        _state = _MotorcycleTemplateTaskTileState(),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _state;

  bool isEnabled() {
    return _state?.isEnabled() ?? false;
  }
}

class _MotorcycleTemplateTaskTileState
    extends State<MotorcycleTemplateTaskTile> {
  bool _isEnabled = true;
  EdgeInsets _propTilePadding;
  Text _propTitle;
  Text _propSubtitle;
  Widget _propLeading;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _propTilePadding = const EdgeInsets.symmetric(horizontal: 8);
    _propTitle = Text(
      widget.task.name,
      style: Theme.of(context).textTheme.taskCardName,
      overflow: TextOverflow.ellipsis,
    );
    _propSubtitle = Text(
      widget.task.description,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.taskCardDescription,
    );
    _propLeading = Container(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      width: 24,
      child: widget._renew
          ? Tooltip(
              message: AppLocalizations.of(context)
                  .motorcycle_task_template_page_task_icon_tooltip_recurring,
              child: Icon(
                Icons.autorenew,
                size: 22,
                color: Colors.blueGrey[100],
              ),
            )
          : widget._fixedTime
              ? Tooltip(
                  message: AppLocalizations.of(context)
                      .motorcycle_task_template_page_task_icon_tooltip_fixed,
                  child: Icon(
                    Icons.schedule,
                    size: 22,
                    color: Colors.blueGrey[100],
                  ),
                )
              : Container(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
          child: _buildTaskTile(),
        ),
        Tooltip(
          message: AppLocalizations.of(context)
              .motorcycle_task_template_page_task_add_switch_tooltip,
          child: Switch(
            activeColor: RnrColors.orange,
            inactiveThumbColor: Colors.white70,
            value: _isEnabled,
            onChanged: (value) {
              setState(() => _isEnabled = value);
            },
          ),
        ),
      ],
    );
  }

  bool isEnabled() => _isEnabled;

  Widget _buildTaskTile() {
    if (widget.task.notes.trim().isNotEmpty) {
      return _buildExpansionTile();
    } else {
      return _buildListTile();
    }
  }

  Widget _buildExpansionTile() {
    return ExpansionTile(
        key: UniqueKey(),
        tilePadding: _propTilePadding,
        title: _propTitle,
        subtitle: _propSubtitle,
        leading: _propLeading,
        initiallyExpanded: false,
        childrenPadding: const EdgeInsets.only(left: 10, right: 8, bottom: 12),
        expandedAlignment: Alignment.centerLeft,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.task.notes,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.subtitle2.copyWith(
                  color: Colors.blueGrey[200],
                ),
          ),
        ]);
  }

  Widget _buildListTile() {
    return ListTile(
      key: UniqueKey(),
      contentPadding: _propTilePadding,
      title: _propTitle,
      subtitle: _propSubtitle,
      leading: _propLeading,
    );
  }
}
