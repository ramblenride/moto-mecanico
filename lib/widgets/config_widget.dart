import 'package:flutter/widgets.dart';
import 'package:moto_mecanico/configuration.dart';

class ConfigWidget extends InheritedWidget {
  const ConfigWidget({
    Key? key,
    required this.config,
    required Widget child,
  }) : super(key: key, child: child);

  final Configuration config;

  static Configuration of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ConfigWidget>()!.config;
  }

  @override
  bool updateShouldNotify(ConfigWidget old) => false;
}
