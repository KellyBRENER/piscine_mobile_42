import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'widget/geolocation.dart';
import 'package:http/http.dart' as http;//pour faire des requete http
import 'dart:async';//pour utiliser debounce (qui permet d'attendre un délai avant une action)
import 'dart:convert';//pour décoder le JSON de la réponse http
import 'widget/error_providers.dart';
import 'widget/kawaii_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widget/today_widget.dart';
import 'widget/current_widget.dart';
import 'widget/weekly_widget.dart';

//afficher les bons messages d'erreur (la localité n'existe pas)
//récupération des données failed (API localité ou weather)


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
      title: 'advanced_weather_app',
      theme: kawaiiLightTheme,
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
      ref.read(errorProvider.notifier).state = "Permission Localisation refusée, merci d'entrer une localité";
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
      ref.read(errorProvider.notifier).state = "l'accés à la localisation n'est pas possible,";
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
          ref.read(errorProvider.notifier).state = "erreur de connection, vérifier votre connection internet ou réessayer plus tard";
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
    final theme = Theme.of(context);
    return SafeArea(
	  child: DefaultTabController(
			length: 3,
			child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background_rainbow.jpg"),
            fit: BoxFit.cover,
            ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            //backgroundColor: theme.colorScheme.inversePrimary,
            title: Row(
              children: [
                IconButton(
                  onPressed: () {_handleLocation();},
                  icon: Icon(Icons.location_on),
				  iconSize: 42,
				  color: Colors.white,
                ),
                Expanded(
                  child: CitySearchField(
                    onCitySelected: (locationData) async {
                      setState(() {
                        _locationData = locationData;
                        _otherCity = true;
                        });
                        if (_locationData != null) {
                          await _getWeather();
                        } else {
                          setState(() {
                            _weather = null;
                          });
                        }
                      },
                    ),
                  )
                ],
              )
            ),
              body: TabBarView(
                children: [
                  CenterBox(
                    theme: theme,
                    locationData: _locationData,
                    title: "Currently",
                    weatherWidget : CurrentWidget(
                      weather: _weather,
                      theme: theme
                      ),
                    ),
                  CenterBox(
                    theme: theme,
                    locationData: _locationData,
                    title: "Today",
                    weatherWidget: TodayWidget(
                      weather : _weather,
                      theme : theme),
                  ),
                  CenterBox(
                    theme: theme,
                    locationData: _locationData,
                    title: "Weekly",
                    weatherWidget: WeeklyWidget(
                      weather: _weather,
                      theme: theme
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: Container(
				color:  Color.fromARGB(100, 212, 99, 173),
				child: const TabBar(
				  tabs: MyHomePage._tabList,
				),
			  ),
            ),
          ),
        ),
      );
  }
}

class CenterBox extends ConsumerWidget {
  const CenterBox({
    super.key,
    required this.theme,
    required Map<String, dynamic>? locationData,
    required String title,
    required Widget weatherWidget,
  }) : _title = title,
  _locationData = locationData,
  _weatherWidget = weatherWidget;

  final String _title;
  final ThemeData theme;
  final Map<String, dynamic>? _locationData;
  final Widget _weatherWidget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
	final error = ref.watch(errorProvider);
    return Center(
      child: Card(
        color: theme.cardTheme.color,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
			    shrinkWrap: true,
          children: [
				    Text(_title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
				    ),
            const SizedBox(height: 20),
            Text(
              _locationData != null
                ? "${_locationData!['name']}\n${_locationData!['admin']}\n${_locationData!['country']}"
                : "",
              textAlign: TextAlign.center,
				      style: theme.textTheme.bodyMedium,
				    ),
			Text(
				error == null
                ? ""
                : "error : $error",
              textAlign: TextAlign.center,
				      style: theme.textTheme.bodyMedium,
			),
            _weatherWidget,
          ],
        ),
      ),
    );
  }
}

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
  Timer? _debounce;//timer pour ne pas appeler l'API a chaque frappe
  OverlayEntry? _overlayEntry;//objet qui sera overLay

  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      _removeOverlay();
      return;
    }
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
			ref.read(errorProvider.notifier).state =
          "nous n'avons pas pu trouvé de localité correspondant à $query";
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
          "erreur de connection, vérifier votre connection internet ou réessayer plus tard";
      _removeOverlay();
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
                  color: Colors.black,
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
            hintText: "Rentrer une localité...",
            // prefixIcon: const Icon(Icons.search),
			// prefixIconColor: Colors.white,
            suffixIcon: const Icon(Icons.search, size: 42,),
			suffixIconColor: Colors.white,
              ),
          ),
        );
  }
}
