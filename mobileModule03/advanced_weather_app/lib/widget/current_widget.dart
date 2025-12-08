import 'package:flutter/material.dart';
import 'package:advanced_weather_app/widget/weather_description.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    if (_weather == null) {
		return Text("pas de données météo", textAlign: TextAlign.center,);
	}
	else {
      temperature = _weather['current']['temperature_2m'].toString();
      weatherCode = _weather['current']['weather_code'];
      weatherDescription = getWeatherDescription(weatherCode);
      weatherIcon = getWeatherIcon(weatherCode);
      windSpeed = _weather['current']['wind_speed_10m'].toString();
    }
    return Column(
      children: [
        Text("$temperature°C",
          textAlign: TextAlign.center,
          style: _theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Text(weatherDescription,
          textAlign: TextAlign.center,
		      style: _theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Icon(weatherIcon, size: 80, color: _theme.iconTheme.color),
        const SizedBox(height: 24),
        Text("🌬️ $windSpeed km/h",
          textAlign: TextAlign.center,
		      style: _theme.textTheme.bodyMedium,
        )
      ],
    );
  }
}
