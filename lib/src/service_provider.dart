import 'package:flutter/foundation.dart';

import 'client.dart';
import 'device_info.dart';
import 'session.dart';
import 'store.dart';

class ServiceProvider {
  ServiceProvider(
      {@required String apiKey,
      @required int timeout,
      @required bool getCarrierInfo}) {
    client = Client(apiKey);
    deviceInfo = DeviceInfo(getCarrierInfo);
    store = Store();
    session = Session(timeout);
  }

  Client client;
  Store store;
  Session session;
  DeviceInfo deviceInfo;
}
