import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(//widget de materialApp qui gère les principales structures d'une page
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("press button",),
            ElevatedButton(onPressed:(){print("Button pressed");}, child: Text("button"))
          ]
        )
      ),
    );
  }
}
