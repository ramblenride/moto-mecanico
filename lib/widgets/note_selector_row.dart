import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:moto_mecanico/models/note.dart';
import 'package:moto_mecanico/themes.dart';
import 'package:moto_mecanico/widgets/config_widget.dart';
import 'package:moto_mecanico/widgets/note_form_field.dart';

enum NoteAction { delete, copyable }

class NoteSelectorRow extends StatefulWidget {
  const NoteSelectorRow({
    super.key,
    this.note,
    required this.onRemove,
    required this.onSaved,
    this.showRenewable = true,
    this.header = true,
    this.minLines = 1,
    this.maxLines = 10,
  });

  final Note? note;
  final bool showRenewable;
  final Function(dynamic) onRemove;
  final Function(dynamic) onSaved;
  final bool header;
  final int minLines;
  final int maxLines;

  @override
  State<NoteSelectorRow> createState() => _NoteSelectorRowState();
}

class _NoteSelectorRowState extends State<NoteSelectorRow> {
  final _formKey = GlobalKey<FormState>();
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        if (_focusNode.hasFocus == false && _formKey.currentState!.validate()) {
          _formKey.currentState!.save();
        }
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (widget.header) {
      children.add(_buildHeader());
    }

    children.add(
      Form(
        key: _formKey,
        child: NoteFormField(
          note: widget.note,
          focusNode: _focusNode,
          onSaved: widget.onSaved,
          validator: (dynamic) => null,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
        ),
      ),
    );

    return Column(children: children);
  }

  Widget _buildHeader() {
    final config = ConfigWidget.of(context);
    final dateFormat = DateFormat(config.dateFormat);
    return Row(
      children: [
        widget.note != null
            ? Text(
                '${AppLocalizations.of(context)!.note_last_updated}: ${dateFormat.format(widget.note!.lastUpdate)}',
                style: Theme.of(context)
                    .textTheme
                    .propEditorHint
                    .copyWith(fontSize: 12),
              )
            : Container(),
        const Spacer(),
        SizedBox(
          height: 30,
          width: 40,
          child: PopupMenuButton<NoteAction>(
            padding: EdgeInsets.zero,
            icon: const Align(
              // Align with the icons above
              alignment: Alignment.centerRight,
              child: Icon(Icons.more_vert),
            ),
            itemBuilder: _getPopupMenuItems,
            onSelected: (value) async {
              switch (value) {
                case NoteAction.delete:
                  {
                    widget.onRemove(widget.note);
                    break;
                  }
                case NoteAction.copyable:
                  {
                    if (widget.note != null) {
                      setState(
                          () => widget.note!.copyable = !widget.note!.copyable);
                    }
                    break;
                  }
              }
            },
          ),
        ),
      ],
    );
  }

  List<PopupMenuEntry<NoteAction>> _getPopupMenuItems(BuildContext context) {
    final items = [
      PopupMenuItem(
        value: NoteAction.delete,
        child: Text(
            AppLocalizations.of(context)!.attachment_selector_action_delete),
      )
    ];

    if (widget.showRenewable == true) {
      items.add(PopupMenuItem(
        value: NoteAction.copyable,
        child: Tooltip(
          message: AppLocalizations.of(context)!.renewable_tooltip,
          child: Row(
            children: [
              Text(AppLocalizations.of(context)!.renewable),
              const SizedBox(
                width: 10,
              ),
              Icon(
                (widget.note != null && widget.note!.copyable)
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                size: 20,
              ),
            ],
          ),
        ),
      ));
    }

    return items;
  }
}
