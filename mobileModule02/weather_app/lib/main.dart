import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'widget/geolocation.dart';

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
	Tab(icon: Icon(Icons.access_time_sharp, size: 40,), text: "Currently",),
	Tab(icon: Icon(Icons.calendar_today_sharp, size: 40,), text: "Today",),
	Tab(icon: Icon(Icons.calendar_view_week_sharp, size: 40,), text: "Weekly",),
	];

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver{
	Position? _currentPosition;
  String _error = '';
  String _currentCity = '';
  bool _serviceEnabled = false;

	void _handleLocation(String cityTapped) async {
    try {
      _showSettingsDialog(context: context);
      if (cityTapped.isNotEmpty) {
        setState(() {
          _currentPosition = null;
          _currentCity = cityTapped;
          _error = '';
        });
      } else {
        if (_serviceEnabled == false) {
          setState(() {
            _currentPosition = null;
            _error = 'GPS desactivé';
            _currentCity = '';
          });
        }
        final position = await determinePosition();
        final city = await getCityFromPosition(position);
        setState((){
          _currentPosition = position;
          _error = '';
          _currentCity = city;
        });
      }
    } catch (e) {
        setState(() {
          _currentCity = '';
          _currentPosition = null;
          _error = e.toString();
        });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _handleLocation('');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifeCycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _handleLocation('');
    }
  }

  void _showSettingsDialog({required BuildContext context}) async {
    _serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_serviceEnabled) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("geolocalisation désactivée"),
            content: Text("voulez vous activer la géolocalisation"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("NON"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await Geolocator.openLocationSettings();
                },
                child: const Text("OUI")
              ),
            ],
          );
        });
      return Future.error("Service de localisation désactivé, veuillez l'activer.");
    }
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
							IconButton(onPressed: () {_handleLocation('');}, icon: Icon(Icons.location_on)),
							Expanded(
								child: TextField(
									maxLines: 1,
									style: TextStyle(fontSize: 18),
									onSubmitted: (String value) {_handleLocation(value);},//à implémenter
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
					CurrentlyPage(location: _currentCity),
					TodayPage(location: _currentCity),
					WeeklyPage(location: _currentCity),
				],),
				bottomNavigationBar: const TabBar(
					tabs: MyHomePage._tabList,
					overlayColor: WidgetStatePropertyAll(Colors.deepPurple),
					labelColor: Colors.deepPurpleAccent,
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
			mainAxisAlignment: MainAxisAlignment.center,
			crossAxisAlignment: CrossAxisAlignment.center,
    		children: [
    			Text('Currently', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36, color: Colors.black),),
    			Text(_location, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36, color: Colors.lightBlueAccent),),
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
			mainAxisAlignment: MainAxisAlignment.center,
			crossAxisAlignment: CrossAxisAlignment.center,
    		children: [
    			Text('Today',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36, color: Colors.black),),
    			Text(_location, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36, color: Colors.lightBlueAccent),),
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
			mainAxisAlignment: MainAxisAlignment.center,
			crossAxisAlignment: CrossAxisAlignment.center,
    		children: [
    			Text('Weekly',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36, color: Colors.black),),
    			Text(_location, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36, color: Colors.lightBlueAccent),),
    		]
    	)
    );
  }
}
