import 'package:amplitude_flutter/src/device_info_helper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized() as TestWidgetsFlutterBinding;

  final MethodChannel channel = MethodChannel('amplitude_flutter');

  // Register the mock handler.
  setUpAll(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch(methodCall.method) {
        case 'carrierName':
          return 'AT&T';
        case 'deviceModel':
          return 'iPhone10,6';
        default:
          return null;
      }
    });
  });

  tearDownAll(() {
    channel.setMockMethodCallHandler(null);
  });

  test('amplitude_flutter channel is setup with carrierName method', () async {
    final String name = await DeviceInfoHelper.getCarrierName;
    expect(name, equals('AT&T'));
  });

// returns device model for iOS
  test('amplitude_flutter channel is setup with deviceModel', () async {
    final String model = await DeviceInfoHelper.getDeviceModel;
    expect(model, equals('iPhone10,6'));
  });


}
