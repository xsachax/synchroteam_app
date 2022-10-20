import 'package:flutter/material.dart';

const MaterialColor companyOrange =
    const MaterialColor(0xFFF68F24, const <int, Color>{});

const MaterialColor companyGrey =
    const MaterialColor(0xFF696465, const <int, Color>{});

const MaterialColor companyLightGrey =
    const MaterialColor(0xFFE0E0E0, const <int, Color>{});

const MaterialColor MyWorkContainer =
    const MaterialColor(0xFFE0E0E0, const <int, Color>{});

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
      scaffoldBackgroundColor: companyLightGrey,
      appBarTheme: AppBarTheme(
        color: Colors.white.withOpacity(0.5),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      cardTheme: CardTheme(
          color: Colors.white,
          elevation: 3.0,
          margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 5.0)),
      primaryTextTheme: TextTheme(headline6: TextStyle(color: Colors.black)),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.grey[800],
          unselectedItemColor: Colors.grey[500]));

/*
  static final ThemeData darkTheme = ThemeData(
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: AppBarTheme(
        color: Colors.black,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
          color: Colors.black,
          elevation: 3.0,
          margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 5.0)),
      textTheme: TextTheme(
          bodyText2: TextStyle(color: Colors.white)
        ),
        
      primaryTextTheme: TextTheme(headline6: TextStyle(color: Colors.white)));
}
*/

  static final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.grey[500],
          unselectedItemColor: Colors.grey[800]));
}
