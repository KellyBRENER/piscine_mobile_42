import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'widget/geolocation.dart';
import 'package:http/http.dart' as http; //pour faire des requete http
import 'dart:async'; //pour utiliser debounce (qui permet d'attendre un délai avant une action)
import 'dart:convert'; //pour décoder le JSON de la réponse http
import 'widget/kawaii_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//afficher les bons messages d'erreur (la localité n'existe pas)
//récupération des données failed (API localité ou weather)

IconData getWeatherIcon(int weatherCode) {
  switch (weatherCode) {
    case 0: // Ciel clair
      return FontAwesomeIcons.solidSun;
    case 1: // Principalement clair
    case 2: // Partiellement nuageux
      return FontAwesomeIcons.cloudSun;
    case 3: // Couvert
      return FontAwesomeIcons.cloud;
    case 45: // Brouillard
    case 48: // Brouillard givrant
      return FontAwesomeIcons.smog;

    // Bruine
    case 51:
    case 53:
    case 55:
    case 56:
    case 57:
      return FontAwesomeIcons.cloudRain;

    // Pluie
    case 61: // Pluie légère
    case 63: // Pluie modérée
    case 65: // Pluie forte
    case 66: // Pluie verglaçante légère
    case 67: // Pluie verglaçante forte
      return FontAwesomeIcons.cloudShowersHeavy;

    // Neige
    case 71: // Neige légère
    case 73: // Neige modérée
    case 75: // Neige forte
    case 77: // Grains de neige
      return FontAwesomeIcons.snowflake;

    // Averses
    case 80: // Averses de pluie légère
    case 81: // Averses de pluie modérées
    case 82: // Averses de pluie fortes
      return FontAwesomeIcons.cloudShowersHeavy;

    // Averses de neige
    case 85:
    case 86:
      return FontAwesomeIcons.cloudMeatball; // Une icône de neige plus lourde

    // Orages
    case 95: // Orage
    case 96: // Orage avec grêle
    case 99: // Orage avec forte grêle
      return FontAwesomeIcons.cloudBolt;

    default:
      return FontAwesomeIcons.circleQuestion; // Icône par défaut
  }
}

final Map<int, String> weatherCodeMap = {
  0: "Clear sky",
  1: "Mainly clear",
  2: "Partly cloudy",
  3: "Overcast",
  45: "Fog",
  48: "Depositing rime fog",
  51: "Light drizzle",
  53: "Moderate drizzle",
  55: "Dense drizzle",
  56: "Light freezing drizzle",
  57: "Dense freezing drizzle",
  61: "Slight rain",
  63: "Moderate rain",
  65: "Heavy rain",
  66: "Light freezing rain",
  67: "Heavy freezing rain",
  71: "Slight snow fall",
  73: "Moderate snow fall",
  75: "Heavy snow fall",
  77: "Snow grains",
  80: "Slight rain showers",
  81: "Moderate rain showers",
  82: "Violent rain showers",
  85: "Slight snow showers",
  86: "Heavy snow showers",
  95: "Thunderstorm",
  96: "Thunderstorm with slight hail",
  99: "Thunderstorm with heavy hail",
};

//   final Map<int, String> weatherCodeMap = {
//   0: "Ciel clair",
//   1: "Principalement clair",
//   2: "Partiellement nuageux",
//   3: "Couvert",
//   45: "Brouillard",
//   48: "Brouillard givrant",
//   51: "Pluie fine",
//   53: "Pluie modérée",
//   55: "Pluie forte",
//   56: "Pluie verglaçante légère",
//   57: "Pluie verglaçante forte",
//   61: "Pluie faible",
//   63: "Pluie modérée",
//   65: "Pluie forte",
//   66: "Pluie verglaçante faible",
//   67: "Pluie verglaçante forte",
//   71: "Neige faible",
//   73: "Neige modérée",
//   75: "Neige forte",
//   77: "Grains de neige",
//   80: "Averse de pluie faible",
//   81: "Averse de pluie modérée",
//   82: "Averse de pluie forte",
//   85: "Averse de neige faible",
//   86: "Averse de neige forte",
//   95: "Orage",
//   96: "Orage avec pluie faible",
//   99: "Orage avec pluie forte"
// };

String getWeatherDescription(int code) {
  return weatherCodeMap[code] ?? "Weather code aknown";
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
      title: 'advanced_weather_app',
      theme: kawaiiLightTheme,
      // darkTheme: kawaiiDarkTheme,
      // themeMode: ThemeMode.system,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  static const List<Tab> _tabList = [
    Tab(icon: Icon(Icons.access_time_sharp, size: 40), text: "Currently"),
    Tab(icon: Icon(Icons.calendar_today_sharp, size: 40), text: "Today"),
    Tab(icon: Icon(Icons.calendar_view_week_sharp, size: 40), text: "Weekly"),
  ];

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
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
          if (_error.isEmpty) {
            _error = "Location permission denied, please enter a locality";
          }
          return;
        });
      }
    }
    if (_permission == LocationPermission.denied) {
      setState(() {
        _otherCity = false;
        _locationData = null;
        if (_error.isEmpty) {
          _error = "Location permission denied, please enter a locality";
        }
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
            if (_error.isEmpty) {
              _error =
                  "could not find any result for the supplied address or coordinates";
            }
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
      setState(() {
        _weather = null;
        if (_error.isEmpty) {
          _error = "no coordinate, could not get weather";
        }
      });
    } else {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=${_locationData!['lat']}'
        '&longitude=${_locationData!['lon']}&daily=weather_code,'
        'temperature_2m_max,temperature_2m_min,wind_speed_10m_max&hourly=temperature_2m,'
        'weather_code,wind_speed_10m&current=temperature_2m,wind_speed_10m,weather_code'
        '&timezone=auto',
      );
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            _weather = data;
            _error = "";
          });
        } else {
          setState(() {
            _weather = null;
            if (_error.isEmpty) {
              _error =
                  "the service connection is lost, please check your internet connection or try again later";
            }
          });
        }
      } catch (e) {
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
    final theme = Theme.of(context);
    return SafeArea(
      child: DefaultTabController(
        length: 3,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/background.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: theme.colorScheme.inversePrimary,
              title: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _handleLocation();
                    },
                    icon: Icon(Icons.location_on),
                    color: theme.colorScheme.onPrimary,
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
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                CenterBox(
                  theme: theme,
                  locationData: _locationData,
                  error: _error,
                  title: "Currently",
                  weatherWidget : CurrentWidget(weather: _weather, theme: theme),
                  weather: _weather),
                CenterBox(theme: theme,
                  locationData: _locationData,
                  error: _error,
                  title: "Today",
                  weather: _weather,
                  weatherWidget: TodayWidget(weather : _weather, theme : theme),
                ),
                WeeklyPage(
                  locationData: _locationData,
                  error: _error,
                  weather: _weather,
                ),
              ],
            ),
            bottomNavigationBar: TabBar(
              tabs: MyHomePage._tabList,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.secondary,
              indicatorColor: theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class CenterBox extends StatelessWidget {
  const CenterBox({
    super.key,
    required this.theme,
    required Map<String, dynamic>? locationData,
    required String error,
    required String title,
    required Map<String, dynamic>? weather,
    required Widget weatherWidget,
  }) : _title = title,
  _locationData = locationData,
  _error = error,
  _weather = weather,
  _weatherWidget = weatherWidget;

  final ThemeData theme;
  final String _title;
  final Map<String, dynamic>? _locationData;
  final String _error;
  final Map<String, dynamic>? _weather;
  final Widget _weatherWidget;

  @override
  Widget build(BuildContext context) {
    return Center(
          child: Card(
              color: theme.cardColor.withAlpha(230),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(_title, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 20),
                      Text(
                        _locationData != null
                            ? "${_locationData!['name']}\n${_locationData!['admin']}\n${_locationData!['country']}"
                            : _error.isEmpty
                            ? ""
                            : "error : $_error",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                      if (_weather == null)
                        Text(
                          "no weather data",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        )
                      else
                        _weatherWidget,
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class CurrentWidget extends StatelessWidget {
  const CurrentWidget({super.key,
    required Map<String, dynamic>? weather,
    required ThemeData theme}) :
    _weather = weather, _theme = theme;

  final Map<String, dynamic>? _weather;
  final ThemeData _theme;

  @override
  Widget build(BuildContext context) {
    String temperature = "";
    int weatherCode = 0;
    String weatherDescription = "";
    String windSpeed = "";
    IconData weatherIcon = FontAwesomeIcons.circleQuestion;
    if (_weather != null) {
      temperature = _weather!['current']['temperature_2m'].toString();
      weatherCode = _weather!['current']['weather_code'];
      weatherDescription = getWeatherDescription(weatherCode);
      weatherIcon = getWeatherIcon(weatherCode);
      windSpeed = _weather!['current']['wind_speed_10m'].toString();
    }
    return Column(
      children: [
        Icon(weatherIcon, size: 80, color: _theme.iconTheme.color),
        Text("$weatherDescription\n🌡️ $temperature°C\n🌬️ $windSpeed km/h",
          textAlign: TextAlign.center,
          style: _theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class TodayWidget extends StatelessWidget {
  const TodayWidget({super.key,
    required Map<String, dynamic>? weather,
    required ThemeData theme}) :
    _weather = weather, _theme = theme;

  final Map<String, dynamic>? _weather;
  final ThemeData _theme;

  @override
  Widget build(BuildContext context) {
    dynamic hourly;
    List<dynamic> times = [];
    List<dynamic> temps = [];
    List<dynamic> winds = [];
    List<dynamic> codes = [];
    String dateOfTheDay = "";
    int count = 0;

    if (_weather != null && _weather!['hourly'] != null) {
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

      count = times.length > 24 ? 24 : times.length; // max 24 heures
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_weather != null && _weather!['hourly'] != null) ...[
          Text(
            dateOfTheDay,
            textAlign: TextAlign.center,
            style: _theme.textTheme.bodyMedium,
            ),
          SizedBox(
            height: 400,
            child: ListView.builder(
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                itemCount: count,
                itemBuilder: (context, index) {
                  DateTime dt = DateTime.parse(times[index]);
                  String formattedTime =
                    "${dt.hour.toString().padLeft(2, '0')}h";
                    num temp = temps[index]; // num pour accepter int ou double
                    num wind = winds[index];
                    int code = codes[index];
                    String description = getWeatherDescription(code);
                    return Text(
                          "$formattedTime : $temp°C - $wind km/h - $description",
                          style: _theme.textTheme.bodyMedium,
                        );
                      },//itembuilder
                    ),
          ),
              ] else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(200),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "no weather",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          );
  }
}

class WeeklyPage extends StatelessWidget {
  const WeeklyPage({
    super.key,
    required Map<String, dynamic>? locationData,
    required String error,
    required Map<String, dynamic>? weather,
  }) : _locationData = locationData,
       _error = error,
       _weather = weather;

  final Map<String, dynamic>? _locationData;
  final Map<String, dynamic>? _weather;
  final String _error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    dynamic weekly;
    List<dynamic> times = [];
    List<dynamic> tempsMin = [];
    List<dynamic> tempsMax = [];
    List<dynamic> codes = [];
    int count = 0;

    if (_weather != null && _weather!['daily'] != null) {
      weekly = _weather!['daily'];
      times = List<dynamic>.from(weekly['time']);
      tempsMin = List<dynamic>.from(weekly['temperature_2m_min']);
      tempsMax = List<dynamic>.from(weekly['temperature_2m_max']);
      codes = List<dynamic>.from(weekly['weather_code']);

      count = times.length > 7 ? 7 : times.length; // max 24 heures
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: theme.cardColor.withAlpha(230),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Weekly", style: theme.textTheme.titleLarge),
              const SizedBox(height: 20),
              Text(
                _locationData != null
                    ? "${_locationData!['name']}\n${_locationData!['admin']}\n${_locationData!['country']}"
                    : _error.isEmpty
                    ? ""
                    : "error : $_error",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              if (_weather != null && _weather!['daily'] != null)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(230),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: count,
                      itemBuilder: (context, index) {
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
                            style: theme.textTheme.bodyMedium,
                          ),
                        );
                      },
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(230),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "no weather",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CitySearchField extends StatefulWidget {
  //fonction callback qui sera appelé quand l'utilisateur sélectionne une ville / renvoie city/lat/lon
  final Function(Map<String, dynamic>? locationData, String error)
  onCitySelected;

  const CitySearchField({super.key, required this.onCitySelected});
  @override
  State<CitySearchField> createState() => _CitySearchFieldState();
}

class _CitySearchFieldState extends State<CitySearchField> {
  //controle le texte du textField
  final TextEditingController _controller = TextEditingController();
  final LayerLink _layerLink =
      LayerLink(); //lien entre le textField et l'objet overlay (overLayEntry)
  final FocusNode _focusNode = FocusNode();
  String _error = '';

  List<Map<String, dynamic>> _suggestions = [];
  bool _isloading = false;
  Timer? _debounce; //timer pour ne pas appeler l'API a chaque frappe
  OverlayEntry? _overlayEntry; //objet qui sera overLay

  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      _removeOverlay();
      return;
    }
    setState(() => _isloading = true);
    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=5&language=fr&format=json',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>?;
        if (results != null) {
          setState(() {
            _suggestions = results
                .map(
                  (r) => {
                    'name': r['name'],
                    'country': r['country'],
                    'lat': r['latitude'],
                    'lon': r['longitude'],
                    'admin': r['admin1'],
                  },
                )
                .toList();
          });
        } else {
          setState(() {
            _suggestions = [];
          });
        }
        _showOverLay(); //crée l'overlay
      } else {
        setState(() {
          _error = "service connection failed to find locality for $query";
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      _removeOverlay();
    } finally {
      //dans tous les cas, _isloading est false à la fin
      setState(() => _isloading = false);
    }
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => _fetchSuggestions(value),
    );
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
    final size =
        renderBox.size; //pour récupérer les dimensions de la target (textfield)

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        //fixe la largeur de l'overlay à celle du champs
        width: size.width,
        child: CompositedTransformFollower(
          //positionne un overlay sur la target
          showWhenUnlinked: false,
          link: _layerLink,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.separated(
                //affiche les suggestions
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _suggestions.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: Colors.grey.shade300),
                itemBuilder: (context, index) {
                  final s = _suggestions[index];
                  return ListTile(
                    title: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: s['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: s['admin'] != null
                                ? " (${s['admin']}, ${s['country']})"
                                : " (${s['country']})",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      _controller.text = s['name'];
                      _handleSelection(s, "");
                    },
                  );
                },
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
          //peut-etre conserver _suggestion
          _suggestions = [];
        });
        _removeOverlay();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      //ajoute un repère sur textField
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
                  _handleSelection(null, "no locality found for '$value'");
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
