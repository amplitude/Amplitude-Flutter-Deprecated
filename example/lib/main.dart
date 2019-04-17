import 'dart:async';

import 'package:amplitude_flutter/amplitude_flutter.dart';
import 'package:amplitude_flutter/identify.dart';
import 'package:flutter/material.dart';

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
    analytics = AmplitudeFlutter('API_KEY');
  }

  Future<void> _sendEvent() async {
    await analytics.logEvent(name: 'Dart Click');

    setState(() {
      _message = 'Sent.';
    });
  }

  Future<void> _sendIdentify() async {
    final Identify identify = Identify()
      ..set('identify_test',
          'identify sent at ${DateTime.now().millisecondsSinceEpoch}')
      ..add('identify_count', 1);

    await analytics.identify(identify);

    setState(() {
      _message = 'Identify Sent.';
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
                child: const Text('Send Event'),
                onPressed: _sendEvent,
              ),
              RaisedButton(
                child: const Text('Identify Event'),
                onPressed: _sendIdentify,
              ),
              Text(
                _message,
                style: TextStyle(color: Colors.black, fontSize: 22),
              )
            ],
          ),
        ),
      ),
    );
  }
}
