import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.teal,
      colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
          secondary: Colors.amber,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          color: Colors.amber,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    ),
    home: HomePage(),
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.04;
    return Scaffold(//widget de materialApp qui gère les principales structures d'une page
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("press button", style: TextStyle(fontSize: fontSize)),
            FractionallySizedBox(
              widthFactor: 0.3,
              child: ElevatedButton(
                  onPressed:(){print("Button pressed");},
                  child: Text("button", style: TextStyle(fontSize: fontSize * 0.8)),
              ),
            )
          ]
        )
      ),
    );
  }
}
