import 'package:flutter/material.dart';

class RnrColors {
  RnrColors._();
  static const blue = MaterialColor(/*0xff1b3e56*/ 0xff3d8dc2, {
    50: Color(0xffecf4f9),
    100: Color(0xffd8e8f3),
    200: Color(0xffb1d1e7),
    300: Color(0xff8bbada),
    400: Color(0xff64a4ce),
    500: Color(0xff3d8dc2),
    600: Color(0xff31719b),
    700: Color(0xff255474),
    800: Color(0xff1b3e56),
    900: Color(0xff0c1c27)
  });
  static const lightBlue = MaterialColor(0xff496883, {
    50: Color(0xffeff2f6),
    100: Color(0xffdee6ed),
    200: Color(0xffbecdda),
    300: Color(0xff9db4c8),
    400: Color(0xff7c9bb6),
    500: Color(0xff5c82a3),
    600: Color(0xff496883),
    700: Color(0xff374e62),
    800: Color(0xff253441),
    900: Color(0xff121a21)
  });

  static const darkBlue = Color(0xff00182d);
  static const lightOrange = Color(0xffffcd58);
  static const orange = Color(0xffe69c24);
  static const darkOrange = Color(0xffaf6e00);
  static const red = Color(0xffdc3723);
}

extension RnrThemes on ThemeData {
  ThemeData get RnrDarkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: RnrColors.blue,
      primaryColorBrightness: Brightness.dark,
      primaryColor: RnrColors.blue[800],
      primaryColorLight: RnrColors.blue,
      primaryColorDark: RnrColors.darkBlue,
      accentColor: RnrColors.orange,
      toggleableActiveColor: RnrColors.blue[700],
      disabledColor: Colors.white54,
      scaffoldBackgroundColor: RnrColors.blue[900],
      dialogBackgroundColor: RnrColors.darkBlue,
      appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(
            color: Colors.grey[200],
          ),
          textTheme: textTheme.apply(bodyColor: Colors.grey[200])),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(color: Colors.blueGrey[900]),
      tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(color: RnrColors.blue[100])),
      tabBarTheme: TabBarTheme(
        unselectedLabelColor: Colors.white70,
        labelColor: RnrColors.orange,
        labelPadding: EdgeInsets.only(bottom: 5),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: RnrColors.orange,
            width: 3,
          ),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: RnrColors.orange,
        selectionColor: RnrColors.blue[300],
        selectionHandleColor: RnrColors.orange,
      ),
    );
  }
}

const RnrDivider = Divider(
  thickness: 2,
  indent: 10,
  endIndent: 10,
  color: Colors.blueGrey,
);

extension CustomTextStyles on TextTheme {
  TextStyle get propEditorName {
    return headline6.copyWith(
      fontSize: 16,
      color: RnrColors.blue[600],
    );
  }

  TextStyle get propEditorValue {
    return headline6.copyWith(
      color: Colors.blueGrey[100],
      fontSize: 22,
    );
  }

  TextStyle get propEditorHint {
    return subtitle2.copyWith(
      color: Colors.blueGrey,
      fontSize: 16,
      fontStyle: FontStyle.italic,
    );
  }

  TextStyle get propEditorLargeValue {
    return propEditorValue.copyWith(
      fontSize: 16,
    );
  }

  TextStyle get propEditorHeader {
    return headline6.copyWith(color: RnrColors.orange, fontSize: 20);
  }

  TextStyle get taskCardName {
    return headline6.copyWith(color: Colors.blueGrey[100]);
  }

  TextStyle get taskCardDescription {
    return subtitle2.copyWith(color: Colors.blueGrey[400], fontSize: 16);
  }

  TextStyle get appbarButton {
    return headline6.copyWith(color: Colors.white);
  }

  TextStyle get labelName {
    return subtitle1.copyWith(color: Colors.white, fontSize: 18);
  }

  TextStyle get dialogHeader {
    return headline6.copyWith(color: Colors.blueGrey[100]);
  }

  TextStyle get selectorWidgetHeader {
    return propEditorName.copyWith(fontSize: 20, color: RnrColors.blue[600]);
  }

  TextStyle get dialogButton {
    return button.copyWith(color: Colors.blueGrey, fontSize: 16);
  }
}
