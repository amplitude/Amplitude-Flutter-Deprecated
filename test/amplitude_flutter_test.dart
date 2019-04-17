import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:amplitude_flutter/amplitude_flutter.dart';
import 'package:amplitude_flutter/src/client.dart';
import 'package:amplitude_flutter/src/device_info.dart';
import 'package:amplitude_flutter/src/session.dart';

class MockClient extends Mock implements Client {}

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

    amplitude = AmplitudeFlutter.private(deviceInfo, client, session);
  });

  test('logEvent', () async {
    amplitude.logEvent(name: 'test');
    verify(client.post(<String, String>{
      'event_type': 'test',
      'session_id': '123',
      'platform': 'iOS'
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
      amplitude.logEvent(name: 'test', properties: properties);
      verify(client.post(<String, dynamic>{
        'event_type': 'test',
        'platform': 'iOS',
        'session_id': '123',
        'user_properties': <String, String>{
          'first_name': 'Joe',
          'last_name': 'Sample'
        }
      }));
    });
  });
}
