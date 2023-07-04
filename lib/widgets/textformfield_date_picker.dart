import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TextFormFieldDatePicker extends StatefulWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? initialDate;
  final bool enabled;
  final String labelText;
  final TextAlign textAlign;
  final TextStyle? style;
  final Icon? prefixIcon;
  final Icon? suffixIcon;
  final String? resetTooltip;
  final DateFormat? dateFormat;
  final InputDecoration? decoration;
  final FocusNode? focusNode;
  final ValueChanged<DateTime?>? onDateChanged;
  final FormFieldSetter<DateTime?>? onSaved;

  TextFormFieldDatePicker({
    Key? key,
    required this.lastDate,
    required this.firstDate,
    this.initialDate,
    this.enabled = false,
    this.labelText = '',
    this.textAlign = TextAlign.start,
    this.style,
    this.prefixIcon,
    this.suffixIcon,
    this.resetTooltip,
    this.dateFormat,
    this.decoration,
    this.focusNode,
    this.onDateChanged,
    this.onSaved,
  })  : assert(!firstDate.isAfter(lastDate),
            'lastDate must be on or after firstDate'),
        super(key: key);

  @override
  _TextFormFieldDatePicker createState() => _TextFormFieldDatePicker();
}

class _TextFormFieldDatePicker extends State<TextFormFieldDatePicker> {
  late final TextEditingController _controllerDate;
  late final DateFormat _dateFormat;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();

    _dateFormat = widget.dateFormat ?? DateFormat.MMMEd();
    _selectedDate = widget.initialDate ?? DateTime.now();

    _controllerDate = TextEditingController();
    if (_selectedDate != null) {
      _controllerDate.text = _dateFormat.format(_selectedDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      width: 165,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: _getRowWidgets(),
      ),
    );
  }

  List<Widget> _getRowWidgets() {
    final widgets = <Widget>[];

    if (_selectedDate != null) {
      widgets.add(
        Container(
          width: 30,
          height: 30,
          child: IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            alignment: Alignment.centerRight,
            icon: Icon(
              Icons.cancel,
              size: 20,
            ),
            color: _selectedDate == null
                ? Colors.transparent
                : Colors.blueGrey[100],
            tooltip: widget.resetTooltip ?? 'Reset date',
            onPressed: () {
              setState(() {
                _controllerDate.text = '';
                _selectedDate = null;
              });
              if (widget.onDateChanged != null) {
                widget.onDateChanged!.call(_selectedDate);
              }
            },
          ),
        ),
      );
    }

    widgets.add(
      Flexible(
        child: TextFormField(
          enabled: widget.enabled,
          focusNode: widget.focusNode,
          controller: _controllerDate,
          decoration: widget.decoration,
          textAlign: widget.textAlign,
          style: widget.style,
          onTap: () => _selectDate(context),
          onSaved: (value) {
            if (widget.onSaved != null) {
              widget.onSaved!.call(_selectedDate);
            }
          },
          readOnly: true,
        ),
      ),
    );

    return widgets;
  }

  @override
  void dispose() {
    _controllerDate.dispose();
    super.dispose();
  }

  Future<Null> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _controllerDate.text = _dateFormat.format(_selectedDate!);
      });

      if (widget.onDateChanged != null) {
        widget.onDateChanged!.call(_selectedDate);
      }
    }

    if (widget.focusNode != null) {
      widget.focusNode!.nextFocus();
    }
  }
}
