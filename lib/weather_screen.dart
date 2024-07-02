import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  double temp = 0;
  bool isLoading = false;
  String weatherDescription = '';
  String cityName = 'London';
  String weatherCondition = 'Cloudy';
  int humidity = 0;
  double windSpeed = 0.0;
  int pressure = 0;

  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadLastSearchedCity();
    getCurrentWeather();
  }

  Future<void> loadLastSearchedCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cityName = prefs.getString('lastCity') ?? 'London';
      _cityController.text = cityName;
    });
  }

  Future<void> saveLastSearchedCity(String city) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastCity', city);
  }

  Future<void> getCurrentWeather() async {
    setState(() {
      isLoading = true;
    });
    try {
      final res = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$OpenWeatherAPIKey&units=metric'),
      );

      final data = jsonDecode(res.body);

      if (data['cod'] != 200) {
        throw 'An unexpected error occurred';
      }

      setState(() {
        temp = data['main']['temp'];
        weatherDescription = data['weather'][0]['description'];
        weatherCondition = data['weather'][0]['main'];
        humidity = data['main']['humidity'];
        windSpeed = data['wind']['speed'];
        pressure = data['main']['pressure'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void handleSearch() {
    setState(() {
      cityName = _cityController.text;
    });
    saveLastSearchedCity(cityName);
    getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: getCurrentWeather,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Enter city name',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => handleSearch(),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: handleSearch,
              child: const Text('Search'),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text(
                                      '$temp °C',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Icon(
                                      weatherCondition == 'Rain'
                                          ? Icons.cloud
                                          : Icons.sunny,
                                      size: 63,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      weatherDescription,
                                      style: const TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Weather Forecast',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      //to view more forecast and it should be scrollable
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Repeat the weather card 5 times
                            SizedBox(
                              width: 100,
                              child: Card(
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Column(
                                    children: [
                                      Text(
                                        '00:00',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Icon(
                                        Icons.cloud,
                                        size: 32,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        '301.12',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Card(
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Column(
                                    children: [
                                      Text(
                                        '03:00',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Icon(
                                        Icons.cloud,
                                        size: 32,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        '301.12',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Card(
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Column(
                                    children: [
                                      Text(
                                        '06:00',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Icon(
                                        Icons.cloud,
                                        size: 32,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        '301.12',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Card(
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Column(
                                    children: [
                                      Text(
                                        '09:00',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Icon(
                                        Icons.cloud,
                                        size: 32,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        '301.12',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Add more forecast cards as needed
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Additional Information',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          AdditionalInfoItem(
                            icon: Icons.water_drop,
                            label: 'Humidity',
                            value: '$humidity',
                          ),
                          AdditionalInfoItem(
                            icon: Icons.air,
                            label: 'Wind Speed',
                            value: '$windSpeed',
                          ),
                          AdditionalInfoItem(
                            icon: Icons.umbrella,
                            label: 'Pressure',
                            value: '$pressure',
                          ),
                        ],
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
