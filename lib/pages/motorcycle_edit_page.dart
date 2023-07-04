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
import 'package:moto_mecanico/storage/motorcycle_local_storage.dart';
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
  MotorcycleEditPage({Key? key, this.motorcycle}) : super(key: key);
  final Motorcycle? motorcycle;

  @override
  _MotorcycleEditPageState createState() =>
      _MotorcycleEditPageState(motorcycle: motorcycle);
}

class _MotorcycleEditPageState extends State<MotorcycleEditPage> {
  _MotorcycleEditPageState({this.motorcycle}) : _isNew = false;

  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late final ScrollController _scrollController;
  late final DistanceUnit _distanceUnit;
  late final String _currencySymbol;
  late final DateFormat _dateFormat;

  Motorcycle? motorcycle;
  bool _isNew;
  File? _image;

  void _setImage() async {
    if (motorcycle?.storage != null && motorcycle!.picture.isNotEmpty) {
      _image = await motorcycle!.storage!.getMotoFile(motorcycle!.picture);
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
    if (motorcycle?.storage == null || !_formKey.currentState!.validate()) {
      return false;
    }

    _formKey.currentState!.save();

    if (_image != null &&
        (motorcycle!.picture.isEmpty == true ||
            _image!.path !=
                (await motorcycle!.storage!.getMotoFile(motorcycle!.picture))
                    ?.path)) {
      if (motorcycle!.picture.isNotEmpty == true) {
        await motorcycle!.storage!.deleteMotoFile(motorcycle!.picture);
      }

      if ((_image?.path ?? '').isNotEmpty) {
        motorcycle!.picture =
            await motorcycle!.storage!.addMotoFile(_image!.path) ?? '';
      }
    }

    motorcycle!.saveChanges();

    return true;
  }

  Widget _displayImage() {
    if (_image != null) {
      // The image is tweaked to look like the image in the garage
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Container(
          height: 160,
          child: Ink.image(
            image: FileImage(_image!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25),
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
            child: Icon(Icons.add_a_photo),
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
              initialValue: motorcycle!.name,
              inputFormatters: [LengthLimitingTextInputFormatter(16)],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!
                      .property_name_missing_error;
                }
                return null;
              },
              onSaved: (value) {
                motorcycle!.name = value ?? '';
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
                  motorcycle!.odometer.toUnit(_distanceUnit).toString(),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(7),
              ],
              onSaved: (value) {
                motorcycle!.odometer = Distance(
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
              initialValue: motorcycle!.immatriculation,
              keyboardType: TextInputType.visiblePassword,
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              inputFormatters: [LengthLimitingTextInputFormatter(16)],
              onSaved: (value) {
                motorcycle!.immatriculation = value ?? '';
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
              initialValue: motorcycle!.make,
              inputFormatters: [LengthLimitingTextInputFormatter(16)],
              onSaved: (value) {
                motorcycle!.make = value ?? '';
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
              initialValue: motorcycle!.model,
              inputFormatters: [LengthLimitingTextInputFormatter(16)],
              onSaved: (value) {
                motorcycle!.model = value ?? '';
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
              initialValue: motorcycle!.year?.toString() ?? '',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              onSaved: (value) {
                motorcycle!.year = (value != null && value.isNotEmpty)
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
              initialValue: motorcycle!.color,
              inputFormatters: [LengthLimitingTextInputFormatter(16)],
              onSaved: (value) {
                motorcycle!.color = value ?? '';
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
              initialValue: motorcycle!.vin,
              keyboardType: TextInputType.visiblePassword,
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              enableSuggestions: false,
              inputFormatters: [LengthLimitingTextInputFormatter(17)],
              onSaved: (value) {
                motorcycle!.vin = value ?? '';
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
              initialValue: motorcycle!.purchasePrice.toString(),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
              ],
              onSaved: (value) {
                motorcycle!.purchasePrice =
                    (value != null && value.isNotEmpty) ? int.parse(value) : 0;
              },
            ),
            trailer: Text(
              '${NumberFormat.compactSimpleCurrency(name: _currencySymbol).currencySymbol}',
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
              initialValue:
                  motorcycle!.purchaseOdometer.toUnit(_distanceUnit).toString(),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(7),
              ],
              onSaved: (value) {
                motorcycle!.purchaseOdometer = Distance(
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
              initialDate: motorcycle!.purchaseDate ?? DateTime.now(),
              firstDate: DateTime.fromMillisecondsSinceEpoch(0),
              lastDate: DateTime(2099, 12, 31),
              dateFormat: _dateFormat,
              onSaved: (selectedDate) {
                motorcycle!.purchaseDate = selectedDate;
              },
            ),
          ),
        ],
      ),
      PropertyEditorCard(
        children: [
          motorcycle?.storage?.storage != null
              ? AttachmentSelector(
                  attachments: motorcycle!.attachments,
                  storage: motorcycle!.storage!.storage,
                )
              : Container(),
        ],
      ),
      RnrDivider,
      PropertyEditorCard(
        children: [_buildNoteSelector()],
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    if (motorcycle == null) {
      // Correctly create the motorcycle to track images/attachments
      // The motorcycle will be removed if the user leaves the page without adding it.
      motorcycle = Motorcycle(name: '');
      motorcycle!.storage = MotorcycleLocalStorage(motoId: motorcycle!.id);
      await motorcycle!.storage!.connect();
      _addMotorcycleToGarage(motorcycle!);

      _isNew = true;
    }

    if (_image == null) {
      _setImage();
      setState(() => {});
    }
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
        if (_isNew) {
          _removeMotorcycleFromGarage(motorcycle!);
        } else {
          await _saveMotorcycle();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isNew
                ? AppLocalizations.of(context)!.motorcycle_edit_page_title_add
                : AppLocalizations.of(context)!.motorcycle_edit_page_title_edit,
          ),
          actions: [
            _isNew
                ? Container(
                    width: 45,
                    child: IconButton(
                      iconSize: 30,
                      icon: Icon(Icons.add_circle_outline),
                      tooltip: AppLocalizations.of(context)!.appbar_add_button,
                      onPressed: () async {
                        if (await _saveMotorcycle()) {
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
                                          motorcycle!.name),
                                  onResult: (result) {
                                    Navigator.of(context).pop(result);
                                  },
                                );
                              },
                            );
                            if (result != null && result) {
                              _removeMotorcycleFromGarage(motorcycle!);

                              while (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
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
      notes: motorcycle!.notes,
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
          duration: Duration(milliseconds: 200),
          curve: Curves.linear);
    }
  }
}
