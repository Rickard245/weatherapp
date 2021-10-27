import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';

import 'SettingsScreen.dart';

void main() => runApp(WeatherApp());

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  int temperature = 0;
  List<int> minTemperatureForecast = List.filled(7, 0);
  List<int> maxTemperatureForecast = List.filled(7, 0);
  String location = 'San Francisco';
  int woeid = 2487956;
  String weather = 'clear';
  String abbreviation = '';
  List<String> abbreviationForecast = List.filled(7, '');
  String errorMessage = '';

  String _currentAddress;

  String searchApiUrl =
      'https://www.metaweather.com/api/location/search/?query=';
  String locationApiUrl = 'https://www.metaweather.com/api/location/';

  get child => null;

  initState() {
    super.initState();
    fetchLocation();
    fetchLocationDay();
  }

  void fetchSearch(String input) async {
    try {
      var searchResult = await http.get(searchApiUrl + input);
      var result = json.decode(searchResult.body)[0];

      setState(() {
        location = result["title"];
        woeid = result["woeid"];
        errorMessage = '';
      });
    } catch (error) {
      setState(() {
        errorMessage =
            "Sorry, we don't have data about this city. Try another one.";
      });
    }
  }

  void fetchLocation() async {
    var locationResult = await http.get(locationApiUrl + woeid.toString());
    var result = json.decode(locationResult.body);
    var consolidated_weather = result["consolidated_weather"];
    var data = consolidated_weather[0];

    setState(() {
      temperature = data["the_temp"].round();
      weather = data["weather_state_name"].replaceAll(' ', '').toLowerCase();
      abbreviation = data["weather_state_abbr"];
    });
  }

  void fetchLocationDay() async {
    var today = new DateTime.now();
    for (var i = 0; i < 7; i++) {
      var locationDayResult = await http.get(locationApiUrl +
          woeid.toString() +
          '/' +
          new DateFormat('y/M/d')
              .format(today.add(new Duration(days: i + 1)))
              .toString());
      var result = json.decode(locationDayResult.body);
      var data = result[0];

      setState(() {
        minTemperatureForecast[i] = data["min_temp"].round();
        maxTemperatureForecast[i] = data["max_temp"].round();
        abbreviationForecast[i] = data["weather_state_abbr"];
      });
    }
  }

  void onTextFieldSubmitted(String input) async {
    fetchSearch(input);
    fetchLocation();
    fetchLocationDay();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('\nWeather App',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 30)),
            actions: <Widget>[
              IconButton(
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.grey,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SettingsScreen(),
                      ),
                    );
                  })
            ],
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  controller: ScrollController(
                    initialScrollOffset: 0.0,
                  ),
                ),
                ListBody(
                  mainAxis: Axis.vertical,
                  children: <Widget>[
                    for (var i = 0; i < 7; i++)
                      forecastElement(i + 1, abbreviationForecast[i],
                          minTemperatureForecast[i], maxTemperatureForecast[i]),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}

Widget forecastElement(
    daysFromNow, abbreviation, minTemperature, maxTemperature) {
  var now = new DateTime.now();
  var oneDayFromNow = now.add(new Duration(days: daysFromNow));
  return Padding(
    padding: const EdgeInsets.only(left: 16.0),
    child: Container(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: <Widget>[          
            Card(
              child: Text(
                new DateFormat.EEEE().format(oneDayFromNow) +
                    "        " +
                    maxTemperature.toString() +
                    "°" +
                    "/" +
                    minTemperature.toString() +
                    "°",
                style: TextStyle(color: Colors.grey, fontSize: 25),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
            //   child: Image.network(
            //     'https://www.metaweather.com/static/img/weather/png/' +
            //         abbreviation +
            //         '.png',
            //     width: 30,
            //   ),
            // ),
          ],
        ),
      ),
    ),
  );
}
