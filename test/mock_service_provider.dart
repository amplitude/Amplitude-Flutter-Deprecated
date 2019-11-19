import 'package:mockito/mockito.dart';

import 'package:amplitude_flutter/src/client.dart';
import 'package:amplitude_flutter/src/device_info.dart';
import 'package:amplitude_flutter/src/store.dart';
import 'package:amplitude_flutter/src/session.dart';
import 'package:amplitude_flutter/src/service_provider.dart';
import 'mock_client.dart';
import 'mock_store.dart';

class MockDeviceInfo extends Mock implements DeviceInfo {}
class MockSession extends Mock implements Session {}

class MockServiceProvider implements ServiceProvider {
  MockServiceProvider({this.client, this.store}) {
    client ??= MockClient();
    store ??= MockStore();
    session = MockSession();
    deviceInfo = MockDeviceInfo();
  }

  @override
  Client client;
  @override
  Store store;
  @override
  Session session;
  @override
  DeviceInfo deviceInfo;
}
