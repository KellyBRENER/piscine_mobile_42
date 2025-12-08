import 'package:flutter/material.dart';
import 'package:advanced_weather_app/widget/weather_description.dart';

class WeeklyWidget extends StatelessWidget {
  const WeeklyWidget({super.key,
    required Map<String, dynamic>? weather,
    required ThemeData theme}) :
    _weather = weather, _theme = theme;

  final Map<String, dynamic>? _weather;
  final ThemeData _theme;

  @override
  Widget build(BuildContext context) {
    dynamic weekly;
    List<dynamic> times = [];
    List<dynamic> tempsMin = [];
    List<dynamic> tempsMax = [];
    List<dynamic> codes = [];
    int count = 0;

    if (_weather == null || _weather['daily'] == null) {
		return Text("pas de données météo", textAlign: TextAlign.center,);
	} else {
      weekly = _weather['daily'];
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
                style: _theme.textTheme.bodyMedium,
                ),
            );
        }),
	  ],
    );
  }
}
