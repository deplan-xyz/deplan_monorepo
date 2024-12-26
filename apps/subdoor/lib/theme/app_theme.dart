import 'package:flutter/material.dart';

const Color primaryColor = Color(0xff11243E);
const Color errorColor = Color(0xffD02626);
const Color successColor = Color(0xff008000);
ThemeData getAppTheme() {
  return ThemeData(
    primaryColor: primaryColor,
    appBarTheme: const AppBarTheme(
      scrolledUnderElevation: 0.0,
      backgroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontFamily: 'sfprodmedium',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'sfprod',
        fontSize: 16,
        color: primaryColor,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        visualDensity: const VisualDensity(vertical: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontFamily: 'sfprodbold',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
        backgroundColor: primaryColor,
        foregroundColor: const Color(0xffFFFFFF),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      elevation: 0,
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xff38536B),
      unselectedItemColor: Color(0xffADB3BC),
      selectedLabelStyle: TextStyle(
        fontFamily: 'sfprod',
        fontSize: 12,
        color: Color(0xff38536B),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
    ),
  );
}
