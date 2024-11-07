import 'package:flutter/material.dart';

class Themes {
  static const Color primaryColor = Color(0xff1AB7D2);
  static const Color secondaryColor = Color(0xff3BC4F7);

  ThemeData get light => ThemeData(
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Mulish', fontSize: 16),
          displayMedium: TextStyle(fontFamily: 'Mulish', fontSize: 16),
          displaySmall: TextStyle(fontFamily: 'Mulish', fontSize: 16),
          headlineLarge: TextStyle(fontFamily: 'Mulish', fontSize: 16),
          headlineMedium: TextStyle(fontFamily: 'Mulish', fontSize: 16),
          headlineSmall: TextStyle(fontFamily: 'Mulish', fontSize: 16),
          titleLarge: TextStyle(fontFamily: 'Mulish', fontSize: 16),
          titleMedium: TextStyle(fontFamily: 'Mulish', fontSize: 16),
          titleSmall: TextStyle(fontFamily: 'Mulish', fontSize: 16),
          bodyLarge: TextStyle(fontFamily: 'Mulish', fontSize: 16),
          bodyMedium: TextStyle(fontFamily: 'Mulish', fontSize: 16),
          bodySmall: TextStyle(fontFamily: 'Mulish', fontSize: 16),
          labelLarge: TextStyle(fontFamily: 'Mulish', fontSize: 16),
        ),
        colorScheme: const ColorScheme(
            brightness: Brightness.light,
            surfaceTint: Color(0xffffffff),
            primary: primaryColor,
            onPrimary: Color(0xFFffffff),
            secondary: primaryColor,
            onSecondary: Color(0xFFFFFFFF),
            error: Color(0xFFBA1A1A),
            onError: Color(0xFFFFFFFF),
            surface: Color(0xffffffff),
            onSurface: Color(0xFF1C1B1F)),
        brightness: Brightness.light,
        dividerTheme: const DividerThemeData(color: Color.fromARGB(255, 202, 202, 202)),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: primaryColor,
        ),
        inputDecorationTheme: InputDecorationTheme(
          errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xffcc0000), width: 1), borderRadius: BorderRadius.circular(10.0)),
          enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xffD3D7DB), width: 1), borderRadius: BorderRadius.circular(10.0)),
          focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: primaryColor, width: 1), borderRadius: BorderRadius.circular(10.0)),
          focusedErrorBorder: OutlineInputBorder(borderSide: const BorderSide(color: primaryColor, width: 1), borderRadius: BorderRadius.circular(10.0)),
          filled: true,
          fillColor: const Color(0x00ffffff),
        ),
      );

  ThemeData get dark => ThemeData(
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Mulish', fontSize: 16),
          displayMedium: TextStyle(fontFamily: 'Mulish', fontSize: 16),
          displaySmall: TextStyle(fontFamily: 'Mulish', fontSize: 16),
          headlineLarge: TextStyle(fontFamily: 'Mulish', fontSize: 16),
          headlineMedium: TextStyle(fontFamily: 'Mulish', fontSize: 16),
          headlineSmall: TextStyle(fontFamily: 'Mulish', fontSize: 16),
          titleLarge: TextStyle(fontFamily: 'Mulish', fontSize: 16),
          titleMedium: TextStyle(fontFamily: 'Mulish', fontSize: 16),
          titleSmall: TextStyle(fontFamily: 'Mulish', fontSize: 16),
          bodyLarge: TextStyle(fontFamily: 'Mulish', fontSize: 16),
          bodyMedium: TextStyle(fontFamily: 'Mulish', fontSize: 16),
          bodySmall: TextStyle(fontFamily: 'Mulish', fontSize: 16),
          labelLarge: TextStyle(fontFamily: 'Mulish', fontSize: 16),
        ),
        colorScheme: const ColorScheme(
            brightness: Brightness.dark,
            surfaceTint: Color(0xff2C282E),
            primary: primaryColor,
            onPrimary: Color(0xFF000000),
            secondary: primaryColor,
            onSecondary: Color(0xFFFFFFFF),
            error: Color(0xffECB4B1),
            onError: Color(0xFFFFFFFF),
            surface: Color(0xFF1C1B1F),
            onSurface: Color(0xFFFFFBFE)),
        brightness: Brightness.dark,
        cardTheme: CardTheme(
          color: const Color(0xff18161A),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(),
        ),
        switchTheme: const SwitchThemeData(thumbColor: WidgetStatePropertyAll(Color(0xffD3D7DB))),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xffAF7548),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: primaryColor),
        scaffoldBackgroundColor: const Color(0xFF28282E),
        textSelectionTheme: const TextSelectionThemeData(cursorColor: primaryColor),
        inputDecorationTheme: InputDecorationTheme(
            errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xffECB4B1), width: 1), borderRadius: BorderRadius.circular(10.0)),
            enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xffD3D7DB), width: 1), borderRadius: BorderRadius.circular(10.0)),
            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: primaryColor, width: 1), borderRadius: BorderRadius.circular(10.0)),
            focusedErrorBorder: OutlineInputBorder(borderSide: const BorderSide(color: primaryColor, width: 1), borderRadius: BorderRadius.circular(10.0)),
            filled: true,
            fillColor: const Color(0xFF28282E)),
      );
}
