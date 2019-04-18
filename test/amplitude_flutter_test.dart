import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:amplitude_flutter/amplitude_flutter.dart';
import 'package:amplitude_flutter/src/device_info.dart';
import 'package:amplitude_flutter/src/identify.dart';
import 'package:amplitude_flutter/src/session.dart';

import 'matchers.dart';
import 'mock_client.dart';

class MockDeviceInfo extends Mock implements DeviceInfo {}

class MockSession extends Mock implements Session {}

void main() {
  AmplitudeFlutter amplitude;

  final MockClient client = MockClient();
  final MockDeviceInfo deviceInfo = MockDeviceInfo();
  final MockSession session = MockSession();

  setUp(() {
    when(deviceInfo.get())
        .thenAnswer((_) => <String, String>{'platform': 'iOS'});
    when(session.getSessionId()).thenAnswer((_) => '123');

    client.reset();

    amplitude = AmplitudeFlutter.private(deviceInfo, client, session);
  });

  test('logEvent', () async {
    amplitude
      ..logEvent(name: 'test')
      ..flushEvents();

    expect(
        client.postCalls.single.single,
        ContainsSubMap(<String, dynamic>{
          'event_type': 'test',
          'session_id': '123',
          'platform': 'iOS',
          'timestamp': isInstanceOf<int>()
        }));
  });

  test('identify', () async {
    amplitude
      ..identify(Identify()..set('cohort', 'test a'))
      ..flushEvents();

    expect(
        client.postCalls.single.single,
        ContainsSubMap(<String, dynamic>{
          'event_type': r'$identify',
          'session_id': '123',
          'user_properties': {
            r'$set': {'cohort': 'test a'}
          },
          'platform': 'iOS',
          'timestamp': isInstanceOf<int>()
        }));
  });

  group('with properties', () {
    test('logEvent', () {
      final Map<String, Map<String, String>> properties =
          <String, Map<String, String>>{
        'user_properties': <String, String>{
          'first_name': 'Joe',
          'last_name': 'Sample'
        }
      };
      amplitude
        ..logEvent(name: 'test', properties: properties)
        ..flushEvents();

      expect(
          client.postCalls.single.single,
          ContainsSubMap(<String, dynamic>{
            'event_type': 'test',
            'session_id': '123',
            'user_properties': {'first_name': 'Joe', 'last_name': 'Sample'},
            'platform': 'iOS',
            'timestamp': isInstanceOf<int>()
          }));
    });
  });
}
