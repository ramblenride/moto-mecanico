import 'package:flutter/material.dart';
import 'package:moto_mecanico/models/motorcycle.dart';
import 'package:moto_mecanico/motorcycle_utils.dart';
import 'package:moto_mecanico/themes.dart';
import 'package:moto_mecanico/widgets/alarms_indicator.dart';
import 'package:moto_mecanico/widgets/config_widget.dart';
import 'package:provider/provider.dart';

class MotorcycleCard extends StatelessWidget {
  const MotorcycleCard({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const image_height = 200.0;
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headline5.copyWith(color: Colors.white);
    final descriptionStyle = theme.textTheme.subtitle1;

    final distanceUnit = ConfigWidget.of(context).distanceUnit;

    return Consumer<Motorcycle>(
      builder: (context, motorcycle, child) => Card(
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(6.0),
            topRight: Radius.circular(6.0),
            bottomLeft: Radius.circular(4.0),
            bottomRight: Radius.circular(4.0),
          ),
        ),
        color: RnrColors.blue[800],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Photo and name.
            SizedBox(
              height: image_height,
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: FutureBuilder(
                        future: getMotoPicture(motorcycle),
                        builder: (BuildContext context,
                            AsyncSnapshot<ImageProvider> imageProvider) {
                          if (imageProvider.hasData) {
                            return Ink.image(
                              image: imageProvider.data,
                              fit: BoxFit.cover,
                            );
                          } else {
                            return Container();
                          }
                        }),
                  ),
                  Positioned(
                    bottom: 16.0,
                    left: 16.0,
                    right: 16.0,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        motorcycle.name,
                        style: titleStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Details and alarms
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 4.0),
              child: DefaultTextStyle(
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: descriptionStyle,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            motorcycle.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            motorcycle.odometer
                                .toUnit(distanceUnit)
                                .toFullString(),
                            style: descriptionStyle.copyWith(
                                color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                    AlarmsIndicator(motorcycle: motorcycle),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
