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
      body: Center(
		child: MyCalculator()
		),
      );
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});
  @override
  Widget  build(BuildContext context) {
    return AppBar(
      title: const  Text("Calculator"),
	  centerTitle: true,
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
      children: <Widget>[
        _DisplaySection(
			calculationText: _calculation,
			resultText: _result,
		),
		Expanded(//prends tout l'espace vertical restant pour ses enfants
			child: _ButtonLayout(onTapped: _handleButtonPress),
		)
      ],
    );
  }
}

class _DisplaySection extends StatelessWidget {
	final String calculationText;
	final String resultText;
	const _DisplaySection({required this.calculationText, required this.resultText, super.key,});

	@override
	Widget	build(BuildContext context) {
		return Container(
			padding: const EdgeInsets.all(16.0),
			alignment: Alignment.centerRight,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.end,
				children: <Widget>[
					Text(calculationText),
					Text(resultText),
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
			children: [
				_buildButtonRow(['1', '2', '3', 'C', 'AC']),
				_buildButtonRow(['4', '5', '6', '+', '-']),
				_buildButtonRow(['7', '8', '9', '*', '/']),
				_buildButtonRow(['0', '.', '00', '=']),
			],
		);
	}

	Widget _buildButtonRow(List<String> buttonLabels) {
		return Row(
			mainAxisAlignment: MainAxisAlignment.spaceEvenly,//répartit les boutons de ma,niere uniforme sur la ligne
			children: buttonLabels.map((label) {
				return CalculatorButton(
					label : label,
					onTapped: () => onTapped(label),
				);
			}).toList(),
		);
	}
}

class	CalculatorButton extends StatelessWidget {
	final String label;
	final VoidCallback onTapped;

	const	CalculatorButton({required this.label, required this.onTapped, super.key});

	@override
	Widget build(BuildContext context) {
		return Expanded(
			child: Padding(
				padding: const EdgeInsets.all(8.0),//rajoute un espace de 8 pixel entre les boutons
				child: ElevatedButton(onPressed: onTapped, child: Text(label)),
			)
		);
	}
}

