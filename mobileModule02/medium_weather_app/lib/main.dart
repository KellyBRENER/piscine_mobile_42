import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'widget/geolocation.dart';
import 'package:http/http.dart' as http;//pour faire des requete http
import 'dart:async';//pour utiliser debounce (qui permet d'attendre un délai avant une action)
import 'dart:convert';//pour décoder le JSON de la réponse http

  final Map<int, String> weatherCodeMap = {
  0: "Ciel clair",
  1: "Principalement clair",
  2: "Partiellement nuageux",
  3: "Couvert",
  45: "Brouillard",
  48: "Brouillard givrant",
  51: "Pluie fine",
  53: "Pluie modérée",
  55: "Pluie forte",
  56: "Pluie verglaçante légère",
  57: "Pluie verglaçante forte",
  61: "Pluie faible",
  63: "Pluie modérée",
  65: "Pluie forte",
  66: "Pluie verglaçante faible",
  67: "Pluie verglaçante forte",
  71: "Neige faible",
  73: "Neige modérée",
  75: "Neige forte",
  77: "Grains de neige",
  80: "Averse de pluie faible",
  81: "Averse de pluie modérée",
  82: "Averse de pluie forte",
  85: "Averse de neige faible",
  86: "Averse de neige forte",
  95: "Orage",
  96: "Orage avec pluie faible",
  99: "Orage avec pluie forte"
};

String getWeatherDescription(int code) {
  return weatherCodeMap[code] ?? "Code inconnu";
}

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
  Map<String, dynamic>? _locationData;
  String _error = '';
  Map<String, dynamic>? _weather;
  LocationPermission? _permission;
  bool _otherCity = false;

	Future<void> checkPermission() async {
	  _permission = await Geolocator.checkPermission();
	  if (_permission == LocationPermission.denied) {
	    _permission = await Geolocator.requestPermission();
	    if (_permission == LocationPermission.deniedForever) {
	      setState(() {
          _otherCity = false;
          _locationData = null;
	        _error = "permission d'accés GPS refusée, veuillez renseigner une localité";
	        return;
	      });
	    }
	  }
	  if (_permission == LocationPermission.denied) {
	    setState(() {
        _otherCity = false;
        _locationData = null;
	      _error = "permission d'accés GPS refusée, veuillez renseigner une localité";
	      return;
	    });
	  }
	}

	void _handleLocation() async {
    try {
    //vérification des permissions
    	_error = '';
    	await checkPermission();
    	if (_error.isNotEmpty) {
    	  return;
    	} else {
        final position = await Geolocator.getCurrentPosition();
	      await Geolocator.isLocationServiceEnabled();
	      final locationData = await getCityFromPosition(position);
        if (locationData != null) {
	        setState(() {
      	    _otherCity = false;
	  	      _error = '';
            _locationData = locationData;
	          return;
          });
          await _getWeather();
        } else {
          setState(() {
            _otherCity = false;
            _error = "pas de localité trouvée pour cette position";
            _locationData = null;
          });
        }
      }
    } catch (e) {
      setState(() {
        _otherCity = false;
        _locationData = null;
        _error = e.toString();
      });
    }
  }

  Future<void> _getWeather() async {
    if (_locationData == null) {
      print("locationdata null pour getweather");
      setState(() {
        _weather = null;
        _error = "no data to get weather";
      });
    } else {
      final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=${_locationData!['lat']}'
      '&longitude=${_locationData!['lon']}&daily=weather_code,'
      'temperature_2m_max,temperature_2m_min,wind_speed_10m_max&hourly=temperature_2m,'
      'weather_code,wind_speed_10m&current=temperature_2m,wind_speed_10m,weather_code'
      '&timezone=auto'
      );
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          print("getweather code 200");
          final data = json.decode(response.body);
            setState(() {
              _weather = data;
              _error = "";
            });
          }
        } catch(e) {
        print("error throw during getweather");
        setState(() {
          _weather = null;
          _error = e.toString();
        });
      }
    }
}

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _handleLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifeCycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _otherCity == false) {
      _handleLocation();
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
							IconButton(
                onPressed: () {_handleLocation();},
                icon: Icon(Icons.location_on)
                ),
							Expanded(
								child: CitySearchField(
                  onCitySelected: (locationData, error) async {
                    setState(() {
                      _locationData = locationData;
                      _error = error;
                      _otherCity = true;
                    });
                    await _getWeather();
                  },
									),
								)
						],
					)
					),
				body: TabBarView(children: [
					CurrentPage(
            locationData: _locationData,
            error: _error,
            weather : _weather,
            ),
          TodayPage(
            locationData: _locationData,
            error: _error,
            weather : _weather,
            ),
          WeeklyPage(
            locationData: _locationData,
            error: _error,
            weather : _weather,
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

class CurrentPage extends StatelessWidget {
  const CurrentPage({
    super.key,
    required Map<String, dynamic>? locationData,
    required String error,
    required Map<String, dynamic>? weather,
  }) : _locationData = locationData, _error = error, _weather = weather;

  final Map<String, dynamic>? _locationData;
  final Map<String, dynamic>? _weather;
  final String _error;

  @override
  Widget build(BuildContext context) {
    String temperature = "";
    String weatherDescription = "";
    String windSpeed = "";
    if (_weather != null) {
      temperature = _weather!['current']['temperature_2m'].toString();
      weatherDescription = getWeatherDescription(_weather!['current']['weather_code']);
      windSpeed = _weather!['current']['wind_speed_10m'].toString();
    }
    return Center(
    	child: Column(
			mainAxisAlignment: MainAxisAlignment.center,
			crossAxisAlignment: CrossAxisAlignment.center,
    		children: [
    			Text("Currently", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36, color: Colors.black),),
  			  Text(_locationData != null ? "${_locationData!['name']}, latitude : ${_locationData!['lat'].toStringAsFixed(2)} et longitude : ${_locationData!['lat'].toStringAsFixed(2)}" : _error.isEmpty ? "" : "erreur : $_error",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.lightBlueAccent),),
          Text(_weather == null ? "no weather" : "weather_code : $weatherDescription,\n"
          "temperature : $temperature,\n"
          "wind : $windSpeed",
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
    required Map<String, dynamic>? locationData,
    required String error,
    required Map<String, dynamic>? weather,
  }) : _locationData = locationData, _error = error, _weather = weather;

  final Map<String, dynamic>? _locationData;
  final Map<String, dynamic>? _weather;
  final String _error;

  @override
  Widget build(BuildContext context) {
  dynamic hourly;
  List<dynamic> times = [];
  List<dynamic> temps = [];
  List<dynamic> codes = [];
  int count = 0;

  if (_weather != null && _weather!['hourly'] != null) {
    hourly = _weather!['hourly'];
    times = List<dynamic>.from(hourly['time']);
    temps = List<dynamic>.from(hourly['temperature_2m']);
    codes = List<dynamic>.from(hourly['weather_code']);

    count = times.length > 24 ? 24 : times.length; // max 24 heures
  }

  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Today",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 36, color: Colors.black),
        ),
        Text(
          _locationData != null
              ? "${_locationData!['name']}, latitude : ${_locationData!['lat'].toStringAsFixed(2)} et longitude : ${_locationData!['lon'].toStringAsFixed(2)}"
              : _error.isEmpty
                  ? ""
                  : "erreur : $_error",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.lightBlueAccent),
        ),
        SizedBox(height: 16),
        if (_weather != null && _weather!['hourly'] != null)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: count,
              itemBuilder: (context, index) {
                DateTime dt = DateTime.parse(times[index]);
                String formattedTime =
                    "${dt.day.toString().padLeft(2, '0')}/"
                    "${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}h";
                num temp = temps[index]; // num pour accepter int ou double
                int code = codes[index];
                String description = getWeatherDescription(code);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    "$formattedTime : $temp°C - $description",
                    style: TextStyle(fontSize: 18),
                  ),
                );
              },
            ),
          )
        else
          Text(
            "no weather",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.lightBlueAccent),
          ),
      ],
    ),
  );
}
}

class WeeklyPage extends StatelessWidget {
  const WeeklyPage({
    super.key,
    required Map<String, dynamic>? locationData,
    required String error,
    required Map<String, dynamic>? weather,
  }) : _locationData = locationData, _error = error, _weather = weather;

  final Map<String, dynamic>? _locationData;
  final Map<String, dynamic>? _weather;
  final String _error;

  @override
  Widget build(BuildContext context) {
    // if (_weather =! null) {
    //   dynamic temperature = _weather!['temperatur_2m'];
    //   dynamic weather_code = _weather!['weather_code'];
    //   dynamic wind_speed = _weather!['wind_speed_10m'];
    // }
    return Center(
    	child: Column(
			mainAxisAlignment: MainAxisAlignment.center,
			crossAxisAlignment: CrossAxisAlignment.center,
    		children: [
    			Text("Weekly", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36, color: Colors.black),),
  			  Text(_locationData != null ? "${_locationData!['name']}, latitude : ${_locationData!['lat'].toStringAsFixed(2)} et longitude : ${_locationData!['lat'].toStringAsFixed(2)}" : _error.isEmpty ? "" : "erreur : $_error",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.lightBlueAccent),),
          Text(_weather == null ? "no weather" : "weather",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.lightBlueAccent),),
    		]
    	)
    );
  }
}

class CitySearchField extends StatefulWidget {
  //fonction callback qui sera appelé quand l'utilisateur sélectionne une ville / renvoie city/lat/lon
  final Function(Map<String, dynamic>? locationData, String error) onCitySelected;

  const CitySearchField({super.key, required this.onCitySelected});
  @override
  State<CitySearchField> createState() => _CitySearchFieldState();
}

class _CitySearchFieldState extends State<CitySearchField> {
  //controle le texte du textField
  final TextEditingController _controller = TextEditingController();
  final LayerLink _layerLink = LayerLink();//lien entre le textField et l'objet overlay (overLayEntry)
  final FocusNode _focusNode = FocusNode();

  List<Map<String, dynamic>> _suggestions = [];
  bool _isloading = false;
  Timer? _debounce;//timer pour ne pas appeler l'API a chaque frappe
  OverlayEntry? _overlayEntry;//objet qui sera overLay

  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      _removeOverlay();
      return;
    }
    setState(() => _isloading = true);
    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=5&language=fr&format=json'
      );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>?;
        _suggestions = results != null
          ? results.map((r) => {
            'name' : r['name'],
            'country' : r['country'],
            'lat' : r['latitude'],
            'lon' : r['longitude'],
            'admin' : r['admin1'],
          }).toList()
          : [];
        _showOverLay();//crée l'overlay
      }
    } catch(e) {
      _removeOverlay();
    } finally {//dans tous les cas, _isloading est false à la fin
      setState(() => _isloading = false);
    }
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _fetchSuggestions(value));
  }

  void _handleSelection(Map<String, dynamic>? locationData, String error) {
    widget.onCitySelected(locationData, error);
    _removeOverlay();
    FocusScope.of(context).unfocus();
    setState(() => _suggestions = []);
  }

  void _showOverLay() {
    _removeOverlay();
    if (_suggestions.isEmpty) return;

    final overLay = Overlay.of(context);

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;//pour récupérer les dimensions de la target (textfield)

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(//fixe la largeur de l'overlay à celle du champs
        width: size.width,
        child:CompositedTransformFollower(//positionne un overlay sur la target
          showWhenUnlinked: false,
          link: _layerLink,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.separated(//affiche les suggestions
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _suggestions.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.grey.shade300,
                ),
                itemBuilder: (context, index) {
                  final s = _suggestions[index];
                  final displayName = s['admin'] != null
                  ? "${s['name']} (${s['admin']}, ${s['country']})"
                  : "${s['name']} (${s['country']})";
                  return ListTile(
                    title: Text(displayName),
                    onTap: () {
                      _controller.text = s['name'];
                      _handleSelection(s, "");
                    },
                  );
                },//itemBuilder
              ),
            ),
          ),
        ),
      ),
    );
    overLay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _debounce?.cancel();
    _removeOverlay();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          _suggestions = [];
        });
        _removeOverlay();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(//ajoute un repère sur textField
      link: _layerLink,
      child: TextField(
        focusNode: _focusNode,
        controller: _controller,
        onSubmitted: (value) async {
          if (value.isNotEmpty) {
            final match = _suggestions.firstWhere(
              (s) => s['name'].toLowerCase() == value.toLowerCase(),
              orElse: () => {},
            );
            if (match.isNotEmpty) {
              _handleSelection(match, "");
            } else {
              _fetchSuggestions(value).then((_) {
                if (_suggestions.isNotEmpty) {
                  final s = _suggestions.first;
                  _handleSelection(s, "");
                } else {
                  _handleSelection(null, "aucune localité trouvée pour '$value'");
                }
              });
            }
          }
        },
        onChanged: _onChanged,
        decoration: InputDecoration(
          hintText: "Entrez une localité...",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _isloading
            ? const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : null,
        ),
      ),
    );
  }
}
