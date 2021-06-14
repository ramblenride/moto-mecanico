import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moto_mecanico/dialogs/add_link_attachment_dialog.dart';
import 'package:moto_mecanico/models/attachment.dart';
import 'package:moto_mecanico/themes.dart';

class AddAttachmentDialog extends StatefulWidget {
  AddAttachmentDialog({@required this.onResult});

  final Function(Attachment) onResult;

  @override
  State<StatefulWidget> createState() => _AddAttachmentDialogState();
}

class _AddAttachmentDialogState extends State<AddAttachmentDialog> {
  _AddAttachmentDialogState();

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
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Text(
              AppLocalizations.of(context).add_attachment_dialog_title,
              style: theme.dialogHeader,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              runAlignment: WrapAlignment.center,
              children: [
                _attachmentItem(
                  Icons.photo_camera,
                  AppLocalizations.of(context)
                      .add_attachment_dialog_add_new_picture,
                  () async =>
                      widget.onResult(await _selectPicture(ImageSource.camera)),
                ),
                _attachmentItem(
                  Icons.insert_photo,
                  AppLocalizations.of(context)
                      .add_attachment_dialog_add_picture,
                  () async => widget
                      .onResult(await _selectPicture(ImageSource.gallery)),
                ),
                _attachmentItem(
                  Icons.attach_file,
                  AppLocalizations.of(context).add_attachment_dialog_add_file,
                  () async => widget.onResult(await _selectFile()),
                ),
                _attachmentItem(
                  Icons.insert_link,
                  AppLocalizations.of(context).add_attachment_dialog_add_link,
                  () async => widget.onResult(await _selectLink()),
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
          ),
        ],
      ),
    );
  }

  Widget _attachmentItem(IconData icon, String title, Function action) {
    return InkWell(
      onTap: action,
      child: Row(
        children: [
          Icon(icon, size: 24),
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

  Future<Attachment> _selectPicture(ImageSource source) async {
    final pickedFile = await picker.getImage(
      source: source,
      maxHeight: 1080,
    );
    if (pickedFile != null) {
      return Attachment(
        type: AttachmentType.picture,
        name: AppLocalizations.of(context)
            .add_attachment_dialog_default_name_picture,
        url: pickedFile.path,
      );
    }
    return null;
  }

  Future<Attachment> _selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      return Attachment(
        type: AttachmentType.file,
        name: AppLocalizations.of(context)
            .add_attachment_dialog_default_name_file,
        url: result.files.single.path,
      );
    }
    return null;
  }

  Future<Attachment> _selectLink() async {
    return await showDialog<Attachment>(
      context: context,
      builder: (BuildContext context) {
        return AddLinkAttachmentDialog(
          onResult: (result) {
            Navigator.of(context).pop(result);
          },
        );
      },
    );
  }
}
