import 'dart:async';

import 'package:amplitude_flutter/src/constants.dart';
import 'package:amplitude_flutter/src/time_utils.dart';
import 'package:flutter/foundation.dart';

import 'config.dart';
import 'device_info.dart';
import 'event.dart';
import 'event_buffer.dart';
import 'identify.dart';
import 'revenue.dart';
import 'service_provider.dart';
import 'session.dart';

class AmplitudeFlutter {
  AmplitudeFlutter(String apiKey, [this.config]) {
    config ??= Config();
    provider = ServiceProvider(
        apiKey: apiKey,
        timeout: config.sessionTimeout,
        getCarrierInfo: config.getCarrierInfo);
    _init();
  }

  AmplitudeFlutter.private(this.provider, this.config) {
    _init();
  }

  bool getCarrierInfo;
  Config config;
  ServiceProvider provider;
  DeviceInfo deviceInfo;
  Session session;
  EventBuffer buffer;
  dynamic userId;

  /// Set the user id associated with events
  void setUserId(dynamic userId) {
    this.userId = userId;
  }

  /// Log an event
  Future<void> logEvent(
      {@required String name,
      Map<String, dynamic> properties = const <String, String>{}, int timestamp}) async {
    if (config.optOut) {
      return Future.value(null);
    }

    // Current event ISN'T session event.
    // It's the time we run auto session logic.
    if (Constants.kSessionEndEvent != name && Constants.kSessionStartEvent != name) {
      final bool needRenew = config.trackSessionEvents &&
          !session.withinSession(TimeUtils().currentTime());

      // End old session.
      if (needRenew) {
        _logSessionEvent(Constants.kSessionEndEvent, session.lastActivity);
      }
      // Always run refresh to update session states.
      session.refresh();
      // Start new session.
      if (needRenew) {
        _logSessionEvent(Constants.kSessionStartEvent, session.lastActivity);
      }
    }

    final Event event = Event(name, sessionId: session.getSessionId(), props: properties);

    final Map<String, String> apiProps = await deviceInfo.getAdvertisingInfo();
    if (apiProps != null) {
      if (event.props.containsKey('api_properties')) {
        apiProps.addAll(event.props['api_properties']);
      }

      event.addProps(<String, dynamic>{
        'api_properties': apiProps
      });
    }
    event.addProps(await deviceInfo.getPlatformInfo());

    if (userId != null) {
      event.addProp('user_id', userId);
    }

    event.timestamp = timestamp ?? TimeUtils().currentTime();
    return buffer.add(event);
  }

  /// Identify the current user
  Future<void> identify(Identify identify,
      {Map<String, dynamic> properties = const <String, dynamic>{}}) async {
    return logEvent(
        name: r'$identify',
        properties: <String, dynamic>{'user_properties': identify.payload}
          ..addAll(properties));
  }

  /// Adds the current user to a group
  Future<void> setGroup(String groupType, dynamic groupValue) async {
    return identify(Identify()..set(groupType, groupValue),
        properties: <String, dynamic>{
          'groups': <String, dynamic>{groupType: groupValue}
        });
  }

  /// Sets properties on a group
  Future<void> groupIdentify(
      String groupType, dynamic groupValue, Identify identify) async {
    return logEvent(name: r'$groupidentify', properties: <String, dynamic>{
      'group_properties': identify.payload,
      'groups': <String, dynamic>{groupType: groupValue}
    });
  }

  /// Log a revenue event
  Future<void> logRevenue(Revenue revenue) async {
    if (revenue.isValid()) {
      return logEvent(
          name: Revenue.EVENT,
          properties: <String, dynamic>{'event_properties': revenue.payload});
    }
  }

  /// Manually flush events in the buffer
  Future<void> flushEvents() => buffer.flush();

  void _logSessionEvent(String sessionEvent, int timestamp) {
    final Map<String, Map<String, String>> properties =
    <String, Map<String, String>>{
      'api_properties': <String, String>{
        'special': sessionEvent,
      }
    };
    logEvent(name: sessionEvent, timestamp: timestamp, properties: properties);
  }

  void _init() {
    deviceInfo = provider.deviceInfo;
    session = provider.session;
    buffer = EventBuffer(provider, config);

    session.start();
    if (config.trackSessionEvents) {
      _logSessionEvent(Constants.kSessionStartEvent, TimeUtils().currentTime());
    }
  }
}
