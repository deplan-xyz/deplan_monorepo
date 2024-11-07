import 'package:flutter/material.dart';

ThemeData getAppTheme() {
  return ThemeData(
    fontFamily: 'SF Pro Display',
    fontFamilyFallback: const ['Gilroy'],
    scaffoldBackgroundColor: COLOR_WHITE,
    hoverColor: Colors.transparent,
    colorScheme: const ColorScheme.light(
      primary: TEXT_MAIN,
      secondary: COLOR_WHITE,
      surfaceTint: Colors.transparent,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: 14,
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: TEXT_MAIN,
        foregroundColor: COLOR_WHITE,
        visualDensity: const VisualDensity(vertical: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(15),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          fontFamily: 'SF Pro Display',
        ),
        shadowColor: Colors.transparent,
      ),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      iconTheme: IconThemeData(color: TEXT_MAIN),
      foregroundColor: TEXT_MAIN,
      backgroundColor: COLOR_WHITE,
      elevation: 0,
      titleSpacing: 20,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontFamily: 'SF Pro Display',
        fontSize: 18,
        color: TEXT_MAIN,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: TEXT_MAIN,
        fontFamily: 'SF Pro Display',
        height: 1.2,
      ),
      headlineMedium: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: TEXT_MAIN,
      ),
      headlineSmall: TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.bold,
        color: TEXT_MAIN,
      ),
      displayLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w300,
        color: TEXT_MAIN,
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w300,
        color: TEXT_MAIN,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        color: TEXT_MAIN,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: TEXT_MAIN,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        color: TEXT_MAIN,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        color: TEXT_MAIN,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(
        color: COLOR_GRAY2,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: TextStyle(
        color: COLOR_BLACK,
        fontWeight: FontWeight.w400,
      ),
      prefixStyle: TextStyle(
        color: COLOR_BLACK,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      helperStyle: TextStyle(color: COLOR_GRAY),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: COLOR_LIGHT_GRAY,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(width: 1),
      ),
      contentPadding: EdgeInsets.only(bottom: 10),
      isDense: true,
    ),
    //Changing the global dialog border
    dialogTheme: const DialogTheme(
      backgroundColor: Colors.amber,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
        side: BorderSide(color: Colors.red),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xffE9E9EE),
    ),
  );
}

const Color COLOR_WHITE = Color(0xffffffff);
const Color COLOR_BLACK = Color(0xff000000);
const Color COLOR_LIGHT_GRAY = Color(0xffEEF0F3);
const Color COLOR_LIGHT_GRAY2 = Color(0xffC4C4C4);
const Color COLOR_LIGHT_GRAY3 = Color(0xffe2e2e8);
const Color COLOR_DISABLED_GRAY3 = Color(0xff87899B);
const Color COLOR_GRAY = Color(0xff87899B);
const Color COLOR_GRAY2 = Color(0xffB8BFCA);

const Color APP_BODY_BG = COLOR_WHITE;
const Color BTN_GRAY_GB = COLOR_LIGHT_GRAY3;

const Color TEXT_MAIN = Color(0xff11243E);
const Color TEXT_SECONDARY = Color(0xff6B6B6B);
const Color TEXT_SECONDARY_ACCENT = Color(0xff88919E);
const Color MAIN_COLOR = Color(0xffAA32E3);
const Color MAIN_COLOR_2 = Color.fromARGB(255, 164, 115, 187);
