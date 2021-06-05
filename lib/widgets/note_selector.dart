import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:moto_mecanico/models/note.dart';
import 'package:moto_mecanico/themes.dart';
import 'package:moto_mecanico/widgets/note_selector_row.dart';

class NoteSelector extends StatefulWidget {
  NoteSelector({
    Key key,
    @required this.notes,
    this.onExpansionChanged,
    this.showRenewable = true,
  })  : assert(notes != null),
        super(key: key);

  final List<Note> notes;
  final bool showRenewable;
  final ValueChanged<bool> onExpansionChanged;

  @override
  State<StatefulWidget> createState() => _NoteSelectorState();
}

class _NoteSelectorState extends State<NoteSelector> {
  Map<Key, NoteSelectorRow> _noteRows;
  bool _expanded = true;
  bool _expansionSignaled = true;

  @override
  void initState() {
    super.initState();
    _buildRows();
  }

  void _notifyExpand() {
    // This event must be signalled after the widget is redrawn
    if (_expansionSignaled == false && widget.onExpansionChanged != null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => widget.onExpansionChanged(_expanded));
    }
    _expansionSignaled = true;
  }

  @override
  Widget build(BuildContext context) {
    final topLineFont = Theme.of(context).textTheme.selectorWidgetHeader;
    _notifyExpand();

    return Wrap(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _expanded = !_expanded;
              _expansionSignaled = false;
            });
          },
          child: ConstrainedBox(
            // Force a uniform height
            constraints: BoxConstraints(minHeight: 35),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)
                      .motorcycle_edit_page_section_header_notes,
                  style: Theme.of(context).textTheme.propEditorHeader,
                ),
                const Spacer(),
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
                              .note_selector_add_note,
                          onPressed: () async {
                            final note = Note(
                                name: DateTime.now().toIso8601String(),
                                text: '');
                            widget.notes.add(note);
                            setState(() {
                              _expanded = true;
                              _buildRows();
                              _expansionSignaled =
                                  false; // Page should scroll down
                            });
                          },
                        )
                      : Container(),
                ),
                Container(
                  // Force a specific width so that it aligns with other selectors.
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  width: 42,
                  child: Text(
                    '(${widget.notes.length})',
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
            children: [..._buildNoteList()],
          ),
        ),
      ],
    );
  }

  void _buildRows() {
    _noteRows = {};
    for (final note in widget.notes) {
      final key = UniqueKey();
      _noteRows[key] = NoteSelectorRow(
        key: key,
        note: note,
        showRenewable: widget.showRenewable,
        onRemove: (note) => setState(() {
          widget.notes.remove(note);
          _buildRows();
        }),
      );
    }
  }

  List<Widget> _buildNoteList() {
    if (!_expanded) return [];
    if (_noteRows.isEmpty) {
      return [
        Text(
          AppLocalizations.of(context).note_selector_empty_list,
          style: Theme.of(context).textTheme.propEditorHint,
        )
      ];
    }

    final noteRows = _noteRows.values.toList();
    return noteRows.reversed.toList();
  }
}
