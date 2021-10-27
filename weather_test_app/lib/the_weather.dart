import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/$weather.png'),
              fit: BoxFit.cover,
              colorFilter: new ColorFilter.mode(
                  Colors.black.withOpacity(0.6), BlendMode.dstATop),
            ),
          ),
          child: temperature == null
              ? Center(child: CircularProgressIndicator())
              : Scaffold(
                  appBar: AppBar(
                    actions: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: GestureDetector(
                          child: Icon(Icons.arrow_back, size: 36.0),
                        ),
                      )
                    ],
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                  ),
                  resizeToAvoidBottomInset: false,
                  backgroundColor: Colors.transparent,
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Center(
                            child: Image.network(
                              'https://www.metaweather.com/static/img/weather/png/' +
                                  abbreviation +
                                  '.png',
                              width: 100,
                            ),
                          ),
                          Center(
                            child: Text(
                              temperature.toString() + ' °C',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 60.0),
                            ),
                          ),
                          Center(
                            child: Text(
                              location,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 40.0),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.only(right: 32.0, left: 32.0),
                            child: Text(errorMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize:
                                        Platform.isAndroid ? 15.0 : 20.0)),
                          )
                        ],
                      ),
                    ],
                  ),
                )),
    );
  }
}
