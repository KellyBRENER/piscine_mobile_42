import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'widget/geolocation.dart';
import 'package:http/http.dart' as http;//pour faire des requete http
import 'dart:async';//pour utiliser debounce (qui permet d'attendre un délai avant une action)
import 'dart:convert';//pour décoder le JSON de la réponse http
import 'widget/error_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//afficher les bons messages d'erreur (la localité n'existe pas)
//récupération des données failed (API localité ou weather)

// final Map<int, String> weatherCodeMap = {
//   0: "Clear sky",
//   1: "Mainly clear",
//   2: "Partly cloudy",
//   3: "Overcast",
//   45: "Fog",
//   48: "Depositing rime fog",
//   51: "Light drizzle",
//   53: "Moderate drizzle",
//   55: "Dense drizzle",
//   56: "Light freezing drizzle",
//   57: "Dense freezing drizzle",
//   61: "Slight rain",
//   63: "Moderate rain",
//   65: "Heavy rain",
//   66: "Light freezing rain",
//   67: "Heavy freezing rain",
//   71: "Slight snow fall",
//   73: "Moderate snow fall",
//   75: "Heavy snow fall",
//   77: "Snow grains",
//   80: "Slight rain showers",
//   81: "Moderate rain showers",
//   82: "Violent rain showers",
//   85: "Slight snow showers",
//   86: "Heavy snow showers",
//   95: "Thunderstorm",
//   96: "Thunderstorm with slight hail",
//   99: "Thunderstorm with heavy hail"
// };


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
  return weatherCodeMap[code] ?? "Weather code aknown";
}

void main() {
  runApp(const ProviderScope(
    child: MyApp()
    )
  );
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

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

	static const List<Tab> _tabList = [
	Tab(icon: Icon(Icons.access_time_sharp, size: 40,), text: "Currently",),
	Tab(icon: Icon(Icons.calendar_today_sharp, size: 40,), text: "Today",),
	Tab(icon: Icon(Icons.calendar_view_week_sharp, size: 40,), text: "Weekly",),
	];

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> with WidgetsBindingObserver{
  Map<String, dynamic>? _locationData;
  Map<String, dynamic>? _weather;
  LocationPermission? _permission;
  bool _otherCity = false;

	Future<void> checkPermission() async {
    try {
	    _permission = await Geolocator.checkPermission();
	    if (_permission == LocationPermission.denied) {
	        _permission = await Geolocator.requestPermission();
      }
	    if (_permission == LocationPermission.deniedForever) {
	        setState(() {
          _otherCity = false;
          _locationData = null;
          });
      }
    } catch(e) {
      ref.read(errorProvider.notifier).state = "Permission Localisation refusée, merci d'entrer une localité"
      "erreur = ${e.toString()}";
	    }
	  if (_permission == LocationPermission.denied) {
      ref.read(errorProvider.notifier).state = "Permission Localisation refusée, merci d'entrer une localité";
	    setState(() {
        _otherCity = false;
        _locationData = null;
	    return;
	    });
	  }
	}

	void _handleLocation() async {
    try {
    	await checkPermission();
        final position = await Geolocator.getCurrentPosition();
	      await Geolocator.isLocationServiceEnabled();
	      final locationData = await getCityFromPosition(position);
        if (locationData != null) {
          ref.read(errorProvider.notifier).state = null;
	        setState(() {
      	    _otherCity = false;
            _locationData = locationData;
	          return;
          });
          await _getWeather();
        } else {
          ref.read(errorProvider.notifier).state = "aucun résultat trouvé pour cette localité";
          setState(() {
            _otherCity = false;
            _locationData = null;
			_weather = null;
          });
        // }
      }
    } catch (e) {
      ref.read(errorProvider.notifier).state = "l'accés à la localisation n'est pas possible,"
      "merci de renseigner une localité.\ninfo : ${e.toString()}";
      setState(() {
        _otherCity = false;
        _locationData = null;
		_weather = null;
      });
    }
  }

  Future<void> _getWeather() async {
    if (_locationData == null) {
      ref.read(errorProvider.notifier).state = "pas de coordonnées, météo introuvable";
      setState(() {
        _weather = null;
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
          final data = json.decode(response.body);
            ref.read(errorProvider.notifier).state = null;
            setState(() {
              _weather = data;
            });
          } else {
            ref.read(errorProvider.notifier).state =
              "erreur de connection, vérifier votre connection internet ou réessayer plus tard";
			      setState(() {
			        _weather = null;
			      });
		      }
        } catch(e) {
          ref.read(errorProvider.notifier).state = "nous n'avons pas pu récupérer les données météorologiques.\n"
          "information sur l'erreur : ${e.toString()}";
        setState(() {
          _weather = null;
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _otherCity == false) {
    //   _handleLocation();
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
                  					onCitySelected: (locationData) async {
                    					setState(() {
                      						_locationData = locationData;
                      						_otherCity = true;
                    					});
                    					await _getWeather();
                  					},
								),
							)
						],
					)
					),
				body: TabBarView(
					children: [
            CenterBox(
              locationData: _locationData,
              title: "Currently",
              weatherWidget : CurrentWidget(weather: _weather/*, theme: theme*/),
            ),
            CenterBox(
              locationData: _locationData,
              title: "Today",
              weatherWidget: TodayWidget(weather : _weather/*, theme : theme*/),
            ),
			CenterBox(
			  locationData: _locationData,
			  title: "Weekly",
			  weatherWidget: WeeklyWidget(weather: _weather)),
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

class CenterBox extends ConsumerWidget {
  const CenterBox({
    super.key,
    required Map<String, dynamic>? locationData,
    required String title,
    required Widget weatherWidget,
  }) : _title = title,
  _locationData = locationData,
  _weatherWidget = weatherWidget;

  final String _title;
  final Map<String, dynamic>? _locationData;
  final Widget _weatherWidget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
	final error = ref.watch(errorProvider);
    return Center(
          child: Card(
			child: ListView(
            padding: const EdgeInsets.all(20.0),
			shrinkWrap: true,
            children: [
				Text(_title, style: TextStyle(
					fontWeight: FontWeight.bold, fontSize: 40, color: Colors.deepPurple),
					textAlign: TextAlign.center,
				),
                const SizedBox(height: 20),
                Text(
                  _locationData != null
                  ? "${_locationData!['name']}\n${_locationData!['admin']}\n${_locationData!['country']}"
                  : error == null
                  ? ""
                  : "error : $error",
                  textAlign: TextAlign.center,
				  style: TextStyle(
					fontWeight: FontWeight.bold,
					fontSize: 24,
					color: Colors.purple,
				  ),
                  ),
                _weatherWidget,
            ],
          ),
        ),
      );
  }
}

class CurrentWidget extends StatelessWidget {
  const CurrentWidget({super.key,
    required Map<String, dynamic>? weather,
    /*required ThemeData theme*/}) :
    _weather = weather/*, _theme = theme*/;

  final Map<String, dynamic>? _weather;
//   final ThemeData _theme;

  @override
  Widget build(BuildContext context) {
    String temperature = "";
    int weatherCode = 0;
    String weatherDescription = "";
    String windSpeed = "";
    // IconData weatherIcon = FontAwesomeIcons.circleQuestion;
    if (_weather == null) {
		return Text("pas de données météo", textAlign: TextAlign.center,);
	}
	else {
      temperature = _weather!['current']['temperature_2m'].toString();
      weatherCode = _weather!['current']['weather_code'];
      weatherDescription = getWeatherDescription(weatherCode);
    //   weatherIcon = getWeatherIcon(weatherCode);
      windSpeed = _weather!['current']['wind_speed_10m'].toString();
    }
    return Column(
      children: [
        // Icon(weatherIcon, size: 80, color: _theme.iconTheme.color),
        Text("🌦️ $weatherDescription\n🌡️ $temperature°C\n🌬️ $windSpeed km/h",
          textAlign: TextAlign.center,
		  style: TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}

class TodayWidget extends StatelessWidget {
  const TodayWidget({super.key,
    required Map<String, dynamic>? weather}) :
    _weather = weather;

  final Map<String, dynamic>? _weather;

  @override
  Widget build(BuildContext context) {
    dynamic hourly;
    List<dynamic> times = [];
    List<dynamic> temps = [];
    List<dynamic> winds = [];
    List<dynamic> codes = [];
    String dateOfTheDay = "";
    int count = 0;

    if (_weather == null || _weather!['hourly'] == null) {
	  return Text("pas de données météo", textAlign: TextAlign.center,);
	} else {
      hourly = _weather!['hourly'];
      times = List<dynamic>.from(hourly['time']);
      temps = List<dynamic>.from(hourly['temperature_2m']);
      winds = List<dynamic>.from(hourly['wind_speed_10m']);
      codes = List<dynamic>.from(hourly['weather_code']);
      DateTime dt = DateTime.parse(times[0]);
      dateOfTheDay =
          "${dt.day.toString().padLeft(2, '0')}/"
          "${dt.month.toString().padLeft(2, '0')}/"
          "${dt.year.toString().padLeft(2, '0')}";

      count = times.length > 24 ? 24 : times.length;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
	      dateOfTheDay,
          textAlign: TextAlign.center,
		  style: TextStyle(fontSize: 24),
          ),
		...List.generate(count, (index) {
            DateTime dt = DateTime.parse(times[index]);
			String formattedTime =
              "${dt.hour.toString().padLeft(2, '0')}h";
            num temp = temps[index]; // num pour accepter int ou double
            num wind = winds[index];
            int code = codes[index];
            String description = getWeatherDescription(code);
            return Padding(
				padding: const EdgeInsets.symmetric(vertical: 4),
				child: Text(
				  "$formattedTime : $temp°C - $wind km/h - $description",
				  style: TextStyle(fontSize: 18),
				  ),
			  );
            }),
	  ],
    );
  }
}

class WeeklyWidget extends StatelessWidget {
  const WeeklyWidget({super.key,
    required Map<String, dynamic>? weather}) :
    _weather = weather;

  final Map<String, dynamic>? _weather;

  @override
  Widget build(BuildContext context) {
    dynamic weekly;
    List<dynamic> times = [];
    List<dynamic> tempsMin = [];
    List<dynamic> tempsMax = [];
    List<dynamic> codes = [];
    int count = 0;

    if (_weather == null || _weather!['daily'] == null) {
		return Text("pas de données météo", textAlign: TextAlign.center,);
	} else {
      weekly = _weather!['daily'];
      times = List<dynamic>.from(weekly['time']);
      tempsMin = List<dynamic>.from(weekly['temperature_2m_min']);
      tempsMax = List<dynamic>.from(weekly['temperature_2m_max']);
      codes = List<dynamic>.from(weekly['weather_code']);
      count = times.length > 7 ? 7 : times.length; // max 24 heures
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
		...List.generate(count, (index) {
			DateTime dt = DateTime.parse(times[index]);
            String formattedTime =
              "${dt.day.toString().padLeft(2, '0')}/"
              "${dt.month.toString().padLeft(2, '0')}/"
			  "${dt.year.toString().padLeft(2, '0')}";
            num tempMin = tempsMin[index];
			num tempMax = tempsMax[index];
            int code = codes[index];
			String description = getWeatherDescription(code);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                "$formattedTime : $tempMin°C to $tempMax°C - $description",
                style: TextStyle(fontSize: 18),
                ),
            );
        }),
	  ],
    );
  }
}
// class WeeklyPage extends ConsumerWidget {
//   const WeeklyPage({
//     super.key,
//     required Map<String, dynamic>? locationData,
//     required Map<String, dynamic>? weather,
//   }) : _locationData = locationData, _weather = weather;

//   final Map<String, dynamic>? _locationData;
//   final Map<String, dynamic>? _weather;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final error = ref.watch(errorProvider);
//     dynamic weekly;
//     List<dynamic> times = [];
//     List<dynamic> tempsMin = [];
//     List<dynamic> tempsMax = [];
//     List<dynamic> codes = [];
//     int count = 0;

//     if (_weather != null && _weather!['daily'] != null) {
//       weekly = _weather!['daily'];
//       times = List<dynamic>.from(weekly['time']);
//       tempsMin = List<dynamic>.from(weekly['temperature_2m_min']);
//       tempsMax = List<dynamic>.from(weekly['temperature_2m_max']);
//       codes = List<dynamic>.from(weekly['weather_code']);
//       count = times.length > 7 ? 7 : times.length; // max 24 heures
//     }

//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Text(
//             "Weekly",
//             style: TextStyle(
//               fontWeight: FontWeight.bold, fontSize: 36, color: Colors.black),
//           ),
//           Text(
//             _locationData != null
//               ? "${_locationData!['name']}\n${_locationData!['admin']}\n${_locationData!['country']}"
//               : error == null
//                   ? ""
//                   : "error : $error",
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 24,
//               color: Colors.lightBlueAccent),
//           ),
//           SizedBox(height: 16),
//           if (_weather != null && _weather!['daily'] != null)
//             Expanded(
//               child: ListView.builder(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: count,
//                 itemBuilder: (context, index) {
//                   DateTime dt = DateTime.parse(times[index]);
//                   String formattedTime =
//                     "${dt.day.toString().padLeft(2, '0')}/"
//                     "${dt.month.toString().padLeft(2, '0')}/"
// 					          "${dt.year.toString().padLeft(2, '0')}";
//                   num tempMin = tempsMin[index];
// 				          num tempMax = tempsMax[index];
//                   int code = codes[index];
//                   String description = getWeatherDescription(code);

//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 4.0),
//                     child: Text(
//                       "$formattedTime : $tempMin°C to $tempMax°C - $description",
//                     style: TextStyle(fontSize: 18),
//                     ),
//                   );
//                 },
//               ),
//             )
//           else
//             Text(
//               "no weather",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 24,
//                 color: Colors.lightBlueAccent),
//             ),
//         ],
//       ),
//     );
//   }
// }

class CitySearchField extends ConsumerStatefulWidget {
  //fonction callback qui sera appelé quand l'utilisateur sélectionne une ville / renvoie city/lat/lon
  final Function(Map<String, dynamic>? locationData) onCitySelected;

  const CitySearchField({super.key, required this.onCitySelected});
  @override
  ConsumerState<CitySearchField> createState() => _CitySearchFieldState();
}

class _CitySearchFieldState extends ConsumerState<CitySearchField> {
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
		if (results != null) {
			setState(() {
				_suggestions = results.map((r) => {
					'name' : r['name'],
					'country' : r['country'],
					'lat' : r['latitude'],
					'lon' : r['longitude'],
					'admin' : r['admin1'],
					}).toList();
				});
		} else {
			setState(() {
				_suggestions = [];
			});
		}
        _showOverLay();//crée l'overlay
      } else {
        ref.read(errorProvider.notifier).state =
          "erreur de connection, vérifier votre connection internet ou réessayer plus tard";
      }
    } catch(e) {
        ref.read(errorProvider.notifier).state =
          "erreur de connection, vérifier votre connection internet ou réessayer plus tard\n"
          "message d'erreur = ${e.toString}";
      _removeOverlay();
    } finally {//dans tous les cas, _isloading est false à la fin
      setState(() => _isloading = false);
    }
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _fetchSuggestions(value));
  }

  void _handleSelection(Map<String, dynamic>? locationData) {
    widget.onCitySelected(locationData);
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
                      _handleSelection(s);
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
        setState(() {//peut-etre conserver _suggestion
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
                _handleSelection(match);
              } else {
                _fetchSuggestions(value).then((_) {
                  if (_suggestions.isNotEmpty) {
                    final s = _suggestions.first;
                    _handleSelection(s);
                  } else {
                    _handleSelection(null);
                  }
                });
              }
            }
          },
          onChanged: _onChanged,
          decoration: InputDecoration(
            hintText: "Enter a locality...",
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
