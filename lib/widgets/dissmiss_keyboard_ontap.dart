import 'package:flutter/widgets.dart';

/// Removes the current focus and to hide the keyboard when
/// the user taps on this widget.
class DismissKeyboardOnTap extends StatelessWidget {
  const DismissKeyboardOnTap({
    super.key,
    required this.child,
  });

  final Widget child;

  void _hideKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _hideKeyboard(context);
      },
      child: child,
    );
  }
}
