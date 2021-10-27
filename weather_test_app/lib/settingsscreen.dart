import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreen createState() => _SettingsScreen();
}

class _SettingsScreen extends State<SettingsScreen> {
  Color bulbColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(""),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 150,
                child: Row(
                  children: <Widget>[
                    Radio(
                        value: Colors.blue,
                        groupValue: bulbColor,
                        onChanged: (val) {
                          bulbColor = val;
                          setState(() {});
                        }),
                    Text('London', style: TextStyle(fontSize: 24))
                  ],
                ),
              ),
              Container(
                width: 150,
                child: Row(
                  children: <Widget>[
                    Radio(
                        value: Colors.green,
                        groupValue: bulbColor,
                        onChanged: (val) {
                          bulbColor = val;
                          setState(() {});
                        }),
                    Text('New York', style: TextStyle(fontSize: 24))
                  ],
                ),
              ),
              Container(
                width: 150,
                child: Row(
                  children: <Widget>[
                    Radio(
                        value: Colors.green,
                        groupValue: bulbColor,
                        onChanged: (val) {
                          bulbColor = val;
                          setState(() {});
                        }),
                    Text('San Francisco', style: TextStyle(fontSize: 24))
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
