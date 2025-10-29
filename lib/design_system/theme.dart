import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'colors.dart';
import 'typography.dart';
import 'spacing.dart';

class GrocliTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: GrocliColors.primaryGreen,
        onPrimary: Colors.white,
        primaryContainer: GrocliColors.primaryGreenLight,
        secondary: GrocliColors.secondaryOrange,
        onSecondary: Colors.white,
        secondaryContainer: GrocliColors.secondaryOrangeLight,
        tertiary: GrocliColors.accentBlue,
        error: GrocliColors.error,
        surface: GrocliColors.surfaceLight,
        onSurface: GrocliColors.textPrimary,
      ),
      scaffoldBackgroundColor: GrocliColors.backgroundLight,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: GrocliColors.primaryGreen,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: GrocliSpacing.elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GrocliSpacing.borderRadiusMd),
        ),
        color: GrocliColors.surfaceLight,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: GrocliSpacing.elevationMedium,
        backgroundColor: GrocliColors.primaryGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GrocliSpacing.borderRadiusXl),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: GrocliSpacing.elevationLow,
          backgroundColor: GrocliColors.primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, GrocliSpacing.buttonHeightMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GrocliSpacing.borderRadiusMd),
          ),
          textStyle: GrocliTypography.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: GrocliColors.primaryGreen,
          textStyle: GrocliTypography.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GrocliColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: GrocliSpacing.md,
          vertical: GrocliSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GrocliSpacing.borderRadiusMd),
          borderSide: BorderSide(color: GrocliColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GrocliSpacing.borderRadiusMd),
          borderSide: BorderSide(color: GrocliColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GrocliSpacing.borderRadiusMd),
          borderSide: BorderSide(color: GrocliColors.primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GrocliSpacing.borderRadiusMd),
          borderSide: BorderSide(color: GrocliColors.error),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GrocliColors.checkboxChecked;
          }
          return GrocliColors.checkboxUnchecked;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GrocliSpacing.borderRadiusSm),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: GrocliColors.divider,
        thickness: 1,
      ),
      textTheme: const TextTheme(
        displayLarge: GrocliTypography.h1,
        displayMedium: GrocliTypography.h2,
        displaySmall: GrocliTypography.h3,
        headlineMedium: GrocliTypography.h4,
        headlineSmall: GrocliTypography.h5,
        titleLarge: GrocliTypography.subtitle1,
        titleMedium: GrocliTypography.subtitle2,
        bodyLarge: GrocliTypography.body1,
        bodyMedium: GrocliTypography.body2,
        labelLarge: GrocliTypography.button,
        bodySmall: GrocliTypography.caption,
        labelSmall: GrocliTypography.overline,
      ).apply(
        bodyColor: GrocliColors.textPrimary,
        displayColor: GrocliColors.textPrimary,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: GrocliColors.primaryGreenLight,
        onPrimary: Colors.black,
        primaryContainer: GrocliColors.primaryGreenDark,
        secondary: GrocliColors.secondaryOrangeLight,
        onSecondary: Colors.black,
        secondaryContainer: GrocliColors.secondaryOrangeDark,
        tertiary: GrocliColors.accentBlueLight,
        error: GrocliColors.error,
        surface: GrocliColors.surfaceDark,
        onSurface: GrocliColors.textPrimaryDark,
      ),
      scaffoldBackgroundColor: GrocliColors.backgroundDark,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: GrocliColors.surfaceDark,
        foregroundColor: GrocliColors.textPrimaryDark,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: GrocliColors.textPrimaryDark,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: GrocliSpacing.elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GrocliSpacing.borderRadiusMd),
        ),
        color: GrocliColors.surfaceDark,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: GrocliSpacing.elevationMedium,
        backgroundColor: GrocliColors.primaryGreenLight,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GrocliSpacing.borderRadiusXl),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: GrocliSpacing.elevationLow,
          backgroundColor: GrocliColors.primaryGreenLight,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, GrocliSpacing.buttonHeightMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GrocliSpacing.borderRadiusMd),
          ),
          textStyle: GrocliTypography.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: GrocliColors.primaryGreenLight,
          textStyle: GrocliTypography.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GrocliColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: GrocliSpacing.md,
          vertical: GrocliSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GrocliSpacing.borderRadiusMd),
          borderSide: BorderSide(color: GrocliColors.dividerDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GrocliSpacing.borderRadiusMd),
          borderSide: BorderSide(color: GrocliColors.dividerDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GrocliSpacing.borderRadiusMd),
          borderSide: BorderSide(color: GrocliColors.primaryGreenLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GrocliSpacing.borderRadiusMd),
          borderSide: BorderSide(color: GrocliColors.error),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GrocliColors.primaryGreenLight;
          }
          return GrocliColors.checkboxUnchecked;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GrocliSpacing.borderRadiusSm),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: GrocliColors.dividerDark,
        thickness: 1,
      ),
      textTheme: const TextTheme(
        displayLarge: GrocliTypography.h1,
        displayMedium: GrocliTypography.h2,
        displaySmall: GrocliTypography.h3,
        headlineMedium: GrocliTypography.h4,
        headlineSmall: GrocliTypography.h5,
        titleLarge: GrocliTypography.subtitle1,
        titleMedium: GrocliTypography.subtitle2,
        bodyLarge: GrocliTypography.body1,
        bodyMedium: GrocliTypography.body2,
        labelLarge: GrocliTypography.button,
        bodySmall: GrocliTypography.caption,
        labelSmall: GrocliTypography.overline,
      ).apply(
        bodyColor: GrocliColors.textPrimaryDark,
        displayColor: GrocliColors.textPrimaryDark,
      ),
    );
  }

  static CupertinoThemeData cupertinoTheme() {
    return const CupertinoThemeData(
      primaryColor: GrocliColors.primaryGreen,
      scaffoldBackgroundColor: GrocliColors.backgroundLight,
      barBackgroundColor: GrocliColors.surfaceLight,
      textTheme: CupertinoTextThemeData(
        primaryColor: GrocliColors.primaryGreen,
        textStyle: GrocliTypography.body1,
      ),
    );
  }
}
