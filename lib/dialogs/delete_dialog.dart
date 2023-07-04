import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DeleteDialog extends StatelessWidget {
  DeleteDialog(
      {required this.title, required this.content, required this.onResult});

  final String title;
  final String content;
  final Function(bool) onResult;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          child: Text(AppLocalizations.of(context)!.dialog_cancel_button),
          onPressed: () => onResult(false),
        ),
        TextButton(
          child: Text(AppLocalizations.of(context)!.dialog_delete_button),
          onPressed: () => onResult(true),
        ),
      ],
    );
  }
}
