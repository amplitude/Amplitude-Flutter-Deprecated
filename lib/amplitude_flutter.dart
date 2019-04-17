import 'dart:async';

import 'package:flutter/foundation.dart';

import 'client.dart';
import 'device_info.dart';
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

    await client.post(eventData);
  }

  Future<void> identify(Identify identify) async {
    return logEvent(name: r'$identify', properties: identify.payload);
  }
}

class Identify {
  Identify() {
    userProps = <String, dynamic>{};

    payload = <String, dynamic>{
      'event_type': r'$identify',
      'user_properties': userProps
    };
  }

  static const String OP_SET = r'$set';
  static const String OP_SET_ONCE = r'$setOnce';
  static const String OP_ADD = r'$add';
  static const String OP_APPEND = r'$append';
  static const String OP_UNSET = r'$unset';

  Map<String, dynamic> payload;
  Map<String, dynamic> userProps;

  void set(String key, dynamic value) {
    addOp(OP_SET, key, value);
  }

  void setOnce(String key, dynamic value) {
    addOp(OP_SET_ONCE, key, value);
  }

  void add(String key, num value) {
    addOp(OP_ADD, key, value);
  }

  void unset(String key) {
    addOp(OP_UNSET, key, '-');
  }

  void append(String key, dynamic value) {
    addOp(OP_APPEND, key, value);
  }

  @visibleForTesting
  void addOp(String op, String key, dynamic value) {
    assert([OP_SET, OP_SET_ONCE, OP_ADD, OP_APPEND, OP_UNSET].contains(op));

    _opMap(op)[key] = value;
  }

  Map<String, dynamic> _opMap(String key) {
    return userProps.putIfAbsent(key, () => <String, dynamic>{});
  }
}
