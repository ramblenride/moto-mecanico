import 'package:flutter/material.dart';

class RnrColors {
  RnrColors._();

  static const blue50 = Color(0xffecf4f9);
  static const blue100 = Color(0xffd8e8f3);
  static const blue200 = Color(0xffb1d1e7);
  static const blue300 = Color(0xff8bbada);
  static const blue400 = Color(0xff64a4ce);
  static const blue500 = Color(0xff3d8dc2);
  static const blue600 = Color(0xff31719b);
  static const blue700 = Color(0xff255474);
  static const blue800 = Color(0xff1b3e56);
  static const blue900 = Color(0xff0c1c27);

  static const lightBlue50 = Color(0xffeff2f6);
  static const lightBlue100 = Color(0xffdee6ed);
  static const lightBlue200 = Color(0xffbecdda);
  static const lightBlue300 = Color(0xff9db4c8);
  static const lightBlue400 = Color(0xff7c9bb6);
  static const lightBlue500 = Color(0xff5c82a3);
  static const lightBlue600 = Color(0xff496883);
  static const lightBlue700 = Color(0xff374e62);
  static const lightBlue800 = Color(0xff253441);
  static const lightBlue900 = Color(0xff121a21);

  static const lightBlue = lightBlue700;
  static const mediumBlue = blue500;
  static const darkBlue = Color(0xff00182d);

  static const lightOrange = Color(0xffffcd58);
  static const mediumOrange = Color(0xffe69c24);
  static const darkOrange = Color(0xffaf6e00);

  static const lightRed = Color(0xffffb4ab);
  static const mediumRed = Color(0xffdc3723);
  static const darkRed = Color(0xff4a0e0a);

  static const lightGray = Color(0xffe3e2e6);
  static const mediumGray = Color(0xffc4c7c5);
  static const outlineGray = Color(0xff8e918f);
  static const darkGray = Color(0xff44474e);
}

extension RnrThemes on ThemeData {
  static ColorScheme get _rnrDarkColorScheme {
    return const ColorScheme.dark(
      // Primary colors
      primary: RnrColors.blue500,
      onPrimary: Colors.white,
      primaryContainer: RnrColors.blue800,
      onPrimaryContainer: RnrColors.blue100,

      // Secondary colors (orange accent)
      secondary: RnrColors.mediumOrange,
      onSecondary: Colors.black,
      secondaryContainer: RnrColors.darkOrange,
      onSecondaryContainer: RnrColors.lightOrange,

      // Tertiary colors (light blue)
      tertiary: RnrColors.lightBlue600,
      onTertiary: Colors.white,
      tertiaryContainer: RnrColors.lightBlue800,
      onTertiaryContainer: RnrColors.lightBlue100,

      // Error colors
      error: RnrColors.mediumRed,
      onError: Colors.white,
      errorContainer: RnrColors.darkRed,
      onErrorContainer: RnrColors.lightRed,

      // Surface colors
      surface: RnrColors.blue900,
      onSurface: RnrColors.lightGray,
      surfaceVariant: RnrColors.darkBlue,
      onSurfaceVariant: RnrColors.mediumGray,

      // Background
      background: RnrColors.blue900,
      onBackground: RnrColors.lightGray,

      // Outline
      outline: RnrColors.outlineGray,
      outlineVariant: RnrColors.darkGray,

      // Other
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: RnrColors.lightGray,
      onInverseSurface: RnrColors.blue900,
      inversePrimary: RnrColors.blue500,
    );
  }

  ThemeData get rnrDarkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _rnrDarkColorScheme,
      appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(
          color: Colors.grey[200],
        ),
        backgroundColor: _rnrDarkColorScheme.primaryContainer,
        foregroundColor: _rnrDarkColorScheme.onPrimaryContainer,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: const DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: _rnrDarkColorScheme.surfaceVariant,
      ),
      tooltipTheme: const TooltipThemeData(
        decoration: BoxDecoration(color: RnrColors.blue100),
      ),
      tabBarTheme: TabBarTheme(
        unselectedLabelColor: Colors.white70,
        labelColor: _rnrDarkColorScheme.secondary,
        labelPadding: const EdgeInsets.only(bottom: 5),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: _rnrDarkColorScheme.secondary,
            width: 3,
          ),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: _rnrDarkColorScheme.secondary,
        selectionColor: _rnrDarkColorScheme.primary.withOpacity(0.3),
        selectionHandleColor: _rnrDarkColorScheme.secondary,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.orange, shape: CircleBorder()),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return null;
          }
          if (states.contains(MaterialState.selected)) {
            return _rnrDarkColorScheme.primary;
          }
          return null;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return null;
          }
          if (states.contains(MaterialState.selected)) {
            return _rnrDarkColorScheme.primary;
          }
          return null;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return null;
          }
          if (states.contains(MaterialState.selected)) {
            return _rnrDarkColorScheme.primary;
          }
          return null;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return null;
          }
          if (states.contains(MaterialState.selected)) {
            return _rnrDarkColorScheme.primary.withOpacity(0.5);
          }
          return null;
        }),
      ),
    );
  }
}

const rnrDivider = Divider(
  thickness: 2,
  indent: 10,
  endIndent: 10,
  color: Colors.blueGrey,
);

extension CustomTextStyles on TextTheme {
  TextStyle get propEditorName {
    return titleLarge!.copyWith(
      fontSize: 16,
      color: RnrColors.blue600,
    );
  }

  TextStyle get propEditorValue {
    return titleLarge!.copyWith(
      color: Colors.blueGrey[100],
      fontSize: 22,
    );
  }

  TextStyle get propEditorHint {
    return titleSmall!.copyWith(
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
    return titleLarge!.copyWith(color: RnrColors.mediumOrange, fontSize: 20);
  }

  TextStyle get taskCardName {
    return titleLarge!.copyWith(color: Colors.blueGrey[100]);
  }

  TextStyle get taskCardDescription {
    return titleSmall!.copyWith(color: Colors.blueGrey[400], fontSize: 16);
  }

  TextStyle get appbarButton {
    return titleLarge!.copyWith(color: Colors.white);
  }

  TextStyle get labelName {
    return titleMedium!.copyWith(color: Colors.white, fontSize: 18);
  }

  TextStyle get dialogHeader {
    return titleLarge!.copyWith(color: Colors.blueGrey[100]);
  }

  TextStyle get selectorWidgetHeader {
    return propEditorName.copyWith(fontSize: 20, color: RnrColors.blue600);
  }

  TextStyle get dialogButton {
    return labelLarge!.copyWith(color: Colors.blueGrey, fontSize: 16);
  }
}
