import 'package:flutter/material.dart';
import 'package:moto_mecanico/themes.dart';

class PropertyEditorCard extends StatelessWidget {
  PropertyEditorCard({
    @required this.children,
    this.title,
    this.icons,
    this.isDialog,
  });

  final List<Widget> children;
  final String title;
  final List<Widget> icons;
  final bool isDialog;

  @override
  Widget build(BuildContext context) {
    final headerStyle = Theme.of(context).textTheme.propEditorHeader;

    final topRow = <Widget>[];
    if (title != null) {
      topRow.add(
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: headerStyle,
          ),
        ),
      );
    }
    if (icons?.isNotEmpty ?? false) {
      topRow.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: icons,
        ),
      );
    }

    final cardChildren = <Widget>[];
    if (topRow.isNotEmpty) {
      cardChildren.add(
        Stack(children: topRow),
      );
    }
    cardChildren.addAll(children);

    final padding = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: cardChildren,
      ),
    );

    if (isDialog != true) {
      return Container(
        child: padding,
      );
    } else {
      return padding;
    }
  }
}
