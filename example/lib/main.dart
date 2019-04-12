import 'package:flutter/material.dart';
import 'dart:async';

import 'package:amplitude_flutter/amplitude_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _message = '';
  AmplitudeFlutter analytics;

  @override
  void initState() {
    super.initState();
    analytics = new AmplitudeFlutter("API_KEY");
  }

  Future<void> _sendEvent() async {
    await analytics.logEvent(name: "Dart Click");

    setState(() {
      _message = "Sent.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Amplitude Flutter'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                child: Text(
                  'Send Event'
                ),
                onPressed: _sendEvent,
              ),
              Text(
                _message,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}