import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:advanced_weather_app/widget/weather_description.dart';

class HourlyTemperatureChart extends StatelessWidget {
  final List<dynamic> times;
  final List<dynamic> temps;

  const HourlyTemperatureChart({
    super.key,
    required this.times,
    required this.temps,
  });
  @override
  Widget build(BuildContext context) {
    final int count = 24;
    final List<FlSpot> spots = List.generate(count,(index) {
      return FlSpot(index.toDouble(), (temps[index] as num).toDouble());
    });

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: count.toDouble(),
          minY: temps.sublist(0, count).reduce((a, b) => a < b ? a : b).toDouble() - 5,
          maxY: temps.sublist(0, count).reduce((a, b) => a > b ? a : b).toDouble() + 5,
          gridData: FlGridData(
            show: true,
            horizontalInterval: 2,
            verticalInterval: 2,
            ),
          borderData: FlBorderData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true, 
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value == meta.min || value == meta.max) return Text("");
                return Text("${value.toInt()}°C", style: const TextStyle(fontSize: 10),);
                },
                interval: 2,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= count) return const SizedBox();
                  final dt = DateTime.parse(times[index]);
                  return Text("${dt.hour}h", style: const TextStyle(fontSize: 10),);
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
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

    if (_weather == null || _weather['hourly'] == null) {
	  return Text("pas de données météo", textAlign: TextAlign.center,);
	} else {
      hourly = _weather['hourly'];
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
        /*Text(
	      dateOfTheDay,
        textAlign: TextAlign.center,
		    style: _theme.textTheme.bodyMedium,
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
				      style: _theme.textTheme.bodyMedium,
				    ),            
			    );
        }),*/
        const SizedBox(height: 16),
        HourlyTemperatureChart(
          times: times,
          temps: temps,
        ),
	  ],
    );
  }
}