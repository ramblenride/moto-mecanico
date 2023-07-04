import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:moto_mecanico/models/attachment.dart';
import 'package:moto_mecanico/storage/storage.dart';
import 'package:moto_mecanico/themes.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

enum AttachmentAction { delete, rename, copyable }

class AttachmentSelectorRow extends StatefulWidget {
  AttachmentSelectorRow({
    Key? key,
    required this.attachment,
    required this.storage,
    required this.onRemove,
  }) : super(key: key);

  final Attachment attachment;
  final Storage storage;
  final Function(Attachment) onRemove;

  @override
  State<StatefulWidget> createState() =>
      _AttachmentSelectorRowState(attachment: attachment);
}

class _AttachmentSelectorRowState extends State<AttachmentSelectorRow> {
  _AttachmentSelectorRowState({required this.attachment});

  final Attachment attachment;
  bool _rename = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: attachment.url,
      child: Row(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            height: 30,
            width: 35,
            child: _getIcon(attachment.type),
          ),
          Expanded(
            child: InkWell(
              onTap: () => _handleTap(attachment),
              child: _getTextOrEditor(),
            ),
          ),
          Container(
            height: 30,
            width: 40,
            child: PopupMenuButton<AttachmentAction>(
              padding: EdgeInsets.zero,
              icon: const Align(
                // Align with the icons above
                alignment: Alignment.centerRight,
                child: Icon(Icons.more_vert),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: !_rename,
                  value: AttachmentAction.rename,
                  child: Text(AppLocalizations.of(context)!
                      .attachment_selector_action_rename),
                ),
                PopupMenuItem(
                  value: AttachmentAction.delete,
                  child: Text(AppLocalizations.of(context)!
                      .attachment_selector_action_delete),
                ),
                PopupMenuItem(
                  value: AttachmentAction.copyable,
                  child: Tooltip(
                    message: AppLocalizations.of(context)!.renewable_tooltip,
                    child: Row(
                      children: [
                        Text(AppLocalizations.of(context)!.renewable),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          attachment.copyable
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
                  case AttachmentAction.rename:
                    {
                      setState(() => _rename = true);
                      break;
                    }
                  case AttachmentAction.delete:
                    {
                      setState(() => widget.onRemove(attachment));
                      break;
                    }
                  case AttachmentAction.copyable:
                    {
                      setState(
                          () => attachment.copyable = !attachment.copyable);
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

  Widget _getTextOrEditor() {
    if (!_rename) {
      return Text(
        attachment.name,
        style:
            Theme.of(context).textTheme.propEditorValue.copyWith(fontSize: 18),
      );
    } else {
      return TextFormField(
        autofocus: true,
        initialValue: attachment.name,
        inputFormatters: [
          LengthLimitingTextInputFormatter(16),
        ],
        onFieldSubmitted: (value) => {
          setState(() {
            if (value.isNotEmpty) {
              attachment.name = value;
            }
            _rename = false;
          })
        },
      );
    }
  }

  void _handleTap(Attachment attachment) {
    switch (attachment.type) {
      case AttachmentType.link:
        _launchURL(attachment.url);
        break;
      case AttachmentType.picture:
        _openFile(attachment.url);
        break;
      case AttachmentType.file:
        _openFile(attachment.url);
        break;
    }
  }

  Icon _getIcon(AttachmentType type) {
    var iconData = Icons.error;
    switch (type) {
      case AttachmentType.file:
        {
          iconData = Icons.attach_file;
          break;
        }
      case AttachmentType.picture:
        {
          iconData = Icons.insert_photo;
          break;
        }
      case AttachmentType.link:
        {
          iconData = Icons.insert_link;
          break;
        }
    }

    return Icon(iconData, color: Colors.blueGrey[100]);
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      final result = await launchUrl(uri);
      if (!result) {
        _showOpenAttachmentError(AppLocalizations.of(context)!
                .attachment_selector_attachment_error_link_open_failed +
            '\n\n${url}');
      }
    } else {
      _showOpenAttachmentError(AppLocalizations.of(context)!
              .attachment_selector_attachment_error_link_unsupported +
          '\n\n${url}');
    }
  }

  void _openFile(String url) async {
    final file = await widget.storage.getFile(url);
    if (file == null) return;

    final result = await OpenFile.open(file.path);
    if (result.type != ResultType.done) {
      String errorMessage;
      switch (result.type) {
        case ResultType.fileNotFound:
          errorMessage = AppLocalizations.of(context)!
              .attachment_selector_attachment_error_file_not_found;
          break;
        case ResultType.noAppToOpen:
          errorMessage = AppLocalizations.of(context)!
              .attachment_selector_attachment_error_no_app_to_open;
          break;
        case ResultType.permissionDenied:
          errorMessage = AppLocalizations.of(context)!
              .attachment_selector_attachment_error_permission_denied;
          break;
        default:
          errorMessage = result.message;
          break;
      }
      _showOpenAttachmentError(AppLocalizations.of(context)!
              .attachment_selector_attachment_error_file_open_failed +
          '\n\n$url\n\n$errorMessage');
    }
  }

  void _showOpenAttachmentError(String message) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!
            .attachment_selector_attachment_error_dialog_title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
          ],
        ),
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)!.dialog_ok_button),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
