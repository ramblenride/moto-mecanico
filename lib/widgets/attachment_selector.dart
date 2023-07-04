import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:moto_mecanico/dialogs/add_attachment_dialog.dart';
import 'package:moto_mecanico/models/attachment.dart';
import 'package:moto_mecanico/storage/storage.dart';
import 'package:moto_mecanico/themes.dart';
import 'package:moto_mecanico/widgets/attachment_selector_row.dart';

class AttachmentSelector extends StatefulWidget {
  AttachmentSelector(
      {Key? key, required this.attachments, required this.storage})
      : super(key: key);

  final List<Attachment> attachments;
  final Storage storage;

  @override
  State<StatefulWidget> createState() => _AttachmentSelectorState();
}

class _AttachmentSelectorState extends State<AttachmentSelector> {
  late final Map<Key, AttachmentSelectorRow> _attachmentRows;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _buildRows();
  }

  @override
  Widget build(BuildContext context) {
    final topLineFont = Theme.of(context).textTheme.selectorWidgetHeader;

    return Wrap(
      children: [
        // FIXME: Top row should be its own widget (reused in CostSelector & NoteSelector)
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
                  AppLocalizations.of(context)!.attachment_selector_title,
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
                          tooltip: AppLocalizations.of(context)!
                              .attachment_selector_add_attachment,
                          onPressed: _addAttachment,
                        )
                      : Container(),
                ),
                Container(
                  // Force a specific width so that it aligns with other selectors.
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  width: 42,
                  child: Text(
                    '(${widget.attachments.length})',
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
          padding: const EdgeInsets.only(left: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [..._buildAttachmentList()],
          ),
        ),
      ],
    );
  }

  void _buildRows() {
    _attachmentRows = {};
    for (final attachment in widget.attachments) {
      final key = UniqueKey();
      _attachmentRows[key] = AttachmentSelectorRow(
        key: key,
        attachment: attachment,
        storage: widget.storage,
        onRemove: (attachment) => setState(() {
          widget.attachments.remove(attachment);
          if (attachment.type == AttachmentType.file ||
              attachment.type == AttachmentType.picture) {
            widget.storage.deleteFile(attachment.url);
          }
          _buildRows();
        }),
      );
    }
  }

  void _addAttachment() async {
    final result = await showDialog<Attachment>(
      context: context,
      builder: (BuildContext context) {
        return AddAttachmentDialog(
          onResult: (result) {
            result ?? Navigator.of(context).pop(result);
          },
        );
      },
    );
    if (result != null) {
      try {
        Attachment attachment;
        if (result.type == AttachmentType.file ||
            result.type == AttachmentType.picture) {
          final id = await widget.storage.addExternalFile(result.url);
          assert(id != null, 'Failed to add file');
          attachment = Attachment(
            type: result.type,
            name: result.name,
            url: id ?? '',
          );
        } else {
          attachment = result;
        }

        widget.attachments.add(attachment);
        setState(() {
          _expanded = true;
          _buildRows();
        });
      } catch (error) {
        debugPrint('Failed to add attachment: ${error.toString()}');
        final snackBar = SnackBar(
          content: Text(
            AppLocalizations.of(context)!.snackbar_storage_error +
                ': ${error.toString()}',
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  List<Widget> _buildAttachmentList() {
    if (!_expanded) return [];
    if (_attachmentRows.isEmpty) {
      return [
        Text(
          AppLocalizations.of(context)!.attachment_selector_empty_list,
          style: Theme.of(context).textTheme.propEditorHint,
        )
      ];
    }

    return _attachmentRows.values.toList();
  }
}
