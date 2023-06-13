import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Weather {
  final int id;
  final String main;
  final String description;
  final String icon;

  Weather({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      id: json['id'],
      main: json['main'],
      description: json['description'],
      icon: json['icon'],
    );
  }
}

class WeatherData {
  final Weather weather;
  final double temperature;
  final String day;
  final int date;
  final int month;
  final int year;

  WeatherData({
    required this.weather,
    required this.temperature,
    required this.day,
    required this.date,
    required this.month,
    required this.year,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final dateTime = DateTime.parse(json['dt_txt']);
    final day = _getDayOfWeek(dateTime.weekday);

    return WeatherData(
      weather: Weather.fromJson(json['weather'][0]),
      temperature: json['main']['temp'].toDouble(),
      day: day,
      date: dateTime.day,
      month: dateTime.month,
      year: dateTime.year,
    );
  }

  static String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Senin';
      case DateTime.tuesday:
        return 'Selasa';
      case DateTime.wednesday:
        return 'Rabu';
      case DateTime.thursday:
        return 'Kamis';
      case DateTime.friday:
        return 'Jumat';
      case DateTime.saturday:
        return 'Sabtu';
      case DateTime.sunday:
        return 'Minggu';
      default:
        return '';
    }
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({Key? key}) : super(key: key);


  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  Future<List<WeatherData>> fetchWeatherForecast() async {
    const apiKey = '879fcc82cfb7e4060e03dbd5236bb7e5';
    const city = 'Jember'; // Ganti dengan kota yang diinginkan

    const apiUrl =
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<dynamic> forecastList = jsonData['list'];
      final forecastDataList = forecastList.map((json) {
        return WeatherData.fromJson(json);
      }).toList();

      // Filter data cuaca untuk menampilkan hanya satu entri per hari
      final filteredDataList = <WeatherData>[];
      var previousDay = '';
      for (final forecastData in forecastDataList) {
        if (forecastData.day != previousDay) {
          filteredDataList.add(forecastData);
          previousDay = forecastData.day;
        }
      }

      return filteredDataList;
    } else {
      throw Exception('Gagal mengambil perkiraan cuaca');
    }
  }

  Widget _buildWeatherConditionWidget(String description) {
    if (description.contains('hujan')) {
      return const Icon(Icons.beach_access);
    } else if (description.contains('berawan')) {
      return const Icon(Icons.cloud);
    } else {
      return const Icon(Icons.wb_sunny);
    }
  }

  Widget _buildWeatherDescriptionWidget(String description) {
    switch (description) {
      case 'broken clouds':
        return const Text('Tertutup Awan');
      case 'few clouds':
        return const Text('Sedikit Berawan');
      case 'scattered clouds':
        return const Text('Cerah Berawan');
      case 'light rain':
        return const Text('Hujan Ringan');
      case 'moderate rain':
        return const Text('Hujan Sedang');
      case 'heavy intensity rain':
        return const Text('Hujan Intensitas Tinggi');
      case 'overcast clouds':
        return const Text('Mendung');
      default:
        return const Text('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perkiraan Cuaca Jember'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: FutureBuilder<List<WeatherData>>(
          future: fetchWeatherForecast(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final forecastDataList = snapshot.data!;
              return ListView.builder(
                itemCount: forecastDataList.length,
                itemBuilder: (context, index) {
                  final forecastData = forecastDataList[index];
                  return Card(
                    child: ListTile(
                      title: Text('${forecastData.day} ${forecastData.date}/${forecastData.month}/${forecastData.year}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Temperature: ${forecastData.temperature.toStringAsFixed(1)}°C',
                          ),
                          _buildWeatherDescriptionWidget(forecastData.weather.description),
                        ],
                      ),
                      leading: Image.network(
                        'https://openweathermap.org/img/wn/${forecastData.weather.icon}.png',
                        height: 40.0,
                        width: 40.0,
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
