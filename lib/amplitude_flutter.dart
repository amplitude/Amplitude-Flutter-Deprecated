import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'device_info.dart';

class AmplitudeFlutter {
  final String apiUrl = 'https://api.amplitude.com/httpapi';
  String apiKey;
  DeviceInfo deviceInfo;

  AmplitudeFlutter(String apiKey) {
    this.apiKey = apiKey;
    deviceInfo = new DeviceInfo();
  }

  Future<void> logEvent({@required String name}) async {
    Map<String, dynamic> eventData = {
      "event_type": name
    };

    Map<String, dynamic> deviceData = deviceInfo.get();
    eventData.addAll(deviceData);

    await http.post(apiUrl, body: {
      "api_key": apiKey,
      "event": json.encode(eventData)
    });
  }
}
