import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import "../lib/amplitude_flutter.dart";
import '../lib/device_info.dart';
import '../lib/client.dart';

class MockClient extends Mock implements Client {}
class MockDeviceInfo extends Mock implements DeviceInfo {}

void main() {
  AmplitudeFlutter amplitude;

  final client = MockClient();
  final deviceInfo = MockDeviceInfo();

  setUp(() {
    when(deviceInfo.get()).thenAnswer((_) => <String, dynamic>{
      'platform': 'iOS'
    });

    amplitude = AmplitudeFlutter.private(deviceInfo, client);
  });

  test('logEvent', () async {
    amplitude.logEvent(name: "test");
    verify(client.post({ 'event_type': 'test', 'platform': 'iOS' }));
  });

  group('with properties', () {
    test('logEvent', () {
      var properties = {
        'user_properties': {
          'first_name': 'Joe',
          'last_name': 'Sample'
        }
      };
      amplitude.logEvent(name: "test", properties: properties);
      verify(client.post({
        'event_type': 'test',
        'platform': 'iOS',
        'user_properties': {
          'first_name': 'Joe',
          'last_name': 'Sample'
        }
      }));
    });
  });
}
