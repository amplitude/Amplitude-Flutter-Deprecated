import 'dart:async';
import 'package:flutter/foundation.dart';

import 'device_info.dart';
import 'event.dart';
import 'event_buffer.dart';
import 'identify.dart';
import 'service_provider.dart';
import 'session.dart';

class AmplitudeFlutter {
  AmplitudeFlutter(String apiKey, {int timeout = defaultTimeout}) {
    provider = ServiceProvider(apiKey: apiKey, timeout: timeout);
    _init();
  }

  @visibleForTesting
  AmplitudeFlutter.private(this.provider) {
    _init();
  }

  static const int defaultTimeout = 300000;
  ServiceProvider provider;
  DeviceInfo deviceInfo;
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
  }

  Future<void> identify(Identify identify) async {
    return logEvent(
        name: r'$identify',
        properties: <String, dynamic>{'user_properties': identify.payload});
  }

  Future<void> flushEvents() => buffer.flush();

  void _init() {
    deviceInfo = provider.deviceInfo;
    session = provider.session;
    buffer = EventBuffer(provider, size: 8);

    session.start();
  }
}
