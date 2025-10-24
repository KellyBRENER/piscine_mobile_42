import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'widget/geolocation.dart';

//au demarrage de l'appli affiche erreur
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
  List<double>? _coordinate;
  String _error = '';
  String _currentCity = '';
  LocationPermission? _permission;
  bool _otherCity = false;

	void _handleLocation(String cityTapped) async {

  try {
    if (cityTapped.isNotEmpty) {
      final coordinate = await getPositionFromCity(cityTapped);
	  if (coordinate == null) {
		setState(() {
		  _otherCity = true;
		  _coordinate = null;
		  _currentCity = cityTapped;
		  _error = "la localité n'a pas été trouvée";
		  return;
		});
	  } else {
	      setState(() {
    	    _otherCity = true;
        	_coordinate = coordinate;
        	_currentCity = cityTapped;
        	_error = '';
        	return;
      	});
	  }
    } else {
    //vérification des permissions
    	_error = '';
    	await checkPermission();
    	if (_error.isNotEmpty) {
    	  return;
    	} else {await locationUpdate();}
    }
  } catch (e) {
    setState(() {
      _otherCity = false;
      _currentCity = '';
      _coordinate = null;
      _error = e.toString();
    });
  }
  }

	Future<void> locationUpdate() async {
	  final position = await Geolocator.getCurrentPosition();
	  await Geolocator.isLocationServiceEnabled();
	  final city = await getCityFromPosition(position);
	  setState((){
      	_otherCity = false;
	  	_coordinate = [position.latitude, position.longitude];
	    _error = '';
	    _currentCity = city;
	    return;
	  });
	}

	Future<void> checkPermission() async {
	  _permission = await Geolocator.checkPermission();
	  if (_permission == LocationPermission.denied) {
	    _permission = await Geolocator.requestPermission();
	    if (_permission == LocationPermission.deniedForever) {
	      setState(() {
          _otherCity = false;
	        _coordinate = null;
	        _currentCity = '';
	        _error = "permission d'accés GPS refusée, veuillez renseigner une localité";
	        return;
	      });
	    }
	  }
	  if (_permission == LocationPermission.denied) {
	    setState(() {
        _otherCity = false;
	      _coordinate = null;
	      _currentCity = '';
	      _error = "permission d'accés GPS refusée, veuillez renseigner une localité";
	      return;
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
    if (state == AppLifecycleState.resumed && _otherCity == false) {
      _handleLocation('');
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
					CurrentlyPage(
            city: _currentCity,
            coordinate : _coordinate,
            error: _error,
            ),
					TodayPage(
            city: _currentCity,
            coordinate : _coordinate,
            error: _error,
            ),
					WeeklyPage(
            city: _currentCity,
            coordinate : _coordinate,
            error: _error,
            ),
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
    required String city,
    required List<double>? coordinate,
    required String error,
  }) : _city = city, _coordinate = coordinate, _error = error;

  final String _city;
  final List<double>? _coordinate;
  final String _error;

  @override
  Widget build(BuildContext context) {
    return Center(
    	child: Column(
			mainAxisAlignment: MainAxisAlignment.center,
			crossAxisAlignment: CrossAxisAlignment.center,
    		children: [
    			Text('Currently', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36, color: Colors.black),),
  			  Text(_city.isNotEmpty && _coordinate != null ? "$_city, latitude : ${_coordinate![0].toStringAsFixed(2)} et longitude : ${_coordinate![1].toStringAsFixed(2)}" : _error.isEmpty ? "" : "erreur : $_error",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.lightBlueAccent),),
    		]
    	)
    );
  }
}

class TodayPage extends StatelessWidget {
  const TodayPage({
    super.key,
    required String city,
    required List<double>? coordinate,
    required String error,
  }) : _city = city, _coordinate = coordinate, _error = error;

  final String _city;
  final List<double>? _coordinate;
  final String _error;

  @override
  Widget build(BuildContext context) {
    return Center(
    	child: Column(
			mainAxisAlignment: MainAxisAlignment.center,
			crossAxisAlignment: CrossAxisAlignment.center,
    		children: [
    			Text('Today', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36, color: Colors.black),),
  			  Text(_city.isNotEmpty && _coordinate != null ? "$_city, latitude : ${_coordinate![0].toStringAsFixed(2)} et longitude : ${_coordinate![1].toStringAsFixed(2)}" : _error.isEmpty ? "" : "erreur : $_error",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.lightBlueAccent),),
    		]
    	)
    );
  }
}

class WeeklyPage extends StatelessWidget {
  const WeeklyPage({
    super.key,
    required String city,
    required List<double>? coordinate,
    required String error,
  }) : _city = city, _coordinate = coordinate, _error = error;

  final String _city;
  final List<double>? _coordinate;
  final String _error;

  @override
  Widget build(BuildContext context) {
    return Center(
    	child: Column(
			mainAxisAlignment: MainAxisAlignment.center,
			crossAxisAlignment: CrossAxisAlignment.center,
    		children: [
    			Text('Weekly', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36, color: Colors.black),),
  			  Text(_city.isNotEmpty && _coordinate != null ? "$_city, latitude : ${_coordinate![0].toStringAsFixed(2)} et longitude : ${_coordinate![1].toStringAsFixed(2)}" : _error.isEmpty ? "" : "erreur : $_error",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.lightBlueAccent),),
    		]
    	)
    );
  }
}
