import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'weather_app',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

	static const List<Tab> _tabList = [
	Tab(icon: Icon(Icons.access_time), text: "Currently",),
	Tab(icon: Icon(Icons.calendar_today), text: "Today",),
	Tab(icon: Icon(Icons.calendar_view_week), text: "Weekly",),
	];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
	  child: DefaultTabController(
			length: 3,
			child: Scaffold(
				appBar: AppBar(
					backgroundColor: Theme.of(context).colorScheme.inversePrimary,
					title: Text('Weather App'),
					// bottom: const TabBar(tabs: _tabList),
					),
				body: const TabBarView(children: [
					Center(child: Text('Currently',)),
					Center(child: Text('Today'),),
					Center(child: Text('Weekly'),),
				],),
				bottomNavigationBar: const TabBar(
					tabs: _tabList,
					overlayColor: WidgetStatePropertyAll(Colors.deepPurple),
					),
			),
		),
	);
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
// 	int _index = 0;
	// final List<Widget> _PageList= [
	// 	currentlyPage(),
	// 	todayPage(),
	// 	weekly(),
	// ];

	// void _changePage(int indexTapped) {
	// 	setState(() {
	// 		_index = indexTapped;
	// 	});
	// }


// Widget currentlyPage() {
// 	return TabBarView(
// 		children: [Text("Currently")],
// 	);
// }
