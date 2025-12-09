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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Températures du jour",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
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
              barWidth: 2,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 2,
                    color: Colors.white,
                    strokeWidth: 1,
                  );
                },
              ),
              color: Color(0xFFFF4FA8),
              ),
            ],
          ),
        ),
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
        Text(
	      dateOfTheDay,
        textAlign: TextAlign.center,
		    style: _theme.textTheme.bodyMedium,
          ),
        const SizedBox(height: 16),
        HourlyTemperatureChart(
          times: times,
          temps: temps,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          width: double.infinity,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: count,
            itemBuilder: (context, index) {
              final dt = DateTime.parse(times[index]);
              final hour = "${dt.hour.toString().padLeft(2, '0')}h";
              final temp = temps[index];
              final wind = winds[index];
              final code = codes[index];
              //final description = getWeatherDescription(code);
              final icon = Icon(getWeatherIcon(code), size: 40, color: _theme.iconTheme.color,);
              return Container(
                width: 150,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _theme.dividerColor,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(hour, style: _theme.textTheme.bodyMedium,),
                    const SizedBox(height: 6),
                    icon,
                    const SizedBox(height: 6),
                    //Text(description, style: _theme.textTheme.bodyMedium, textAlign: TextAlign.center,),
                    //const SizedBox(height: 6),
                    Text("$temp°C", style: _theme.textTheme.bodyMedium,),
                    const SizedBox(height: 6),
                    Text("$wind km/h", style: _theme.textTheme.bodyMedium,),
                  ],
                ),
              );
            },
          ),
        )
	  ],
    );
  }
}