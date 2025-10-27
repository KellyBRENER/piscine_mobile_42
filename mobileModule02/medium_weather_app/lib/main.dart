import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'widget/geolocation.dart';
import 'package:http/http.dart' as http;//pour faire des requete http
import 'dart:async';//pour utiliser debounce (qui permet d'attendre un délai avant une action)
import 'dart:convert';//pour décoder le JSON de la réponse http

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
								child: CitySearchField(
                  onCitySelected: (city, coordinate, error) {
                    setState(() {
                      _currentCity = city;
                      _coordinate = coordinate;
                      _error = error;
                    });
                  },
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

class CitySearchField extends StatefulWidget {
  //fonction callback qui sera appelé quand l'utilisateur sélectionne une ville / renvoie city/lat/lon
  final Function(String city, List<double>? coordinate, String error) onCitySelected;

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

  void _handleSelection(String city, List<double>? coordinate, String error) {
    widget.onCitySelected(city, coordinate, error);
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
                      _handleSelection(s['name'],[s['lat'], s['lon'],], "");
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
              _handleSelection(match['name'], [match['lat'], match['lon'],], "");
            } else {
              _fetchSuggestions(value).then((_) {
                if (_suggestions.isNotEmpty) {
                  final s = _suggestions.first;
                  _handleSelection(s['name'], [s['lat'], s['lon']], "");
                } else {
                  _handleSelection('', null, "aucune localité trouvée pour '$value'");
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
