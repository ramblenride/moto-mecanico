import 'package:flutter/widgets.dart';
import 'package:moto_mecanico/configuration.dart';

class ConfigWidget extends InheritedWidget {
  const ConfigWidget({
    super.key,
    required this.config,
    required super.child,
  });

  final Configuration config;

  static Configuration of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ConfigWidget>()!.config;
  }

  @override
  bool updateShouldNotify(ConfigWidget oldWidget) => true;
}
