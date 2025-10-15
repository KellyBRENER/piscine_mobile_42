import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  Widget build(BuildContext context) {
    return SafeArea(

	  child: Scaffold(
		  appBar: MyAppBar(),
		  body: const MyCalculator(),
			),
	);
		}
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("Calculator"),
      centerTitle: true,
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
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
  String _result = '0';
  String _calculation = '0';
  void _handleButtonPress(String textButton) {
    setState(() {
      _result = '0';
      _calculation = '0';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: _DisplaySection(
            calculationText: _calculation,
            resultText: _result,
          ),
        ),
        Expanded(flex: 1, child: _ButtonLayout(onTapped: _handleButtonPress)),
      ],
    );
  }
}

class _DisplaySection extends StatelessWidget {
  final String calculationText;
  final String resultText;
  const _DisplaySection({
    required this.calculationText,
    required this.resultText});

  @override
  Widget build(BuildContext context) {
    return Container(
      //widget pour habillage
      color: Colors.grey[300],
      alignment: Alignment
          .centerRight, //aligne le contenu en bas a droite du conteneur
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment:
            CrossAxisAlignment.end, //aligne les enfants à droite
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Text(
                calculationText,
                style: const TextStyle(fontSize: 24, color: Colors.grey),
                maxLines: null,
                overflow: TextOverflow.fade,
                textAlign: TextAlign.right,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            resultText,
            style: const TextStyle(fontSize: 48, color: Colors.blueGrey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ButtonLayout extends StatelessWidget {
  //déclare une variable de type fonction avec un arg string qui stockera la fonction utilise par les futurs boutons
  final Function(String) onTapped;

  const _ButtonLayout({required this.onTapped});

  @override
  Widget build(BuildContext context) {
    return Column(
		mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(child: _buildButtonRow(['7', '8', '9', 'C', 'AC'])),
        Expanded(child: _buildButtonRow(['4', '5', '6', '+', '-'])),
        Expanded(child: _buildButtonRow(['1', '2', '3', '*', '/'])),
        Expanded(child: _buildButtonRow(['0', '.', '00', '=', ''])),
      ],
    );
  }

  Widget _buildButtonRow(List<String> buttonLabels) {
    return Row(
		crossAxisAlignment: CrossAxisAlignment.stretch,
		children: buttonLabels.map((label) {
			Color buttonColor = Colors.blueGrey;
			if (['+', '-','*','/'].contains(label)) {
				buttonColor = Colors.teal;
			} else if (label == '=') {
				buttonColor = Colors.deepOrange;
			} else if (['C', 'AC'].contains(label)) {
				buttonColor = Colors.purple;
			}
			return CalculatorButton(
				label: label,
				onTapped: () => onTapped(label),
				color : buttonColor,
				);
			}).toList(),
		);
  }
}

class CalculatorButton extends StatelessWidget {
  final String label;
  final VoidCallback onTapped;
  final Color color;

  const CalculatorButton({
    required this.label,
    required this.onTapped,
	this.color = Colors.blueGrey,
	super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed:() {
			onTapped;
			print("'$label'");
		},
        style: ElevatedButton.styleFrom(
          shape: const BeveledRectangleBorder(),
		  padding: EdgeInsets.zero,
		  backgroundColor: color,
		  shadowColor: Colors.amberAccent,
		  foregroundColor: Colors.amberAccent,
        ),
        child: Text(label, style: const TextStyle(fontSize: 24), selectionColor: Colors.amberAccent),
      ),
    );
  }
}
