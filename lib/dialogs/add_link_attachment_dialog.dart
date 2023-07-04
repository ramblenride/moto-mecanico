import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:moto_mecanico/models/attachment.dart';
import 'package:moto_mecanico/themes.dart';
import 'package:moto_mecanico/widgets/dissmiss_keyboard_ontap.dart';

class AddLinkAttachmentDialog extends StatefulWidget {
  const AddLinkAttachmentDialog({super.key, required this.onResult});

  final Function(Attachment?) onResult;

  @override
  State<StatefulWidget> createState() => _AddLinkAttachmentDialogState();
}

class _AddLinkAttachmentDialogState extends State<AddLinkAttachmentDialog> {
  _AddLinkAttachmentDialogState();

  final _formKey = GlobalKey<FormState>();

  String? link_name;
  String? link_url;

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
                    topRight: Radius.circular(20)),
              ),
              child: Text(
                AppLocalizations.of(context)!.add_link_attachment_dialog_title,
                style: theme.dialogHeader,
                textAlign: TextAlign.center,
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Form(
                    key: _formKey,
                    child: Wrap(
                      runSpacing: 10,
                      children: [
                        Text(
                          AppLocalizations.of(context)!
                              .add_link_attachment_dialog_property_name_link_name,
                          style: theme.propEditorName,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!
                                .add_link_attachment_dialog_property_hint_link_name,
                            hintStyle: propHintStyle,
                          ),
                          textAlign: TextAlign.start,
                          style: propValueStyle,
                          initialValue: '',
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(32),
                          ],
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .property_name_missing_error;
                            }
                            return null;
                          },
                          onSaved: (value) {
                            link_name = value;
                          },
                        ),
                        Text(
                          AppLocalizations.of(context)!
                              .add_link_attachment_dialog_property_name_link_value,
                          style: theme.propEditorName,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!
                                .add_link_attachment_dialog_property_hint_link_value,
                            hintStyle: propHintStyle,
                          ),
                          textAlign: TextAlign.start,
                          style: propValueStyle.copyWith(fontSize: 16),
                          initialValue: '',
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(64),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .add_link_attachment_error_url_missing;
                            }
                            try {
                              final scheme = Uri.parse(value).scheme;
                              if (scheme.toLowerCase().compareTo('http') != 0 &&
                                  scheme.toLowerCase().compareTo('https') !=
                                      0) {
                                return AppLocalizations.of(context)!
                                    .add_link_attachment_error_not_supported;
                              }
                            } on FormatException {
                              return AppLocalizations.of(context)!
                                  .add_link_attachment_error_not_supported;
                            }

                            return null;
                          },
                          onSaved: (value) {
                            link_url = value;
                          },
                        ),
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
            final attachment = _getLink();
            if (attachment != null) {
              widget.onResult(attachment);
            }
          },
        ),
      ],
    );
  }

  Attachment? _getLink() {
    if (!_formKey.currentState!.validate()) {
      return null;
    }

    _formKey.currentState!.save();
    return Attachment(
      type: AttachmentType.link,
      name: link_name ?? '',
      url: link_url ?? '',
    );
  }
}
