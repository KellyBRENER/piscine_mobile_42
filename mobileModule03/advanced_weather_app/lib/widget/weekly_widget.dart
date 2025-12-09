import 'package:flutter/material.dart';
import 'package:advanced_weather_app/widget/weather_description.dart';
import 'package:fl_chart/fl_chart.dart';

Widget _legendItem(Color color, String text) {
  return Row(
    children: [
      Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 4),
      Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    ],
  );
}

class DailyTemperatureChart extends StatelessWidget {
  final List<dynamic> times;
  final List<dynamic> tempsMin;
  final List<dynamic> tempsMax;

  const DailyTemperatureChart({
    super.key,
    required this.times,
    required this.tempsMin,
    required this.tempsMax,
  });
  @override
  Widget build(BuildContext context) {
    final int count = 7;
    final List<FlSpot> tempMinSpots = List.generate(count,(index) {
      return FlSpot(index.toDouble(), (tempsMin[index] as num).toDouble());
    });
    final List<FlSpot> tempMaxSpots = List.generate(count,(index) {
      return FlSpot(index.toDouble(), (tempsMax[index] as num).toDouble());
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Températures de la semaine",
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
            minY: tempsMin.sublist(0, count).reduce((a, b) => a < b ? a : b).toDouble() - 5,
            maxY: tempsMax.sublist(0, count).reduce((a, b) => a > b ? a : b).toDouble() + 5,
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
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= count) return const SizedBox();
                    DateTime dt = DateTime.parse(times[index]);
                    String formattedTime =
                    "${dt.day.toString().padLeft(2, '0')}/"
                    "${dt.month.toString().padLeft(2, '0')}";
                    return Text(formattedTime, style: const TextStyle(fontSize: 10),);
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
              spots: tempMinSpots,
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
                color: Color(0xFF72DDF7),
              ),
              LineChartBarData(
                spots: tempMaxSpots,
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
              )
            ],
          ),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(Color(0xFFFF4FA8), "Températures Max"),
          const SizedBox(width: 8),
          _legendItem(Color(0xFF72DDF7), "Températures Min"),
        ],
      )
      ],
    );
  }
}


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
        DailyTemperatureChart(
          times: times,
          tempsMin: tempsMin,
          tempsMax: tempsMax,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          width: double.infinity,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: count,
            itemBuilder: (context, index) {
              DateTime dt = DateTime.parse(times[index]);
              String formattedTime =
              "${dt.day.toString().padLeft(2, '0')}/"
              "${dt.month.toString().padLeft(2, '0')}";
			        final tempMin = tempsMin[index];
              final tempMax = tempsMax[index];
              final code = codes[index];
              //final description = getWeatherDescription(code);
              final icon = Icon(getWeatherIcon(code), size: 40, color: _theme.iconTheme.color,);
              return Container(
                width: 180,
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
                    Text(formattedTime, style: _theme.textTheme.bodyMedium,),
                    const SizedBox(height: 6),
                    icon,
                    const SizedBox(height: 6),
                    Text("Min $tempMin°C", style: _theme.textTheme.bodyMedium?.copyWith(color : Color(0xFF72DDF7)),),
                    const SizedBox(height: 6),
                    Text("Max $tempMax°C", style: _theme.textTheme.bodyMedium?.copyWith(color: Color(0xFFFF4FA8)),),
                  ],
                ),
              );
            },
          ),
        ),
		/*...List.generate(count, (index) {
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
        }),*/
	  ],
    );
  }
}
