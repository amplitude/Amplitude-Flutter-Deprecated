import 'dart:async';
import 'package:flutter/foundation.dart';

import 'client.dart';
import 'device_info.dart';
import 'event.dart';
import 'event_buffer.dart';
import 'identify.dart';
import 'session.dart';

class AmplitudeFlutter {
  AmplitudeFlutter(String apiKey, {int timeout}) {
    client = Client(apiKey);
    deviceInfo = DeviceInfo();
    session = Session(timeout: timeout);

    _init();

    session.start();
  }

  @visibleForTesting
  AmplitudeFlutter.private(this.deviceInfo, this.client, this.session) {
    _init();
  }

  DeviceInfo deviceInfo;
  Client client;
  Session session;
  EventBuffer buffer;

  Future<void> logEvent(
      {@required String name,
      Map<String, dynamic> properties = const <String, String>{}}) async {
    session.refresh();

    final Event event =
        Event(name, sessionId: session.getSessionId(), props: properties)
          ..addProps(deviceInfo.get());

    buffer.add(event);

    await Future.value(null);
  }

  Future<void> identify(Identify identify) async {
    return logEvent(name: r'$identify', properties: identify.payload);
  }

  Future<void> flushEvents() => buffer.flush();

  void _init() {
    buffer = EventBuffer(client, size: 8);
  }
}
