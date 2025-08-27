import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:moto_mecanico/dialogs/delete_dialog.dart';
import 'package:moto_mecanico/locale/formats.dart';
import 'package:moto_mecanico/models/distance.dart';
import 'package:moto_mecanico/models/garage_model.dart';
import 'package:moto_mecanico/models/motorcycle.dart';
import 'package:moto_mecanico/themes.dart';
import 'package:moto_mecanico/widgets/attachment_selector.dart';
import 'package:moto_mecanico/widgets/config_widget.dart';
import 'package:moto_mecanico/widgets/dissmiss_keyboard_ontap.dart';
import 'package:moto_mecanico/widgets/note_selector.dart';
import 'package:moto_mecanico/widgets/property_editor_card.dart';
import 'package:moto_mecanico/widgets/property_editor_row.dart';
import 'package:moto_mecanico/widgets/textformfield_date_picker.dart';
import 'package:provider/provider.dart';

enum MotorcycleAction {
  delete,
}

/// This page allows to add a new motorcycle or edit an existing one.
/// It contains all informations about the motorcycle, except for the tasks.
/// If editing an existing motorcycle, a button allows to delete the motorcycle.
/// The changes are saved when the 'back' button is pressed.
class MotorcycleEditPage extends StatefulWidget {
  const MotorcycleEditPage(this.motorcycle, {super.key, this.create = false});
  final Motorcycle motorcycle;
  final bool create;

  @override
  State<StatefulWidget> createState() => _MotorcycleEditPageState();
}

class _MotorcycleEditPageState extends State<MotorcycleEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  DistanceUnit _distanceUnit = DistanceUnit.unitKm;
  String _currencySymbol = '\$';
  DateFormat _dateFormat = DateFormat.yMd();
  late final ScrollController _scrollController;

  File? _image;

  void _setImage() async {
    if (widget.motorcycle.storage != null &&
        widget.motorcycle.picture.isNotEmpty) {
      _image = await widget.motorcycle.storage!
          .getMotoFile(widget.motorcycle.picture);
    }
  }

  void _getNewImage(ImageSource source) async {
    // FIXME: How to remove the image? Long press?
    final pickedFile = await _imagePicker.pickImage(
      source: source,
      maxHeight: 1080,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _addMotorcycleToGarage(Motorcycle moto) async {
    await Provider.of<GarageModel>(context, listen: false).add(moto);
  }

  void _removeMotorcycleFromGarage(Motorcycle moto) async {
    Provider.of<GarageModel>(context, listen: false).remove(moto);
  }

  Future<bool> _saveMotorcycle() async {
    if (widget.motorcycle.storage == null ||
        !_formKey.currentState!.validate()) {
      return false;
    }

    _formKey.currentState!.save();

    if (_image != null &&
        (widget.motorcycle.picture.isEmpty == true ||
            _image!.path !=
                (await widget.motorcycle.storage!
                        .getMotoFile(widget.motorcycle.picture))
                    ?.path)) {
      if (widget.motorcycle.picture.isNotEmpty == true) {
        await widget.motorcycle.storage!
            .deleteMotoFile(widget.motorcycle.picture);
      }

      if ((_image?.path ?? '').isNotEmpty) {
        widget.motorcycle.picture =
            await widget.motorcycle.storage!.addMotoFile(_image!.path) ?? '';
      }
    }

    widget.motorcycle.saveChanges();

    return true;
  }

  Widget _displayImage() {
    if (_image != null) {
      // The image is tweaked to look like the image in the garage
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SizedBox(
          height: 160,
          child: Ink.image(
            image: FileImage(_image!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: RnrColors.orange),
        color: RnrColors.blue[900],
      ),
      height: 160,
      child: Text(
        AppLocalizations.of(context)!
            .motorcycle_edit_page_image_selection_empty,
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(color: Colors.white70),
      ),
    );
  }

  Widget _buildImageSection() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          _displayImage(),
          FloatingActionButton(
            onPressed: () => _getNewImage(ImageSource.gallery),
            tooltip: AppLocalizations.of(context)!
                .motorcycle_edit_page_image_selection_tooltip,
            child: const Icon(Icons.add_a_photo),
          ),
        ],
      ),
    );
  }

  InputDecoration _valueFieldDecoration(String hint) {
    return InputDecoration.collapsed(
      hintText: hint,
      hintStyle: Theme.of(context).textTheme.propEditorHint,
    );
  }

  List<Widget> _buildFormFields() {
    final propValueStyle = Theme.of(context).textTheme.propEditorValue;

    return [
      _buildImageSection(),
      PropertyEditorCard(
        children: [
          PropertyEditorRow(
            name: AppLocalizations.of(context)!
                .motorcycle_edit_page_name_prop_name,
            inputField: TextFormField(
              decoration: _valueFieldDecoration(AppLocalizations.of(context)!
                  .motorcycle_edit_page_hint_prop_name),
              style: propValueStyle,
              textAlign: TextAlign.end,
              initialValue: widget.motorcycle.name,
              inputFormatters: [LengthLimitingTextInputFormatter(16)],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!
                      .property_name_missing_error;
                }
                return null;
              },
              onSaved: (value) {
                widget.motorcycle.name = value ?? '';
              },
            ),
          ),
          PropertyEditorRow(
            name: AppLocalizations.of(context)!
                .motorcycle_edit_page_name_prop_odometer,
            inputField: TextFormField(
              decoration: _valueFieldDecoration(AppLocalizations.of(context)!
                  .motorcycle_edit_page_hint_prop_odometer),
              style: propValueStyle,
              textAlign: TextAlign.end,
              initialValue:
                  widget.motorcycle.odometer.toUnit(_distanceUnit).toString(),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(7),
              ],
              onSaved: (value) {
                widget.motorcycle.odometer = Distance(
                    (value != null && value.isNotEmpty)
                        ? int.parse(value)
                        : null,
                    _distanceUnit);
              },
            ),
            trailer: Text(
              '${AppLocalSupport.distanceUnits[_distanceUnit]}',
              style: propValueStyle,
            ),
          ),
          PropertyEditorRow(
            name: AppLocalizations.of(context)!
                .motorcycle_edit_page_name_prop_licence_plate,
            inputField: TextFormField(
              decoration: _valueFieldDecoration(AppLocalizations.of(context)!
                  .motorcycle_edit_page_hint_prop_licence_plate),
              textAlign: TextAlign.end,
              style: propValueStyle,
              initialValue: widget.motorcycle.immatriculation,
              keyboardType: TextInputType.visiblePassword,
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              inputFormatters: [LengthLimitingTextInputFormatter(16)],
              onSaved: (value) {
                widget.motorcycle.immatriculation = value ?? '';
              },
            ),
          ),
        ],
      ),
      PropertyEditorCard(
        title: AppLocalizations.of(context)!
            .motorcycle_edit_page_section_header_moto_info,
        children: [
          PropertyEditorRow(
            name: AppLocalizations.of(context)!
                .motorcycle_edit_page_name_prop_make,
            inputField: TextFormField(
              decoration: _valueFieldDecoration(AppLocalizations.of(context)!
                  .motorcycle_edit_page_hint_prop_make),
              style: propValueStyle,
              textAlign: TextAlign.end,
              initialValue: widget.motorcycle.make,
              inputFormatters: [LengthLimitingTextInputFormatter(16)],
              onSaved: (value) {
                widget.motorcycle.make = value ?? '';
              },
            ),
          ),
          PropertyEditorRow(
            name: AppLocalizations.of(context)!
                .motorcycle_edit_page_name_prop_model,
            inputField: TextFormField(
              decoration: _valueFieldDecoration(AppLocalizations.of(context)!
                  .motorcycle_edit_page_hint_prop_model),
              style: propValueStyle,
              textAlign: TextAlign.end,
              initialValue: widget.motorcycle.model,
              inputFormatters: [LengthLimitingTextInputFormatter(16)],
              onSaved: (value) {
                widget.motorcycle.model = value ?? '';
              },
            ),
          ),
          PropertyEditorRow(
            name: AppLocalizations.of(context)!
                .motorcycle_edit_page_name_prop_year,
            inputField: TextFormField(
              decoration: _valueFieldDecoration(AppLocalizations.of(context)!
                  .motorcycle_edit_page_hint_prop_year),
              style: propValueStyle,
              textAlign: TextAlign.end,
              initialValue: widget.motorcycle.year?.toString() ?? '',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              onSaved: (value) {
                widget.motorcycle.year = (value != null && value.isNotEmpty)
                    ? int.parse(value)
                    : null;
              },
            ),
          ),
          PropertyEditorRow(
            name: AppLocalizations.of(context)!
                .motorcycle_edit_page_name_prop_color,
            inputField: TextFormField(
              decoration: _valueFieldDecoration(AppLocalizations.of(context)!
                  .motorcycle_edit_page_hint_prop_color),
              style: propValueStyle,
              textAlign: TextAlign.end,
              initialValue: widget.motorcycle.color,
              inputFormatters: [LengthLimitingTextInputFormatter(16)],
              onSaved: (value) {
                widget.motorcycle.color = value ?? '';
              },
            ),
          ),
          PropertyEditorRow(
            name: AppLocalizations.of(context)!
                .motorcycle_edit_page_name_prop_vin,
            inputField: TextFormField(
              decoration: _valueFieldDecoration(AppLocalizations.of(context)!
                  .motorcycle_edit_page_hint_prop_vin),
              style: propValueStyle,
              textAlign: TextAlign.end,
              initialValue: widget.motorcycle.vin,
              keyboardType: TextInputType.visiblePassword,
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              enableSuggestions: false,
              inputFormatters: [LengthLimitingTextInputFormatter(17)],
              onSaved: (value) {
                widget.motorcycle.vin = value ?? '';
              },
            ),
          )
        ],
      ),
      PropertyEditorCard(
        title: AppLocalizations.of(context)!
            .motorcycle_edit_page_section_header_purchase_info,
        children: [
          PropertyEditorRow(
            name: AppLocalizations.of(context)!
                .motorcycle_edit_page_name_prop_price,
            inputField: TextFormField(
              decoration: _valueFieldDecoration(AppLocalizations.of(context)!
                  .motorcycle_edit_page_hint_prop_purchase_price),
              textAlign: TextAlign.end,
              style: propValueStyle,
              initialValue: widget.motorcycle.purchasePrice.toString(),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
              ],
              onSaved: (value) {
                widget.motorcycle.purchasePrice =
                    (value != null && value.isNotEmpty) ? int.parse(value) : 0;
              },
            ),
            trailer: Text(
              NumberFormat.compactSimpleCurrency(name: _currencySymbol)
                  .currencySymbol,
              style: propValueStyle,
            ),
          ),
          PropertyEditorRow(
            name: AppLocalizations.of(context)!
                .motorcycle_edit_page_name_prop_odometer,
            inputField: TextFormField(
              decoration: _valueFieldDecoration(AppLocalizations.of(context)!
                  .motorcycle_edit_page_hint_prop_odometer),
              textAlign: TextAlign.end,
              style: propValueStyle,
              initialValue: widget.motorcycle.purchaseOdometer
                  .toUnit(_distanceUnit)
                  .toString(),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(7),
              ],
              onSaved: (value) {
                widget.motorcycle.purchaseOdometer = Distance(
                    (value != null && value.isNotEmpty)
                        ? int.parse(value)
                        : null,
                    _distanceUnit);
              },
            ),
            trailer: Text(
              '${AppLocalSupport.distanceUnits[_distanceUnit]}',
              style: propValueStyle,
            ),
          ),
          PropertyEditorRow(
            name: AppLocalizations.of(context)!
                .motorcycle_edit_page_name_prop_date,
            inputField: TextFormFieldDatePicker(
              decoration: _valueFieldDecoration(AppLocalizations.of(context)!
                  .motorcycle_edit_page_hint_prop_purchase_date),
              resetTooltip: AppLocalizations.of(context)!.tooltip_reset_date,
              textAlign: TextAlign.end,
              style: propValueStyle,
              initialDate: widget.motorcycle.purchaseDate,
              firstDate: DateTime.fromMillisecondsSinceEpoch(0),
              lastDate: DateTime.now(),
              dateFormat: _dateFormat,
              onSaved: (selectedDate) {
                widget.motorcycle.purchaseDate = selectedDate;
              },
            ),
          ),
        ],
      ),
      PropertyEditorCard(
        children: [
          widget.motorcycle.storage?.storage != null
              ? AttachmentSelector(
                  attachments: widget.motorcycle.attachments,
                  storage: widget.motorcycle.storage!.storage,
                )
              : Container(),
        ],
      ),
      rnrDivider,
      PropertyEditorCard(
        children: [_buildNoteSelector()],
      ),
    ];
  }

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    if (_image == null) {
      _setImage();
      setState(() => {});
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ConfigWidget.of(context);
    _distanceUnit = config.distanceUnit;
    _currencySymbol = config.currencySymbol;
    _dateFormat = DateFormat(config.dateFormat);

    return PopScope(
      canPop: true,
      onPopInvoked: (bool didPop) async {
        if (!didPop) return;
        if (!widget.create) {
          await _saveMotorcycle();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.create
                ? AppLocalizations.of(context)!.motorcycle_edit_page_title_add
                : AppLocalizations.of(context)!.motorcycle_edit_page_title_edit,
          ),
          actions: [
            widget.create
                ? SizedBox(
                    width: 45,
                    child: IconButton(
                      iconSize: 30,
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: AppLocalizations.of(context)!.appbar_add_button,
                      onPressed: () async {
                        if (await _saveMotorcycle() && context.mounted) {
                          _addMotorcycleToGarage(widget.motorcycle);
                          Navigator.pop(context);
                        }
                      },
                    ),
                  )
                : PopupMenuButton<MotorcycleAction>(
                    itemBuilder: (context) => [
                          PopupMenuItem(
                            value: MotorcycleAction.delete,
                            child: Text(AppLocalizations.of(context)!
                                .motorcycle_view_appbar_popop_delete_moto),
                          ),
                        ],
                    onSelected: (value) async {
                      switch (value) {
                        case MotorcycleAction.delete:
                          {
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return DeleteDialog(
                                  title: AppLocalizations.of(context)!
                                      .motorcycle_delete_dialog_title,
                                  content: AppLocalizations.of(context)!
                                      .motorcycle_delete_dialog_text(
                                          widget.motorcycle.name),
                                  onResult: (result) {
                                    Navigator.of(context).pop(result);
                                  },
                                );
                              },
                            );
                            if (result != null && result) {
                              _removeMotorcycleFromGarage(widget.motorcycle);

                              if (context.mounted) {
                                while (Navigator.of(context).canPop()) {
                                  Navigator.of(context).pop();
                                }
                              }
                            }
                            break;
                          }
                      }
                    })
          ],
        ),
        body: DismissKeyboardOnTap(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Wrap(
                  runSpacing: 10,
                  children: _buildFormFields(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteSelector() {
    final key = GlobalKey();

    return NoteSelector(
      key: key,
      notes: widget.motorcycle.notes,
      showRenewable: false,
      onExpansionChanged: (isExpanded) async {
        if (isExpanded) {
          _scrollDown(key);
        }
      },
    );
  }

  void _scrollDown(GlobalKey myKey) {
    final keyContext = myKey.currentContext;

    if (keyContext != null) {
      // FIXME: Scroll to show the first note and the beginning of the next one
      //final box = keyContext.findRenderObject() as RenderBox;
      _scrollController.animateTo(
          _scrollController.position.pixels + 200 /*box.size.height*/,
          duration: const Duration(milliseconds: 200),
          curve: Curves.linear);
    }
  }
}
