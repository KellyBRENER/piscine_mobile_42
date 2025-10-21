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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

	static const List<Tab> _tabList = [
	Tab(icon: Icon(Icons.access_time), text: "Currently",),
	Tab(icon: Icon(Icons.calendar_today), text: "Today",),
	Tab(icon: Icon(Icons.calendar_view_week), text: "Weekly",),
	];

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
	String _location = '';
	void _handleLocation(String locationTapped) {
		setState(() {
		  _location = locationTapped;
		});
	}
  @override
  Widget build(BuildContext context) {
    return SafeArea(
	  child: DefaultTabController(
			length: 3,
			child: Scaffold(
				appBar: AppBar(
					backgroundColor: Theme.of(context).colorScheme.inversePrimary,
					title: Row(
						children: [
							IconButton(onPressed: () {//rechercher une localité et l'assigner à _location
							}, icon: Icon(Icons.location_on)),
							Expanded(
								child: TextField(
									maxLines: 1,
									style: TextStyle(fontSize: 18),
									onSubmitted: (String value) {_handleLocation(value);},
									decoration: InputDecoration(
										hintText: 'Entrez une localité...',
										prefixIcon: Icon(Icons.search),
										),
									),
								)
						],
					)
					),
				body: TabBarView(children: [
					CurrentlyPage(location: _location),
					TodayPage(location: _location),
					WeeklyPage(location: _location),
				],),
				bottomNavigationBar: const TabBar(
					tabs: MyHomePage._tabList,
					overlayColor: WidgetStatePropertyAll(Colors.deepPurple),
					),
			),
		),
	);
  }
}

class CurrentlyPage extends StatelessWidget {
  const CurrentlyPage({
    super.key,
    required String location,
  }) : _location = location;

  final String _location;

  @override
  Widget build(BuildContext context) {
    return Center(
    	child: Column(
    		children: [
    			Text('Currently',),
    			Text(_location),
    		]
    	)
    );
  }
}

class TodayPage extends StatelessWidget {
  const TodayPage({
    super.key,
    required String location,
  }) : _location = location;

  final String _location;

  @override
  Widget build(BuildContext context) {
    return Center(
    	child: Column(
    		children: [
    			Text('Today',),
    			Text(_location),
    		]
    	)
    );
  }
}

class WeeklyPage extends StatelessWidget {
  const WeeklyPage({
    super.key,
    required String location,
  }) : _location = location;

  final String _location;

  @override
  Widget build(BuildContext context) {
    return Center(
    	child: Column(
    		children: [
    			Text('Weekly',),
    			Text(_location),
    		]
    	)
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
