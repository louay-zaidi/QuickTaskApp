import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  primaryColor: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  brightness: Brightness.light,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(color: Color(0xFF1a434e)),
  ),
  drawerTheme: DrawerThemeData(
    backgroundColor: Colors.white,
    scrimColor: Colors.black.withOpacity(0.5),
    elevation: 16.0,
  ),
);

final darkTheme = ThemeData(
  primaryColor: Colors.black,
  scaffoldBackgroundColor: Color(0xFF1a434e),
  brightness: Brightness.dark,
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF1a434e),
    iconTheme: IconThemeData(color: Color(0xFF325863)),
  ),
  drawerTheme: DrawerThemeData(
    backgroundColor: Color(0xFF1a434e),
    scrimColor: Colors.black.withOpacity(0.7),
    elevation: 16.0,
  ),
);
