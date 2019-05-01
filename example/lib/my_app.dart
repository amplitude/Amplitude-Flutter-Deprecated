import 'dart:async';

import 'package:amplitude_flutter/amplitude_flutter.dart';
import 'package:flutter/material.dart';

import 'user_id_form.dart';

class MyApp extends StatefulWidget {
  const MyApp(this.apiKey);

  final String apiKey;

  @override
  _MyAppState createState() => _MyAppState(apiKey);
}

class _MyAppState extends State<MyApp> {
  _MyAppState(this.apiKey);

  String apiKey;
  String _message = '';
  AmplitudeFlutter analytics;

  @override
  void initState() {
    super.initState();
    analytics = AmplitudeFlutter(apiKey, Config(bufferSize: 8));
  }

  void _onUserIdChange(String userId) {
    analytics.setUserId(userId.isEmpty ? null : userId);
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

  Future<void> _sendGroupIdentify() async {
    final Identify identify = Identify()
      ..set('group_identify_test',
          'group identify sent at ${DateTime.now().millisecondsSinceEpoch}');
    await analytics.groupIdentify('account', 'acme', identify);

    setState(() {
      _message = 'Group Identify Sent';
    });
  }

  Future<void> _setGroup() async {
    const groupType = 'account';
    const groupValue = 'acme';

    await analytics.setGroup(groupType, groupValue);

    setState(() {
      _message = 'Group set to $groupType / $groupValue';
    });
  }

  Future<void> _sendRevenue() async {
    final Revenue revenue = Revenue()
      ..setProductId('specialProduct')
      ..setPrice(41.23)
      ..setQuantity(2);

    await analytics.logRevenue(revenue);

    setState(() {
      _message = 'Revenue Sent.';
    });
  }

  Future<void> _flushEvents() async {
    await analytics.flushEvents();

    setState(() {
      _message = 'Events flushed.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Amplitude Flutter'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView(
            children: <Widget>[
              UserIdForm(_onUserIdChange),
              RaisedButton(
                child: const Text('Send Event'),
                onPressed: _sendEvent,
              ),
              RaisedButton(
                child: const Text('Identify Event'),
                onPressed: _sendIdentify,
              ),
              RaisedButton(
                child: const Text('Set group'),
                onPressed: _setGroup,
              ),
              RaisedButton(
                child: const Text('Group Identify Event'),
                onPressed: _sendGroupIdentify,
              ),
              RaisedButton(
                child: const Text('Revenue Event'),
                onPressed: _sendRevenue,
              ),
              RaisedButton(
                child: const Text('Flush Events'),
                onPressed: _flushEvents,
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
