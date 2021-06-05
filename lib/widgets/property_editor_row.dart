import 'package:flutter/material.dart';
import 'package:moto_mecanico/themes.dart';

// An expanded row that contains the name of a property on the left, and
// some input field on the right. The optional trailer is added to the right
// of the inputField.
class PropertyEditorRow extends StatelessWidget {
  PropertyEditorRow({
    @required this.name,
    @required this.inputField,
    this.trailer,
  })  : assert(name != null),
        assert(inputField != null);

  static const WIDTH_NARROW_LAYOUT = 360;
  final String name;
  final Widget inputField;
  final Widget trailer;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final children = <Widget>[
      Flexible(
        child: inputField,
      ),
    ];

    if (trailer != null) {
      children.add(const SizedBox(width: 5));
      children.add(trailer);
    }

    if (width < WIDTH_NARROW_LAYOUT) {
      return _buildNarrowLayout(context, children);
    }

    return _buildLayout(context, children);
  }

  Widget _buildLayout(BuildContext context, List<Widget> inputChildren) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(height: 45), // Force a uniform height
        Expanded(
          flex: 40,
          child: Text(
            name,
            style: Theme.of(context).textTheme.propEditorName,
          ),
        ),

        Expanded(
          flex: 60,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: inputChildren,
          ),
        ),
      ],
    );
  }

  /// On narrow screens we use two rows.
  Widget _buildNarrowLayout(BuildContext context, List<Widget> inputChildren) {
    return Wrap(children: [
      Text(
        name,
        style: Theme.of(context).textTheme.propEditorName,
      ),
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: inputChildren,
        ),
      ),
      //  ),
    ]);
  }
}
