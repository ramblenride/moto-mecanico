import 'package:flutter/material.dart';
import 'package:moto_mecanico/themes.dart';

class PopupButtonsItem<T> {
  const PopupButtonsItem({
    required this.value,
    required this.icon,
    this.selectedIcon,
    this.tooltip = '',
    this.enabled = true,
  });

  /// The value that will be returned if this entry is selected.
  final T value;

  /// Whether the user is permitted to select this item.
  /// Defaults to true. If this is false, then the item will not react to
  /// touches.
  final bool enabled;

  /// The icon displayed for this entry.
  final Widget icon;

  /// The optional icon displayed for this entry when selected.
  /// If null, the icon will be used.
  final Widget? selectedIcon;

  /// String to display over the item on long press.
  final String tooltip;
}

/// Signature for the callback invoked when a button item is selected. The
/// argument is the value of the [PopupButtonsItem] that caused its button array
/// to be dismissed.
///
/// Used by [PopupButtonsButton.onSelected].
typedef PopupButtonsItemSelected<T> = void Function(T value);

class PopupButtonsButton<T> extends StatefulWidget {
  /// Creates a button that shows a popup menu.
  ///
  /// The [itemBuilder] argument must not be null.
  PopupButtonsButton({
    Key? key,
    required this.items,
    required this.initialValue,
    required this.onSelected,
    this.tooltip = '',
    this.elevation = 8,
    this.enabled = true,
    this.size = 42,
    this.color,
    this.borderColor,
    this.selectedColor,
  })  : assert(items.isNotEmpty),
        super(key: key);

  /// The list of items to diaplay
  final List<PopupButtonsItem<T>> items;

  /// The initially selected item.
  final T initialValue;

  /// Called when the user selects a value from the popup buttons created by this button.
  final PopupButtonsItemSelected<T> onSelected;

  /// Text that describes the action that will occur when the button is pressed.
  ///
  /// This text is displayed when the user long-presses on the button and is
  /// used for accessibility.
  final String tooltip;

  /// The z-coordinate at which to place the buttons when open. This controls the
  /// size of the shadow below the buttons.
  ///
  /// Defaults to 8.
  final double elevation;

  /// Whether this button is interactive.
  ///
  /// Must be non-null, defaults to `true`
  ///
  /// If `true` the button will respond to presses by displaying the buttons.
  ///
  /// If `false`, the button is styled with the disabled color from the
  /// current [Theme] and will not respond to presses or show the popup
  /// menu and [onSelected], [onCanceled] and [itemBuilder] will not be called.
  ///
  /// This can be useful in situations where the app needs to show the button,
  /// but doesn't currently have anything to show in the menu.
  final bool enabled;

  /// The size of the button entries.
  final double size;

  /// If provided, the background color used for the buttons.
  /// If this property is null, then [RnrColors.darkBlue] is used.
  final Color? color;

  /// If provided, the border color used around the buttons.
  final Color? borderColor;

  /// If provided, the color used for the selected button.
  /// If this property is null, then RnrColors.orange is used.
  final Color? selectedColor;

  @override
  _PopupButtonsButtonState<T> createState() => _PopupButtonsButtonState<T>();
}

class _PopupButtonsButtonState<T> extends State<PopupButtonsButton<T>>
    with SingleTickerProviderStateMixin {
  bool _isOpened = false;
  late final AnimationController _animationController;
  late final Animation<double> _animateIcon;
  late final Animation<double> _translateAnimation;
  late final T _selectedValue;
  final Curve _curve = Curves.easeOut;
  final Duration _animationDuration = Duration(milliseconds: 250);

  @override
  void initState() {
    _selectedValue = widget.initialValue;
    _animationController =
        AnimationController(duration: _animationDuration, vsync: this)
          ..addListener(
            () {
              setState(() {});
            },
          );
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _translateAnimation = Tween<double>(
      begin: 0,
      end: widget.size * 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void animate() {
    if (!_isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    _isOpened = !_isOpened;
  }

  Widget _createButton(PopupButtonsItem<T> item) {
    return AnimatedOpacity(
      opacity: _animateIcon.value,
      duration: _animationDuration,
      child: Container(
        decoration: BoxDecoration(
          //image: DecorationImage(
          //  image: AssetImage(IMG_TASK_SMALL),
          //  fit: BoxFit.fill,
          //),
          color: widget.color ?? RnrColors.darkBlue,
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.borderColor ?? RnrColors.blue[600]!,
            width: 2,
          ),
        ),
        width: widget.size,
        height: widget.size,
        child: IconButton(
          padding: EdgeInsets.all(2),
          constraints: BoxConstraints.expand(),
          onPressed: () {
            setState(() {
              widget.onSelected(item.value);
              _selectedValue = item.value;
              animate();
            });
          },
          tooltip: item.tooltip,
          icon: item.icon,
        ),
        //  ),
      ),
    );
  }

  Widget _createSelected(T value) {
    PopupButtonsItem item =
        widget.items.firstWhere((element) => element.value == value);

    return Container(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      width: widget.size,
      height: widget.size,
      child: IconButton(
        padding: EdgeInsets.all(2),
        constraints: BoxConstraints.expand(),
        onPressed: widget.enabled ? animate : () {},
        tooltip: widget.tooltip,
        icon: item.selectedIcon ?? item.icon,
      ),
    );
  }

  List<Widget> _buildChildren() {
    final children = <Widget>[];
    var num = 1;
    for (final item in widget.items) {
      if (item.value != _selectedValue) {
        children.add(Transform(
            transform: Matrix4.translationValues(
              _translateAnimation.value * -1 * num * 1.1,
              0.0,
              widget.elevation,
            ),
            child: _createButton(item)));
        num = num + 1;
      }
    }

    return children;
  }

  @override
  Widget build(BuildContext context) {
    // The container is needed because
    // the stack doesn't send click events in the overflow region
    return Container(
      width: widget.size * widget.items.length * 1.11,
      height: widget.size,
      child: Stack(
        alignment: Alignment.centerRight,
        children: <Widget>[
          ..._buildChildren(),
          _createSelected(_selectedValue),
        ],
      ),
    );
  }
}
