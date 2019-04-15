import 'dart:async';
import 'package:flutter/foundation.dart';

import 'client.dart';
import 'device_info.dart';

class AmplitudeFlutter {
  AmplitudeFlutter(String apiKey) {
    client = Client(apiKey);
    deviceInfo = DeviceInfo();
  }

  @visibleForTesting
  AmplitudeFlutter.private(this.deviceInfo, this.client);

  DeviceInfo deviceInfo;
  Client client;

  Future<void> logEvent(
      {@required String name,
      Map<String, dynamic> properties = const <String, String>{}}) async {
    final Map<String, dynamic> eventData = <String, String>{'event_type': name};
    eventData.addAll(properties);

    final Map<String, dynamic> deviceData = deviceInfo.get();
    eventData.addAll(deviceData);

    await client.post(eventData);
  }
}
