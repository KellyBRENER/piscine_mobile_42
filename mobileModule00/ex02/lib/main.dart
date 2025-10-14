import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(//widget à la base de l'arbre des widget
      title: 'Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget  build(BuildContext context) {
    return Scaffold(//va accueillir les 2 widgets appBar et Calculator
      appBar: MyAppBar(),
      body: MyCalculator(),
      );
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});
  @override
  Widget  build(BuildContext context) {
    return AppBar(
      title: const  Text("Calculator"),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class MyCalculator extends StatefulWidget {
  const MyCalculator({super.key});
  @override
  State<MyCalculator> createState() => _MyCalculatorState();
}

class _MyCalculatorState extends State<MyCalculator> {
  String _display = '0';
  void _handleButtonPress(String textButton) {
    setState(() {
      if (textButton == '0') {
        _display = '0';
      } else {
        _display = '0';
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_display),
        ElevatedButton(onPressed: () => _handleButtonPress('1'),
        child: Text('1')),
      ],
    );
  }
}
