import 'package:flutter/material.dart';

/// 🌸 Thème clair (Kawaii Manga Light)
final ThemeData kawaiiLightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 244, 235, 239), // rose cerise
    primary: const Color.fromARGB(255, 72, 171, 229), // rose saturé
    secondary: const Color(0xFF6AD8E4), // turquoise clair
    surface: const Color(0xFFFFFAFD), // blanc rosé
  ),
  scaffoldBackgroundColor: const Color(0xFFFFF6FB),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.bold,
      color: Color(0xFF3A1C71), // violet foncé
      fontFamily: 'ComicNeue',
    ),
    titleLarge: TextStyle(
      fontSize: 50,
      fontWeight: FontWeight.w700,
      color:  Color(0xFFFF4FA8),
    ),
    bodyMedium: TextStyle(
      fontSize: 24,
      color: Colors.white,
    ),
    labelSmall: TextStyle(
      fontSize: 14,
      color: Color.fromARGB(255, 171, 205, 204),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(45, 212, 99, 173), // rose manga
    foregroundColor: Colors.black,
    elevation: 3,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  ),
  tabBarTheme : TabBarThemeData(
    indicatorColor: Colors.white,
    labelColor: Colors.white,
    overlayColor: WidgetStatePropertyAll(const Color.fromARGB(255, 70, 154, 165)),
    unselectedLabelColor: Colors.white,
  ),
  // 🚨 CORRECTION ICI : Utiliser CardTheme au lieu de CardThemeData
  cardTheme: CardThemeData(
    // elevation: 4,
    color:  Color.fromARGB(45, 212, 99, 173),
    //color: const Color(0xFFFFE6F3), // rose clair
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
  iconTheme: const IconThemeData(color: Color(0xFFFF4FA8), size: 26),
  // Note: ButtonThemeData est généralement obsolète pour Material 3,
  // mais je le garde si vous visez une compatibilité spécifique.
  buttonTheme: const ButtonThemeData(buttonColor: Color(0xFF6AD8E4)),
);

/// 🌙 Thème sombre (Kawaii Manga Dark)
final ThemeData kawaiiDarkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFFF4FA8),
    brightness: Brightness.dark,
    primary: const Color(0xFFFF80C0),
    secondary: const Color(0xFF6AD8E4),
    surface: const Color(0xFF2A2633),
  ),
  scaffoldBackgroundColor: const Color(0xFF1B1824),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.bold,
      color: Color(0xFFFFE6F3), // rose clair
      fontFamily: 'ComicNeue',
    ),
    titleLarge: TextStyle(
      fontSize: 50,
      fontWeight: FontWeight.w700,
      color: Color(0xFFFFCFEA),
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      color: Color(0xFFE2B7D3),
    ),
    labelSmall: TextStyle(
      fontSize: 14,
      color: Color(0xFFFFAACC),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF3C2F41),
    foregroundColor: Colors.white,
    elevation: 3,
    centerTitle: true,
  ),
  // 🚨 CORRECTION ICI : Utiliser CardTheme au lieu de CardThemeData
  cardTheme: CardThemeData(
    // elevation: 4,
    color: const Color(0xFF32283A),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
  iconTheme: const IconThemeData(color: Color(0xFFFF80C0), size: 26),
);
