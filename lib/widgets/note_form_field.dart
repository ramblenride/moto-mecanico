import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moto_mecanico/models/note.dart';
import 'package:moto_mecanico/themes.dart';

class NoteFormField extends FormField<Note> {
  static const int maxLength = 2000;

  final Note note;

  NoteFormField({
    Key key,
    this.note,
    minLines = 1,
    maxLines = 10,
    focusNode,
    decoration = const InputDecoration(
      contentPadding: EdgeInsets.all(10),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: RnrColors.blue),
      ),
    ),
    FormFieldSetter onSaved,
    FormFieldValidator validator,
  }) : super(
          key: key,
          onSaved: onSaved,
          validator: validator,
          builder: (FormFieldState field) {
            return Row(
              children: [
                Expanded(
                  child: TextFormField(
                    focusNode: focusNode,
                    decoration: decoration,
                    style:
                        Theme.of(field.context).textTheme.propEditorLargeValue,
                    initialValue: note?.text ?? '',
                    minLines: minLines,
                    maxLines: maxLines,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(maxLength),
                    ],
                    onSaved: (value) {
                      if (note == null) {
                        if (value.isNotEmpty) {
                          if (onSaved != null) {
                            onSaved(Note(
                              name: DateTime.now().toIso8601String(),
                              text: value,
                            ));
                          }
                        }
                      } else {
                        note.text = value;
                        if (onSaved != null) onSaved(note);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: focusNode != null ? 22 : 0,
                  child: (focusNode != null && focusNode.hasFocus)
                      ? InkWell(
                          onTap: () => focusNode.unfocus(),
                          child: Icon(Icons.check_circle, size: 22),
                        )
                      : null,
                ),
              ],
            );
          },
        );
}
