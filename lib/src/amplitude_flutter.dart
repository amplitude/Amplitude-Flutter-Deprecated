import 'dart:async';
import 'package:flutter/foundation.dart';

import 'client.dart';
import 'device_info.dart';
import 'event_store.dart';
import 'identify.dart';
import 'session.dart';

class AmplitudeFlutter {
  AmplitudeFlutter(String apiKey, {int timeout}) {
    client = Client(apiKey);
    deviceInfo = DeviceInfo();

    session = Session(timeout: timeout);
    session.start();
  }

  @visibleForTesting
  AmplitudeFlutter.private(this.deviceInfo, this.client, this.session);

  DeviceInfo deviceInfo;
  Client client;
  Session session;

  final EventStore eventStore = EventStore();

  Future<void> logEvent(
      {@required String name,
      Map<String, dynamic> properties = const <String, String>{}}) async {
    session.refresh();
    final String sessionId = session.getSessionId();
    final Map<String, dynamic> eventData = <String, dynamic>{
      'event_type': name,
      'session_id': sessionId
    };
    eventData.addAll(properties);

    final Map<String, String> deviceData = deviceInfo.get();
    eventData.addAll(deviceData);

    eventStore.enqueue(eventData);

    await Future.value(null);
  }

  Future<void> identify(Identify identify) async {
    return logEvent(name: r'$identify', properties: identify.payload);
  }

  Future<void> flushEvents() async {
    const int maxBatch = 100;

    if (eventStore.length > 0) {
      await client.post(eventStore.dequeue(maxBatch));
    } else {
      await Future.value(null);
    }
  }
}
